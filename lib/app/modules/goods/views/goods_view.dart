import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../controllers/goods_controller.dart';
import '../../../data/services/auth_service.dart';

class GoodsView extends GetView<GoodsController> {
  const GoodsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.goodsList.isEmpty) {
          return const _EmptyGoodsState();
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchGoods(),
          color: Colors.orange,
          child: _buildBody(),
        );
      }),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.arrow_back_ios_rounded,
            size: 20,
            color: Colors.black87,
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Goods',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Obx(
            () => Text(
              '${controller.totalItems} items',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ),
        ],
      ),
      centerTitle: false,
      actions: [
        IconButton(
          onPressed: () {
            // Search goods
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Iconsax.search_normal,
              size: 22,
              color: Colors.black87,
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            // Filter goods
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Iconsax.filter, size: 22, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Stats Card
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.amber.shade50, Colors.orange.shade50],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Iconsax.shop,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Goods',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Obx(
                            () => Text(
                              '${controller.totalItems} Items',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Obx(
                              () => Text(
                                '${controller.categoryCount} categories',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
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
        ),

        // Categories Tabs
        SliverToBoxAdapter(
          child: Container(
            height: 60,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildCategoryTab('All', Iconsax.shop),
                const SizedBox(width: 8),
                _buildCategoryTab('Articles', Iconsax.document),
                const SizedBox(width: 8),
                _buildCategoryTab('Videos', Iconsax.video_play),
                const SizedBox(width: 8),
                _buildCategoryTab('Images', Iconsax.gallery),
                const SizedBox(width: 8),
                _buildCategoryTab('Links', Iconsax.link),
              ],
            ),
          ),
        ),

        // Recently Added Header (Always shown if not empty)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, top: 20, bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Collection',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Goods List
        Obx(
          () => SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final news = controller.filteredGoods[index];
              return _buildGoodItem(
                title: news.title,
                description: news.content,
                category: news.categoryName,
                time: news.createdAtFormatted,
                imageUrl: news.image ?? '',
                isPinned: false,
                onTap: () {
                  Get.toNamed('/news-detail', arguments: news);
                },
                onRemove: () => controller.removeGood(news),
              );
            }, childCount: controller.filteredGoods.length),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 30)),
      ],
    );
  }

  Widget _buildCategoryTab(String label, IconData icon) {
    return Obx(() {
      final isActive = controller.selectedCategory.value == label;
      return GestureDetector(
        onTap: () => controller.changeCategory(label),
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          child: Chip(
            label: Row(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isActive ? Colors.white : Colors.grey[700],
                ),
                const SizedBox(width: 6),
                Text(label),
              ],
            ),
            backgroundColor: isActive ? Colors.orange : Colors.grey[100],
            labelStyle: TextStyle(
              color: isActive ? Colors.white : Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildGoodItem({
    required String title,
    required String description,
    required String category,
    required String time,
    required String imageUrl,
    required bool isPinned,
    required VoidCallback onTap,
    required VoidCallback onRemove,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.orange.withOpacity(0.1),
          highlightColor: Colors.orange.withOpacity(0.05),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[200]!, width: 1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Thumbnail
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isPinned)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Iconsax.coin,
                                    size: 12,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Pinned',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.orange,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(
                                category,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _getCategoryIcon(category),
                                  size: 12,
                                  color: _getCategoryColor(category),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  category,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _getCategoryColor(category),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Iconsax.clock,
                            size: 14,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            time,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Remove Button
                IconButton(
                  onPressed: onRemove,
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Iconsax.close_circle,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'articles':
        return Colors.blue;
      case 'videos':
        return Colors.red;
      case 'images':
        return Colors.green;
      case 'links':
        return Colors.purple;
      default:
        return Colors.orange;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'articles':
        return Iconsax.document;
      case 'videos':
        return Iconsax.video_play;
      case 'images':
        return Iconsax.gallery;
      case 'links':
        return Iconsax.link;
      default:
        return Iconsax.shop;
    }
  }

  Widget _buildBottomActions() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton.icon(
              onPressed: () {
                // Create collection
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: const Icon(Iconsax.add_circle, size: 20),
              label: const Text(
                'New Good',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Container(width: 1, height: 24, color: Colors.grey[300]),
          Expanded(
            child: TextButton.icon(
              onPressed: () {
                // Share all goods
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: const Icon(Iconsax.share, size: 20),
              label: const Text(
                'Export All',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Optional: Empty State Widget
class _EmptyGoodsState extends StatelessWidget {
  const _EmptyGoodsState();

  @override
  Widget build(BuildContext context) {
    final isGuest = AuthService.token == 'guest';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: (isGuest ? Colors.blue : Colors.orange).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isGuest ? Iconsax.login : Iconsax.shop,
              size: 60,
              color: isGuest ? Colors.blue : Colors.orange,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isGuest ? 'Login Required' : 'No Goods Yet',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              isGuest
                  ? 'Please login to save and view your bookmarked articles, videos, and links.'
                  : 'Save articles, videos, and links that you want to revisit later. '
                        'They will appear here for easy access.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              if (isGuest) {
                Get.offAllNamed('/login');
              } else {
                Get.back(); // Go back to browse
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isGuest ? Colors.blue : Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            icon: Icon(isGuest ? Iconsax.login : Iconsax.discover),
            label: Text(
              isGuest ? 'Login Now' : 'Browse Content',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
