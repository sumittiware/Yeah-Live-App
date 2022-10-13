import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:live_app/screens/live_screen.dart';
import 'package:live_app/utils/navigation.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:live_app/models/rooms.dart';
import 'package:live_app/styles/colors.dart';

class LiveTile extends StatelessWidget {
  final _colorUtils = ColorUtils();
  final Room room;

  LiveTile({
    super.key,
    required this.room,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        NavigationUtils().push(
          context,
          LiveScreen(
            roomId: room.id,
            isBroadcaster: false,
          ),
        );
      },
      child: Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _getProfileWidget(),
                const SizedBox(
                  width: 8,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitle(),
                    _buildSubTitle(),
                  ],
                ),
                const Spacer(),
                _buildWatchingIcon(),
              ],
            ),
          )),
    );
  }

  Widget _buildTitle() {
    return Text(
      room.title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        // fontSize: 18,
      ),
    );
  }

  Widget _getProfileWidget() {
    if (room.userProfile.isEmpty) {
      return ProfilePicture(
        name: room.username,
        radius: 24,
        fontsize: 20,
      );
    } else {
      return CircleAvatar(
        backgroundImage: NetworkImage(room.userProfile),
        radius: 24,
      );
    }
  }

  Widget _buildSubTitle() {
    final time = DateTime.fromMillisecondsSinceEpoch(
      room.timestamp.millisecondsSinceEpoch,
    );

    final timeDiff = DateTime.now().subtract(
      Duration(seconds: time.second),
    );

    return Text('${room.username} | ${timeago.format(
      timeDiff,
      locale: 'en',
    )}');
  }

  Widget _buildWatchingIcon() {
    return Container(
      padding: const EdgeInsets.all(6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.visibility_rounded,
            size: 18,
            color: _colorUtils.textColor,
          ),
          const SizedBox(
            width: 4,
          ),
          Text(
            '${room.liveCount}',
            style: TextStyle(
              fontSize: 16,
              color: _colorUtils.textColor,
            ),
          )
        ],
      ),
    );
  }
}
