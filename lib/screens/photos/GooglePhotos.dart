import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mediaexchange/screens/photos/fileopen.dart';
import 'package:mediaexchange/screens/signin.dart';
import 'package:mediaexchange/services/SharedPreferencesHandler.dart';
import 'package:mediaexchange/services/connection_provider.dart';

class GooglePhotoApi extends StatefulWidget {
  const GooglePhotoApi({super.key});

  @override
  State<GooglePhotoApi> createState() => _GooglePhotoApiState();
}

class _GooglePhotoApiState extends State<GooglePhotoApi> {
  List data = [];

  String nextpagetoken = "";
  int pageno = 0;
  bool loading = false;
  String filter = "all";
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
    data.clear();
    data.add(response['mediaItems']);
    nextpagetoken = response['nextPageToken'].toString();

    if (data.contains('error')) {
      await ConnectionProvider().authorize();
      await SharedPreferencesHandler().setString("auth_code", "");
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => SignIn()));
      Fluttertoast.showToast(msg: "SignIn again ");
    }

    loading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
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
                          child: Text("Upload")),
                      Center(
                        child: DropdownButton(
                          value: filter,
                          dropdownColor: Colors.red,
                          items: [
                            DropdownMenuItem(
                              child: Text("All"),
                              value: "all",
                            ),
                            DropdownMenuItem(
                              child: Text("Photos"),
                              value: "photo",
                            ),
                            DropdownMenuItem(
                              child: Text("Video"),
                              value: "video",
                            ),
                            DropdownMenuItem(
                              child: Text("Favorite"),
                              value: "fav",
                            ),
                            DropdownMenuItem(
                              child: Text("Newest First"),
                              value: "new",
                            ),
                            DropdownMenuItem(
                              child: Text("Oldest First"),
                              value: "old",
                            ),
                          ],
                          onChanged: (value) async {
                            loading = true;
                            filter = value.toString();

                            setState(() {});
                            if (value == "all") {
                              listfile();
                              loading = false;
                              setState(() {});
                            } else {
                              var response = await ConnectionProvider()
                                  .photoFilter(type: filter);
                              print(response);
                              data.clear();
                              pageno = 0;
                              data.add(response['mediaItems']);
                              nextpagetoken =
                                  response['nextPageToken'].toString();
                            }

                            loading = false;
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  data[pageno] == null
                      ? Text("Empty")
                      : GridView.builder(
                          itemCount: data[pageno].length,
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
                                print(data[pageno][index]);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Fileopen(
                                      data: data[pageno][index],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    // border: Border.all(width: 1),
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                        alignment: Alignment.center,
                                        image: NetworkImage(
                                            scale: 3,
                                            data[pageno][index]['baseUrl']
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
                          }),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                          onPressed: () async {
                            if (pageno != 0) {
                              pageno = pageno - 1;
                              setState(() {});
                            }
                          },
                          icon: Icon(Icons.arrow_circle_left_outlined)),
                      IconButton(
                          onPressed: () async {
                            print(nextpagetoken);
                            if (nextpagetoken != "" &&
                                nextpagetoken != "null") {
                              var request = await ConnectionProvider()
                                  .listPhotofile(nextPageToken: nextpagetoken);
                              nextpagetoken =
                                  request['nextPageToken'].toString();

                              // print(request);

                              data.add(request['mediaItems']);
                              pageno = pageno + 1;
                              setState(() {});
                            }
                          },
                          icon: Icon(Icons.arrow_circle_right_outlined))
                    ],
                  )
                ],
              ),
            ),
    );
  }
}
