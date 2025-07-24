import 'package:equatable/equatable.dart';

class ChatImage extends Equatable {
  final String id;
  final String publicId;
  final String originalName;
  final String originalUrl;
  final Map<String, String> urls;

  const ChatImage({
    required this.id,
    required this.publicId,
    required this.originalName,
    required this.originalUrl,
    required this.urls,
  });

  @override
  List<Object> get props => [id, publicId, originalName, originalUrl, urls];
}
