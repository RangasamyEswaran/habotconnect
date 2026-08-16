import 'package:get/get.dart';

import '../controller/lsa_verification_controller.dart';

class LsaVerificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LsaVerificationController>(() => LsaVerificationController());
  }
}
