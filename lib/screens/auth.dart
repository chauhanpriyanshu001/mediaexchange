import 'dart:async';

import 'package:fluttertoast/fluttertoast.dart';

import 'package:mediaexchange/screens/photos/usingapi/GooglePhotos.dart';
import 'package:mediaexchange/services/SharedPreferencesHandler.dart';
import 'package:mediaexchange/services/connection_provider.dart';
import 'package:mediaexchange/services/const.dart';
import 'package:mediaexchange/screens/instgram/insta.dart';
import 'package:mediaexchange/screens/photos/photo_homepage.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:google_sign_in/google_sign_in.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  FirebaseAuth auth = FirebaseAuth.instance;
  final googleSignIn = GoogleSignIn();
  String instaaccesscode = "";
  User? userNew;

  GoogleSignInAccount? _user;

  GoogleSignInAccount get user => _user!;

  Future googleLogin() async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;
      _user = googleUser;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print(e.toString());
    }
  }

  // driveredirect() {
  //   userNew = auth.currentUser;
  //   print(user);
  //   print(userNew);
  //   service = "drive";
  //   SharedPreferencesHandler().setString('service', service);
  //   setState(() {});
  //   Navigator.pushReplacement(
  //       context, MaterialPageRoute(builder: (context) => GoogleDriveHome()));
  // }

  photoredirect() async {
    userNew = auth.currentUser;
    print(user);
    print(userNew);
    service = "photo";
    await SharedPreferencesHandler().setString('service', service);

    setState(() {});
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => PhotoHomepage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Media Exchange Service",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "SignIn",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            Image(image: AssetImage('assets/img/02.png')),
            SizedBox(
              height: 100,
            ),

            // // Drive
            // InkWell(
            //     onTap: () async {
            //       // await googleLogin();
            //       // driveredirect();
            //       String auth_code =
            //           await SharedPreferencesHandler().getString("auth_code");
            //       var response = await ConnectionProvider().authorize();

            //       // if (auth_code == "") {
            //       //   var response = await ConnectionProvider().authorize();

            //       //   Navigator.pushReplacement(context,
            //       //       MaterialPageRoute(builder: (context) => AcceseCode()));
            //       // } else {
            //       //   Navigator.pushReplacement(
            //       //       context,
            //       //       MaterialPageRoute(
            //       //           builder: (context) => GoogleDriveApiHome()));
            //       // }
            //     },
            //     child: signInBtn(
            //         "https://i.pinimg.com/originals/66/93/fe/6693fe87db15daf20dd4c1e95a34d065.png",
            //         "Continue to Google Drive Service")),
            // SizedBox(
            //   height: 10,
            // ),

            // Photos
            InkWell(
                onTap: () async {
                  // Using Firebase
                  // await googleLogin();
                  // photoredirect();
                  // Using Api
                  await SharedPreferencesHandler()
                      .setString('service', service);

                  service = "photo";
                  await SharedPreferencesHandler()
                      .setString('service', service);
                  String auth_code =
                      await SharedPreferencesHandler().getString("auth_code");

                  if (auth_code == "") {
                    var response = await ConnectionProvider().authorize();

                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => AcceseCode()));
                  } else {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GooglePhotoApi()));
                  }
                },
                child: signInBtn(
                    "https://logohistory.net/wp-content/uploads/2022/10/Google-Photos-logo.png",
                    "Continue to Google Photo Service")),
            SizedBox(
              height: 10,
            ),

            // Instagram
            InkWell(
                onTap: () async {
                  // await googleLogin();
                  // photoredirect();

                  service = "instagram";
                  await SharedPreferencesHandler()
                      .setString('service', service);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Insta()));
                },
                child: signInBtn(
                    "https://lh3.googleusercontent.com/proxy/oNTjoYoASVVlr1vNFTgSzwT2EQFTuUJCYnosh07q1rQbeIihL4kfL1_Z23HMD6t4trzV7kL0giLscs3Yehs9HDxj_QJQGE2eRMasjTErFxxn_dHDAaxGWTZWkVropxPm0v9d5ngpPcDfS9BQPMJKiaU0pzKI_nCIOJSDLKB4Oa9K4uLrDIvR",
                    "Continue to Instagram Service"))
          ],
        ),
      ),
    );
  }
}

Widget signInBtn(String logo, String label) {
  return Container(
    height: 50,
    padding: EdgeInsets.all(5),
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9), color: Colors.black),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image(
          image: NetworkImage(scale: 20, logo),
        ),
        SizedBox(
          width: 10,
        ),
        Text(
          label,
          style: TextStyle(
              fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
        )
      ],
    ),
  );
}

class AcceseCode extends StatefulWidget {
  const AcceseCode({super.key});

  @override
  State<AcceseCode> createState() => AacceseCodeState();
}

class AacceseCodeState extends State<AcceseCode> {
  TextEditingController code = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Get Your Authentication Code"),
      ),
      body: Center(
        child: Column(
          children: [
            TextFormField(
              controller: code,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter Copied Url here",
              ),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () async {
                  print(code.text.split("code=").last.split("&scope").first);
                  var request = await ConnectionProvider().exchangeToken(
                      code:
                          code.text.split("code=").last.split("&scope").first);
                  Map data = request;
                  if (data.containsKey("error")) {
                    Fluttertoast.showToast(
                        msg: "Authorization Failed Please Try again");
                  } else {
                    print(data['access_token']);
                    await SharedPreferencesHandler().setString(
                        "auth_code", data['access_token'].toString());
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GooglePhotoApi()));
                  }
                },
                child: Center(
                  child: Text("Continue"),
                ))
          ],
        ),
      ),
    );
  }
}
