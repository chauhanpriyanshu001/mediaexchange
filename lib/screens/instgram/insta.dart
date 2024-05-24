import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart' as http;
import 'package:mediaexchange/screens/auth.dart';
import 'package:mediaexchange/screens/instgram/instaUpload.dart';
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
  FirebaseAuth auth = FirebaseAuth.instance;

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

  String redirectUri = "https://socialsizzle.herokuapp.com/auth/";
  String clientID = "1096625224730439";
  String client_secret = "a26e7cf75d16c6f1f93fa9603cbc4eb9";
  String scope = "user_profile,user_media";
  String responseType = "code";
  String access_token = "";
  String user_id = "25641738518806404";
  bool loading = false;
  String instaId = '';
  instaAuth() async {
    final res = await http.get(Uri.parse(
        "https://api.instagram.com/oauth/authorize?client_id=${clientID}&redirect_uri=${redirectUri}&scope=${scope}&response_type=${responseType}"));
    // https://socialsizzle.herokuapp.com/auth/?code=AQDIgMlBSxY8PFjsEa5JWf95a8i1SBLzIp94NbZQnDRANFyO7C3CDZEoNH2sYU-Id39ArDvTIgWvXWzoeWckqBeJWgKe_gQUdqnUyoD6_0F4jSzr10ag0sGlppeH6qaXsbyK2RiNIhclCdFH97oiPpxl4SylpeSX74jyM-i869rqUiFDpsHodzlI8lUNmZC0DZsQyJ37p38HSeSxT_yGg6Q9DnwvhVm3YUVocIH48ECQrg#_
    print(res.body);
    print(res.request);
    print(res.reasonPhrase);
    print(res.statusCode);

    print(res.body.contains(redirectUri));

    setState(() {});
  }

  Future _signInWithFacebook() async {
    // 1. Trigger Facebook Login
    final LoginResult loginResult =
        await FacebookAuth.instance.login(permissions: [
      'instagram_basic',
      "instagram_content_publish",
      "pages_read_engagement",
      "instagram_content_publish",
      "pages_read_engagement",
    ]);

    // 2. Handle Login Result
    if (loginResult.status == LoginStatus.success) {
      // 3. Get Facebook Access Token
      final accessToken = loginResult.accessToken;
      print(accessToken!.token);
      // 4. Use Access Token for Firebase Authentication
      final credential = FacebookAuthProvider.credential(accessToken!.token);
      code = accessToken.token;
      setState(() {});

      try {
        // Sign in with Firebase
        await auth.signInWithCredential(credential);
        print("Firebase Login successful with Facebook");
        // Navigate to the home screen or wherever you want
        getUserMedia();
        print(auth.currentUser);
      } catch (e) {
        print("Error signing in with Facebook: ${e.toString()}");
      }
    } else {
      print("Facebook Login failed");

      // Handle failed login
    }
  }

  instaAccessCode() async {
    // final res = await http
    //     .post(Uri.parse("https://api.instagram.com/oauth/access_token"), body: {
    //   "client_id": clientID,
    //   "client_secret": client_secret,
    //   "code": code,
    //   "grant_type": "authorization_code",
    //   "redirect_uri": redirectUri
    // });
    // print(res.body);
    // print(res.request);
    // print(res.reasonPhrase);
    // print(res.statusCode);
    await _signInWithFacebook();
  }

  getUserInfo() async {
    loading = true;
    setState(() {});
    final res = await http.get(
      Uri.parse(
          "https://graph.instagram.com/me?fields=id,username&access_token=$access_token"),
    );
    print(res.body);
    print(res.request);
    print(res.reasonPhrase);
    print(res.statusCode);
    data = {};
    data = jsonDecode(res.body);
    print(data);
    loading = false;
    getuserMediaId();
    setState(() {});
  }

  getuserMediaId() async {
    loading = true;
    setState(() {});
    final res = await http.get(
      Uri.parse(
          "https://graph.instagram.com/${data['id']}/media?access_token=$access_token"),
    );
    print(res.body);
    print(res.request);
    print(res.reasonPhrase);
    print(res.statusCode);

    mediaid = jsonDecode(res.body);

    getUserMedia();
    setState(() {});
  }

  getUserMedia() async {
    loading = true;
    setState(() {});
    // Request for getting connected instagram account
    if (instaId == "") {
      var request1 = await http.get(Uri.parse(
          "https://graph.facebook.com/v19.0/me/accounts?fields=connected_instagram_account&access_token=$code"));
      print(request1.body);
      print(request1.statusCode);
      Map data = jsonDecode(request1.body);
      print(data['data'][1]['connected_instagram_account']['id']);
      instaId = data['data'][1]['connected_instagram_account']['id'].toString();
      setState(() {});
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

    // Get the app's temporary directory
    Directory? tempDir = await getDownloadsDirectory();

    // Create a file in the temporary directory
    File file = File('${tempDir?.path}/image.jpg');

    // Write the image data to the file
    await file.writeAsBytes(response.bodyBytes);
    Fluttertoast.showToast(msg: 'Image downloaded to: ${file.path}');

    print('Image downloaded to: ${file.path}');
  }

  getUploadFiles() async {
    loading = true;
    setState(() {});
    List fileUrls = [];
    var database = FirebaseStorage.instance;
    await Permission.photos;
    FilePickerResult? pickfile =
        await FilePicker.platform.pickFiles(allowMultiple: true);
    if (pickfile != null) {
      // Cheking if the picked file is singe or multiple

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
          loading = false;
          setState(() {});
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
        }
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
          title: Text("Instagram Service"),
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
                                    // setState(() {});
                                    // Request for getting post id -not posted yet

                                    // var request1 = await http.post(Uri.parse(
                                    //     "https://graph.facebook.com/v19.0/$instaId/media?image_url=https://khudkibook.web.app/img/bg.png&caption=uploadusingapi&access_token=$code"));
                                    // print(request1.body);
                                    // print(request1.statusCode);
                                    // Map id = jsonDecode(request1.body);
                                    // print(id);
                                    // // Posting now using post id
                                    // var request2 = await http.post(Uri.parse(
                                    //     "https://graph.facebook.com/v19.0/$instaId/media_publish?creation_id=${id['id']}&access_token=$code"));
                                    // print(request2.body);
                                    // print(request2.statusCode);
                                    // if (request2.statusCode.toString() ==
                                    //     "200") {
                                    //   Fluttertoast.showToast(
                                    //       msg: "Post Uploaded");
                                    // } else {
                                    //   Fluttertoast.showToast(
                                    //       msg: "Post Not Uploaded");
                                    // }
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
