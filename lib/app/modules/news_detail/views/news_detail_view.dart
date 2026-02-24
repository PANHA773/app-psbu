import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/news_model.dart';
import '../../../data/models/comment_model.dart';
import '../../../data/models/video/views/video_player_screen.dart';
import '../../../../core/app_colors.dart';
import '../controllers/news_detail_controller.dart';

class NewsDetailView extends GetView<NewsDetailController> {
  const NewsDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Obx(() {
        final news = controller.news.value;

        if (news == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading article...',
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color?.withValues(
                      alpha: 0.7,
                    ),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Hero Image App Bar
            SliverAppBar(
              expandedHeight: 320,
              floating: false,
              pinned: true,
              snap: false,
              elevation: 0,
              backgroundColor: isDark ? const Color(0xFF181920) : Colors.white,
              surfaceTintColor: Colors.transparent,
              leading: Padding(
                padding: const EdgeInsets.only(left: 8, top: 8),
                child: _overlayCircleAction(
                  icon: Iconsax.arrow_left_2,
                  onTap: Get.back,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8, top: 8),
                  child: Obx(
                    () => _overlayCircleAction(
                      icon: controller.isGood.value
                          ? Icons.bookmark_added
                          : Icons.bookmark_add_outlined,
                      iconColor: controller.isGood.value
                          ? const Color(0xFFFF8A00)
                          : Colors.white,
                      onTap: controller.toggleGood,
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    news.image != null && news.image!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: news.image!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Container(color: const Color(0xFFFFF1E3)),
                            errorWidget: (context, url, error) => Container(
                              color: const Color(0xFFFFF1E3),
                              child: const Center(
                                child: Icon(
                                  Iconsax.gallery,
                                  size: 44,
                                  color: Color(0xFFFF8A00),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            color: const Color(0xFFFFF1E3),
                            child: const Center(
                              child: Icon(
                                Iconsax.gallery,
                                size: 44,
                                color: Color(0xFFFF8A00),
                              ),
                            ),
                          ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.12),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 20,
                      child: Text(
                        news.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content Area
            SliverToBoxAdapter(
              child: Container(
                transform: Matrix4.translationValues(0, -24, 0),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              news.categoryName,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF23252C)
                                  : const Color(0xFFF2F3F5),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              _estimateReadTime(news.content),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? Colors.grey[300]
                                    : Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      Text(
                        news.title,
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w800,
                          height: 1.35,
                          color: isDark ? Colors.white : Colors.black87,
                          letterSpacing: -0.4,
                        ),
                      ),
                      if (news.video != null && news.video!.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        OutlinedButton.icon(
                          onPressed: () => Get.to(
                            () => VideoPlayerScreen(videoUrl: news.video!),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(
                              color: AppColors.primary.withValues(alpha: 0.35),
                            ),
                            minimumSize: const Size(double.infinity, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Iconsax.play_circle, size: 18),
                          label: const Text(
                            'Watch Video',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                      const SizedBox(height: 22),

                      // Author & Metadata Row
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1C1D24)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF2B2D36)
                                : const Color(0xFFE9ECF1),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Author Avatar
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: news.authorAvatar != null
                                    ? CachedNetworkImage(
                                        imageUrl: news.authorAvatar!,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            Container(
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.1),
                                              child: Center(
                                                child: Icon(
                                                  Iconsax.user,
                                                  color: AppColors.primary,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                      )
                                    : Container(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.1,
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Iconsax.user,
                                            color: AppColors.primary,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Author Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    news.authorName,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Iconsax.calendar_1,
                                        size: 14,
                                        color: Colors.grey[500],
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        news.createdAtFormatted,
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Icon(
                                        Iconsax.eye,
                                        size: 14,
                                        color: Colors.grey[500],
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${news.views} reads',
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Content
                      Text(
                        news.content,
                        style: TextStyle(
                          fontSize: 15.5,
                          height: 1.72,
                          color: isDark ? Colors.grey[300] : Colors.grey[800],
                          letterSpacing: 0.15,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Tags
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [news.categoryName, 'News', 'Campus'].map((
                          tag,
                        ) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF23252C)
                                  : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey[300]
                                    : Colors.grey[700],
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 40),

                      // Documents Section
                      if (news.documents.isNotEmpty) ...[
                        _buildDocumentsSection(news),
                        const SizedBox(height: 40),
                      ],

                      // Comments Section
                      const SizedBox(height: 40),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 24,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Comments',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Obx(
                            () => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${controller.comments.length}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Obx(() {
                        if (controller.isLoadingComments.value &&
                            controller.comments.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        }

                        if (controller.comments.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1C1D24)
                                  : const Color(0xFFF7F8FA),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF2B2D36)
                                    : const Color(0xFFEAECEF),
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Iconsax.message_text,
                                  size: 40,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No comments yet.',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Be the first to share your thoughts!',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.comments.length,
                          separatorBuilder: (context, i) =>
                              const SizedBox(height: 20),
                          itemBuilder: (context, i) {
                            final c = controller.comments[i];
                            final isMine =
                                c.authorId != null &&
                                c.authorId == controller.currentUserId.value;
                            return GestureDetector(
                              onLongPress: isMine
                                  ? () => _showCommentActions(c)
                                  : null,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1C1D24)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF2B2D36)
                                        : const Color(0xFFE9ECF1),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.03,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: CachedNetworkImage(
                                        imageUrl: c.authorAvatar ?? '',
                                        fit: BoxFit.cover,
                                        width: 40,
                                        height: 40,
                                        placeholder: (context, url) => Icon(
                                          Iconsax.user,
                                          size: 20,
                                          color: AppColors.primary,
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Icon(
                                              Iconsax.user,
                                              size: 20,
                                              color: AppColors.primary,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                c.authorName,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                  color: isDark
                                                      ? Colors.white
                                                      : Colors.black87,
                                                ),
                                              ),
                                              Text(
                                                c.createdAtFormatted,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey[400],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            c.content,
                                            style: TextStyle(
                                              fontSize: 14,
                                              height: 1.5,
                                              color: isDark
                                                  ? Colors.grey[300]
                                                  : Colors.grey[700],
                                            ),
                                          ),
                                          if (isMine) ...[
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                _commentActionChip(
                                                  icon: Iconsax.edit,
                                                  label: 'Edit',
                                                  onTap: () =>
                                                      _showEditCommentDialog(c),
                                                ),
                                                const SizedBox(width: 8),
                                                _commentActionChip(
                                                  icon: Iconsax.trash,
                                                  label: 'Delete',
                                                  color: Colors.red,
                                                  onTap: () =>
                                                      _confirmDelete(c),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }),
                      const SizedBox(height: 32),

                      // Comment Input
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1C1D24)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF2B2D36)
                                : AppColors.primary.withValues(alpha: 0.14),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: controller.commentController,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.grey[200]
                                      : Colors.black87,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Share your thoughts...',
                                  hintStyle: TextStyle(
                                    color: isDark
                                        ? Colors.grey[500]
                                        : Colors.grey[400],
                                    fontSize: 14,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: controller.addComment,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.primary.withValues(alpha: 0.8),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Iconsax.send_1,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Related Articles Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Related Articles',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : Colors.grey[800],
                            ),
                          ),
                          Icon(
                            Iconsax.arrow_right_3,
                            size: 18,
                            color: isDark ? Colors.grey[400] : Colors.grey[500],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Related Articles List
                      Obx(() {
                        if (controller.isLoadingRelated.value) {
                          return const SizedBox(
                            height: 240,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (controller.relatedNews.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return SizedBox(
                          height: 240,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: controller.relatedNews.length,
                            itemBuilder: (context, index) {
                              final item = controller.relatedNews[index];
                              return _buildRelatedArticle(item);
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),

      // Bottom Action Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF15161C) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              // Back Button
              SizedBox(
                width: 90,
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(
                      color: isDark
                          ? const Color(0xFF2B2D36)
                          : Colors.grey[200]!,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.arrow_left,
                        size: 16,
                        color: isDark ? Colors.grey[300] : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Back',
                        style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Action Buttons
              Obx(() {
                // Extremely defensive null checks
                final newsVal = controller.news.value;
                final liked = controller.isLiked.value;
                final count = controller.likeCount.value;

                if (newsVal == null) return const SizedBox.shrink();

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Like Button
                    _buildActionButton(
                      icon: liked ? Icons.favorite : Icons.favorite_border,
                      label: '$count',
                      isActive: liked,
                      activeColor: Colors.red,
                      onPressed: () => controller.toggleLike(),
                    ),
                    const SizedBox(width: 8),

                    // Share Button
                    _buildActionButton(
                      icon: Iconsax.share,
                      label: 'Share',
                      onPressed: () => controller.shareNews(),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _overlayCircleAction({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
  }) {
    return Material(
      color: Colors.black.withValues(alpha: 0.28),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 20, color: iconColor),
        ),
      ),
    );
  }

  String _estimateReadTime(String content) {
    final wordCount = content
        .trim()
        .split(RegExp(r'\\s+'))
        .where((value) => value.isNotEmpty)
        .length;
    final minutes = (wordCount / 220).ceil();
    return '${minutes < 1 ? 1 : minutes} min read';
  }

  Widget _buildRelatedArticle(NewsModel related) {
    final isDark = Get.isDarkMode;
    return GestureDetector(
      onTap: () => Get.toNamed(
        '/news-detail',
        arguments: related,
        preventDuplicates: false,
      ),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1D24) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF2B2D36) : const Color(0xFFE9ECF1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Container(
                height: 120,
                width: double.infinity,
                color: AppColors.primary.withValues(alpha: 0.1),
                child: related.image != null
                    ? Image.network(
                        related.image!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Icon(
                            Iconsax.image,
                            size: 40,
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          Iconsax.image,
                          size: 40,
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    related.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.grey[800],
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Iconsax.eye, size: 12, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        '${related.views}',
                        style: TextStyle(color: Colors.grey[500], fontSize: 11),
                      ),
                      const SizedBox(width: 8),
                      Icon(Iconsax.clock, size: 12, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        related.createdAtFormatted,
                        style: TextStyle(color: Colors.grey[500], fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsSection(NewsModel news) {
    final isDark = Get.isDarkMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Iconsax.document_text_1, color: AppColors.primary, size: 24),
            const SizedBox(width: 12),
            Text(
              'Attached Documents',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1D24) : Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF2B2D36) : Colors.grey[200]!,
            ),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: news.documents.length,
            separatorBuilder: (context, index) =>
                Divider(height: 1, color: Colors.grey[200]),
            itemBuilder: (context, index) {
              final doc = news.documents[index];
              return ListTile(
                onTap: () => controller.openDocument(doc.url),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getFileIcon(doc.name),
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                title: Text(
                  doc.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                subtitle: Text(
                  doc.url.split('.').last.toUpperCase(),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                trailing: Icon(
                  Iconsax.import_1,
                  color: Colors.grey[400],
                  size: 20,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _getFileIcon(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return Iconsax.document_text;
      case 'doc':
      case 'docx':
        return Iconsax.document_1;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Iconsax.image;
      default:
        return Iconsax.document;
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    bool isActive = false,
    Color? activeColor,
    required VoidCallback onPressed,
  }) {
    final effectiveColor = activeColor ?? AppColors.primary;
    final isDark = Get.isDarkMode;
    return Container(
      decoration: BoxDecoration(
        color: isActive
            ? effectiveColor.withValues(alpha: 0.12)
            : (isDark ? const Color(0xFF23252C) : Colors.grey[50]),
        borderRadius: BorderRadius.circular(12),
        border: isActive
            ? Border.all(color: effectiveColor.withValues(alpha: 0.3))
            : Border.all(
                color: isDark ? const Color(0xFF2B2D36) : Colors.grey[200]!,
              ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isActive ? effectiveColor : Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? effectiveColor : Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCommentActions(CommentModel comment) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Iconsax.edit, color: AppColors.primary),
              title: const Text('Edit comment'),
              onTap: () {
                Get.back();
                _showEditCommentDialog(comment);
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.trash, color: Colors.red),
              title: const Text('Delete comment'),
              onTap: () {
                Get.back();
                _confirmDelete(comment);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _commentActionChip({
    required IconData icon,
    required String label,
    Color color = AppColors.primary,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCommentDialog(CommentModel comment) {
    final controller = Get.find<NewsDetailController>();
    final textController = TextEditingController(text: comment.content);
    Get.dialog(
      AlertDialog(
        title: const Text('Edit comment'),
        content: TextField(
          controller: textController,
          maxLines: null,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Update your comment...'),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newText = textController.text.trim();
              if (newText.isNotEmpty) {
                controller.editComment(commentId: comment.id, content: newText);
                Get.back();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(CommentModel comment) {
    final controller = Get.find<NewsDetailController>();
    Get.dialog(
      AlertDialog(
        title: const Text('Delete comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              controller.deleteComment(comment.id);
              Get.back();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
