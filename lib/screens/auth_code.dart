import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mediaexchange/screens/insta/insta.dart';
import 'package:mediaexchange/screens/photos/GooglePhotos.dart';
import 'package:mediaexchange/services/SharedPreferencesHandler.dart';
import 'package:mediaexchange/services/connection_provider.dart';

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
                  if (code.text.contains("https://www.google.com/")) {
                    print("Insta Auth");
// For Instagram

                    var request = await ConnectionProvider().exchangeTokenInsta(
                        code:
                            code.text.split("code=").last.split("-A#_").first);
                    Map data = request;
                    if (data.containsKey("error")) {
                      Fluttertoast.showToast(
                          msg: "Authorization Failed Please Try again");
                    } else {
                      print(data['access_token']);
                      await SharedPreferencesHandler().setString(
                          "insta_auth_code", data['access_token'].toString());
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => Insta()));
                    }
                  } else {
// For Gooogle Photos

                    print(code.text.split("code=").last.split("&scope").first);
                    var request = await ConnectionProvider().exchangeToken(
                        code: code.text
                            .split("code=")
                            .last
                            .split("&scope")
                            .first);
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
