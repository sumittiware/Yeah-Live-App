import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:live_app/screens/create_live_screen.dart';
import 'package:live_app/components/live_tile.dart';
import 'package:live_app/models/rooms.dart';
import 'package:live_app/styles/colors.dart';
import 'package:live_app/utils/navigation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _colorUtils = ColorUtils();

  Future<void> _createRoom() async {
    NavigationUtils().push(
      context,
      const CreateLiveScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logo_white.png',
          height: kToolbarHeight - 20,
          fit: BoxFit.fitHeight,
        ),
        backgroundColor: _colorUtils.primaryDark,
      ),
      body: _buildBody(),
      floatingActionButton: _buildActionButton(),
    );
  }

  // All the live streams will be displayed here
  Widget _buildBody() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('live').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: ColorUtils().primaryDark,
            ),
          );
        }
        final data = snapshot.data!.docs;
        List<Room> rooms = [];
        for (QueryDocumentSnapshot ele in data) {
          rooms.add(
            Room.fromJson(ele),
          );
        }
        if (rooms.isEmpty) {
          return const Center(
            child: Text('No one is live at the moment'),
          );
        }
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemBuilder: (_, index) {
            return LiveTile(room: rooms[index]);
          },
          itemCount: rooms.length,
        );
      },
    );
  }

  Widget _buildActionButton() {
    return InkWell(
      onTap: _createRoom,
      child: Material(
        color: _colorUtils.buttonColor,
        elevation: 4,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          child: Text(
            "Go Live",
            style: TextStyle(
              color: _colorUtils.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
