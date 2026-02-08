import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:university_news_app/app/modules/profile/views/profile_view.dart';

import '../../../../core/app_colors.dart';
import '../../../data/models/news_model.dart';
import '../../../data/models/video/views/video_player_screen.dart';
import '../../about/views/about_view.dart';
import '../../goods/views/goods_view.dart';
import '../../post/views/post_view.dart';
import '../controllers/home_controller.dart';
import '../../story/controllers/story_controller.dart';
import '../../../data/models/story_model.dart';

import '../../category/views/category_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  static final StoryController storyController = Get.put(StoryController());

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      _buildNewsTab(),
      const CategoryView(),
      PostView(),
      const GoodsView(),
      ProfileView(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(
        () =>
            IndexedStack(index: controller.selectedIndex.value, children: tabs),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ===================== BOTTOM NAVIGATION BAR =====================
  Widget _buildBottomNavBar() {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(Iconsax.home_2, 'Home', 0),
              _buildNavItem(Iconsax.category_2, 'Categories', 1),
              _buildNavItem(Iconsax.add_circle, 'Post', 2),
              _buildNavItem(Iconsax.shop, 'Goods', 3),
              _buildNavItem(Iconsax.profile_circle, 'Profile', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isActive = controller.selectedIndex.value == index;

    return GestureDetector(
      onTap: () => controller.changeTab(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: isActive ? AppColors.primary : Colors.grey[600],
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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
        backgroundColor: Colors.white,
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

    if (featuredNews.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const SizedBox(height: 16),
        CarouselSlider(
          options: CarouselOptions(
            height: 200,
            aspectRatio: 16 / 9,
            viewportFraction: 0.9,
            initialPage: 0,
            enableInfiniteScroll: true,
            reverse: false,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            enlargeFactor: 0.3,
            scrollDirection: Axis.horizontal,
            onPageChanged: (index, reason) {
              controller.currentSliderIndex.value = index;
            },
          ),
          items: featuredNews.take(3).map((news) {
            return _buildSliderItem(news);
          }).toList(),
        ),
        const SizedBox(height: 8),
        // Dots Indicator
        Obx(() {
          final sliderItems = featuredNews.take(3).toList();
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: sliderItems.asMap().entries.map((entry) {
              return Container(
                width: controller.currentSliderIndex.value == entry.key
                    ? 20
                    : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: controller.currentSliderIndex.value == entry.key
                      ? AppColors.primary
                      : AppColors.primary.withOpacity(0.4),
                ),
              );
            }).toList(),
          );
        }),
        const SizedBox(height: 24),
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
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(
                                  news.authorAvatar!,
                                ),
                                fit: BoxFit.cover,
                              ),
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
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
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      snap: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: Padding(
        padding: const EdgeInsets.only(left: 20, top: 16),
        child: CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.2),
          radius: 20,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(top: 16, right: 10),
          child: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.2),
            radius: 20,
            child: IconButton(
              icon: const Icon(
                Iconsax.notification,
                color: Colors.white,
                size: 22,
              ),
              onPressed: () {
                Get.toNamed('/notifications');
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16, right: 10),
          child: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.2),
            radius: 20,
            child: IconButton(
              icon: const Icon(Iconsax.message, color: Colors.white, size: 22),
              onPressed: () {
                Get.toNamed('/chat');
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16, right: 20),
          child: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.2),
            radius: 20,
            child: IconButton(
              icon: const Icon(
                Iconsax.info_circle,
                color: Colors.white,
                size: 22,
              ),
              onPressed: () {
                Get.toNamed('/about');
              },
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.9),
                AppColors.primary.withOpacity(0.8),
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 50, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _getGreeting(),
                    key: ValueKey(_getGreeting()),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'PSBU News',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                _buildStoriesRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoriesRow() {
    return Obx(() {
      final stories = storyController.stories;
      if (stories.isEmpty) {
        return const SizedBox.shrink();
      }
      return SizedBox(
        height: 78,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: stories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final story = stories[index];
            final user = story.user;
            final initials = user.name.isNotEmpty ? user.name[0] : '?';
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => Get.toNamed('/story-view', arguments: story),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      backgroundImage:
                          user.avatar == null || user.avatar!.isEmpty
                              ? null
                              : CachedNetworkImageProvider(user.avatar!),
                      child: user.avatar == null || user.avatar!.isEmpty
                          ? Text(
                              initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 56,
                  child: Text(
                    user.name.isEmpty ? 'Unknown' : user.name,
                    style: const TextStyle(
                      color: Colors.white,
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
    if (hour < 12) return 'Good Morning! ☀️';
    if (hour < 17) return 'Good Afternoon! 🌤️';
    return 'Good Evening! 🌙';
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
    return GestureDetector(
      onTap: () => Get.toNamed('/news-detail', arguments: widget.news),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                    color: Colors.grey[100],
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
                            print(
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
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                      color: Colors.black87,
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
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(
                                widget.news.authorAvatar!,
                              ),
                              fit: BoxFit.cover,
                            ),
                            border: Border.all(color: Colors.white, width: 2),
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
                                color: Colors.grey[700],
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
                      color: Colors.grey[600],
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
                        top: BorderSide(color: Colors.grey[200]!, width: 1),
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
                              color: Colors.grey[500],
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${widget.news.views}',
                              style: TextStyle(
                                color: Colors.grey[600],
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
                                      : Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isLiked ? Iconsax.heart : Iconsax.heart,
                                      color: isLiked
                                          ? Colors.red
                                          : Colors.grey[600],
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '$likeCount',
                                      style: TextStyle(
                                        color: isLiked
                                            ? Colors.red
                                            : Colors.grey[600],
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
                                      : Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  isGood ? Iconsax.shop : Iconsax.shop,
                                  color: isGood
                                      ? AppColors.primary
                                      : Colors.grey[600],
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
                                  color: Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Iconsax.share,
                                  color: Colors.grey[600],
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
