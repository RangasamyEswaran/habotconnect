import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum VerificationStatus {
  idle,
  processing,
  quarantined,
  success,
}

class LineageException implements Exception {
  const LineageException(this.message);

  final String message;

  @override
  String toString() => message;
}

class LsaVerificationController extends GetxController {
  static const _endpointUrl = 'https://api.habotconnect.com/v1/compliance/verify';
  static const _traceId = '8f3d1b2a-4c9e-4a11-b8d2-9901ef23a011';
  static const _logicHash = 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';

  final lsaId = 'LSA-7049'.obs;
  final parentConsentCode = ''.obs;
  final predecessorId = 'PRED-9982-XYZ'.obs;
  final currentStatus = VerificationStatus.idle.obs;
  final formLocked = false.obs;
  final systemMessage = ''.obs;

  final parentConsentFocusNode = FocusNode();
  final parentConsentController = TextEditingController();

  DateTime? _focusStartedAt;
  Timer? _frictionTimer;

  @override
  void onInit() {
    super.onInit();
    parentConsentFocusNode.addListener(_handleParentConsentFocusChange);
  }

  @override
  void onClose() {
    _frictionTimer?.cancel();
    parentConsentFocusNode.removeListener(_handleParentConsentFocusChange);
    parentConsentFocusNode.dispose();
    parentConsentController.dispose();
    super.onClose();
  }

  void _handleParentConsentFocusChange() {
    if (parentConsentFocusNode.hasFocus) {
      _focusStartedAt = DateTime.now().toUtc();
      _startFrictionTimer();
    } else {
      _cancelFrictionTimer();
    }
  }

  void _startFrictionTimer() {
    _cancelFrictionTimer();
    _frictionTimer = Timer(const Duration(seconds: 5), () {
      if (!parentConsentFocusNode.hasFocus || formLocked.value) {
        return;
      }

      final duration = DateTime.now().toUtc().difference(_focusStartedAt ?? DateTime.now().toUtc());
      final seconds = (duration.inMilliseconds / 1000).toStringAsFixed(1);

      debugPrint(
        '[UI_FRICTION_LOG] Timestamp: ${DateTime.now().toUtc().toIso8601String()} | Field: parent_consent_code | Hesitation Duration: ${seconds}s',
      );
    });
  }

  void _cancelFrictionTimer() {
    _frictionTimer?.cancel();
    _frictionTimer = null;
  }

  void updateParentConsentCode(String value) {
    if (formLocked.value) {
      return;
    }
    _cancelFrictionTimer();
    final upperValue = value.toUpperCase().trim();
    parentConsentCode.value = upperValue;
    parentConsentController.text = upperValue;
  }

  void resetToInitialState() {
    _cancelFrictionTimer();
    parentConsentCode.value = '';
    parentConsentController.clear();
    currentStatus.value = VerificationStatus.idle;
    formLocked.value = false;
    systemMessage.value = '';
    parentConsentFocusNode.unfocus();
    update();
  }

  void resetFormState() {
    _cancelFrictionTimer();
    parentConsentCode.value = '';
    currentStatus.value = VerificationStatus.quarantined;
    systemMessage.value = 'Data Quarantined – Compliance Failure';
  }

  void purgeVolatileMemory() {
    _cancelFrictionTimer();
    parentConsentCode.value = '';
    systemMessage.value = 'Data Quarantined – Compliance Failure';
  }

  void handleLineageFailure({bool lockForm = false}) {
    purgeVolatileMemory();
    formLocked.value = lockForm;
    currentStatus.value = VerificationStatus.quarantined;
    systemMessage.value = 'Data Quarantined – Compliance Failure';
  }

