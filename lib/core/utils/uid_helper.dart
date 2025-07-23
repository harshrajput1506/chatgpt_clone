import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class UidHelper {
  static const String _uidKey = 'device_uid';
  static Future<String> getUid() async {
    final sp = await SharedPreferences.getInstance();
    final uid = sp.getString(_uidKey);
    if (uid == null || uid.isEmpty) {
      final newUid = Uuid().v4();
      await sp.setString(_uidKey, newUid);
      return newUid;
    }
    return uid;
  }
}
