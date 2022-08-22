import 'dart:async';
import 'dart:typed_data';

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:h_view/src/ui/helper_widgets.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as pp;

import 'api.dart';

const _fs = LocalFileSystem();

class FilesImpl implements Files {
  const FilesImpl();

  @override
  final bool supportsGetDirectoryPath = true;

  @override
  FutureOr<File> readableFile(PlatformFile platformFile) {
    return _fs.file(platformFile.path);
  }

  @override
  Future<String> saveFile(BuildContext context, String? dir, String fileName,
      Uint8List bytes) async {
    Future<bool?> askToOverwrite(String name) => showYesNoDialog(context,
        question: Text('File "$name" already exists.\n'
            'Do you want to override it?'),
        title: const Text('Overwrite file?'));

    final targetDir =
        dir.map(_fs.directory) ?? await pp.getApplicationDocumentsDirectory();
    final imageFileName = '${p.withoutExtension(p.basename(fileName))}.png';
    final file = _fs.file(p.join(targetDir.path, imageFileName));
    if (await file.exists()) {
      final overwrite = await askToOverwrite(imageFileName);
      if (overwrite == null || !overwrite) {
        throw 'operation cancelled';
      }
    }
    await file.writeAsBytes(bytes);
    return file.path;
  }
}

extension on String? {
  T? map<T>(T Function(String) mapper) {
    final self = this?.trim();
    if (self == null || self.isEmpty) return null;
    return mapper(self);
  }
}
