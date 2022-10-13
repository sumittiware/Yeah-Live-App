import 'dart:convert';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:live_app/components/custom_text_field.dart';
import 'package:live_app/components/dialog.dart';
import 'package:live_app/styles/colors.dart';
import 'package:live_app/utils/agora_utils.dart';
import 'package:live_app/utils/firebase_utils.dart';
import 'package:http/http.dart' as http;
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;

class LiveScreen extends StatefulWidget {
  final String roomId;
  final bool isBroadcaster;

  const LiveScreen({
    super.key,
    required this.roomId,
    required this.isBroadcaster,
  });

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  final _newMessegeController = TextEditingController();
  final _scrollController = ScrollController();
  // RTC Engine for the agora SDK
  late final RtcEngine _engine;
  // all users in the list
  List<int> remoteUid = [];
  // disabling and enabling camera
  bool _disabledVideo = false;
  // mute the audios
  bool _muted = false;
  // colors
  final _colorUtils = ColorUtils();

  // token to join stream, to be fetched from server
  String? token;

  @override
  void dispose() {
    _engine.destroy();
    // if broadcaster delete the entire room or just decrease counter
    if (widget.isBroadcaster) {
      FirebaseUtils.deleteRoom(widget.roomId);
    } else {
      FirebaseUtils.removeUserToStream(widget.roomId);
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // User joined event will be added in the docs

    FirebaseUtils.addEvent(
      widget.roomId,
      'Joined',
      FirebaseAuth.instance.currentUser!.displayName!,
    );
    // to stay at the end of feeds ot see new messeges
    _scrollController.addListener(() {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
    _initEngine();
  }

  // fetch the token from server
  Future<void> getToken() async {
    final res = await http.get(
      Uri.parse(
        '$serverUrl/rtc/${widget.roomId}/publisher/userAccount/${FirebaseAuth.instance.currentUser!.uid}/',
      ),
    );

    if (res.statusCode == 200) {
      setState(() {
        token = res.body;
        token = jsonDecode(token!)['rtcToken'];
      });
    } else {
      debugPrint('Failed to fetch the token');
    }
  }

  void _initEngine() async {
    _engine = await RtcEngine.createWithContext(RtcEngineContext(appId));
    _addListeners();

    await _engine.enableVideo();
    await _engine.startPreview();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    if (widget.isBroadcaster) {
      _engine.setClientRole(ClientRole.Broadcaster);
    } else {
      _engine.setClientRole(ClientRole.Audience);
    }
    _joinChannel();
  }

  void _addListeners() {
    _engine.setEventHandler(
      RtcEngineEventHandler(
        joinChannelSuccess: (channel, uid, elapsed) {
          debugPrint('joinChannelSuccess $channel $uid $elapsed');
        },
        userJoined: (uid, elapsed) {
          debugPrint('userJoined $uid $elapsed');
          FirebaseUtils.addUserToStream(widget.roomId);
          setState(() {
            remoteUid.add(uid);
          });
        },
        userOffline: (uid, reason) {
          debugPrint('userOffline $uid $reason');
          setState(() {
            remoteUid.removeWhere((element) => element == uid);
          });
        },
        leaveChannel: (stats) {
          debugPrint('leaveChannel $stats');
          setState(() {
            remoteUid.clear();
          });
        },
        tokenPrivilegeWillExpire: (token) async {
          await getToken();
          await _engine.renewToken(token);
        },
      ),
    );
  }

  void _joinChannel() async {
    await getToken();
    if (token != null) {
      try {
        await _engine.joinChannelWithUserAccount(
          token,
          widget.roomId,
          FirebaseAuth.instance.currentUser!.uid,
        );
      } catch (_) {}
    }
  }

  Future<void> _addEvent() async {
    if (_newMessegeController.text.trim().isNotEmpty) {
      await FirebaseUtils.addEvent(
        widget.roomId,
        _newMessegeController.text,
        FirebaseAuth.instance.currentUser!.displayName!,
      );
      _newMessegeController.clear();
    }
  }

  Future<void> _onLeaveRoom() async {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Stack(
          children: [
            _createView(),
            _eventFeeds(),
            _bottomBar(),
            _buildLiveComponent(),
          ],
        ),
      ),
    );
  }

  Widget _eventFeeds() {
    final size = MediaQuery.of(context).size;
    return Positioned(
      bottom: 70,
      child: SizedBox(
        height: size.height * 0.2,
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('live')
              .doc(widget.roomId)
              .collection('events')
              .orderBy(
                'timestamp',
              )
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            }
            final data = snapshot.data!.docs;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: data
                    .map(
                      (e) => Container(
                        margin: const EdgeInsets.all(4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.withOpacity(0.3),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.get('username'),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _colorUtils.white,
                              ),
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                            Text(
                              e.get('messege'),
                              style: TextStyle(
                                color: _colorUtils.white,
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _createView() {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height,
      width: size.width,
      child: (widget.isBroadcaster)
          ? const RtcLocalView.SurfaceView(
              zOrderMediaOverlay: true,
              zOrderOnTop: true,
            )
          : (remoteUid.isNotEmpty)
              ? RtcRemoteView.TextureView(
                  uid: remoteUid[0],
                  channelId: widget.roomId,
                )
              : Container(),
    );
  }

  Widget _bottomBar() {
    final size = MediaQuery.of(context).size;
    if (widget.isBroadcaster) {
      return Positioned(
        bottom: 0,
        child: InkWell(
          onTap: () => showLeaveRoomDialog(
            context,
            'Do you want to end the live!!',
            true,
            _onLeaveRoom,
          ),
          child: Container(
            height: 70,
            width: size.width,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                FloatingActionButton(
                  heroTag: '1',
                  onPressed: () {
                    if (_disabledVideo) {
                      _engine.enableVideo();
                    } else {
                      _engine.disableVideo();
                    }

                    setState(() {
                      _disabledVideo = !_disabledVideo;
                    });
                  },
                  elevation: 0,
                  backgroundColor: ColorUtils().buttonColor,
                  child: Icon(
                    (_disabledVideo)
                        ? Icons.camera_alt_rounded
                        : Icons.videocam_off_rounded,
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "End Live",
                      style: TextStyle(
                        color: ColorUtils().white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                FloatingActionButton(
                  heroTag: '2',
                  onPressed: () {
                    if (_muted) {
                      _engine.enableAudio();
                    } else {
                      _engine.disableAudio();
                    }
                    setState(() {
                      _muted = !_muted;
                    });
                  },
                  elevation: 0,
                  backgroundColor: ColorUtils().buttonColor,
                  child: Icon(
                    (_muted) ? Icons.mic_off : Icons.mic,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Positioned(
        bottom: 0,
        child: SizedBox(
          height: 70,
          width: size.width,
          child: Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _newMessegeController,
                  label: 'say hi..',
                ),
              ),
              FloatingActionButton(
                heroTag: '4',
                onPressed: _addEvent,
                elevation: 0,
                backgroundColor: ColorUtils().buttonColor,
                child: const Icon(
                  Icons.send_rounded,
                ),
              ),
              FloatingActionButton(
                heroTag: '3',
                onPressed: () => showLeaveRoomDialog(
                  context,
                  'Do you want to leave room!',
                  true,
                  _onLeaveRoom,
                ),
                elevation: 0,
                backgroundColor: Colors.red,
                child: const Icon(
                  Icons.close_rounded,
                ),
              )
            ],
          ),
        ),
      );
    }
  }

  // Component will display the count of total live users
  Widget _buildLiveComponent() {
    return Positioned(
      top: 50,
      right: 30,
      child: Container(
        height: 40,
        width: 70,
        decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(
              Icons.visibility_rounded,
              size: 20,
              color: ColorUtils().textColor,
            ),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('live')
                    .doc(widget.roomId)
                    .snapshots(),
                builder: (_, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container();
                  }
                  if (snapshot.hasError) {
                    showLeaveRoomDialog(context, 'The live has ended!!', false,
                        () {
                      Navigator.of(context).pop();
                    });
                  }
                  final liveCount = snapshot.data!.get('liveCount');
                  return Text(
                    '${liveCount}',
                    style: TextStyle(
                      fontSize: 18,
                      color: ColorUtils().textColor,
                    ),
                  );
                })
          ],
        ),
      ),
    );
  }
}
