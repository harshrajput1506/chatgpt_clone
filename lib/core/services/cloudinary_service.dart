import 'package:chatgpt_clone/core/constants/app_url.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:logger/web.dart';
import '../utils/failures.dart';

class CloudinaryService {
  late final CloudinaryPublic _cloudinary;
  final Logger _logger = Logger(printer: PrettyPrinter());

  CloudinaryService() {
    _cloudinary = CloudinaryPublic(
      AppUrl.cloudinaryCloudName,
      AppUrl.cloudinaryPreset,
    );
  }

  Future<Map<String, dynamic>> uploadImage(String imagePath) async {
    try {
      _logger.i('Uploading image to Cloudinary: $imagePath');
      final result = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imagePath,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      _logger.i(
        'Image uploaded successfully: ${result.secureUrl}, data - ${result.data}, context - ${result.context}, publicId - ${result.publicId}, ',
      );
      return {
        'publicId': result.publicId,
        'originalName': result.originalFilename,
        'originalUrl': result.secureUrl,
      };
    } catch (e) {
      _logger.e('Failed to upload image: $e');
      throw ServerFailure('Failed to upload image: $e');
    }
  }
}
