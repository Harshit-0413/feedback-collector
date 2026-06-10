import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

class MediaService {
  final ImagePicker _picker = ImagePicker();

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final sdkInt = await _getAndroidSdkInt();
      if (sdkInt >= 33) {
        final images = await Permission.photos.request();
        final videos = await Permission.videos.request();
        return images.isGranted && videos.isGranted;
      } else {
        final storage = await Permission.storage.request();
        return storage.isGranted;
      }
    }
    return true;
  }

  Future<int> _getAndroidSdkInt() async {
    try {
      final result = await Process.run('getprop', ['ro.build.version.sdk']);
      return int.tryParse(result.stdout.toString().trim()) ?? 33;
    } catch (_) {
      return 33;
    }
  }

  Future<String?> pickImage() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (file == null) return null;
    return await _saveToAppDirectory(file.path);
  }

  Future<String?> pickVideo() async {
    final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file == null) return null;
    return await _saveToAppDirectory(file.path);
  }

  Future<String?> captureImage() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (file == null) return null;
    return await _saveToAppDirectory(file.path);
  }

  Future<String> _saveToAppDirectory(String sourcePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory('${appDir.path}/feedback_media');
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }
    final fileName = path.basename(sourcePath);
    final destPath = '${mediaDir.path}/$fileName';
    await File(sourcePath).copy(destPath);
    return destPath;
  }

  Future<void> deleteMedia(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  bool isVideo(String filePath) {
    final ext = path.extension(filePath).toLowerCase();
    return ['.mp4', '.mov', '.avi', '.mkv'].contains(ext);
  }

  bool isImage(String filePath) {
    final ext = path.extension(filePath).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.gif', '.webp'].contains(ext);
  }
}
