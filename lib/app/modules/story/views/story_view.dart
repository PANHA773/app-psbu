import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import '../../../data/models/story_model.dart';
import '../../../data/services/auth_service.dart';

class StoryView extends StatelessWidget {
  const StoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final StoryModel? story = Get.arguments is StoryModel
        ? Get.arguments as StoryModel
        : null;
    final user = story?.user;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          user?.name.isNotEmpty == true ? user!.name : 'Story',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: story == null
          ? const Center(
              child: Text(
                'No story found',
                style: TextStyle(color: Colors.white),
              ),
            )
          : Stack(
              fit: StackFit.expand,
              children: [
                _StoryImage(url: story.image),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                        Colors.black.withOpacity(0.6),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white24,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: CachedNetworkImage(
                            imageUrl: user?.avatar ?? '',
                            fit: BoxFit.cover,
                            width: 36,
                            height: 36,
                            placeholder: (context, url) => Center(
                              child: Text(
                                user?.name.isNotEmpty == true
                                    ? user!.name[0]
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Center(
                              child: Text(
                                user?.name.isNotEmpty == true
                                    ? user!.name[0]
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          user?.name.isNotEmpty == true ? user!.name : 'Story',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (story.caption.isNotEmpty)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 24,
                    child: Text(
                      story.caption,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
    );
  }
}

class _StoryImage extends StatelessWidget {
  final String url;
  const _StoryImage({required this.url});

  Future<_ImageResult> _loadImageBytes() async {
    try {
      final token = await AuthService.getToken();
      final dio = Dio();
      final response = await dio.get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          headers: token == null ? null : {'Authorization': 'Bearer $token'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final contentType = response.headers.value('content-type');
      final isImage = contentType?.startsWith('image/') ?? false;

      if (!isImage && response.statusCode == 200) {
        return _ImageResult(
          bytes: Uint8List(0),
          statusCode: 200,
          error: 'Not an image ($contentType)',
        );
      }

      final bytes = Uint8List.fromList(response.data ?? []);
      return _ImageResult(bytes: bytes, statusCode: response.statusCode);
    } catch (e) {
      return _ImageResult(bytes: Uint8List(0), error: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return const Center(
        child: Icon(Icons.broken_image, color: Colors.white, size: 48),
      );
    }
    return FutureBuilder<_ImageResult>(
      future: _loadImageBytes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        final result = snapshot.data;
        if (result == null || result.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.broken_image, color: Colors.white54, size: 48),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    result?.error ?? 'Unexpected error loading image',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        }

        if (result.statusCode != null && result.statusCode != 200) {
          return Center(
            child: Text(
              'Failed to load (HTTP ${result.statusCode})',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        if (result.bytes.isEmpty) {
          return const Center(
            child: Icon(Icons.broken_image, color: Colors.white54, size: 48),
          );
        }

        return Image.memory(
          result.bytes,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Icon(Icons.broken_image, color: Colors.white, size: 48),
          ),
        );
      },
    );
  }
}

class _ImageResult {
  final Uint8List bytes;
  final int? statusCode;
  final String? error;
  _ImageResult({required this.bytes, this.statusCode, this.error});
}
