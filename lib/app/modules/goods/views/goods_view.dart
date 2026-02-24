import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../controllers/goods_controller.dart';
import '../../../data/models/news_model.dart';
import '../../../data/services/auth_service.dart';

class GoodsView extends GetView<GoodsController> {
  const GoodsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const _GoodsLoadingState();
        }

        if (controller.goodsList.isEmpty) {
          return const _EmptyGoodsState();
        }

        return RefreshIndicator(
          onRefresh: controller.refreshGoods,
          color: const Color(0xFFFF8A00),
          child: _buildBody(theme),
        );
      }),
      bottomNavigationBar: _buildBottomActions(theme),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final canPop = Navigator.of(context).canPop();
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      elevation: 0,
      backgroundColor: theme.scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leading: canPop
          ? IconButton(
              onPressed: Get.back,
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF23242A) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            )
          : null,
      titleSpacing: canPop ? 6 : 20,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                colors: [Color(0xFFFF8A00), Color(0xFFFF5A3C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
            },
            child: const Text(
              'Saved Goods',
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
              '${controller.totalItems} items in your collection',
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
        _buildTopAction(icon: Iconsax.refresh, onTap: controller.fetchGoods),
        _buildTopAction(
          icon: Iconsax.filter_remove,
          onTap: () => controller.changeCategory('All'),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildTopAction({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = Get.isDarkMode;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF23242A) : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 19,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    final filtered = controller.filteredGoods;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverToBoxAdapter(child: _buildHeroCard(theme)),
        SliverToBoxAdapter(child: _buildCategoryRail(theme)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
            child: Row(
              children: [
                Container(
                  width: 5,
                  height: 22,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8A00),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Collection',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: theme.textTheme.titleLarge?.color,
                  ),
                ),
                const Spacer(),
                Text(
                  '${filtered.length} visible',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textTheme.bodySmall?.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (filtered.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Text(
                  'No items found in this category.\nTry selecting a different filter.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color?.withValues(
                      alpha: 0.75,
                    ),
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            sliver: SliverList.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final news = filtered[index];
                return _buildGoodItem(theme, news);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildHeroCard(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF2B1E17), Color(0xFF221B18)]
              : const [Color(0xFFFFF1E6), Color(0xFFFFF7F1)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? const Color(0xFF3A302B) : const Color(0xFFFFDFC8),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF8A00), Color(0xFFFF5A3C)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Iconsax.archive, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your saved library',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 6),
                Obx(
                  () => Row(
                    children: [
                      Text(
                        '${controller.totalItems}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? const Color(0xFFFFB46A)
                              : const Color(0xFFEF6C00),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'items',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF3A302B)
                    : const Color(0xFFFFE4D1),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                '${controller.categoryCount} categories',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? const Color(0xFFFFC58D)
                      : const Color(0xFFB85A00),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRail(ThemeData theme) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        children: const [
          _CategoryChip(label: 'All', icon: Iconsax.shop),
          _CategoryChip(label: 'Articles', icon: Iconsax.document),
          _CategoryChip(label: 'Videos', icon: Iconsax.video_play),
          _CategoryChip(label: 'Images', icon: Iconsax.gallery),
          _CategoryChip(label: 'Links', icon: Iconsax.link),
        ],
      ),
    );
  }

  Widget _buildGoodItem(ThemeData theme, NewsModel news) {
    final categoryColor = _getCategoryColor(news.categoryName);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: isDark ? const Color(0xFF1B1C22) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => Get.toNamed('/news-detail', arguments: news),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF2B2D35)
                    : const Color(0xFFEAECEF),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildThumbnail(news.image),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        news.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        news.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.45,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: categoryColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _getCategoryIcon(news.categoryName),
                                  size: 12,
                                  color: categoryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  news.categoryName,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: categoryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Iconsax.clock,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            news.createdAtFormatted,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(99),
                  onTap: () => controller.removeGood(news),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2B2D35)
                          : const Color(0xFFF5F5F7),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Iconsax.trash,
                      size: 16,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
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

  Widget _buildThumbnail(String? imageUrl) {
    final hasImage = imageUrl != null && imageUrl.trim().isNotEmpty;
    final radius = BorderRadius.circular(14);

    return ClipRRect(
      borderRadius: radius,
      child: Container(
        width: 88,
        height: 88,
        color: const Color(0xFFFFEFE3),
        child: hasImage
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildImageFallback(),
              )
            : _buildImageFallback(),
      ),
    );
  }

  Widget _buildImageFallback() {
    return const Center(
      child: Icon(Iconsax.gallery, color: Color(0xFFFF8A00), size: 24),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'articles':
        return const Color(0xFF2979FF);
      case 'videos':
        return const Color(0xFFE53935);
      case 'images':
        return const Color(0xFF00A86B);
      case 'links':
        return const Color(0xFF8E44AD);
      default:
        return const Color(0xFFFF8A00);
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

  Widget _buildBottomActions(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF14151A) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF252730) : const Color(0xFFE9EAEE),
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: controller.fetchGoods,
                icon: const Icon(Iconsax.refresh, size: 18),
                label: const Text('Refresh'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8A00),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => controller.changeCategory('All'),
                icon: const Icon(Iconsax.filter_remove, size: 18),
                label: const Text('Clear Filter'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? Colors.white : Colors.black87,
                  side: BorderSide(
                    color: isDark
                        ? const Color(0xFF2B2D35)
                        : const Color(0xFFD9DCE2),
                  ),
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends GetView<GoodsController> {
  final String label;
  final IconData icon;

  const _CategoryChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Obx(() {
        final isActive = controller.selectedCategory.value == label;
        return InkWell(
          borderRadius: BorderRadius.circular(99),
          onTap: () => controller.changeCategory(label),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              gradient: isActive
                  ? const LinearGradient(
                      colors: [Color(0xFFFF8A00), Color(0xFFFF5A3C)],
                    )
                  : null,
              color: isActive
                  ? null
                  : (isDark
                        ? const Color(0xFF23242A)
                        : const Color(0xFFF3F4F7)),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(
                color: isActive
                    ? Colors.transparent
                    : (isDark
                          ? const Color(0xFF2E3038)
                          : const Color(0xFFE7E9EE)),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: isActive
                      ? Colors.white
                      : (isDark ? Colors.grey[300] : Colors.grey[700]),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive
                        ? Colors.white
                        : (isDark ? Colors.grey[300] : Colors.grey[700]),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _GoodsLoadingState extends StatelessWidget {
  const _GoodsLoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 6,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
      itemBuilder: (_, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      width: double.infinity,
                      color: Colors.grey.withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: 160,
                      color: Colors.grey.withValues(alpha: 0.15),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      height: 24,
                      width: 110,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyGoodsState extends StatelessWidget {
  const _EmptyGoodsState();

  @override
  Widget build(BuildContext context) {
    final isGuest = AuthService.token == 'guest';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isGuest
                      ? const [Color(0xFF8EC5FF), Color(0xFF5A8BFF)]
                      : const [Color(0xFFFFC88D), Color(0xFFFF8A5C)],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isGuest ? Iconsax.login : Iconsax.archive,
                size: 52,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              isGuest ? 'Login Required' : 'Nothing Saved Yet',
              style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(
              isGuest
                  ? 'Please login to access your saved articles, videos, images, and links.'
                  : 'Bookmark items from the feed and they will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: () {
                if (isGuest) {
                  Get.offAllNamed('/login');
                  return;
                }
                Get.back();
              },
              icon: Icon(isGuest ? Iconsax.login : Iconsax.discover),
              label: Text(isGuest ? 'Login Now' : 'Browse Content'),
              style: FilledButton.styleFrom(
                backgroundColor: isGuest
                    ? const Color(0xFF4C7CFF)
                    : const Color(0xFFFF8A00),
                foregroundColor: Colors.white,
                minimumSize: const Size(180, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
