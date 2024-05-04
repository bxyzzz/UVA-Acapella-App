import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:acapella_app/screens/list_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


// source of this is basically Prof's github of the login screen, it's pretty much 1-to-1 but made the UI nicer looking
// https://docs.google.com/document/d/11Ua7lxhBOR-k_1pKl6CCHrQicYLgoV0X_fyrMNJSBcs/edit
// https://docs.google.com/document/d/1LbCC3nEygmuM7Fr_sA01Ra1G0OFb5MweoIhn1vXOlho/edit
// https://github.com/cs-4720-uva/flutter_firebase_demo/blob/11fcca6189b4b00760141790aa0e9ecd854ef637/lib/screens/log_in_screen.dart#L90

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key, required this.title});
  final String title;
  

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  int _counter = 0;
  final _emailFieldController = TextEditingController();
  final _passwordFieldController = TextEditingController();
  String _statusLabel = "";
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;


void _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final userCredential = await _auth.signInWithCredential(credential);
        setState(() {
          _statusLabel = 'Logged in as ${userCredential.user!.displayName}';
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TracksScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _statusLabel = "Failed to sign in with Google: ${e.message}";
      });
    } catch (e) {
      setState(() {
        _statusLabel = "Failed to sign in with Google: ${e.toString()}";
      });
    }
  }

  void _signIn() async {
    var result = "";
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailFieldController.text,
        password: _passwordFieldController.text,
      );
      result = "Logged In - ${credential.user?.email}";
      
      if (!mounted) return;
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TracksScreen())
      );
      
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        result = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        result = 'Wrong password provided for that user.';
      } else {
        result = e.code;
      }
    } catch (e) {
      result = e.toString();
    }
    setState(() {
      _statusLabel = result;
    });
  }

  void _createUser() async {
    var result = "";
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailFieldController.text,
        password: _passwordFieldController.text,
      );
      result = "User Created!";

      if (credential.user != null) {
        // manually set the user id first as the identifier for the /users/ collection
        await firestore.collection('users').doc(credential.user!.uid).set({
          'email': credential.user!.email,  // Assuming you want to store the email
        });
        // add 4 empty tracks (since I only allow users to record/rerecord tracks once they exist in the collection)
        // thus they have to be prepopulated
        // NAMES ARE IMPORTANT AS RECORD_AUDIO_SCREEN IS HARD CODED TO GO TO track# 

        await firestore.collection('users').doc(credential.user!.uid).collection('tracks').doc('track1').set({
        'name': 'Empty Track 1',
        'duration': 0,
        'trackUrl': '',
        });
        
        await firestore.collection('users').doc(credential.user!.uid).collection('tracks').doc('track2').set({
        'name': 'Empty Track 2',
        'duration': 0,
        'trackUrl': '',
        });

        await firestore.collection('users').doc(credential.user!.uid).collection('tracks').doc('track3').set({
        'name': 'Empty Track 3',
        'duration': 0,
        'trackUrl': '',
        });
        
        await firestore.collection('users').doc(credential.user!.uid).collection('tracks').doc('track4').set({
        'name': 'Empty Track 4',
        'duration': 0,
        'trackUrl': '',
        });

        result = "User Created and added to database!";
      }


    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        result = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        result = 'The account already exists for that email.';
      } else if (e.code == 'invalid-email'){
        result = 'Bad email format...';
      } else {
        result = e.code;
      }
    } catch (e) {
      result = e.toString();
    }
    setState(() {
      _statusLabel = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Welcome!"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Tracks App", style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)), 
            SizedBox(height: 20), 
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Email",
                  prefixIcon: Icon(Icons.mail), 
                ),
                controller: _emailFieldController,
              ),
            ),
            SizedBox(height: 10), 
            Container(
              width: MediaQuery.of(context).size.width * 0.8, 
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Password",
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                controller: _passwordFieldController,
              ),
            ),
            SizedBox(height: 20), 
            Container(
              width: MediaQuery.of(context).size.width * 0.8, // set all of the widths to be 80% based off some online examples i saw
              child: TextButton(
                onPressed: _signIn,
                child: Text("Sign-in", style: TextStyle(color: Colors.white)),
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary, 
                ),
              ),
            ),
            SizedBox(height: 10), // just copy pasted same thing and changed some small stuff
            Container(
              width: MediaQuery.of(context).size.width * 0.8, 
              child: ElevatedButton.icon(
                icon: Icon(Icons.login),
                label: Text("Sign in with Google"),
                onPressed: _signInWithGoogle,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blue,
                ),
              ),
            ),
            SizedBox(height: 10), 
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: TextButton(
                onPressed: _createUser,
                child: const Text("Create User"),
              ),
            ),
            SizedBox(height: 20), 
            Text(_statusLabel),
          ],
        ),
      ),
    );
  }
}