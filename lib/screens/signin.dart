import 'dart:async';

import 'package:fluttertoast/fluttertoast.dart';

import 'package:flutter/material.dart';
import 'package:mediaexchange/screens/auth_code.dart';
import 'package:mediaexchange/screens/photos/GooglePhotos.dart';
import 'package:mediaexchange/services/SharedPreferencesHandler.dart';
import 'package:mediaexchange/services/connection_provider.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  String service = "";
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

            // Photos
            InkWell(
                onTap: () async {
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
                  service = "instagram";
                  await SharedPreferencesHandler()
                      .setString('service', service);
                  await ConnectionProvider().instaAuthorize();
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AcceseCode()));
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
