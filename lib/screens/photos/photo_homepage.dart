import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:mediaexchange/services/const.dart';

import 'package:mediaexchange/screens/auth.dart';
import 'package:video_player/video_player.dart';

class PhotoHomepage extends StatefulWidget {
  const PhotoHomepage({super.key});

  @override
  State<PhotoHomepage> createState() => _PhotoHomepageState();
}

class _PhotoHomepageState extends State<PhotoHomepage> {
  GoogleSignInAccount? _user;
  GoogleSignInAccount? googleSignInAccount;
  Map<String, String> authCode = {};
  GoogleSignInAccount get user => _user!;
  final googleSignIn = GoogleSignIn();
  bool loading = false;
  User? userNew;
  Map data = {};
  FirebaseAuth auth = FirebaseAuth.instance;
  Future logout() async {
    await googleSignIn.signIn();
    await FirebaseAuth.instance.signOut();
    googleSignInAccount = null;
    service = '';

    setState(() {});
  }

  Future _signinUser() async {
    final googleSignIn = GoogleSignIn.standard(
        scopes: ['https://www.googleapis.com/auth/photoslibrary']);
    googleSignInAccount = await googleSignIn.signIn();
    return;
  }

  upload(File file) async {
    await _signinUser();

    final authHeaders = await googleSignInAccount!.authHeaders;

    final client = _GoogleAuthClient(authHeaders);

    var tokenResult = await client.post(
      Uri.parse('https://photoslibrary.googleapis.com/v1/uploads'),
      headers: {
        'Content-type': 'application/octet-stream',
        'X-Goog-Upload-Content-Type': 'image/png',
        'X-Goog-Upload-Protocol': 'raw'
      },
      body: file.readAsBytesSync(),
    );
    print(tokenResult.body);
    var res = await client.post(
        Uri.parse(
            'https://photoslibrary.googleapis.com/v1/mediaItems:batchCreate'),
        headers: {'Content-type': 'application/json'},
        body: jsonEncode({
          "newMediaItems": [
            {
              "description": "Posted Using Api",
              "simpleMediaItem": {
                "fileName": "Photo.png",
                "uploadToken": tokenResult.body
              }
            }
          ]
        }));

    print(res.body);
  }

  listfile() async {
    loading = true;
    setState(() {});
    await _signinUser();

    final authHeaders = await googleSignInAccount!.authHeaders;
    print(authHeaders['Authorization']);
    final String code = await googleSignInAccount!.serverAuthCode.toString();

    final client = _GoogleAuthClient(authHeaders);

    var tokenResult = await client.get(
      Uri.parse(
          'https://photoslibrary.googleapis.com/v1/mediaItems?pageSize=50'),
      headers: {
        "Authorization": authHeaders['Authorization'].toString(),
        'Accept': 'application/json,'
      },
    );
    print(tokenResult.body);
    print(tokenResult.reasonPhrase);
    loading = false;
    data = jsonDecode(tokenResult.body);
    authCode = authHeaders;
    setState(() {});
  }

  pickAndUploadFile() async {
    setState(() {});
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      File file = File(result.files.single.path!);
      await upload(file);

      setState(() {});
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userNew = auth.currentUser;
    listfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Google Photo Service"),
          actions: [
            ElevatedButton.icon(
                onPressed: () async {
                  await logout();
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => SignIn()));
                },
                icon: Icon(Icons.logout),
                label: Text("LogOut"))
          ],
        ),
        body: loading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Column(children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            userNew!.displayName.toString(),
                            style: TextStyle(fontSize: 20),
                          ),
                          ElevatedButton(
                              onPressed: () async {
                                pickAndUploadFile();
                              },
                              child: Text("Upload"))
                        ],
                      ),
                      GridView.builder(
                          itemCount: data['mediaItems'].length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  crossAxisCount: 2),
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Fileopen(
                                      data: data['mediaItems'][index],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(width: 1),
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                        alignment: Alignment.center,
                                        image: NetworkImage(
                                            scale: 3,
                                            data['mediaItems'][index]['baseUrl']
                                                .toString()))),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // Text(
                                    //   file.name.toString(),
                                    //   style: TextStyle(fontSize: 15),
                                    // ),
                                  ],
                                ),
                              ),
                            );
                          })
                    ]),
                  ),
                ),
              ));
  }
}

class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;

  final http.Client _client = http.Client();

  _GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}

class Fileopen extends StatefulWidget {
  // final String filename;
  // final String fileurl;
  final Map data;
  const Fileopen({super.key, required this.data});

  @override
  State<Fileopen> createState() => FileopenState();
}

class FileopenState extends State<Fileopen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.data['filename']),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Column(
            children: [
              Expanded(
                child: Image(
                  image: NetworkImage(
                    widget.data['baseUrl'],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class VideoFile extends StatefulWidget {
  final Map data;
  final Map<String, String> header;

  const VideoFile({super.key, required this.data, required this.header});

  @override
  State<VideoFile> createState() => _VideoFileState();
}

class _VideoFileState extends State<VideoFile> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
        Uri.parse(
          widget.data['baseUrl'].toString(),
        ),
        httpHeaders: widget.header);
    print(widget.data['baseUrl'].toString());

    _initializeVideoPlayerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.data['filename']),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Wrap the play or pause in a call to `setState`. This ensures the
          // correct icon is shown.
          setState(() {
            // If the video is playing, pause it.
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              // If the video is paused, play it.
              _controller.play();
            }
          });
        },
        // Display the correct icon depending on the state of the player.
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(5),
        child: FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // If the VideoPlayerController has finished initialization, use
              // the data it provides to limit the aspect ratio of the video.
              return AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                // Use the VideoPlayer widget to display the video.
                child: VideoPlayer(_controller),
              );
            } else {
              // If the VideoPlayerController is still initializing, show a
              // loading spinner.
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}
