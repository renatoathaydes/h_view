import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:file_picker/file_picker.dart';

Future<File> readableFile(PlatformFile platformFile) async {
  final fs = MemoryFileSystem();
  final file = fs.file(platformFile.name);
  await file.writeAsBytes(platformFile.bytes!);
  return file;
}
