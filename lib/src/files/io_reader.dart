import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:file_picker/file_picker.dart';

Future<File> readableFile(PlatformFile platformFile) async {
  return const LocalFileSystem().file(platformFile.path);
}