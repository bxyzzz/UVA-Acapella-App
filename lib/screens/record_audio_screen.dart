import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:acapella_app/screens/list_screen.dart';

import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:firebase_storage/firebase_storage.dart';

// import 'package:firebase_app_check/firebase_app_check.dart';

// SOURCE 1: https://pub.dev/packages/flutter_sound/example
// SOURCE 2: https://www.youtube.com/watch?v=j4mX0jtxWpA

// app check??? https://firebase.google.com/docs/app-check/android/custom-provider
// https://pub.dev/packages/audio_waveforms

class RecordAudioScreen extends StatefulWidget {
  final String trackId;
  const RecordAudioScreen({Key? key, required this.trackId}) : super(key: key);

  @override
  _RecordAudioScreenState createState() => _RecordAudioScreenState();
}

class _RecordAudioScreenState extends State<RecordAudioScreen> {
  FlutterSoundRecorder recorder = FlutterSoundRecorder();
  final AssetsAudioPlayer _player = AssetsAudioPlayer();
  bool isRecording = false;
  bool isPlaying = false;
  String filePath = '';
  int _trackNumber = 1;


  @override
  void initState() {
    super.initState();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    final status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      throw 'Microphone permission not granted';
    }

    await recorder.openAudioSession();

    recorder.setSubscriptionDuration(
      const Duration(milliseconds: 500) // must update the timer to let update the state of the numbers!
    );

    updateFilePath();
    print("File will be saved at: $filePath"); // see if im saving the audio clip correctly 
    
  }

   void updateFilePath() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    filePath = '${appDir.path}/${widget.trackId}.wav';
  }

  Future<void> startRecording() async {
    await recorder.startRecorder(toFile: filePath);
    setState(() {
      isRecording = true;
    });
    recorder.onProgress!.listen((event) {
      },
    );
  }

  Future<void> stopRecording() async {
    String? result = await recorder.stopRecorder();
    setState(() {
      isRecording = false;
    });

    // figured it'd be easiest to automatically upload the file to firebase 

    uploadFirebase(filePath);
  }

  Future<void> uploadFirebase(String filePath) async {
    File file = File(filePath);
    try {
      // this function basically creates the route/reference for when uploading the recorded microphone track to Firebase Storage
      String userId = FirebaseAuth.instance.currentUser!.uid;
      String fileName = path.basename(file.path);
      // THIS IS IMPORTANT, SENDS IT TO *SPECIFICALLY* track# slot
      Reference ref = FirebaseStorage.instance.ref('audio/$userId/track$_trackNumber.wav');

      UploadTask uploadTask = ref.putFile(file); // upload

      // this was helper code to see if the upload was actually happening correctly or not
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        print('Task state: ${snapshot.state}');
        print('Progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100} %');
      });

      final url = await (await uploadTask).ref.getDownloadURL();
      print('Download URL: $url'); // more code to make sure that the audio file *actually* exists

      saveTrackInfo(url);
      incrementTrackNumber();
    } catch (e) {
      print(e);
    }
  }

   void incrementTrackNumber() {
    setState(() {
      _trackNumber = _trackNumber % 4 + 1; // Cycles through 1 to 4
      updateFilePath();
    });
  }

   Future<void> saveTrackInfo(String url) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(userId).collection('tracks').doc('track$_trackNumber').set({
      'trackUrl': url,
      'name': 'Track ${widget.trackId}',
      'timestamp': FieldValue.serverTimestamp(),
      'userId': userId
    });
  }

  void playTrack() {
    _player.open( 
      Audio.file(filePath),
      autoStart: true,
    );
    setState(() {
      isPlaying = true;
    });
  }

  void stopTrack() {
    _player.stop();
    setState(() {
      isPlaying = false;
    });
  }

  @override
  void dispose() {
    recorder.closeAudioSession(); // close recorder when done with it
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recording Audio'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            StreamBuilder<RecordingDisposition>(
              stream: recorder.onProgress,
              builder: (context, snapshot) {
                final duration = snapshot.hasData ? snapshot.data!.duration : Duration.zero;

                String twoDigits(int n) => n.toString().padLeft(1);
                  final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
                  final twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
                  
                  return Text('$twoDigitMinutes:$twoDigitSeconds',
                  style: const TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    ),
                  );

              },
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: isRecording ? stopRecording : startRecording,
              icon: Icon(isRecording ? Icons.stop : Icons.mic),
              label: Text(isRecording ? 'Stop Recording' : 'Start Recording'),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: isPlaying ? stopTrack : playTrack,
              icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
              label: Text(isPlaying ? 'Stop Playback' : 'Start Playback'),
            ),
          ],
        ),
      ),
    );
  }
}