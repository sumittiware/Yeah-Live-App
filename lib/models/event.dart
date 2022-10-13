import 'package:cloud_firestore/cloud_firestore.dart';

class LiveEvent {
  String id;
  String username;
  String messege;
  Timestamp timestamp;

  LiveEvent({
    required this.id,
    required this.username,
    required this.messege,
    required this.timestamp,
  });

  factory LiveEvent.fromJson(QueryDocumentSnapshot data) {
    return LiveEvent(
      id: data.id,
      username: data.get('username'),
      messege: data.get('messege'),
      timestamp: data.get('timestamp'),
    );
  }
}
