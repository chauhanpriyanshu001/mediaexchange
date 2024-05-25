import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mediaexchange/screens/signin.dart';
import 'package:mediaexchange/services/SharedPreferencesHandler.dart';
import 'package:mediaexchange/services/const.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  service = await SharedPreferencesHandler().getString("service");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: SignIn());
  }
}
