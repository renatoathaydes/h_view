import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import 'api.dart';

class FilesImpl implements Files {
  const FilesImpl();

  @override
  final bool supportsGetDirectoryPath = false;

  @override
  FutureOr<File> readableFile(PlatformFile platformFile) async {
    final fs = MemoryFileSystem();
    final file = fs.file(platformFile.name);
    await file.writeAsBytes(platformFile.bytes!);
    return file;
  }

  @override
  Future<String> saveFile(BuildContext context, String? dir, String fileName,
      Uint8List bytes) async {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final imageFileName = '${p.withoutExtension(p.basename(fileName))}.png';
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = imageFileName;
    html.document.body!.children.add(anchor);

    try {
      anchor.click();
    } finally {
      html.document.body!.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
    }

    return imageFileName;
  }
}
