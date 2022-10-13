// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

void showLeaveRoomDialog(
  context,
  String label,
  bool option,
  Function() onLeaveRoom,
) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(label),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onLeaveRoom();
          },
          child: Text('Yes'),
        ),
        if (option)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('No'),
          )
      ],
    ),
  );
}
