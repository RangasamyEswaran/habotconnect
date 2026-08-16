import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controller/lsa_verification_controller.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final upperText = newValue.text.toUpperCase();
    return newValue.copyWith(
      text: upperText,
      selection: TextSelection.collapsed(offset: upperText.length),
    );
  }
}

class LsaVerificationScreen extends GetView<LsaVerificationController> {
  const LsaVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8FAFF),
              Color(0xFFEFF4FF),
              Color(0xFFF5F7FB),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1D4ED8).withValues(alpha: 0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ------------------------------------------------------------------
                      // Header / Brand section
                      // ------------------------------------------------------------------
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF2563EB),
                                  Color(0xFF1D4ED8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(
                              Icons.verified_user_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'LSA Onboarding Gate',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'HabotConnect Data Compliance',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFF5B6478),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // ------------------------------------------------------------------
                      // System state / status banner
                      // ------------------------------------------------------------------
                      Obx(() {
                        final status = controller.currentStatus.value;
                        final statusConfig = _statusConfig(status);

                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: statusConfig['bgColor'] as Color,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: statusConfig['borderColor'] as Color,
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  statusConfig['icon'] as IconData,
                                  color: statusConfig['textColor'] as Color,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  statusConfig['label'] as String,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: statusConfig['textColor'] as Color,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 18),

                      Obx(() {
                        final message = controller.systemMessage.value;
                        if (message.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 18),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: controller.currentStatus.value ==
                                    VerificationStatus.success
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: controller.currentStatus.value ==
                                      VerificationStatus.success
                                  ? const Color(0xFF86EFAC)
                                  : const Color(0xFFFCA5A5),
                            ),
                          ),
                          child: Text(
                            message,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: controller.currentStatus.value ==
                                      VerificationStatus.success
                                  ? const Color(0xFF166534)
                                  : const Color(0xFFB91C1C),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }),

                      // ------------------------------------------------------------------
                      // Form section
                      // ------------------------------------------------------------------
                      _buildFieldLabel(theme, 'LSA ID'),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: controller.lsaId.value,
                        readOnly: true,
                        decoration: _fieldDecoration(
                          hintText: 'LSA-7049',
                          prefixIcon: Icons.badge_rounded,
                          fillColor: const Color(0xFFF8FAFC),
                        ),
                      ),

                      const SizedBox(height: 18),

                      _buildFieldLabel(theme, 'Parent Consent Code'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: controller.parentConsentController,
                        focusNode: controller.parentConsentFocusNode,
                        onChanged: (value) {
                          controller.updateParentConsentCode(value);
                        },
                        enabled: !controller.formLocked.value,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          UpperCaseTextFormatter(),
                        ],
                        decoration: _fieldDecoration(
                          hintText: 'Enter consent code',
                          prefixIcon: Icons.key_rounded,
                        ),
                      ),

                      const SizedBox(height: 18),

                      _buildFieldLabel(theme, 'Predecessor ID'),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: controller.predecessorId.value,
                        readOnly: true,
                        decoration: _fieldDecoration(
                          hintText: 'PRED-9982-XYZ',
                          prefixIcon: Icons.lock_rounded,
                          fillColor: const Color(0xFFF8FAFC),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ------------------------------------------------------------------
                      // Action button
                      // ------------------------------------------------------------------
                      SizedBox(
                        width: double.infinity,
                        child: Obx(
                          () {
                            final hasConsentCode =
                                controller.parentConsentCode.value.trim().isNotEmpty;

                            return FilledButton.icon(
                              onPressed:
                                  controller.formLocked.value ||
                                          controller.currentStatus.value ==
                                              VerificationStatus.processing ||
                                          !hasConsentCode
                                      ? null
                                      : controller.submitVerification,
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: const Color(0xFF1D4ED8),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              icon: controller.currentStatus.value ==
                                      VerificationStatus.processing
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.check_circle_outline_rounded),
                              label: Text(
                                controller.currentStatus.value ==
                                        VerificationStatus.processing
                                    ? 'Processing...'
                                    : 'Verify & Submit',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Helper widgets and styling
  // --------------------------------------------------------------------------
  Widget _buildFieldLabel(ThemeData theme, String label) {
    return Text(
      label,
      style: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1F2937),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String hintText,
    required IconData prefixIcon,
    Color fillColor = Colors.white,
  }) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: fillColor,
      prefixIcon: Icon(prefixIcon, color: const Color(0xFF64748B), size: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
    );
  }

  Map<String, dynamic> _statusConfig(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.idle:
        return {
          'label': 'Idle',
          'bgColor': const Color(0xFFE2E8F0),
          'borderColor': const Color(0xFFCBD5E1),
          'textColor': const Color(0xFF334155),
          'icon': Icons.info_outline_rounded,
        };
      case VerificationStatus.processing:
        return {
          'label': 'Processing',
          'bgColor': const Color(0xFFDBEAFE),
          'borderColor': const Color(0xFF93C5FD),
          'textColor': const Color(0xFF1D4ED8),
          'icon': Icons.autorenew_rounded,
        };
      case VerificationStatus.quarantined:
        return {
          'label': 'Quarantined (Fail-Closed)',
          'bgColor': const Color(0xFFFEE2E2),
          'borderColor': const Color(0xFFFCA5A5),
          'textColor': const Color(0xFFB91C1C),
          'icon': Icons.warning_amber_rounded,
        };
      case VerificationStatus.success:
        return {
          'label': 'Success',
          'bgColor': const Color(0xFFDCFCE7),
          'borderColor': const Color(0xFF86EFAC),
          'textColor': const Color(0xFF166534),
          'icon': Icons.check_circle_rounded,
        };
    }
  }
}
