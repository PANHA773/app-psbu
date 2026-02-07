import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/app_colors.dart';
import '../controllers/post_controller.dart';
import '../../../data/models/category_model.dart';

class PostView extends StatefulWidget {
  const PostView({super.key});

  @override
  State<PostView> createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
  final PostController controller = Get.put(PostController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Obx(() {
          if (controller.isLoading.value) {
            return _buildLoadingState();
          }

          return Form(
            key: controller.formKey,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildHeader(),
                    const SizedBox(height: 8),
                    _buildTextFieldSection(
                      controller.titleController,
                      'Post Title',
                      Iconsax.edit_2,
                      maxLines: 1,
                      isRequired: true,
                      characterLimit: 100,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Title is required'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    _buildTextFieldSection(
                      controller.contentController,
                      'What would you like to share?',
                      Iconsax.document_text,
                      maxLines: 8,
                      isRequired: true,
                      characterLimit: 2000,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Content is required'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    _buildMediaSection(),
                    const SizedBox(height: 20),
                    _buildCategorySection(),
                    const SizedBox(height: 32),
                    _buildPublishButton(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
      bottomNavigationBar: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () {
                controller.titleController.clear();
                controller.contentController.clear();
                controller.imageController.clear();
                controller.videoController.clear();
              },
              icon: Icon(Iconsax.trash, color: Colors.grey[600]),
              tooltip: 'Clear All',
            ),
            IconButton(
              onPressed: () {}, // TODO: Implement Draft
              icon: Icon(Iconsax.save_2, color: Colors.grey[600]),
              tooltip: 'Save Draft',
            ),
            IconButton(
              onPressed: () {}, // TODO: Implement Media Picker
              icon: Icon(Iconsax.gallery_add, color: Colors.grey[600]),
              tooltip: 'Add Media',
            ),
          ],
        ),
      ),
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
            'Create Post',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          Text(
            'Share your thoughts',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
      centerTitle: false,
      actions: [
        IconButton(
          onPressed: () {
            Get.toNamed('/post-preview');
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Iconsax.eye, size: 22, color: Colors.black87),
          ),
          tooltip: 'Preview',
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(25, 6, 190, 150),
                  Color.fromARGB(51, 6, 190, 150),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Iconsax.edit, size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          const Text(
            'Loading editor...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color.fromARGB(13, 6, 190, 150), Colors.white],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color.fromARGB(25, 6, 190, 150), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Iconsax.info_circle,
              size: 24,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Amazing Content',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Share your knowledge, experiences, or thoughts with the community.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldSection(
    TextEditingController textController,
    String hintText,
    IconData icon, {
    int maxLines = 1,
    bool isRequired = false,
    int characterLimit = 0,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(8, 0, 0, 0),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 12, bottom: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(25, 6, 190, 150),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Text(
                  hintText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                if (isRequired)
                  Text(
                    ' *',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextFormField(
              controller: textController,
              maxLines: maxLines,
              validator: validator,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'Enter your $hintText...',
                hintStyle: TextStyle(fontSize: 15, color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) {
                if (characterLimit > 0) {
                  setState(() {});
                }
              },
            ),
          ),
          if (characterLimit > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16, bottom: 12),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${textController.text.length}/$characterLimit',
                  style: TextStyle(
                    fontSize: 12,
                    color: textController.text.length > characterLimit
                        ? Colors.red
                        : Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMediaSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(8, 0, 0, 0),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16),
            child: Text(
              'Add Media (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Image URL Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!, width: 1),
                    ),
                    child: TextField(
                      controller: controller.imageController,
                      decoration: InputDecoration(
                        hintText: 'Image URL (optional)',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Iconsax.image,
                          color: Colors.grey[500],
                        ),
                        suffixIcon: controller.imageController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  controller.imageController.clear();
                                  setState(() {});
                                },
                                icon: Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Colors.grey[500],
                                ),
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(13, 33, 150, 243),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Iconsax.gallery_add,
                    size: 22,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Video URL Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!, width: 1),
                    ),
                    child: TextField(
                      controller: controller.videoController,
                      decoration: InputDecoration(
                        hintText: 'Video URL (optional)',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Iconsax.video,
                          color: Colors.grey[500],
                        ),
                        suffixIcon: controller.videoController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  controller.videoController.clear();
                                  setState(() {});
                                },
                                icon: Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Colors.grey[500],
                                ),
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(13, 244, 67, 54),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Iconsax.video_add,
                    size: 22,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Media Preview
          if (controller.imageController.text.isNotEmpty ||
              controller.videoController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Media Preview:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!, width: 1),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: controller.imageController.text.isNotEmpty
                                ? Color.fromARGB(13, 33, 150, 243)
                                : Color.fromARGB(13, 244, 67, 54),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                          ),
                          child: Icon(
                            controller.imageController.text.isNotEmpty
                                ? Iconsax.image
                                : Iconsax.video,
                            color: controller.imageController.text.isNotEmpty
                                ? Colors.blue
                                : Colors.red,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.imageController.text.isNotEmpty
                                    ? 'Image URL'
                                    : 'Video URL',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                controller.imageController.text.isNotEmpty
                                    ? controller.imageController.text
                                    : controller.videoController.text,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[500],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _infoBox({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(8, 0, 0, 0),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildCategorySection() {
    return Obx(() {
      if (controller.isLoading.value && controller.categories.isEmpty) {
        return _infoBox(
          child: const Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Loading categories...'),
            ],
          ),
        );
      }

      if (controller.categories.isEmpty) {
        return _infoBox(
          child: Row(
            children: [
              Icon(Iconsax.warning_2, color: Colors.orange[400], size: 20),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'No categories available',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        );
      }

      final selected =
          controller.selectedCategory.value ?? controller.categories.first;

      return _infoBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Category *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<CategoryModel>(
              initialValue: selected,
              isExpanded: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              icon: Icon(Icons.arrow_drop_down, color: Colors.grey[500]),
              items: controller.categories.map((cat) {
                return DropdownMenuItem<CategoryModel>(
                  value: cat,
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Color.fromARGB(25, 6, 190, 150),
                        ),
                        child: Icon(
                          Iconsax.category,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          cat.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (cat) {
                if (cat != null) controller.selectedCategory.value = cat;
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPublishButton() {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(77, 6, 190, 150),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: controller.isPublishing.value
              ? null
              : controller.submitPost,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: controller.isPublishing.value
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Publishing...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Iconsax.send, size: 20),
                    const SizedBox(width: 10),
                    const Text(
                      'Publish Post',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(51, 255, 255, 255),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'POST',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // Helper Methods
}
