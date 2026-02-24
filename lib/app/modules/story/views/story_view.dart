import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../data/models/comment_model.dart';
import '../../../data/models/story_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/comment_service.dart';
import '../../../data/services/story_service.dart';

class StoryView extends StatefulWidget {
  const StoryView({super.key});

  @override
  State<StoryView> createState() => _StoryViewState();
}

class _StoryViewState extends State<StoryView> {
  StoryModel? story;
  final TextEditingController _commentController = TextEditingController();
  final List<CommentModel> _comments = <CommentModel>[];
  bool _isLoadingComments = false;
  bool _isSendingComment = false;
  int _viewerCount = 0;
  VideoPlayerController? _videoController;
  bool _isVideoLoading = false;
  String? _videoError;

  @override
  void initState() {
    super.initState();
    story = _readStoryArgument(Get.arguments);
    if (story != null) {
      _viewerCount = story?.viewerCount ?? 0;
      _initializeStoryMedia();
      _fetchComments();
      _incrementView();
    }
  }

  StoryModel? _readStoryArgument(dynamic args) {
    try {
      if (args == null) return null;
      return StoryModel.fromAny(args);
    } catch (e) {
      debugPrint('StoryView: invalid route argument -> $e');
      return null;
    }
  }

  Future<void> _initializeStoryMedia() async {
    if (story == null || !story!.hasVideo) return;

    final mediaUrl = story!.mediaUrl;
    if (mediaUrl.isEmpty) return;

    setState(() {
      _isVideoLoading = true;
      _videoError = null;
    });

    try {
      final token = await AuthService.getToken();
      final headers = <String, String>{};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final controller = VideoPlayerController.networkUrl(
        Uri.parse(mediaUrl),
        httpHeaders: headers,
      );

      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }

      await _videoController?.dispose();
      _videoController = controller
        ..setLooping(true)
        ..play();

      setState(() {
        _isVideoLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isVideoLoading = false;
        _videoError = e.toString();
      });
    }
  }

  Future<void> _incrementView() async {
    if (story == null) return;
    try {
      final ok = await StoryService().incrementStoryView(story!.id);
      if (ok && mounted) {
        setState(() {
          _viewerCount = _viewerCount + 1;
        });
      }
    } catch (_) {
      // Ignore failures silently.
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _fetchComments() async {
    if (story == null) return;

    setState(() => _isLoadingComments = true);
    try {
      final data = await CommentService.fetchStoryComments(story!.id);
      if (!mounted) return;

      setState(() {
        _comments
          ..clear()
          ..addAll(data);
      });
    } catch (_) {
      if (!mounted) return;
      setState(_comments.clear);
    } finally {
      if (mounted) {
        setState(() => _isLoadingComments = false);
      }
    }
  }

  Future<void> _sendComment() async {
    if (story == null || _isSendingComment) return;

    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSendingComment = true);
    try {
      final comment = await CommentService.createStoryComment(story!.id, text);
      if (!mounted) return;

      setState(() {
        _comments.insert(0, comment);
      });
      _commentController.clear();
    } catch (e) {
      if (!mounted) return;
      Get.snackbar(
        'Error',
        'Failed to comment: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() => _isSendingComment = false);
      }
    }
  }

  String _storyTimeLabel() {
    final createdAt = story?.createdAt;
    if (createdAt == null) return 'just now';

    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final currentStory = story;
    if (currentStory == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF101217),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.broken_image_outlined,
                  color: Colors.white70,
                  size: 32,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'No story found',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(onPressed: Get.back, child: const Text('Go back')),
            ],
          ),
        ),
      );
    }

    final user = currentStory.user;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1013),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildStoryMedia(),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.75),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.84),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                children: [
                  _buildTopHeader(user),
                  const Spacer(),
                  _buildBottomComposer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeader(StoryUser user) {
    return Column(
      children: [
        Row(
          children: [
            _iconShell(icon: Icons.arrow_back_ios_new_rounded, onTap: Get.back),
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white24,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _buildUserAvatar(user),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name.isNotEmpty ? user.name : 'Story',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _storyTimeLabel(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            _statChip(icon: Icons.visibility_rounded, label: '$_viewerCount'),
            const SizedBox(width: 8),
            _statChip(
              icon: story?.hasVideo == true
                  ? Icons.videocam_rounded
                  : Icons.image_rounded,
              label: story?.hasVideo == true ? 'Video' : 'Image',
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 3,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(99),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: 1,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFA620), Color(0xFFFF6E40)],
                ),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomComposer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF11131A).withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (story?.caption.isNotEmpty == true)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                story!.caption,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Row(
            children: [
              Text(
                'Comments',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.92),
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '${_comments.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              _iconShell(
                icon: Icons.refresh_rounded,
                onTap: _fetchComments,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(height: 140, child: _buildCommentList()),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  style: const TextStyle(color: Colors.white, fontSize: 13.5),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendComment(),
                  decoration: InputDecoration(
                    hintText: 'Write a comment',
                    hintStyle: const TextStyle(
                      color: Colors.white60,
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.09),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFFFA620)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _isSendingComment ? null : _sendComment,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFA620), Color(0xFFFF6E40)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFA620).withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: _isSendingComment
                      ? const Padding(
                          padding: EdgeInsets.all(11),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconShell({
    required IconData icon,
    required VoidCallback onTap,
    double size = 18,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, size: size, color: Colors.white),
      ),
    );
  }

  Widget _statChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 13),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryMedia() {
    if (story == null) return const SizedBox.shrink();

    if (!story!.hasVideo) {
      return _StoryImage(url: story!.image);
    }

    if (_isVideoLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_videoError != null || _videoController == null) {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.videocam_off, color: Colors.white70, size: 46),
              const SizedBox(height: 10),
              Text(
                _videoError ?? 'Failed to load video story',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _initializeStoryMedia,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white54),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        final currentController = _videoController;
        if (currentController == null) return;
        if (currentController.value.isPlaying) {
          currentController.pause();
        } else {
          currentController.play();
        }
        setState(() {});
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: _videoController!.value.size.width,
              height: _videoController!.value.size.height,
              child: VideoPlayer(_videoController!),
            ),
          ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 160),
            opacity: _videoController!.value.isPlaying ? 0 : 1,
            child: Center(
              child: Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white38),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 44,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentList() {
    if (_isLoadingComments) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_comments.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.mode_comment_outlined, color: Colors.white54, size: 22),
            SizedBox(height: 6),
            Text(
              'No comments yet',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: _comments.length,
      itemBuilder: (context, index) {
        final comment = _comments[index];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 13,
              backgroundColor: Colors.white24,
              child:
                  comment.authorAvatar != null &&
                      comment.authorAvatar!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: CachedNetworkImage(
                        imageUrl: comment.authorAvatar!,
                        width: 26,
                        height: 26,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Text(
                          comment.authorName.isNotEmpty
                              ? comment.authorName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                        errorWidget: (context, url, error) => Text(
                          comment.authorName.isNotEmpty
                              ? comment.authorName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    )
                  : Text(
                      comment.authorName.isNotEmpty
                          ? comment.authorName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.authorName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      comment.content,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 8),
    );
  }

  Widget _buildUserAvatar(StoryUser? user) {
    final avatar = user?.avatar;
    if (avatar == null || avatar.isEmpty) {
      return Center(
        child: Text(
          user?.name.isNotEmpty == true ? user!.name[0] : '?',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: avatar,
      fit: BoxFit.cover,
      width: 40,
      height: 40,
      placeholder: (context, url) => Center(
        child: Text(
          user?.name.isNotEmpty == true ? user!.name[0] : '?',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Center(
        child: Text(
          user?.name.isNotEmpty == true ? user!.name[0] : '?',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _StoryImage extends StatefulWidget {
  final String url;

  const _StoryImage({required this.url});

  @override
  State<_StoryImage> createState() => _StoryImageState();
}

class _StoryImageState extends State<_StoryImage> {
  late Future<_ImageResult> _imageFuture;

  @override
  void initState() {
    super.initState();
    _imageFuture = _loadImageBytes();
  }

  @override
  void didUpdateWidget(covariant _StoryImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _imageFuture = _loadImageBytes();
    }
  }

  Future<_ImageResult> _loadImageBytes() async {
    try {
      final token = await AuthService.getToken();
      final dio = Dio();
      final response = await dio.get<List<int>>(
        widget.url,
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
    if (widget.url.isEmpty) {
      return const Center(
        child: Icon(Icons.broken_image, color: Colors.white, size: 48),
      );
    }

    return FutureBuilder<_ImageResult>(
      future: _imageFuture,
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
