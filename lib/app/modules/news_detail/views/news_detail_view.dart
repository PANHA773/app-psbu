import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/news_model.dart';
import '../../../data/models/comment_model.dart';
import '../../../../core/app_colors.dart';
import '../controllers/news_detail_controller.dart';

class NewsDetailView extends GetView<NewsDetailController> {
  const NewsDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
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
              backgroundColor: Colors.transparent,
              leading: Padding(
                padding: const EdgeInsets.only(left: 8, top: 8),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.3),
                  child: IconButton(
                    icon: const Icon(
                      Iconsax.arrow_left_2,
                      color: Colors.white,
                      size: 22,
                    ),
                    onPressed: () => Get.back(),
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8, top: 8),
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.3),
                    child: Obx(
                      () => IconButton(
                        icon: Icon(
                          controller.isGood.value
                              ? Icons
                                    .bookmark_added // Using standard Icons for clarity
                              : Icons.bookmark_add_outlined,
                          color: controller.isGood.value
                              ? Colors.orange
                              : Colors.white,
                          size: 24,
                        ),
                        onPressed: () => controller.toggleGood(),
                      ),
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    // Hero Image
                    CachedNetworkImage(
                      imageUrl: news.image ?? '',
                      width: double.infinity,
                      height: 360,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 360,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.primary.withOpacity(0.1),
                              AppColors.primary.withOpacity(0.05),
                            ],
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 360,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.primary.withOpacity(0.2),
                              AppColors.primary.withOpacity(0.1),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Iconsax.gallery,
                            size: 60,
                            color: AppColors.primary.withOpacity(0.4),
                          ),
                        ),
                      ),
                    ),

                    // Gradient Overlay
                    Container(
                      height: 360,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0],
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
                decoration: const BoxDecoration(
                  color: Colors.white,
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
                      // Category Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          news.categoryName,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Title
                      Text(
                        news.title,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          height: 1.4,
                          color: Colors.black87,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Author & Metadata Row
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey[200]!, width: 1),
                            bottom: BorderSide(
                              color: Colors.grey[200]!,
                              width: 1,
                            ),
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
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
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
                                                  .withOpacity(0.1),
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
                                        color: AppColors.primary.withOpacity(
                                          0.1,
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
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
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
                          fontSize: 16,
                          height: 1.8,
                          color: Colors.grey[700],
                          letterSpacing: 0.3,
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
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
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
                          const Text(
                            'Comments',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
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
                                color: AppColors.primary.withOpacity(0.1),
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
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey[200]!),
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
                            final isMine = c.authorId != null &&
                                c.authorId == controller.currentUserId.value;
                            return GestureDetector(
                              onLongPress:
                                  isMine ? () => _showCommentActions(c) : null,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey[100]!),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
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
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                  color: Colors.black87,
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
                                              color: Colors.grey[700],
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
                                                  onTap: () => _confirmDelete(c),
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: controller.commentController,
                                style: const TextStyle(fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: 'Share your thoughts...',
                                  hintStyle: TextStyle(
                                    color: Colors.grey[400],
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
                                      AppColors.primary.withOpacity(0.8),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
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
                              color: Colors.grey[800],
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'See All',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
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
                    side: BorderSide(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.arrow_left,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Back',
                        style: TextStyle(
                          color: Colors.grey[600],
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

  Widget _buildRelatedArticle(NewsModel related) {
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                color: AppColors.primary.withOpacity(0.1),
                child: related.image != null
                    ? Image.network(
                        related.image!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Icon(
                            Iconsax.image,
                            size: 40,
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          Iconsax.image,
                          size: 40,
                          color: AppColors.primary.withOpacity(0.3),
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
                      color: Colors.grey[800],
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
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
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
                    color: AppColors.primary.withOpacity(0.1),
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
    return Container(
      decoration: BoxDecoration(
        color: isActive ? effectiveColor.withOpacity(0.1) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: isActive
            ? Border.all(color: effectiveColor.withOpacity(0.3))
            : Border.all(color: Colors.grey[200]!),
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
          color: color.withOpacity(0.08),
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
          decoration: const InputDecoration(
            hintText: 'Update your comment...',
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newText = textController.text.trim();
              if (newText.isNotEmpty) {
                controller.editComment(
                  commentId: comment.id,
                  content: newText,
                );
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
        content:
            const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              controller.deleteComment(comment.id);
              Get.back();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
