import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart' as http;
import 'package:mediaexchange/screens/insta/instaUpload.dart';
import 'package:mediaexchange/screens/signin.dart';
import 'package:mediaexchange/services/SharedPreferencesHandler.dart';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class Insta extends StatefulWidget {
  const Insta({
    super.key,
  });

  @override
  State<Insta> createState() => _InstaState();
}

class _InstaState extends State<Insta> {
  // FirebaseAuth auth = FirebaseAuth.instance;

  Map data = {};
  Map mediaid = {};
  List media = [];
  String Url = "";
  String code = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    instaAccessCode();
  }

  String access_token = "";
  bool loading = false;
  String instaId = '';

  instaAccessCode() async {
    access_token =
        await SharedPreferencesHandler().getString("insta_auth_code");
    code = await SharedPreferencesHandler().getString("insta_auth_code");
    getUserMedia();
  }

  getUserMedia() async {
    loading = true;
    setState(() {});
    // Request for getting connected instagram account
    if (instaId == "") {
      var request1 = await http.get(Uri.parse(
          "https://graph.facebook.com/v19.0/me/accounts?fields=connected_instagram_account&access_token=$code"));

      if (request1.statusCode == 200) {
        Map data = jsonDecode(request1.body);
        print(data['data'][1]['connected_instagram_account']['id']);
        instaId =
            data['data'][1]['connected_instagram_account']['id'].toString();
        setState(() {});
      } else {
        Fluttertoast.showToast(msg: "Error Ocurred");
      }
    }

    // Request for Insta Information
    var request2 = await http.get(Uri.parse(
        "https://graph.facebook.com/v19.0/$instaId?fields=biography,name,profile_picture_url,username,website,media&access_token=$code"));

    print(request2.body);
    print(request2.statusCode);
    data = jsonDecode(request2.body);
    media.clear();
    for (var i = 0; i < data['media']['data'].length; i++) {
      final res = await http.get(
        Uri.parse(
            "https://graph.facebook.com/v19.0/${data['media']['data'][i]['id']}?fields=media_url,media_type&access_token=$code"),
      );
      media.add(jsonDecode(res.body));
    }
    print(media);
    loading = false;

    setState(() {});
  }

  Future<void> downloadImage(String imageUrl) async {
    // Send a GET request to the URL
    var response = await http.get(Uri.parse(imageUrl));
    Directory? tempDir;
    // Get the app's temporary directory
    if (Platform.isIOS) {
      tempDir = await getApplicationDocumentsDirectory();
    } else {
      tempDir = await getDownloadsDirectory();
    }

    // Create a file in the temporary directory
    File file = File('${tempDir?.path}/image.jpg');

    // Write the image data to the file
    await file.writeAsBytes(response.bodyBytes);
    Fluttertoast.showToast(msg: 'Image downloaded to: ${file.path}');

    print('Image downloaded to: ${file.path}');
  }

  getUploadFiles() async {
    List fileUrls = [];
    var database = FirebaseStorage.instance;
    await Permission.photos;
    FilePickerResult? pickfile =
        await FilePicker.platform.pickFiles(allowMultiple: true);
    if (pickfile != null) {
      // Cheking if the picked file is singe or multiple
      loading = true;
      setState(() {});
      if (pickfile.isSinglePick) {
        // Single file
        // Getting file path
        File file = File(pickfile.files.single.path!);
        // Uploading into database
        var req = await database
            .ref()
            .child("instaPost${DateTime.now()}")
            .putFile(file);
        print(req.state);
        // Getting uploaded url
        String newUrl = await req.ref.getDownloadURL();
// adding in list
        fileUrls.add(newUrl);

        loading = false;
        // Navigate
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UploadPost(
                      instaId: instaId,
                      fileUrl: fileUrls,
                      token: code,
                    ))).then((value) {
          getUserMedia();
          setState(() {});
        });
      } else {
        // For Multiple file file
        // Getting file path using loop for multiple file

        for (var i = 0; i < pickfile.files.length; i++) {
          File file = File(pickfile.files[i].path!);
          // Uploading into database

          var req = await database
              .ref()
              .child("instaPost${DateTime.now()}")
              .putFile(file);
          print(req.state);
          String newUrl = await req.ref.getDownloadURL();
          // adding in list

          fileUrls.add(newUrl);

          // Navigate
        }
        loading = false;
        setState(() {});
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UploadPost(
                      instaId: instaId,
                      fileUrl: fileUrls,
                      token: code,
                    ))).then((value) {
          getUserMedia();
          setState(() {});
        });
      }
    }
    loading = false;
    setState(() {});
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("Instagram Service"),
          centerTitle: false,
          actions: [
            ElevatedButton.icon(
                onPressed: () async {
                  // await logout();
                  await SharedPreferencesHandler().setString("auth_code", "");
                  await SharedPreferencesHandler().setString("service", "");
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => SignIn()));
                },
                icon: Icon(Icons.logout),
                label: Text("LogOut"))
          ],
        ),
        body: loading
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: [
                    data.isEmpty
                        ? SizedBox()
                        : Row(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundImage:
                                    NetworkImage(data['profile_picture_url']),
                              ),
                              Text(
                                data['username'].toString(),
                                style: TextStyle(fontSize: 20),
                              ),
                              Expanded(child: SizedBox()),
                              ElevatedButton(
                                  onPressed: () async {
                                    loading = true;
                                    getUploadFiles();

                                    loading = false;
                                    // getUserMedia();
                                    // setState(() {});
                                  },
                                  child: Text("Upload"))
                            ],
                          ),
                    GridView.builder(
                        shrinkWrap: true,
                        itemCount: media.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2),
                        itemBuilder: (context, index) {
                          return Container(
                            child: InkWell(
                              onTap: () async {
                                print(media[index]['media_type']);
                                await downloadImage(
                                    media[index]['media_url'].toString());
                              },
                              child: Image(
                                  image:
                                      NetworkImage(media[index]['media_url'])),
                            ),
                          );
                        })
                  ],
                ),
              ));
  }
}
