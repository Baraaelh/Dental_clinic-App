import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/errors/error_messages.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../controllers/appointment_controller.dart';

enum _PaymentMethod { clinic, card }

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({
    super.key,
    required this.dentistId,
    required this.dentistName,
    required this.date,
    required this.time,
    required this.patientId,
    required this.patientName,
  });

  final String dentistId;
  final String dentistName;
  final DateTime date;
  final String time;
  final String patientId;
  final String patientName;

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  _PaymentMethod _method = _PaymentMethod.clinic;
  bool _isProcessing = false;
  bool _isSuccess = false;

  @override
  void dispose() {
    _cardCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  String _amount(AppLocalizations l10n) =>
      l10n.amountWithCurrency(AppConfig.depositAmount.toString());

  /// Luhn checksum: catches typos in the card number.
  static bool _passesLuhn(String digits) {
    var sum = 0;
    var doubleIt = false;
    for (var i = digits.length - 1; i >= 0; i--) {
      var d = int.parse(digits[i]);
      if (doubleIt) {
        d *= 2;
        if (d > 9) d -= 9;
      }
      sum += d;
      doubleIt = !doubleIt;
    }
    return sum % 10 == 0;
  }

  String? _validateCard(String? v, AppLocalizations l10n) {
    final digits = (v ?? '').replaceAll(' ', '');
    if (digits.isEmpty) return l10n.cardNumberRequired;
    if (digits.length != 16 || !_passesLuhn(digits)) {
      return l10n.cardNumberInvalid;
    }
    return null;
  }

  String? _validateExpiry(String? v, AppLocalizations l10n) {
    if (v == null || v.isEmpty) return l10n.expiryRequired;
    if (!RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(v)) {
      return l10n.expiryInvalid;
    }
    final parts = v.split('/');
    final month = int.parse(parts[0]);
    final year = 2000 + int.parse(parts[1]);
    final now = DateTime.now();
    if (year < now.year || (year == now.year && month < now.month)) {
      return l10n.cardExpired;
    }
    return null;
  }

  String? _validateCvv(String? v, AppLocalizations l10n) {
    if (v == null || v.isEmpty) return l10n.cvvRequired;
    if (!RegExp(r'^\d{3,4}$').hasMatch(v)) return l10n.cvvInvalid;
    return null;
  }

  Future<void> _submit() async {
    final payByCard = _method == _PaymentMethod.card;
    if (payByCard && !_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);
    // Simulated gateway round-trip (see AppConfig.cardPaymentIsDemo).
    if (payByCard) await Future.delayed(const Duration(milliseconds: 1500));

    try {
      await ref.read(bookAppointmentProvider.notifier).book(
            patientId: widget.patientId,
            patientName: widget.patientName,
            dentistId: widget.dentistId,
            dentistName: widget.dentistName,
            date: widget.date,
            time: widget.time,
            isPaid: payByCard,
          );
      if (mounted) {
        ref.invalidate(upcomingAppointmentProvider(widget.patientId));
        setState(() {
          _isProcessing = false;
          _isSuccess = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.errorMessage(e)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_isSuccess) return _buildSuccess(context, l10n);

    final payByCard = _method == _PaymentMethod.card;
    final sectionTitle = Theme.of(context)
        .textTheme
        .titleSmall
        ?.copyWith(fontWeight: FontWeight.bold);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(l10n.payment),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCard(context, l10n),
              const SizedBox(height: 24),
              Text(l10n.paymentMethod, style: sectionTitle),
              const SizedBox(height: 12),
              _MethodOption(
                icon: Icons.storefront_outlined,
                title: l10n.payAtClinic,
                subtitle: l10n.payAtClinicSubtitle,
                selected: !payByCard,
                onTap: () => setState(() => _method = _PaymentMethod.clinic),
              ),
              const SizedBox(height: 8),
              _MethodOption(
                icon: Icons.credit_card_outlined,
                title: l10n.payByCard,
                subtitle: AppConfig.cardPaymentIsDemo
                    ? l10n.payByCardSubtitle
                    : _amount(l10n),
                selected: payByCard,
                onTap: () => setState(() => _method = _PaymentMethod.card),
              ),
              if (payByCard) ...[
                const SizedBox(height: 20),
                if (AppConfig.cardPaymentIsDemo) ...[
                  _DemoNotice(text: l10n.demoPaymentNotice),
                  const SizedBox(height: 16),
                ],
                Text(l10n.cardDetails, style: sectionTitle),
                const SizedBox(height: 16),
                AppTextField(
                  label: l10n.cardNumber,
                  hint: '0000 0000 0000 0000',
                  controller: _cardCtrl,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.credit_card_outlined),
                  inputFormatters: [_CardNumberFormatter()],
                  validator: (v) => _validateCard(v, l10n),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: l10n.expiryDate,
                        hint: 'MM/YY',
                        controller: _expiryCtrl,
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.date_range_outlined),
                        inputFormatters: [_ExpiryDateFormatter()],
                        validator: (v) => _validateExpiry(v, l10n),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppTextField(
                        label: l10n.cvv,
                        hint: '000',
                        controller: _cvvCtrl,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        prefixIcon: const Icon(Icons.lock_outline),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        validator: (v) => _validateCvv(v, l10n),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 32),
              AppButton(
                label: payByCard
                    ? l10n.payDepositButton(_amount(l10n))
                    : l10n.confirmBooking,
                onPressed: _submit,
                isLoading: _isProcessing,
                icon: payByCard ? Icons.payment : Icons.check,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                l10n.appointmentSummary,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            icon: Icons.person_outline,
            label: l10n.doctorLabel,
            value: l10n.doctorName(widget.dentistName),
          ),
          const SizedBox(height: 6),
          _SummaryRow(
            icon: Icons.calendar_today_outlined,
            label: l10n.dateLabel,
            // Uses the app language (Intl.defaultLocale is set in main.dart).
            value: DateFormat.yMMMMEEEEd().format(widget.date),
          ),
          const SizedBox(height: 6),
          _SummaryRow(
            icon: Icons.access_time_outlined,
            label: l10n.timeLabel,
            value: widget.time,
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.depositAmount,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                _amount(l10n),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess(BuildContext context, AppLocalizations l10n) {
    final paidByCard = _method == _PaymentMethod.card;
    final message = paidByCard
        ? l10n.bookingPendingMessage
        : '${l10n.bookingPendingMessage}\n${l10n.payAtClinicReminder(_amount(l10n))}';
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 60,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                paidByCard ? l10n.paymentSuccessTitle : l10n.bookingSuccess,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 40),
              AppButton(
                label: l10n.myAppointments,
                onPressed: () => context.go('/appointments'),
                icon: Icons.calendar_today,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MethodOption extends StatelessWidget {
  const _MethodOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        selected ? AppColors.primary : Theme.of(context).dividerColor;
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.06)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: selected ? 1.5 : 1),
          ),
          child: Row(
            children: [
              Icon(icon, color: selected ? AppColors.primary : AppColors.textSecondary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? AppColors.primary : AppColors.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoNotice extends StatelessWidget {
  const _DemoNotice({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.warning, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 16) return oldValue;

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final text = buffer.toString();
    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 4) return oldValue;

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(digits[i]);
    }
    final text = buffer.toString();
    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
