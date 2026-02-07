import 'package:get/get.dart';
import '../../../data/models/about_model.dart';
import '../../../data/services/about_service.dart';


class AboutController extends GetxController {
  var isLoading = true.obs;
  var errorMessage = ''.obs;
  var about = Rx<AboutModel?>(null);

  final AboutService _service = AboutService();

  @override
  void onInit() {
    super.onInit();
    fetchAbout();
  }

  Future<void> fetchAbout() async {
    try {
      isLoading.value = true;
      final data = await AboutService.fetchAbout();

      about.value = data; // ✅ force update
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

}
