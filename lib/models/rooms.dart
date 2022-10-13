import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  String id;
  String username;
  String userProfile;
  String title;
  int liveCount;
  Timestamp timestamp;

  Room({
    required this.id,
    required this.username,
    required this.userProfile,
    required this.title,
    required this.timestamp,
    required this.liveCount,
  });

  factory Room.fromJson(QueryDocumentSnapshot data) {
    return Room(
      id: data.id,
      username: data.get('username'),
      userProfile: data.get('userProfile'),
      title: data.get('title'),
      timestamp: data.get('timestamp'),
      liveCount: data.get('liveCount'),
    );
  }
}