  void showValidationErrorPopup(String errorMessage) {
    Get.defaultDialog(
      barrierDismissible: false,      radius: 24,
      backgroundColor: Colors.white,
      titlePadding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      title: '',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFCA5A5), Color(0xFFEF4444)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.close_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Validation Failed',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Get.back();
                resetToInitialState();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? validateSubmissionForm() {
    final trimmedLsaId = lsaId.value.trim();
    final trimmedPredecessorId = predecessorId.value.trim();
    final trimmedConsentCode = parentConsentController.text.trim();

    if (trimmedConsentCode.isEmpty) {
      return 'Parent consent code cannot be empty.';
    }

    if (trimmedLsaId.isEmpty) {
      return 'LSA ID is required.';
    }

    if (trimmedPredecessorId.isEmpty) {
      return 'Predecessor lineage is missing.';
    }

    final consentPattern = RegExp(r'^PCC-\d{4}-\d{4,}$');
    if (!consentPattern.hasMatch(trimmedConsentCode)) {
      return 'Parent consent code format is invalid. Use PCC-YYYY-NNNN.';
    }

    return null;
  }

  Future<void> submitVerification() async {
    _cancelFrictionTimer();

    if (currentStatus.value == VerificationStatus.processing) {
      return;
    }

    final validationMessage = validateSubmissionForm();
    if (validationMessage != null) {
      currentStatus.value = VerificationStatus.quarantined;
      systemMessage.value = 'Data Quarantined – Compliance Failure';
      formLocked.value = false;
      showValidationErrorPopup(validationMessage);
      return;
    }

    if (predecessorId.value.trim().isEmpty) {
      currentStatus.value = VerificationStatus.quarantined;
      systemMessage.value = 'Data Quarantined – Compliance Failure';
      formLocked.value = false;
      throw const LineageException('Lineage missing: predecessor_id is required.');
    }

    currentStatus.value = VerificationStatus.processing;
    systemMessage.value = 'Verifying compliance metadata...';

    // Smooth professional delay before final outcome popup.
    await Future.delayed(const Duration(seconds: 2));

    final requestUrl = Uri.parse(_endpointUrl);
    final requestBody = {
      'predecessor_id': predecessorId.value,
      'lsa_id': lsaId.value,
      'parent_consent_code': parentConsentController.text.trim(),
      'timestamp_utc': DateTime.now().toUtc().toIso8601String(),
    };

    // Mock / commented API call for local test compliance flow.
    debugPrint('API Metadata: x-trace-id=$_traceId | x-logic-hash=$_logicHash');
    debugPrint('API Request URL: ${requestUrl.toString()}');
    debugPrint('API Request Payload: ${jsonEncode(requestBody)}');

    // final response = await http.post(
    //   requestUrl,
    //   headers: {
    //     'Content-Type': 'application/json',
    //     'Accept': 'application/json',
    //     'Host': 'api.habotconnect.com',
    //     'x-trace-id': _traceId,
    //     'x-logic-hash': _logicHash,
    //   },
    //   body: jsonEncode(requestBody),
    // ).timeout(const Duration(seconds: 12));
    //
    // debugPrint('API Response Status: ${response.statusCode}');
    // debugPrint('API Response Body: ${response.body}');
    //
    // Map<String, dynamic>? responseBody;
    // try {
    //   final decoded = jsonDecode(response.body);
    //   if (decoded is Map<String, dynamic>) {
    //     responseBody = decoded;
    //   }
    // } catch (_) {
    //   responseBody = null;
    // }
    //
    // final isNullResponse = responseBody == null || responseBody['status'] == null;
    // final isServerFailure = response.statusCode >= 500;

    final simulatedResponse = {
      'status': 'success',
      'message': 'Compliance verified successfully',
    };
    final simulatedStatusCode = 200;

    debugPrint('API Response Status: $simulatedStatusCode');
    debugPrint('API Response Body: ${jsonEncode(simulatedResponse)}');

    if (simulatedStatusCode >= 200 && simulatedStatusCode < 300) {
      currentStatus.value = VerificationStatus.success;
      formLocked.value = false;
      systemMessage.value = 'Verification succeeded.';

      Get.defaultDialog(
        barrierDismissible: false,
        radius: 24,
        backgroundColor: Colors.white,
        titlePadding: const EdgeInsets.only(top: 20, left: 20, right: 20),
        contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        title: '',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Compliance Verified',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'The LSA onboarding compliance check passed successfully for ${lsaId.value}.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  resetToInitialState();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D4ED8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
      return;
    }

    handleLineageFailure(lockForm: true);
    showValidationErrorPopup('Data Quarantined – Compliance Failure. Please contact support if this persists.');
  }
}
