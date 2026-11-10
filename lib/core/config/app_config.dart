class AppConfig {
  const AppConfig._();

  static const String appName = 'Dental Clinic';
  static const String appVersion = '1.0.0';

  static const String clinicName = 'Dental Clinic';
  static const String clinicPhone = '+966500000000';
  static const String clinicEmail = 'info@dentalclinic.com';
  static const String clinicWhatsApp = '966500000000';
  static const double clinicLatitude = 24.7136;
  static const double clinicLongitude = 46.6753;
  static const String clinicAddress = 'Riyadh, Saudi Arabia';

  static const String fcmSenderId = 'YOUR_SENDER_ID';

  /// Booking deposit, shown on the payment screen. The currency label comes
  /// from the translations (`amountWithCurrency`).
  static const int depositAmount = 20;

  /// There is no real payment gateway yet: card payments are simulated and
  /// the screen says so. Connect a gateway (with a server that marks the
  /// appointment as paid) before turning this off.
  static const bool cardPaymentIsDemo = true;
}
