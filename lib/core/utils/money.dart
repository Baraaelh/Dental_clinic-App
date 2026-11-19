import '../../l10n/app_localizations.dart';

/// Price with the clinic currency in the current language, e.g. "25 JD" /
/// "25 د.أ". Whole amounts drop the decimals; others keep two.
/// The currency label lives in the translations (`amountWithCurrency`).
String formatPrice(AppLocalizations l10n, num price) {
  final amount = price == price.roundToDouble()
      ? price.toStringAsFixed(0)
      : price.toStringAsFixed(2);
  return l10n.amountWithCurrency(amount);
}
