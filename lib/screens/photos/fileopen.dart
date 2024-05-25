import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
