import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/failures.dart';

class CloudinaryService {
  late final CloudinaryPublic _cloudinary;

  CloudinaryService() {
    final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
    final uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

    _cloudinary = CloudinaryPublic(cloudName, uploadPreset);
  }

  Future<String> uploadImage(String imagePath) async {
    try {
      final result = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(imagePath),
      );
      return result.secureUrl;
    } catch (e) {
      throw ServerFailure('Failed to upload image: $e');
    }
  }
}
