import 'package:get/get.dart';

import '../modules/lsa_verification/binding/lsa_verification_binding.dart';
import '../modules/lsa_verification/view/lsa_verification_screen.dart';
import '../modules/login/binding/login_binding.dart';
import '../modules/login/view/login_view.dart';
import 'app_routes.dart';

class AppPages {
  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.lsaVerification,
      page: () => const LsaVerificationScreen(),
      binding: LsaVerificationBinding(),
    ),
  ];
}
