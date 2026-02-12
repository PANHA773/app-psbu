import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/news_model.dart';
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
                              ? Iconsax
                                    .shop // Filled icon for saved state
                              : Iconsax
                                    .shop, // Outline icon for non-saved state
                          color: Colors.white,
                          size: 22,
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
                      const SizedBox(height: 8),
                      Text(
                        'Comments',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Obx(() {
                        final comments = controller.comments;
                        if (comments.isEmpty) {
                          return const Text('No comments yet.', style: TextStyle(color: Colors.grey));
                        }
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: comments.length,
                          separatorBuilder: (context, i) => const Divider(height: 16),
                          itemBuilder: (context, i) {
                            final c = comments[i];
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.grey[200],
                                  child: Icon(Icons.person, size: 16, color: Colors.grey[600]),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(c.authorName ?? 'User', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      const SizedBox(height: 2),
                                      Text(c.content, style: const TextStyle(fontSize: 14)),
                                      const SizedBox(height: 2),
                                      Text(c.createdAtFormatted ?? '', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      }),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: controller.commentController,
                              decoration: InputDecoration(
                                hintText: 'Write a comment...',
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: controller.addComment,
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(12),
                              backgroundColor: AppColors.primary,
                            ),
                            child: const Icon(Icons.send, color: Colors.white, size: 20),
                          ),
                        ],
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
              // Back to Home
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                  icon: Icon(
                    Iconsax.arrow_left,
                    size: 18,
                    color: Colors.grey[600],
                  ),
                  label: Text(
                    'Back',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Action Buttons
              Obx(
                () => Row(
                  children: [
                    // Like Button
                    _buildActionButton(
                      icon: controller.isLiked.value
                          ? Iconsax.heart
                          : Iconsax.heart,
                      label: '${controller.likeCount.value}',
                      isActive: controller.isLiked.value,
                      activeColor: Colors.red,
                      onPressed: () => controller.toggleLike(),
                    ),
                    const SizedBox(width: 12),

                    // Share Button
                    _buildActionButton(
                      icon: Iconsax.share,
                      label: 'Share',
                      onPressed: () => controller.shareNews(),
                    ),
                  ],
                ),
              ),
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
}
