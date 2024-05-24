// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class UploadPost extends StatefulWidget {
  final List fileUrl;
  final String token;
  final String instaId;
  const UploadPost({
    Key? key,
    required this.fileUrl,
    required this.token,
    required this.instaId,
  }) : super(key: key);

  @override
  State<UploadPost> createState() => _UploadPostState();
}

class _UploadPostState extends State<UploadPost> {
  bool loading = false;
  TextEditingController caption = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Post"),
        actions: [
          ElevatedButton(
              onPressed: () async {
                loading = true;

                setState(() {});
                // Request for getting post id -not posted yet

                var request1 = await http.post(Uri.parse(
                    "https://graph.facebook.com/v19.0/${widget.instaId}/media?image_url=${widget.fileUrl[0]}&caption=${caption.text}&access_token=${widget.token}"));
                print(request1.body);
                print(request1.statusCode);
                Map id = jsonDecode(request1.body);
                print(id);
                // // Posting now using post id
                var request2 = await http.post(Uri.parse(
                    "https://graph.facebook.com/v19.0/${widget.instaId}/media_publish?creation_id=${id['id']}&access_token=${widget.token}"));
                print(request2.body);
                print(request2.statusCode);
                if (request2.statusCode.toString() == "200") {
                  Fluttertoast.showToast(msg: "Post Uploaded");
                } else {
                  Fluttertoast.showToast(msg: "Post Not Uploaded");
                }
                Navigator.pop(context, true);
                loading = false;

                setState(() {});
              },
              child: Text("Upload"))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: loading
              ? CircularProgressIndicator()
              : Column(
                  children: [
                    ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: widget.fileUrl.length,
                        itemBuilder: (context, index) {
                          return Container(
                              width: MediaQuery.sizeOf(context).width / 2,
                              height: MediaQuery.sizeOf(context).height / 2,
                              child: Image(
                                  image: NetworkImage(widget.fileUrl[index])));
                        }),
                    Expanded(
                      child: TextField(
                        controller: caption,
                        decoration: InputDecoration(hintText: "Add Caption"),
                      ),
                    )
                  ],
                ),
        ),
      ),
    );
  }
}
