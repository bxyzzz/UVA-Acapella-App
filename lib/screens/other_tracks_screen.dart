
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
  List<DocumentSnapshot> allTracks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAllTracks();
  }

  void fetchAllTracks() async {
    String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    QuerySnapshot usersSnapshot = await firestore.collection('users').get();
    List<QueryDocumentSnapshot> users = usersSnapshot.docs;

// get all tracks from ALL other users
    for (var userDoc in users) {
      if (userDoc.id != currentUserId) { // dont add your own tracks
        QuerySnapshot tracksSnapshot = await firestore
            .collection('users')
            .doc(userDoc.id)
            .collection('tracks')
            .get();

        allTracks.addAll(tracksSnapshot.docs); 
      }
    }

    setState(() {
      isLoading = false; 
    });
  }


  // BASICALLY BECAUSE I STORE IT AS USERS/TRACKS I HAVE TO ITERATE THROUGH EVERY USER oops (except the current user)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Other Users' Tracks"),
      ),
      body: isLoading
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: allTracks.length,
            itemBuilder: (context, index) {
              DocumentSnapshot trackDoc = allTracks[index];
              return TrackWidget(track: trackDoc, recordable: false,);
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

/*import 'package:acapella_app/screens/list_screen.dart';

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
        stream: firestore.collection('tracks').where('userId', isNotEqualTo: currentUserId).snapshots(), // get all tracks from ALL other users
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          return ListView(
            children: snapshot.data!.docs.where((doc) {
              var docData = doc.data() as Map<String, dynamic>; 
              return docData['userId'] != null && docData['userId'] != currentUserId;
            }).map((doc) {
              return TrackWidget(track: doc);
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
*/