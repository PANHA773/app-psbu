import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/app_colors.dart';
import '../../../data/models/news_model.dart';
import '../controllers/my_posts_controller.dart';

class MyPostsView extends GetView<MyPostsController> {
  const MyPostsView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<MyPostsController>()) {
      Get.put(MyPostsController());
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(theme, isDark),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const _LoadingGrid();
        }

        if (controller.error.value.isNotEmpty) {
          return _ErrorState(
            message: controller.error.value,
            onRetry: controller.fetchMyPosts,
          );
        }

        if (controller.myPosts.isEmpty) {
          return const _EmptyState();
        }

        return RefreshIndicator(
          onRefresh: controller.fetchMyPosts,
          color: AppColors.primary,
          child: _buildBody(theme, isDark),
        );
      }),
    );
  }

  AppBar _buildAppBar(ThemeData theme, bool isDark) {
    return AppBar(
      elevation: 0,
      backgroundColor: theme.scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: () => Get.offAllNamed('/home'),
        icon: _topAction(icon: Iconsax.arrow_left_2, isDark: isDark),
      ),
      titleSpacing: 6,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                colors: [Color(0xFFFF8A00), Color(0xFFFF5A3C)],
              ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
            },
            child: const Text(
              'My Posts',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
            ),
          ),
          Obx(
            () => Text(
              '${controller.myPosts.length} published items',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: controller.fetchMyPosts,
          icon: _topAction(icon: Iconsax.refresh, isDark: isDark),
        ),
        IconButton(
          onPressed: () => Get.toNamed('/post'),
          icon: _topAction(icon: Iconsax.add, isDark: isDark),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _topAction({required IconData icon, required bool isDark}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF24262D) : const Color(0xFFF1F2F4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        size: 18,
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildBody(ThemeData theme, bool isDark) {
    final posts = controller.myPosts;
    final videoCount = posts.where((p) => (p.video ?? '').isNotEmpty).length;
    final imageCount = posts.where((p) => (p.image ?? '').isNotEmpty).length;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 10, 20, 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? const [Color(0xFF2B1D16), Color(0xFF1F1A18)]
                    : const [Color(0xFFFFEFE2), Color(0xFFFFF7F0)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF3D302B)
                    : const Color(0xFFFFDFC6),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF8A00), Color(0xFFFF5A3C)],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Iconsax.document_text, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _pill('${posts.length} total', isDark),
                      _pill('$imageCount images', isDark),
                      _pill('$videoCount videos', isDark),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          sliver: SliverLayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.crossAxisExtent;
              final crossAxisCount = width >= 1150
                  ? 4
                  : width >= 780
                  ? 3
                  : 2;

              return SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.76,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final post = posts[index];
                  return _PostCard(
                    post: post,
                    isDark: isDark,
                    onTap: () => Get.toNamed('/news-detail', arguments: post),
                    onMore: () => _showActions(context, post),
                  );
                }, childCount: posts.length),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _pill(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3A302B) : const Color(0xFFFFE4CF),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: isDark ? const Color(0xFFFFC696) : const Color(0xFFBA5A00),
        ),
      ),
    );
  }

  Future<void> _showActions(BuildContext context, NewsModel post) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Iconsax.eye),
                title: const Text('View'),
                onTap: () {
                  Get.back();
                  Get.toNamed('/news-detail', arguments: post);
                },
              ),
              ListTile(
                leading: const Icon(Iconsax.edit_2),
                title: const Text('Edit'),
                onTap: () {
                  Get.back();
                  _showEditDialog(context, post);
                },
              ),
              ListTile(
                leading: const Icon(Iconsax.trash, color: Colors.red),
                title: Text(
                  'Delete',
                  style: TextStyle(
                    color: isDark ? Colors.red[300] : Colors.red[700],
                  ),
                ),
                onTap: () {
                  Get.back();
                  _confirmDelete(context, post);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, NewsModel post) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              controller.deletePost(post);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, NewsModel post) async {
    final titleController = TextEditingController(text: post.title);
    final contentController = TextEditingController(text: post.content);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1C1D24) : Colors.white,
        title: const Text('Edit Post'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              controller.updatePost(
                post: post,
                title: titleController.text.trim(),
                content: contentController.text.trim(),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final NewsModel post;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onMore;

  const _PostCard({
    required this.post,
    required this.isDark,
    required this.onTap,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = post.image ?? '';
    final hasVideo = (post.video ?? '').isNotEmpty;

    return Material(
      color: isDark ? const Color(0xFF1C1D24) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF2B2D36) : const Color(0xFFE8EBF1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  _thumb(imageUrl, hasVideo),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        post.categoryName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: InkWell(
                      onTap: onMore,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.5)
                              : Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Iconsax.more,
                          size: 16,
                          color: isDark ? Colors.grey[200] : Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black87,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: Text(
                          post.content,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            height: 1.35,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            hasVideo ? Iconsax.video_play : Iconsax.gallery,
                            size: 12,
                            color: hasVideo
                                ? const Color(0xFFE53935)
                                : AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              post.createdAtFormatted,
                              style: TextStyle(
                                fontSize: 10.5,
                                color: isDark
                                    ? Colors.grey[500]
                                    : Colors.grey[500],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(Iconsax.eye, size: 12, color: Colors.grey[500]),
                          const SizedBox(width: 3),
                          Text(
                            '${post.views}',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _thumb(String imageUrl, bool hasVideo) {
    if (imageUrl.isEmpty) {
      return Container(
        width: double.infinity,
        height: 122,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Center(
          child: Icon(
            hasVideo ? Iconsax.video_play : Iconsax.document,
            color: AppColors.primary,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 122,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: AppColors.primary.withValues(alpha: 0.12),
            child: Icon(
              hasVideo ? Iconsax.video_play : Iconsax.document,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.76,
      ),
      itemBuilder: (_, __) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
            ),
          ),
        );
      },
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.warning_2, size: 48, color: Colors.orange[600]),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.grey[300] : Colors.black54,
              ),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 116,
              height: 116,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.document,
                size: 54,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'No Posts Yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Create your first post and it will show up here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () => Get.toNamed('/post'),
              icon: const Icon(Iconsax.add),
              label: const Text('Create Post'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
