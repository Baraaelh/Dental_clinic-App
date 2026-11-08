import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graduation/features/appointments/presentation/screens/payment_screen.dart';
import 'package:graduation/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

Widget _app(Locale locale) {
  Intl.defaultLocale = locale.languageCode; // as main.dart does
  DateFormat.useNativeDigitsByDefaultFor('ar', false);
  return ProviderScope(
    child: MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: PaymentScreen(
        dentistId: 'd1',
        dentistName: 'Sara',
        date: DateTime(2026, 12, 15),
        time: '10:30',
        patientId: 'p1',
        patientName: 'Ali',
      ),
    ),
  );
}

void main() {
  testWidgets('Arabic: translated summary, pay-at-clinic is the default',
      (tester) async {
    await tester.pumpWidget(_app(const Locale('ar')));
    await tester.pumpAndSettle();

    expect(find.text('الدفع'), findsOneWidget); // app bar
    expect(find.text('د. Sara'), findsOneWidget);
    expect(find.textContaining('ديسمبر'), findsOneWidget); // Arabic month
    expect(find.textContaining('15'), findsOneWidget); // Latin digits
    expect(find.text('20 د.أ'), findsOneWidget);
    expect(find.text('الدفع في العيادة'), findsOneWidget);
    // Card form is hidden until the card option is chosen.
    expect(find.text('رقم البطاقة'), findsNothing);
    expect(find.text('تأكيد الحجز'), findsOneWidget);

    // No leftover English UI text.
    for (final english in [
      'Payment',
      'Appointment Summary',
      'Deposit Amount',
      'Secured & encrypted payment',
    ]) {
      expect(find.text(english), findsNothing, reason: english);
    }
  });

  testWidgets('Arabic: card option shows the demo notice and validates',
      (tester) async {
    await tester.pumpWidget(_app(const Locale('ar')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('دفع العربون بالبطاقة'));
    await tester.pumpAndSettle();

    final l10n = lookupAppLocalizations(const Locale('ar'));
    expect(find.text(l10n.demoPaymentNotice), findsOneWidget);
    expect(find.text('رقم البطاقة'), findsOneWidget);

    // Submitting empty shows Arabic validation errors, not English ones.
    final payButton = find.text(l10n.payDepositButton('20 د.أ'));
    await tester.ensureVisible(payButton);
    await tester.tap(payButton);
    await tester.pumpAndSettle();
    expect(find.text(l10n.cardNumberRequired), findsOneWidget);
    expect(find.text(l10n.cvvRequired), findsOneWidget);
    expect(find.text('Card number is required'), findsNothing);

    // A number that fails the Luhn check is rejected.
    await tester.enterText(
        find.widgetWithText(TextFormField, 'رقم البطاقة'), '1234567812345678');
    await tester.tap(payButton);
    await tester.pumpAndSettle();
    expect(find.text(l10n.cardNumberInvalid), findsOneWidget);

    await tester.enterText(
        find.widgetWithText(TextFormField, 'رقم البطاقة'), '4242424242424242');
    await tester.tap(payButton);
    await tester.pumpAndSettle();
    expect(find.text(l10n.cardNumberInvalid), findsNothing);
  });

  testWidgets('English still works', (tester) async {
    await tester.pumpWidget(_app(const Locale('en')));
    await tester.pumpAndSettle();
    expect(find.text('Payment'), findsOneWidget);
    expect(find.text('Dr. Sara'), findsOneWidget);
    expect(find.textContaining('December'), findsOneWidget);
    expect(find.text('20 JD'), findsOneWidget);
  });
}
