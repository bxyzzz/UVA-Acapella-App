import 'package:acapella_app/screens/other_tracks_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:acapella_app/screens/record_audio_screen.dart';
import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart';

// Waveforms Source: https://pub.dev/packages/flutter_audio_waveforms/install
// Source: https://blog.logrocket.com/creating-flutter-audio-player-recorder-app/

// source attempt to add waveforms https://medium.com/@TakRutvik/how-to-add-audiowaveforms-to-your-flutter-apps-c948c205d2c7


class TracksScreen extends StatefulWidget {
  @override
  _TracksScreenState createState() => _TracksScreenState();
}

class _TracksScreenState extends State<TracksScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text("Your Tracks"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.collection('users').doc(userId).collection('tracks').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView(
            children: snapshot.data!.docs.map((doc) {
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
                  // does nothing bc this one just goes to your tracks, which we're already on
                },
              ),
              Text('Your Tracks', style: TextStyle(color: Colors.white, fontSize: 10)),
              IconButton(
                icon: Icon(Icons.track_changes, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OtherTracksScreen()),
                  );
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

class TrackWidget extends StatefulWidget {
  final DocumentSnapshot track;
  bool recordable; // you can only see mic icon if you are the owner of your own recordings

  TrackWidget({Key? key, required this.track, this.recordable = true}) : super(key: key);

  @override
  _TrackWidgetState createState() => _TrackWidgetState();
}

class _TrackWidgetState extends State<TrackWidget> {
  late AudioPlayer player;
  PlayerState? playerState;
  Duration? duration;
  Duration? position;

  @override
  void initState() {
    super.initState();
    player = AudioPlayer();
    player.setReleaseMode(ReleaseMode.stop);
    initAudioPlayer();
  }

  void initAudioPlayer() {
    player.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          playerState = state;
        });
      }
    });

    player.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });

    player.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var trackData = widget.track.data() as Map<String, dynamic>; 
  String trackUrl = trackData['trackUrl'] as String? ?? '';
  String trackName = trackData['name'] as String? ?? 'Unknown Track';

  // putting things as cards makes it look nicer and makes it more separable

    return Card(
      child: Row(
        children: [
          Expanded(
            flex: 6, 
            child: ListTile(
              title: Text(trackName),
              subtitle: Slider(
                onChanged: (value) {
                  final newDuration = Duration(milliseconds: (value * (duration?.inMilliseconds ?? 0)).round());
                  player.seek(newDuration);
                },
                value: (position != null && duration != null && position!.inMilliseconds > 0 && position!.inMilliseconds < duration!.inMilliseconds) ?
                        position!.inMilliseconds / duration!.inMilliseconds : 0.0,
                min: 0.0,
                max: 1.0,
              ),
              trailing: IconButton(
                icon: Icon(
                  playerState == PlayerState.playing ? Icons.pause : Icons.play_arrow,
                  color: Colors.blue,
                ),
                onPressed: () async {
                  if (playerState == PlayerState.playing) {
                    await player.pause();
                  } else {
                    await player.setSource(UrlSource(trackUrl));
                    await player.resume();
                  }
                },
              ),
            ),
          ),
          if (widget.recordable) 
            Expanded(
              flex: 4, 
              child: IconButton(
                icon: Icon(Icons.mic, color: Colors.blue),
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => RecordAudioScreen(trackId: widget.track.id)),
                  );
                },
              ),
            )
        ],
      ),
    );
  }
}
