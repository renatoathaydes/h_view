import 'dart:async';
import 'dart:typed_data';

import 'package:file/file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'api.dart';

class FilesImpl implements Files {
  const FilesImpl();

  @override
  bool get supportsGetDirectoryPath {
    throw UnsupportedError(
        'supportsGetDirectoryPath not supported on this Platform');
  }

  @override
  FutureOr<File> readableFile(PlatformFile platformFile) async {
    throw UnsupportedError('readableFile not supported on this Platform');
  }

  @override
  Future<String> saveFile(
      BuildContext context, String? dir, String fileName, Uint8List bytes) {
    throw UnsupportedError('saveFile not supported on this Platform');
  }
}
