import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/app_colors.dart';
import '../../../data/models/category_model.dart';
import '../controllers/post_controller.dart';

class PostView extends StatefulWidget {
  const PostView({super.key});

  @override
  State<PostView> createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
  late final PostController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<PostController>()
        ? Get.find<PostController>()
        : Get.put(PostController());
    controller.titleController.addListener(_onTextChanged);
    controller.contentController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    controller.titleController.removeListener(_onTextChanged);
    controller.contentController.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(theme, isDark),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const _ComposerLoading();
          }

          return Form(
            key: controller.formKey,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                    child: _buildComposerHero(isDark),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                    child: _buildTextComposer(
                      label: 'Post title',
                      hint: 'Add a clear headline',
                      icon: Iconsax.edit_2,
                      textController: controller.titleController,
                      maxLines: 1,
                      characterLimit: 100,
                      isDark: isDark,
                      validator: (value) {
                        final hasMedia =
                            controller.imagePath.value.isNotEmpty ||
                            controller.videoPath.value.isNotEmpty;
                        if ((value == null || value.trim().isEmpty) &&
                            !hasMedia) {
                          return 'Title is required when no media is attached';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                    child: _buildTextComposer(
                      label: 'Content',
                      hint: 'Share your update with the community',
                      icon: Iconsax.document_text,
                      textController: controller.contentController,
                      maxLines: 7,
                      characterLimit: 2000,
                      isDark: isDark,
                      validator: (value) {
                        final hasMedia =
                            controller.imagePath.value.isNotEmpty ||
                            controller.videoPath.value.isNotEmpty;
                        if ((value == null || value.trim().isEmpty) &&
                            !hasMedia) {
                          return 'Content is required when no media is attached';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                    child: _buildMediaSection(isDark),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 120),
                    child: _buildCategorySection(isDark),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
      bottomNavigationBar: _buildBottomBar(isDark),
    );
  }

  AppBar _buildAppBar(ThemeData theme, bool isDark) {
    return AppBar(
      elevation: 0,
      backgroundColor: theme.scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      titleSpacing: 6,
      leading: IconButton(
        onPressed: Get.back,
        icon: Container(
          width: 36,
          height: 36,
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
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                colors: [Color(0xFFFFA221), Color(0xFFFF6F3C)],
              ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
            },
            child: const Text(
              'Create Post',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
            ),
          ),
          Text(
            'Publish text, image, or video',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Get.toNamed('/post-preview'),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF23242A) : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Iconsax.eye,
                size: 19,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComposerHero(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF2C2219), Color(0xFF231C16)]
              : const [Color(0xFFFFF1E1), Color(0xFFFFF8EF)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? const Color(0xFF403226) : const Color(0xFFFFE0BB),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFA221), Color(0xFFFF6F3C)],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Iconsax.edit, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create something worth reading',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tip: a title + short media context gets more engagement.',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController textController,
    required int maxLines,
    required int characterLimit,
    required bool isDark,
    required String? Function(String?)? validator,
  }) {
    final currentLength = textController.text.length;

    return _sectionCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.grey[100] : Colors.black87,
                ),
              ),
              const Text(
                ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: textController,
            maxLines: maxLines,
            maxLength: characterLimit,
            validator: validator,
            style: TextStyle(
              fontSize: 14.5,
              height: 1.45,
              color: isDark ? Colors.grey[100] : Colors.black87,
            ),
            buildCounter:
                (
                  BuildContext context, {
                  required int currentLength,
                  required bool isFocused,
                  required int? maxLength,
                }) {
                  return const SizedBox.shrink();
                },
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[500] : Colors.grey[500],
              ),
              filled: true,
              fillColor: isDark
                  ? const Color(0xFF23252D)
                  : const Color(0xFFF6F7F9),
              contentPadding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: isDark
                      ? const Color(0xFF2E3038)
                      : const Color(0xFFE6E8ED),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$currentLength/$characterLimit',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: currentLength > characterLimit
                    ? Colors.red
                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaSection(bool isDark) {
    final hasImage = controller.imagePath.value.isNotEmpty;
    final hasVideo = controller.videoPath.value.isNotEmpty;

    return _sectionCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Iconsax.gallery,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Media',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.grey[100] : Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(optional)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _MediaSelectTile(
            icon: Iconsax.image,
            title: hasImage
                ? _fileNameFromPath(controller.imagePath.value)
                : 'Pick image',
            subtitle: 'JPG, PNG',
            accent: const Color(0xFF2F80ED),
            isDark: isDark,
            trailingIcon: hasImage ? Iconsax.close_circle : Iconsax.gallery_add,
            onTap: hasImage
                ? () => controller.imagePath.value = ''
                : () => controller.pickImage(),
          ),
          const SizedBox(height: 10),
          _MediaSelectTile(
            icon: Iconsax.video_play,
            title: hasVideo
                ? _fileNameFromPath(controller.videoPath.value)
                : 'Pick video',
            subtitle: 'Max 5 min',
            accent: const Color(0xFFE74C3C),
            isDark: isDark,
            trailingIcon: hasVideo ? Iconsax.close_circle : Iconsax.video_add,
            onTap: hasVideo
                ? () => controller.videoPath.value = ''
                : () => controller.pickVideo(),
          ),
          if (hasImage || hasVideo) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF23252D)
                    : const Color(0xFFF6F7F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (hasImage)
                    _MediaChip(
                      icon: Iconsax.image,
                      label: _fileNameFromPath(controller.imagePath.value),
                      color: const Color(0xFF2F80ED),
                      isDark: isDark,
                    ),
                  if (hasVideo)
                    _MediaChip(
                      icon: Iconsax.video_play,
                      label: _fileNameFromPath(controller.videoPath.value),
                      color: const Color(0xFFE74C3C),
                      isDark: isDark,
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategorySection(bool isDark) {
    if (controller.categories.isEmpty) {
      return _sectionCard(
        isDark: isDark,
        child: Row(
          children: [
            Icon(Iconsax.warning_2, size: 18, color: Colors.orange[500]),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'No categories available. Pull to refresh or retry.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
            ),
            TextButton(
              onPressed: controller.fetchCategories,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final selected =
        controller.categories.any(
          (item) => item.id == controller.selectedCategory.value?.id,
        )
        ? controller.selectedCategory.value
        : controller.categories.first;

    if (controller.selectedCategory.value == null && selected != null) {
      controller.selectedCategory.value = selected;
    }

    return _sectionCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Iconsax.category,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Category',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.grey[100] : Colors.black87,
                ),
              ),
              const Text(
                ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<CategoryModel>(
            initialValue: selected,
            isExpanded: true,
            icon: Icon(
              Iconsax.arrow_down_1,
              size: 16,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[100] : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark
                  ? const Color(0xFF23252D)
                  : const Color(0xFFF6F7F9),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: isDark
                      ? const Color(0xFF2E3038)
                      : const Color(0xFFE6E8ED),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.2,
                ),
              ),
            ),
            items: controller.categories.map((cat) {
              return DropdownMenuItem<CategoryModel>(
                value: cat,
                child: Text(cat.name),
              );
            }).toList(),
            onChanged: (cat) {
              if (cat != null) {
                controller.selectedCategory.value = cat;
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF14151A) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF262932) : const Color(0xFFE8EBF0),
            ),
          ),
        ),
        child: Obx(() {
          final hasMedia =
              controller.imagePath.value.isNotEmpty ||
              controller.videoPath.value.isNotEmpty;
          final hasText =
              controller.titleController.text.trim().isNotEmpty ||
              controller.contentController.text.trim().isNotEmpty;
          final canPublish =
              (hasText || hasMedia) &&
              controller.selectedCategory.value != null &&
              !controller.isPublishing.value;

          return Row(
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  controller.titleController.clear();
                  controller.contentController.clear();
                  controller.clearMedia();
                  FocusScope.of(context).unfocus();
                  setState(() {});
                },
                icon: const Icon(Iconsax.trash, size: 17),
                label: const Text('Reset'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? Colors.grey[100] : Colors.black87,
                  side: BorderSide(
                    color: isDark
                        ? const Color(0xFF2B2D35)
                        : const Color(0xFFD8DCE3),
                  ),
                  minimumSize: const Size(100, 46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: canPublish ? controller.submitPost : null,
                  icon: controller.isPublishing.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Iconsax.send_1, size: 17),
                  label: Text(
                    controller.isPublishing.value ? 'Publishing...' : 'Publish',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(46),
                    disabledBackgroundColor: AppColors.primary.withValues(
                      alpha: 0.4,
                    ),
                    disabledForegroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _sectionCard({required bool isDark, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B1C22) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF2B2D35) : const Color(0xFFE9EBF0),
        ),
      ),
      child: child,
    );
  }

  String _fileNameFromPath(String path) {
    if (path.trim().isEmpty) {
      return '';
    }
    final parts = path.replaceAll('\\', '/').split('/');
    return parts.isNotEmpty ? parts.last : path;
  }
}

class _MediaSelectTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final bool isDark;
  final IconData trailingIcon;
  final VoidCallback onTap;

  const _MediaSelectTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.isDark,
    required this.trailingIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF23252D) : const Color(0xFFF6F7F9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? const Color(0xFF2E3038) : const Color(0xFFE6E8ED),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 17, color: accent),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.grey[100] : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              trailingIcon,
              size: 18,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;

  const _MediaChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComposerLoading extends StatelessWidget {
  const _ComposerLoading();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
      itemCount: 5,
      itemBuilder: (_, index) {
        final height = index == 0 ? 120.0 : 160.0;
        return Container(
          height: height,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
            ),
          ),
        );
      },
    );
  }
}
