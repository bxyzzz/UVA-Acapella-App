import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';

// SOURCE: https://github.com/cs-4720-uva/flutter_firebase_demo/blob/11fcca6189b4b00760141790aa0e9ecd854ef637/lib/firebase_options.dart

// SOURCE: https://console.firebase.google.com/u/0/project/acapella-app-19092/overview

import 'package:acapella_app/screens/log_in_screen.dart';
// import 'package:firebase_app_check/firebase_app_check.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // await FirebaseAppCheck.instance.activate(); // can't figure out how to use w/o bricking my system
  // turns out i never needed it in the first place... wtf

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tracks App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SignInScreen(title: 'Welcome!'),
    );
  }
}