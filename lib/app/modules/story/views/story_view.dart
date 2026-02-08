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
                        backgroundImage: user?.avatar == null ||
                                user!.avatar!.isEmpty
                            ? null
                            : CachedNetworkImageProvider(user.avatar!),
                        child: user?.avatar == null || user!.avatar!.isEmpty
                            ? Text(
                                user?.name.isNotEmpty == true
                                    ? user!.name[0]
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : null,
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
    final bytes = Uint8List.fromList(response.data ?? []);
    return _ImageResult(bytes: bytes, statusCode: response.statusCode);
  }

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return const Center(
        child: Icon(Icons.broken_image, color: Colors.white),
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
        if (result == null || result.bytes.isEmpty) {
          return const Center(
            child: Icon(Icons.broken_image, color: Colors.white),
          );
        }
        if (result.statusCode != null && result.statusCode != 200) {
          return Center(
            child: Text(
              'Failed to load image (HTTP ${result.statusCode})',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }
        return Image.memory(
          result.bytes,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      },
    );
  }
}

class _ImageResult {
  final Uint8List bytes;
  final int? statusCode;
  _ImageResult({required this.bytes, this.statusCode});
}
