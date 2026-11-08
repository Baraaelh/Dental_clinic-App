class AppConstants {
  const AppConstants._();

  static const String usersCollection = 'users';
  static const String dentistsCollection = 'dentists';
  static const String servicesCollection = 'services';
  static const String appointmentsCollection = 'appointments';
  static const String reviewsCollection = 'reviews';
  static const String notificationsCollection = 'notifications';
  static const String bookedSlotsCollection = 'booked_slots';

  static const String rolePatient = 'patient';
  static const String roleAdmin = 'admin';

  static const String statusPending = 'Pending';
  static const String statusApproved = 'Approved';
  static const String statusRejected = 'Rejected';
  static const String statusCompleted = 'Completed';
  static const String statusCancelled = 'Cancelled';

  static const int pageSize = 10;
  static const int featuredDentistsCount = 3;
  static const int recentAppointmentsCount = 5;
  static const int recentReviewsCount = 5;

  static const String onboardingShownKey = 'onboarding_shown';
  static const String rememberMeKey = 'remember_me';
  static const String savedEmailKey = 'saved_email';
  static const String themeModeKey = 'theme_mode';
  static const String localeKey = 'locale';
  static const String notificationsEnabledKey = 'notifications_enabled';

  static const String storageProfileImages = 'profile_images';
  static const String storageDentistImages = 'dentist_images';
  static const String storageServiceImages = 'service_images';

  static const String defaultProfileImage =
      'https://ui-avatars.com/api/?background=1565C0&color=fff&name=';

  static const double clinicLatitude = 24.7136;
  static const double clinicLongitude = 46.6753;
  static const String clinicPhone = '+966500000000';
  static const String clinicEmail = 'info@dentalclinic.com';
  static const String clinicWhatsApp = '966500000000';

  static const List<String> weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const String workStartTime = '09:00';
  static const String workEndTime = '17:00';
  static const int slotDurationMinutes = 30;

  static const Duration firestoreTimeout = Duration(seconds: 15);
}
