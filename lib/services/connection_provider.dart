import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mediaexchange/services/SharedPreferencesHandler.dart';
import 'package:url_launcher/url_launcher.dart';

const String apiKey = "";
const String clientId =
    "37298714691-24da4ft551re8fbjgn56c8e0ubrkbs0i.apps.googleusercontent.com";
const String client_secret = "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";
const String apiBaseURL = "https://accounts.google.com/o/oauth2/v2/";
const String apiScope = "https://www.googleapis.com/auth/photoslibrary";
const String apiRedirectURL =
    "https://khudkibook-gtu-496e0.firebaseapp.com/__/auth/handler";

class ConnectionProvider {
  Dio? httpClient;

  /// To initialise the OAuth 2.0 PKCE Authorization flow.
  /// Open this url on a browser to login as a user. Once the user
  /// provides consent, the api will return an Authorization Grant to the
  /// redirect url.
  /// Catch this response through a local server and save the code.
  /// Set the response_type parameter to "code".
  Future<Uri?> authorize() async {
    Uri url = Uri.parse(
        "https://accounts.google.com/o/oauth2/v2/auth?scope=$apiScope&response_type=code&redirect_uri=$apiRedirectURL&client_id=$clientId");
    if (await canLaunchUrl(url))
      await launchUrl(url);
    else
      // can't launch url, there is some error
      throw "Could not launch $url";
    // print(res.body);
    // print(res.statusCode);

    return url;
  }

  /// Uses the [code] stored as part of the [authorize] call.
  /// This makes the request to the authorization server to exchange
  /// the grant code for access_token and refresh_token.
  /// Save both these tokens for subsequent requests.
  Future<dynamic> exchangeToken({code}) async {
    var response = await http.post(
      Uri.parse(
          "https://oauth2.googleapis.com/token?code=$code&client_id=$clientId&client_secret=$client_secret&redirect_uri=$apiRedirectURL&grant_type=authorization_code"),
    );

    print(response.body);
    print(response.statusCode);
    print(response.request);

    return jsonDecode(response.body);
  }

  // Get Google Drive Files
  Future<dynamic> getFilesList() async {
    String auth_code = await SharedPreferencesHandler().getString("auth_code");
    var response = await http.get(Uri.parse(
        "https://www.googleapis.com/drive/v2/files?access_token=$auth_code"));
    print(response.body);
    print(response.statusCode);
    return jsonDecode(response.body);
  }

// Get Google Photos Files
  Future<dynamic> listPhotofile() async {
    String auth_code = await SharedPreferencesHandler().getString("auth_code");
    print(auth_code);
    var tokenResult = await http.get(
      Uri.parse(
          'https://photoslibrary.googleapis.com/v1/mediaItems?pageSize=50'),
      headers: {
        "Authorization": "Bearer $auth_code",
        'Accept': 'application/json,'
      },
    );
    print(tokenResult.body);
    print(tokenResult.reasonPhrase);

    return jsonDecode(tokenResult.body);
  }

// Post to Google Photo
  Future<dynamic> uploadTophotos(File file) async {
    String auth_code = await SharedPreferencesHandler().getString("auth_code");

    var tokenResult = await http.post(
      Uri.parse('https://photoslibrary.googleapis.com/v1/uploads'),
      headers: {
        "Authorization": "Bearer $auth_code",
        'Content-type': 'application/octet-stream',
        'X-Goog-Upload-Content-Type': 'image/png',
        'X-Goog-Upload-Protocol': 'raw'
      },
      body: file.readAsBytesSync(),
    );
    print(tokenResult.body);
    var res = await http.post(
        Uri.parse(
            'https://photoslibrary.googleapis.com/v1/mediaItems:batchCreate'),
        headers: {
          "Authorization": "Bearer $auth_code",
          'Content-type': 'application/json'
        },
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
    print(res.statusCode);
    return res.statusCode;
  }

  /// Uses the [refreshToken] stored as part of call to [exchangeToken].
  /// Requests the authorization server to refresh the access_token. A
  /// successful response will provide a new valid access_token. Save
  /// this for subsequent requests.
  /// Set the grant_type to "refresh_token".
  Future refreshToken({refreshToken}) async {
    throw UnimplementedError();
  }

  /// Retrieve the associated user email for the account that is authorized.
  Future<String?> getUserEmail({accessToken}) async {
    throw UnimplementedError();
  }

  /// Returns a map of fields required for authentication of a request
  /// such as the bearer access_token saved after [exchangeToken] or
  /// [refreshToken].
  Map<String, dynamic> authHeaders(params) {
    // TODO: return the real access token retrieved
    return {'access_token': 'xyz'};
  }

  /// Read the entire metadata of the object identified by [metadata]
  /// stored in the connector.
  /// [metadata] would usually include only the basic identifiers such as
  /// file_id, drive_id, etc.
  /// The response would include detailed information like creation_date,
  /// file_size, mimetype, path, parent, owner, filename, etc.
  Future<dynamic> read({metadata, params}) async {
    throw UnimplementedError();
  }

  /// Updates the metadata information for the object identified by [metadata]
  /// on the connector.
  /// [fields] is a map that contains the metadata fields to update and their
  /// new values. These could be the filename, parent, path, etc.
  /// Returns true if successful.
  Future<bool> updateConnectorMetadata({metadata, fields, params}) async {
    throw UnimplementedError();
  }

  /// Update the contents of the object identified by [metadata]
  /// on the connector.
  /// [resource] can be a list of bytes.
  /// Can be thought of as [upload] with overwrite.
  /// Returns true if successful.
  Future<bool> updateResource({metadata, resource, params}) async {
    throw UnimplementedError();
  }

  /// Delete the object identified by [metadata] stored in the connector.
  /// Returns true if successful.
  Future<bool> delete({metadata, params}) async {
    throw UnimplementedError();
  }

  /// Uploads the file stored at [filePath] to the location and with
  /// properties defined through [metadata].
  /// [params] can contain other useful information needed to complete
  /// this operation.
  /// Returns true if successful.
  Future upload({filePath, metadata, params, contentLength}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    File file = File(result!.files.single.path!);

    var request = await http.post(
        Uri.parse(
            "https://www.googleapis.com/upload/drive/v3/files?uploadType=media"),
        body: {
          "Content-Type": 'application/octet-stream',
          "Content-Length": file.openRead()
        });

    print(request.body);
    print(request.statusCode);
    throw UnimplementedError();
  }

  /// Download the object identified by [metadata] from the connector
  /// to the local [downloadDir].
  /// Return the path of the file downloaded or null.
  Future<String?> download({metadata, downloadDir, params}) async {
    throw UnimplementedError();
  }

  /// Returns a list of files stored in [currentFolder] on the connector.
  /// Initially, this would be the home/root folder.
  /// The term 'folder' is used loosely. For connectors that offer music files,
  /// the folder equivalent would be something like a playlist.
  Future<List> index({currentFolder, filters, paginate = false, params}) async {
    String? sortBy = filters['sort_by'];
    bool? asc = filters['asc_by'];
    String type = filters['type'] ?? 'files';

    // TODO: complete the request and transform response to a list
    final response = httpClient?.request("");

    throw UnimplementedError();
  }

  /// Similar to [index].
  /// Returns the sub-folders stored in [currentFolder] on the connector.
  Future<List> indexFolders({currentFolder, params}) async {
    // // Can be assumed to be as follows
    // return index(currentFolder: currentFolder, filters: {
    //   'type': 'folder',
    // }, params: params);
    throw UnimplementedError();
  }
}
