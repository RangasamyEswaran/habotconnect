import 'package:get/get.dart';

class LoginController extends GetxController {
  final email = ''.obs;
  final password = ''.obs;
  final isLoading = false.obs;

  void updateEmail(String value) => email.value = value;

  void updatePassword(String value) => password.value = value;

  Future<void> login() async {
    if (email.value.trim().isEmpty || password.value.trim().isEmpty) {
      Get.snackbar('Validation', 'Email and password are required.');
      return;
    }

    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500));
    isLoading.value = false;

    Get.snackbar('Success', 'Login successful');
  }
}
