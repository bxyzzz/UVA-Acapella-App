import 'package:acapella_app/screens/list_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:acapella_app/screens/record_audio_screen.dart';
import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart';

// bug fix source: https://stackoverflow.com/questions/64949640/flutter-unhandled-exception-bad-state-field-does-not-exist-within-the-documen

class OtherTracksScreen extends StatefulWidget {
  @override
  _OtherTracksScreenState createState() => _OtherTracksScreenState();
}

class _OtherTracksScreenState extends State<OtherTracksScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Other Users' Tracks"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.collection('tracks').where(FieldPath.documentId, isNotEqualTo: currentUserId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              if (doc['userId'] != currentUserId) {  // Assuming 'userId' is stored in each track document
                return TrackWidget(track: doc);
              } else {
                return Container(); // This will not show current user's tracks.
              }
            }).toList(),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey[850],
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.mic, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TracksScreen()),
                  );
                },
              ),
              Text('Your Tracks', style: TextStyle(color: Colors.white, fontSize: 10)),
              IconButton(
                icon: Icon(Icons.track_changes, color: Colors.white),
                onPressed: () {
                  // stay on current screen
                },
              ),
              Text('Other Tracks', style: TextStyle(color: Colors.white, fontSize: 10)),
              IconButton(
                icon: Icon(Icons.share, color: Colors.white),
                onPressed: () {
                  // if i time to implement make this go to ShareScreen()
                },
              ),
              Text('Share', style: TextStyle(color: Colors.white, fontSize: 10)),
              IconButton(
                icon: Icon(Icons.person, color: Colors.white),
                onPressed: () {
                  // if time to implement add an edit profile screen
                },
              ),
              Text('Profile', style: TextStyle(color: Colors.white, fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }
}