import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:university_news_app/app/modules/add-friend/views/add_friend_view.dart';
import 'package:university_news_app/app/modules/profile/views/profile_view.dart';
import 'package:university_news_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:university_news_app/app/config.dart';

import '../../../../core/app_colors.dart';
import '../../../data/models/news_model.dart';
import '../../../data/models/video/views/video_player_screen.dart';
import '../../goods/views/goods_view.dart';
import '../../post/views/post_view.dart';
import '../../my-posts/views/my_posts_view.dart';
import '../controllers/home_controller.dart';
import '../../story/controllers/story_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  static final StoryController storyController = Get.put(StoryController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<Widget> tabs = [
      _buildNewsTab(),
      const GoodsView(),
      PostView(),
      const AddFriendView(),
      const MyPostsView(),
      ProfileView(),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Obx(
        () =>
            IndexedStack(index: controller.selectedIndex.value, children: tabs),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ===================== BOTTOM NAVIGATION BAR =====================
  Widget _buildBottomNavBar() {
    return Obx(() {
      final isDark = Get.isDarkMode;
      return SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: Get.theme.cardColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.18 : 0.06),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _buildNavItem(Iconsax.home_2, 'Home', 0)),
              Expanded(child: _buildNavItem(Iconsax.shop, 'Favorite', 1)),
              // Expanded(child: _buildNavItem(Iconsax.add_circle, 'Post', 2)),
              Expanded(child: _buildNavItem(Iconsax.people, 'Add Friend', 3)),
              Expanded(child: _buildNavItem(Iconsax.document, 'My Posts', 4)),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isActive = controller.selectedIndex.value == index;
    final bool isDark = Get.isDarkMode;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => controller.changeTab(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(isDark ? 0.25 : 0.16),
                    Colors.orange.withOpacity(isDark ? 0.2 : 0.1),
                  ],
                )
              : null,
          color: isActive ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isActive
                  ? AppColors.primary
                  : (isDark ? Colors.grey[300] : Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isActive
                    ? AppColors.primary
                    : (isDark ? Colors.grey[300] : Colors.grey[600]),
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== NEWS TAB =====================
  Widget _buildNewsTab() {
    return Obx(
      () => RefreshIndicator(
        onRefresh: controller.refreshPosts,
        color: AppColors.primary,
        backgroundColor: Get.theme.scaffoldBackgroundColor,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            _buildAppBar(),
            if (controller.isLoading.value)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(AppColors.primary),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading latest news...',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              )
            else if (controller.newsList.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.document, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'No news available at the moment.',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Check back later for updates',
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildListDelegate([
                  // Featured News Slider
                  _buildFeaturedSlider(),
                  // Regular News List
                  ...controller.newsList.map((news) {
                    return Container(
                      margin: const EdgeInsets.only(
                        bottom: 20,
                        left: 20,
                        right: 20,
                      ),
                      child: ModernNewsCard(news: news),
                    );
                  }).toList(),
                ]),
              ),
          ],
        ),
      ),
    );
  }

  // ===================== FEATURED NEWS SLIDER =====================
  Widget _buildFeaturedSlider() {
    // Get featured news (first 5 items or any logic you want)
    final featuredNews = controller.newsList.take(5).toList();
    final isDark = Get.isDarkMode;

    if (featuredNews.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                width: 5,
                height: 22,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Featured Spotlight',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const Spacer(),
              Obx(
                () => Text(
                  '${controller.currentSliderIndex.value + 1}/${featuredNews.take(3).length}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        CarouselSlider(
          options: CarouselOptions(
            height: 210,
            aspectRatio: 16 / 9,
            viewportFraction: 0.88,
            initialPage: 0,
            enableInfiniteScroll: true,
            reverse: false,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            enlargeFactor: 0.22,
            scrollDirection: Axis.horizontal,
            onPageChanged: (index, reason) {
              controller.currentSliderIndex.value = index;
            },
          ),
          items: featuredNews.take(3).map((news) {
            return _buildSliderItem(news);
          }).toList(),
        ),
        const SizedBox(height: 10),
        // Dots Indicator
        Obx(() {
          final sliderItems = featuredNews.take(3).toList();
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: sliderItems.asMap().entries.map((entry) {
              final isActive = controller.currentSliderIndex.value == entry.key;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: controller.currentSliderIndex.value == entry.key
                    ? 22
                    : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: isActive
                      ? AppColors.primary
                      : (isDark ? Colors.grey[700] : Colors.grey[300]),
                ),
              );
            }).toList(),
          );
        }),
        const SizedBox(height: 22),
      ],
    );
  }

  Widget _buildSliderItem(NewsModel news) {
    return GestureDetector(
      onTap: () => Get.toNamed('/news-detail', arguments: news),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              CachedNetworkImage(
                imageUrl: news.image ?? '',
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.primary.withOpacity(0.1),
                  child: const Center(
                    child: Icon(Iconsax.gallery, size: 50, color: Colors.white),
                  ),
                ),
              ),

              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                    ],
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Badge
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          news.categoryName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Title
                    Text(
                      news.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Author & Date
                    Row(
                      children: [
                        if (news.authorAvatar != null)
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: news.authorAvatar!,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.white24,
                                  child: const Icon(
                                    Iconsax.user,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                news.authorName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (news.createdAt != null)
                                Text(
                                  news.createdAtFormatted,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 11,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Read Time/Views
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Iconsax.eye,
                                size: 12,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${news.views}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Featured Badge
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(Iconsax.star, size: 12, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Featured',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
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

  // ===================== APP BAR =====================
  SliverAppBar _buildAppBar() {
    final isDark = Get.isDarkMode;

    return SliverAppBar(
      expandedHeight: 250,
      floating: false,
      pinned: true,
      snap: false,
      elevation: 0,
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleSpacing: 20,
      title: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: [AppColors.primary, Colors.orange, Colors.red],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds),
        child: const Text(
          'news app',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
      ),
      actions: [
        _buildHeaderAction(
          icon: Iconsax.notification,
          onTap: () => Get.toNamed('/notifications'),
        ),
        _buildHeaderAction(
          icon: Iconsax.message,
          onTap: () => Get.toNamed('/chat'),
        ),
        _buildHeaderAction(
          icon: Iconsax.info_circle,
          onTap: () => Get.toNamed('/about'),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: GestureDetector(
            onTap: () => Get.toNamed('/profile'),
            child: Obx(() {
              final user = Get.find<AuthController>().user.value;
              final backgroundColor = isDark
                  ? Colors.grey[850]!
                  : Colors.grey[100]!;
              if (user != null &&
                  user.avatar != null &&
                  user.avatar!.isNotEmpty) {
                String avatarUrl = user.avatar!;
                if (avatarUrl.startsWith('http')) {
                  avatarUrl = AppConfig.transformUrl(avatarUrl);
                } else {
                  avatarUrl = '${AppConfig.imageUrl}/$avatarUrl';
                }
                return Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(avatarUrl),
                    onBackgroundImageError: (e, s) =>
                        debugPrint('AppBar avatar error: $e'),
                  ),
                );
              }
              return Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Iconsax.user,
                  color: isDark ? Colors.grey[300] : Colors.black54,
                  size: 20,
                ),
              );
            }),
          ),
        ),
      ],
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          // Prevent overflow while the SliverAppBar collapses.
          final showExpandedContent = constraints.maxHeight > 205;
          return FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    isDark ? const Color(0xFF1E1F24) : const Color(0xFFFFF7EF),
                    isDark
                        ? const Color(0xFF131418)
                        : Get.theme.scaffoldBackgroundColor,
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 53, 20, 14),
                  child: showExpandedContent
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFFFA726),
                                    Color(0xFFFF7043),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.withOpacity(
                                      isDark ? 0.22 : 0.3,
                                    ),
                                    blurRadius: 22,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _getGreeting(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Explore trending posts and campus stories.',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.92,
                                            ),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Iconsax.flash_1,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildStoriesRow(),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderAction({
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
            color: isDark ? Colors.grey[850] : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isDark ? Colors.white : Colors.black87,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildStoriesRow() {
    return Obx(() {
      final isDark = Get.isDarkMode;
      final stories = storyController.stories;
      if (stories.isEmpty) {
        return const SizedBox.shrink();
      }
      return SizedBox(
        height: 84,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: stories.length + 1,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => storyController.pickAndPostStory(),
                    child: Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E1F24)
                              : Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 23,
                          backgroundColor: isDark
                              ? Colors.grey[850]
                              : AppColors.primary.withOpacity(0.1),
                          child: const Icon(
                            Iconsax.add,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Add Story',
                    style: TextStyle(
                      color: isDark ? Colors.grey[300] : Colors.black87,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            }

            final story = stories[index - 1];
            final user = story.user;
            final initials = user.name.isNotEmpty ? user.name[0] : '?';
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => Get.toNamed('/story-view', arguments: story),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.pinkAccent,
                          Colors.orangeAccent,
                          Colors.yellowAccent,
                          Colors.greenAccent,
                          Colors.blueAccent,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1F24) : Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 23,
                        backgroundColor: isDark
                            ? Colors.grey[850]
                            : AppColors.primary.withOpacity(0.1),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(23),
                          child: CachedNetworkImage(
                            imageUrl: user.avatar ?? '',
                            fit: BoxFit.cover,
                            width: 46,
                            height: 46,
                            placeholder: (context, url) => Text(
                              initials,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            errorWidget: (context, url, error) => Text(
                              initials,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 56,
                  child: Text(
                    user.name.isEmpty ? 'Unknown' : user.name,
                    style: TextStyle(
                      color: isDark ? Colors.grey[200] : Colors.black87,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            );
          },
        ),
      );
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

// ===================== MODERN NEWS CARD =====================
class ModernNewsCard extends StatefulWidget {
  final NewsModel news;
  const ModernNewsCard({super.key, required this.news});

  @override
  State<ModernNewsCard> createState() => _ModernNewsCardState();
}

class _ModernNewsCardState extends State<ModernNewsCard> {
  bool isLiked = false;
  bool isGood = false;
  int likeCount = 0;

  @override
  void initState() {
    super.initState();
    // Initialize with actual values from news model
    likeCount = widget.news.views; // Using views as initial likes for demo
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => Get.toNamed('/news-detail', arguments: widget.news),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.grey[850]! : Colors.grey[200]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE WITH OVERLAY
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: Stack(
                children: [
                  // IMAGE
                  Container(
                    height: 180,
                    width: double.infinity,
                    color: isDark ? Colors.grey[850] : Colors.grey[100],
                    child: CachedNetworkImage(
                      imageUrl: widget.news.image ?? '',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(AppColors.primary),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.primary.withOpacity(0.1),
                        child: Center(
                          child: Icon(
                            Iconsax.gallery,
                            size: 50,
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ▶ VIDEO PLAY BUTTON (ONLY IF VIDEO EXISTS)
                  if (widget.news.video != null &&
                      widget.news.video!.isNotEmpty)
                    Positioned.fill(
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            // Debug: Print video URL
                            debugPrint(
                              '🎥 Opening video player with URL: ${widget.news.video}',
                            );

                            // Validate URL before opening
                            if (widget.news.video!.isEmpty) {
                              Get.snackbar(
                                'Error',
                                'Video URL is empty',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                              return;
                            }

                            Get.to(
                              () => VideoPlayerScreen(
                                videoUrl: widget.news.video!,
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // CONTENT
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TITLE
                  Text(
                    widget.news.title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  // AUTHOR & DATE
                  Row(
                    children: [
                      // AUTHOR AVATAR
                      if (widget.news.authorAvatar != null)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: widget.news.authorAvatar!,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => Container(
                                color: AppColors.primary.withOpacity(0.1),
                                child: Icon(
                                  Iconsax.user,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withOpacity(0.1),
                          ),
                          child: Icon(
                            Iconsax.user,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ),

                      // AUTHOR INFO
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.news.authorName,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey[300]
                                    : Colors.grey[700],
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (widget.news.createdAt != null)
                              Text(
                                widget.news.createdAtFormatted,
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // EXCERPT
                  Text(
                    widget.news.content,
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 13,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 16),

                  // ACTION BUTTONS ROW
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // VIEWS
                        Row(
                          children: [
                            Icon(
                              Iconsax.eye,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[500],
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${widget.news.views}',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey[300]
                                    : Colors.grey[600],
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        // ACTION BUTTONS
                        Row(
                          children: [
                            // LIKE BUTTON
                            InkWell(
                              onTap: () {
                                setState(() {
                                  isLiked = !isLiked;
                                  likeCount += isLiked ? 1 : -1;
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isLiked
                                      ? Colors.red.withOpacity(0.1)
                                      : (isDark
                                            ? Colors.grey[800]
                                            : Colors.grey.withOpacity(0.1)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isLiked ? Iconsax.heart : Iconsax.heart,
                                      color: isLiked
                                          ? Colors.red
                                          : (isDark
                                                ? Colors.grey[300]
                                                : Colors.grey[600]),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '$likeCount',
                                      style: TextStyle(
                                        color: isLiked
                                            ? Colors.red
                                            : (isDark
                                                  ? Colors.grey[300]
                                                  : Colors.grey[600]),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            // BOOKMARK BUTTON
                            InkWell(
                              onTap: () {
                                setState(() {
                                  isGood = !isGood;
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isGood
                                      ? AppColors.primary.withOpacity(0.1)
                                      : (isDark
                                            ? Colors.grey[800]
                                            : Colors.grey.withOpacity(0.1)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  isGood ? Iconsax.shop : Iconsax.shop,
                                  color: isGood
                                      ? AppColors.primary
                                      : (isDark
                                            ? Colors.grey[300]
                                            : Colors.grey[600]),
                                  size: 18,
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            // SHARE BUTTON
                            InkWell(
                              onTap: () {
                                // Share functionality
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.grey[800]
                                      : Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Iconsax.share,
                                  color: isDark
                                      ? Colors.grey[300]
                                      : Colors.grey[600],
                                  size: 18,
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
          ],
        ),
      ),
    );
  }
}
