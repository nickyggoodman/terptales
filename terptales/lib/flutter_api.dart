import 'dart:io';

import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

// I am referencing this video: https://www.youtube.com/watch?v=uizZbJWziEg
class PDFApi {
  static Future<File> loadNetwork(String url) async {
    // put the url of the pdf inside here
    final response = await http.get(url);
    // access the bytes from this response
    final bytes = response.bodyBytes;

    // store bytes inside of a file
    return _storeFile(url, bytes);
  }

  // method to STORE file
  static Future<File> _storeFile(String url, List<int> bytes) async {

    final filename = basename(url);
    final dir = await getApplicationDocumentsDirectory();

    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    return file;

  }

}