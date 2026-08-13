import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

class SAFPlugin {
  static const platform = const MethodChannel('com.perol.dev/saf');

  static Future<String?> createFile(String name, String type) async {
    final result = await platform
        .invokeMethod("createFile", {'name': name, 'mimeType': type});
    if (result != null) {
      return result;
    }
    return null;
  }

  static Future<void> writeUri(String uri, Uint8List data) async {
    return platform.invokeMethod("writeUri", {'uri': uri, 'data': data});
  }

  static Future<Uint8List?> openFile() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          return File(file.path!).readAsBytes();
        }
        if (file.bytes != null) {
          return file.bytes;
        }
      }
    } catch (e) {
      print("FilePicker error: $e");
    }
    return null;
  }
}