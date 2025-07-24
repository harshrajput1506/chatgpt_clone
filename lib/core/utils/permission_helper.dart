import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  static Future<bool> requestImagePermissions() async {
    if (await Permission.photos.request().isGranted ||
        await Permission.storage.request().isGranted) {
      return true;
    }
    return false;
  }
}
