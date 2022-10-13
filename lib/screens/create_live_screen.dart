import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:live_app/components/custom_button.dart';
import 'package:live_app/components/custom_text_field.dart';
import 'package:live_app/screens/live_screen.dart';
import 'package:live_app/styles/colors.dart';
import 'package:live_app/utils/firebase_utils.dart';
import 'package:live_app/utils/navigation.dart';
import 'package:permission_handler/permission_handler.dart';

class CreateLiveScreen extends StatefulWidget {
  const CreateLiveScreen({super.key});

  @override
  State<CreateLiveScreen> createState() => _CreateLiveScreenState();
}

class _CreateLiveScreenState extends State<CreateLiveScreen> {
  final TextEditingController _titleController = TextEditingController();
  Uint8List? image;
  final _colorUtils = ColorUtils();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> goLiveStream() async {
    final result = await [Permission.microphone, Permission.camera].request();
    bool flag = true;
    result.forEach(
      (key, value) {
        if (value == PermissionStatus.denied ||
            value == PermissionStatus.permanentlyDenied) {
          flag = false;
        }
      },
    );
    if (!flag) {
      return;
    }
    await FirebaseUtils.createRoom(
      _titleController.text,
    );

    Future.delayed(
      const Duration(seconds: 0),
      () {
        NavigationUtils().pushReplace(
          context,
          LiveScreen(
            roomId: FirebaseAuth.instance.currentUser!.uid,
            isBroadcaster: true,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Live'),
        backgroundColor: _colorUtils.primaryDark,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 12,
                      ),
                      const Text(
                        'Title',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: CustomTextField(
                          controller: _titleController,
                          label: 'Add title',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 10,
                ),
                child: CustomButton(
                  label: 'Go Live!',
                  onTap: goLiveStream,
                  spread: true,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
