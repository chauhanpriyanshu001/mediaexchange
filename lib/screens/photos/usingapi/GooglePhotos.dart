import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mediaexchange/screens/auth.dart';
import 'package:mediaexchange/screens/photos/photo_homepage.dart';
import 'package:mediaexchange/services/SharedPreferencesHandler.dart';
import 'package:mediaexchange/services/connection_provider.dart';

class GooglePhotoApi extends StatefulWidget {
  const GooglePhotoApi({super.key});

  @override
  State<GooglePhotoApi> createState() => _GooglePhotoApiState();
}

class _GooglePhotoApiState extends State<GooglePhotoApi> {
  Map data = {};
  bool loading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listfile();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  listfile() async {
    loading = true;
    setState(() {});
    var response = await ConnectionProvider().listPhotofile();
    data = response;
    print(data);
    loading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Google Photo Service"),
        actions: [
          ElevatedButton.icon(
              onPressed: () async {
                // await logout();
                await SharedPreferencesHandler().setString("auth_code", "");
                await SharedPreferencesHandler().setString("service", "");
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => SignIn()));
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
              padding: EdgeInsets.all(15),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Text(

                      //   style: TextStyle(fontSize: 20),
                      // ),
                      // Upload
                      ElevatedButton(
                          onPressed: () async {
                            loading = true;
                            setState(() {});
                            FilePickerResult? result = await FilePicker.platform
                                .pickFiles(type: FileType.image);

                            if (result != null) {
                              File file = File(result.files.single.path!);
                              var response = await ConnectionProvider()
                                  .uploadTophotos(file);
                              if (response.toString() == "200") {
                                listfile();
                                setState(() {});
                                Fluttertoast.showToast(msg: "Uploded");
                              } else {
                                Fluttertoast.showToast(msg: "Error Ocuured");
                              }

                              setState(() {});
                            } else {
                              Fluttertoast.showToast(msg: "No File Selected");
                            }
                            loading = false;
                            setState(() {});
                          },
                          child: Text("Upload"))
                    ],
                  ),
                  GridView.builder(
                      itemCount: data['mediaItems'].length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                ],
              ),
            ),
    );
  }
}
