import 'package:mediaexchange/services/SharedPreferencesHandler.dart';
import 'package:mediaexchange/services/const.dart';
import 'package:mediaexchange/screens/photos/photo_homepage.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mediaexchange/screens/auth.dart';

import 'package:mediaexchange/screens/instgram/insta.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  service = await SharedPreferencesHandler().getString("service");
  print(service);

  runApp(const MyApp());
}

User? userNew;
FirebaseAuth auth = FirebaseAuth.instance;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application .

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: service == "instagram"
            ? Insta()
            : service == "photo"
                ? PhotoHomepage()
                : SignIn());
  }
}
