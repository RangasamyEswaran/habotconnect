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
    return Scaffold(
      body: _ScreenBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Obx(
                  () => _VerificationCard(
                    title: 'LSA Onboarding Gate',
                    subtitle: 'HabotConnect Data Compliance',
                    status: controller.currentStatus.value,
                    systemMessage: controller.systemMessage.value,
                    lsaId: controller.lsaId.value,
                    predecessorId: controller.predecessorId.value,
                    consentController: controller.parentConsentController,
                    consentFocusNode: controller.parentConsentFocusNode,
                    consentValue: controller.parentConsentCode.value,
                    isFormLocked: controller.formLocked.value,
                    isProcessing: controller.currentStatus.value ==
                        VerificationStatus.processing,
                    hasConsentValue:
                        controller.parentConsentController.text.trim().isNotEmpty,
                    onConsentChanged: controller.updateParentConsentCode,
                    onSubmit: controller.submitVerification,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScreenBackground extends StatelessWidget {
  const _ScreenBackground({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: child,
    );
  }
}

class _VerificationCard extends StatelessWidget {
  const _VerificationCard({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.systemMessage,
    required this.lsaId,
    required this.predecessorId,
    required this.consentController,
    required this.consentFocusNode,
    required this.consentValue,
    required this.isFormLocked,
    required this.isProcessing,
    required this.hasConsentValue,
    required this.onConsentChanged,
    required this.onSubmit,
  });

  final String title;
  final String subtitle;
  final VerificationStatus status;
  final String systemMessage;
  final String lsaId;
  final String predecessorId;
  final TextEditingController consentController;
  final FocusNode consentFocusNode;
  final String consentValue;
  final bool isFormLocked;
  final bool isProcessing;
  final bool hasConsentValue;
  final ValueChanged<String> onConsentChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
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
          _ScreenHeader(
            title: title,
            subtitle: subtitle,
          ),
          const SizedBox(height: 22),
          _StatusBanner(status: status),
          const SizedBox(height: 18),
          if (systemMessage.isNotEmpty)
            _SystemAlert(
              message: systemMessage,
              isSuccess: status == VerificationStatus.success,
            ),
          const SizedBox(height: 6),
          _FieldLabel(label: 'LSA ID'),
          const SizedBox(height: 8),
          _ReadOnlyField(
            value: lsaId,
            hintText: 'LSA-7049',
            icon: Icons.badge_rounded,
            fillColor: const Color(0xFFF8FAFC),
          ),
          const SizedBox(height: 18),
          _FieldLabel(label: 'Parent Consent Code'),
          const SizedBox(height: 8),
          _ConsentInputField(
            controller: consentController,
            focusNode: consentFocusNode,
            value: consentValue,
            enabled: !isFormLocked,
            hintText: 'Enter consent code',
            onChanged: onConsentChanged,
          ),
          const SizedBox(height: 18),
          _FieldLabel(label: 'Predecessor ID'),
          const SizedBox(height: 8),
          _ReadOnlyField(
            value: predecessorId,
            hintText: 'PRED-9982-XYZ',
            icon: Icons.lock_rounded,
            fillColor: const Color(0xFFF8FAFC),
          ),
          const SizedBox(height: 28),
          _SubmitButton(
            enabled: !isFormLocked && !isProcessing && hasConsentValue,
            isProcessing: isProcessing,
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}

class _ScreenHeader extends StatelessWidget {
  const _ScreenHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF2563EB),
                Color(0xFF1D4ED8),
              ],
            ),
            borderRadius: BorderRadius.all(Radius.circular(18)),
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
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF5B6478),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.status});

  final VerificationStatus status;

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig(status);
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: config['bgColor'] as Color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: config['borderColor'] as Color,
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
              config['icon'] as IconData,
              color: config['textColor'] as Color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              config['label'] as String,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: config['textColor'] as Color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
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

class _SystemAlert extends StatelessWidget {
  const _SystemAlert({
    required this.message,
    required this.isSuccess,
  });

  final String message;
  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isSuccess ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSuccess ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5),
        ),
      ),
      child: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isSuccess ? const Color(0xFF166534) : const Color(0xFFB91C1C),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      label,
      style: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1F2937),
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({
    required this.value,
    required this.hintText,
    required this.icon,
    this.fillColor = Colors.white,
  });

  final String value;
  final String hintText;
  final IconData icon;
  final Color fillColor;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      decoration: _fieldDecoration(
        hintText: hintText,
        prefixIcon: icon,
        fillColor: fillColor,
      ),
    );
  }
}

class _ConsentInputField extends StatelessWidget {
  const _ConsentInputField({
    required this.controller,
    required this.focusNode,
    required this.value,
    required this.enabled,
    required this.hintText,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String value;
  final bool enabled;
  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      enabled: enabled,
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.characters,
      inputFormatters: [UpperCaseTextFormatter()],
      decoration: _fieldDecoration(
        hintText: hintText,
        prefixIcon: Icons.key_rounded,
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.enabled,
    required this.isProcessing,
    required this.onPressed,
  });

  final bool enabled;
  final bool isProcessing;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: const Color(0xFF1D4ED8),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        icon: isProcessing
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
          isProcessing ? 'Processing...' : 'Verify & Submit',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
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
