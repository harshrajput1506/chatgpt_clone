import 'package:equatable/equatable.dart';

class ChatImage extends Equatable {
  final String id;
  final String publicId;
  final String originalName;
  final int size;
  final String format;
  final int width;
  final int height;
  final String originalUrl;
  final List<String> urls;

  const ChatImage({
    required this.id,
    required this.publicId,
    required this.originalName,
    required this.size,
    required this.format,
    required this.width,
    required this.height,
    required this.originalUrl,
    required this.urls,
  });

  @override
  List<Object> get props => [
    id,
    publicId,
    originalName,
    size,
    format,
    width,  
    height,
    originalUrl,
    urls,
  ];
}


// id: image.id,
//         publicId: image.publicId,
//         originalName: image.originalName,
//         size: image.size,
//         format: image.format,
//         dimensions: {
//             width: image.width,
//             height: image.height
//         },
//         urls: generateImageVariants(image.publicId),
//         createdAt: image.createdAt