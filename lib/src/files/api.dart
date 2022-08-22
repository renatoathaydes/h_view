import 'dart:async';
import 'dart:typed_data';

import 'package:file/file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

abstract class Files {
  bool get supportsGetDirectoryPath;

  FutureOr<File> readableFile(PlatformFile platformFile);

  Future<String> saveFile(
      BuildContext context, String? dir, String fileName, Uint8List bytes);
}
