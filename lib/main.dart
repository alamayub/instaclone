import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:insta_clone/state/auth/backend/authenticator.dart';
import 'dart:developer' as devtools show log;

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authenticator'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () async {
                final res = await const Authenticator().loginWithGoogle();
                res.log();
              },
              child: const Text('Sign In With Google'),
            ),
            TextButton(
              onPressed: () async {
                final res = await const Authenticator().loginWithFacebook();
                res.log();
              },
              child: const Text('Sign In With Facebook'),
            ),
          ],
        ),
      ),
    );
  }
}

extension Log on Object {
  void log() => devtools.log(toString());
}
