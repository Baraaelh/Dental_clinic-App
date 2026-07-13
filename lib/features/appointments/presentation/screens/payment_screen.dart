import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../controllers/appointment_controller.dart';

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
  bool _isProcessing = false;
  bool _isSuccess = false;

  @override
  void dispose() {
    _cardCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  String? _validateCard(String? v) {
    if (v == null || v.isEmpty) return 'Card number is required';
    if (v.replaceAll(' ', '').length != 16) return 'Enter a valid 16-digit card number';
    return null;
  }

  String? _validateExpiry(String? v) {
    if (v == null || v.isEmpty) return 'Expiry date is required';
    if (!RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(v)) {
      return 'Enter a valid expiry (MM/YY)';
    }
    final parts = v.split('/');
    final month = int.parse(parts[0]);
    final year = 2000 + int.parse(parts[1]);
    final now = DateTime.now();
    if (year < now.year || (year == now.year && month < now.month)) {
      return 'Card is expired';
    }
    return null;
  }

  String? _validateCvv(String? v) {
    if (v == null || v.isEmpty) return 'CVV is required';
    if (!RegExp(r'^\d{3}$').hasMatch(v)) return 'Enter a valid 3-digit CVV';
    return null;
  }

  Future<void> _pay() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));

    try {
      await ref.read(bookAppointmentProvider.notifier).book(
            patientId: widget.patientId,
            patientName: widget.patientName,
            dentistId: widget.dentistId,
            dentistName: widget.dentistName,
            date: widget.date,
            time: widget.time,
            isPaid: true,
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
            content: Text(e.toString().replaceAll('Exception:', '').trim()),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSuccess) return _buildSuccess(context);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Payment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCard(context),
              const SizedBox(height: 24),
              Text(
                'Payment Details',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Card Number',
                hint: '0000 0000 0000 0000',
                controller: _cardCtrl,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.credit_card_outlined),
                inputFormatters: [_CardNumberFormatter()],
                validator: _validateCard,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Expiry Date',
                      hint: 'MM/YY',
                      controller: _expiryCtrl,
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.date_range_outlined),
                      inputFormatters: [_ExpiryDateFormatter()],
                      validator: _validateExpiry,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppTextField(
                      label: 'CVV',
                      hint: '000',
                      controller: _cvvCtrl,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      prefixIcon: const Icon(Icons.lock_outline),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      validator: _validateCvv,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              AppButton(
                label: 'Pay Deposit — 20 JD',
                onPressed: _pay,
                isLoading: _isProcessing,
                icon: Icons.payment,
              ),
              const SizedBox(height: 12),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock, size: 12, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Text(
                      'Secured & encrypted payment',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textHint),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
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
                'Appointment Summary',
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
            label: 'Doctor',
            value: 'Dr. ${widget.dentistName}',
          ),
          const SizedBox(height: 6),
          _SummaryRow(
            icon: Icons.calendar_today_outlined,
            label: 'Date',
            value: DateFormat('EEEE, MMM dd, yyyy').format(widget.date),
          ),
          const SizedBox(height: 6),
          _SummaryRow(
            icon: Icons.access_time_outlined,
            label: 'Time',
            value: widget.time,
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Deposit Amount',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                '20 JD',
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

  Widget _buildSuccess(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                'Payment Successful!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Your appointment has been booked.\nThe clinic will confirm shortly.',
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
