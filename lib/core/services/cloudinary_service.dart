import 'package:cloudinary_public/cloudinary_public.dart';
import '../utils/failures.dart';

class CloudinaryService {
  late final CloudinaryPublic _cloudinary;

  CloudinaryService() {
    final cloudName =  '';
    final uploadPreset = '';

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
