// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Dental Clinic';

  @override
  String get continueBtn => 'Continue';

  @override
  String get skip => 'Skip';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get confirm => 'Confirm';

  @override
  String get close => 'Close';

  @override
  String get retry => 'Retry';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get ok => 'OK';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get noData => 'No data available';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get noInternetConnection => 'No internet connection';

  @override
  String get refresh => 'Refresh';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get all => 'All';

  @override
  String get viewAll => 'View All';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get submit => 'Submit';

  @override
  String get update => 'Update';

  @override
  String get add => 'Add';

  @override
  String get remove => 'Remove';

  @override
  String get markAllRead => 'Mark all as read';

  @override
  String get optional => 'Optional';

  @override
  String get onboarding1Title => 'Expert Dental Care';

  @override
  String get onboarding1Subtitle =>
      'Connect with the best dental specialists for your needs';

  @override
  String get onboarding2Title => 'Easy Booking';

  @override
  String get onboarding2Subtitle =>
      'Schedule appointments with just a few taps';

  @override
  String get onboarding3Title => 'Track Your Health';

  @override
  String get onboarding3Subtitle =>
      'Manage your dental history and appointments in one place';

  @override
  String get getStarted => 'Get Started';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirmTitle => 'Logout';

  @override
  String get logoutConfirmMessage => 'Are you sure you want to logout?';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'Enter your email';

  @override
  String get password => 'Password';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get confirmPasswordHint => 'Re-enter your password';

  @override
  String get fullName => 'Full Name';

  @override
  String get fullNameHint => 'Enter your full name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get phoneNumberHint => 'Enter your phone number';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get forgotPasswordTitle => 'Forgot Password';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email to receive a reset link';

  @override
  String get sendResetEmail => 'Send Reset Email';

  @override
  String get resetEmailSent =>
      'Password reset email sent. Please check your inbox.';

  @override
  String get noAccount => 'Don\'t have an account? ';

  @override
  String get haveAccount => 'Already have an account? ';

  @override
  String get signUp => 'Sign Up';

  @override
  String get signIn => 'Sign In';

  @override
  String get verifyEmailTitle => 'Verify Your Email';

  @override
  String get verifyEmailMessage =>
      'A verification email has been sent to your email address. Please verify before logging in.';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emailInvalid => 'Please enter a valid email';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordTooShort => 'Password must be at least 8 characters';

  @override
  String get passwordNeedsUppercase =>
      'Password must contain at least one uppercase letter';

  @override
  String get passwordNeedsNumber => 'Password must contain at least one number';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get nameTooShort => 'Name must be at least 2 characters';

  @override
  String get phoneRequired => 'Phone number is required';

  @override
  String get phoneInvalid => 'Please enter a valid phone number';

  @override
  String get commentRequired => 'Comment is required';

  @override
  String get commentTooShort => 'Comment must be at least 10 characters';

  @override
  String get welcome => 'Welcome';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get home => 'Home';

  @override
  String get bookAppointment => 'Book Appointment';

  @override
  String get myAppointments => 'My Appointments';

  @override
  String get services => 'Services';

  @override
  String get featuredDentists => 'Featured Dentists';

  @override
  String get clinicServices => 'Clinic Services';

  @override
  String get upcomingAppointment => 'Upcoming Appointment';

  @override
  String get noUpcomingAppointments => 'No upcoming appointments';

  @override
  String get today => 'Today';

  @override
  String get dentists => 'Dentists';

  @override
  String get dentistDetails => 'Dentist Details';

  @override
  String get searchDentists => 'Search dentists...';

  @override
  String get specialization => 'Specialization';

  @override
  String get experience => 'Experience';

  @override
  String experienceYears(int years) {
    return '$years years of experience';
  }

  @override
  String get about => 'About';

  @override
  String get workingDays => 'Working Days';

  @override
  String get workingHours => 'Working Hours';

  @override
  String get averageRating => 'Average Rating';

  @override
  String totalReviews(int count) {
    return '$count reviews';
  }

  @override
  String get noDentists => 'No dentists found';

  @override
  String get noDentistsForFilter => 'No dentists found for this specialization';

  @override
  String get clinicServicesTitle => 'Our Services';

  @override
  String get serviceDetails => 'Service Details';

  @override
  String get price => 'Price';

  @override
  String get noServices => 'No services available';

  @override
  String get selectDate => 'Select Date';

  @override
  String get selectTime => 'Select Time';

  @override
  String get availableSlots => 'Available Slots';

  @override
  String get bookedSlots => 'Already Booked';

  @override
  String get confirmBooking => 'Confirm Booking';

  @override
  String get bookingSuccess => 'Appointment Booked Successfully!';

  @override
  String get bookingSuccessMessage =>
      'Your appointment has been submitted. You will receive a confirmation soon.';

  @override
  String get slotAlreadyBooked =>
      'This time slot is already booked. Please select another.';

  @override
  String get selectDateFirst => 'Please select a date first';

  @override
  String get selectTimeFirst => 'Please select a time slot';

  @override
  String get noSlotsAvailable => 'No time slots available';

  @override
  String get duplicateAppointment =>
      'You already have an appointment at this time';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get history => 'History';

  @override
  String get appointmentDetails => 'Appointment Details';

  @override
  String get dentistName => 'Dentist';

  @override
  String get appointmentDate => 'Date';

  @override
  String get appointmentTime => 'Time';

  @override
  String get appointmentStatus => 'Status';

  @override
  String get cancelAppointment => 'Cancel Appointment';

  @override
  String get cancelAppointmentConfirmTitle => 'Cancel Appointment';

  @override
  String get cancelAppointmentConfirmMessage =>
      'Are you sure you want to cancel this appointment?';

  @override
  String get appointmentCancelled => 'Appointment cancelled successfully';

  @override
  String get noAppointments => 'No appointments found';

  @override
  String get noUpcomingAppointmentsHistory => 'No upcoming appointments';

  @override
  String get noHistoryAppointments => 'No past appointments';

  @override
  String get pending => 'Pending';

  @override
  String get approved => 'Approved';

  @override
  String get rejected => 'Rejected';

  @override
  String get completed => 'Completed';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get statusTimeline => 'Status Timeline';

  @override
  String get appointmentRequested => 'Appointment Requested';

  @override
  String get appointmentReviewed => 'Appointment Reviewed';

  @override
  String get appointmentFinished => 'Appointment Finished';

  @override
  String get reviews => 'Reviews';

  @override
  String get writeReview => 'Write a Review';

  @override
  String get yourRating => 'Your Rating';

  @override
  String get yourComment => 'Your Comment';

  @override
  String get commentHint => 'Share your experience...';

  @override
  String get reviewSubmitted => 'Review submitted successfully';

  @override
  String get noReviews => 'No reviews yet';

  @override
  String get ratingBreakdown => 'Rating Breakdown';

  @override
  String get cannotReview =>
      'You can only review dentists you have completed appointments with';

  @override
  String get alreadyReviewed => 'You have already reviewed this dentist';

  @override
  String get notifications => 'Notifications';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get notificationRead => 'Notification marked as read';

  @override
  String get allNotificationsRead => 'All notifications marked as read';

  @override
  String get profile => 'Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get changePhoto => 'Change Photo';

  @override
  String get changePassword => 'Change Password';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get passwordChanged => 'Password changed successfully';

  @override
  String get profileUpdated => 'Profile updated successfully';

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get callUs => 'Call Us';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get emailUs => 'Email Us';

  @override
  String get location => 'Location';

  @override
  String get followUs => 'Follow Us';

  @override
  String get adminDashboard => 'Admin Dashboard';

  @override
  String get totalPatients => 'Total Patients';

  @override
  String get todaysAppointments => 'Today\'s Appointments';

  @override
  String get pendingApprovals => 'Pending Approvals';

  @override
  String get totalDentists => 'Total Dentists';

  @override
  String get recentAppointments => 'Recent Appointments';

  @override
  String get manageDentists => 'Manage Dentists';

  @override
  String get addDentist => 'Add Dentist';

  @override
  String get editDentist => 'Edit Dentist';

  @override
  String get deleteDentist => 'Delete Dentist';

  @override
  String get deleteDentistConfirm =>
      'Are you sure you want to delete this dentist?';

  @override
  String get dentistAdded => 'Dentist added successfully';

  @override
  String get dentistUpdated => 'Dentist updated successfully';

  @override
  String get dentistDeleted => 'Dentist deleted successfully';

  @override
  String get dentistImage => 'Dentist Image';

  @override
  String get selectWorkingDays => 'Select Working Days';

  @override
  String get startTime => 'Start Time';

  @override
  String get endTime => 'End Time';

  @override
  String get description => 'Description';

  @override
  String get descriptionHint => 'Enter description';

  @override
  String get manageAppointments => 'Manage Appointments';

  @override
  String get approveAppointment => 'Approve';

  @override
  String get rejectAppointment => 'Reject';

  @override
  String get markCompleted => 'Mark Completed';

  @override
  String get appointmentApproved => 'Appointment approved';

  @override
  String get appointmentRejected => 'Appointment rejected';

  @override
  String get appointmentCompleted => 'Appointment marked as completed';

  @override
  String get filterByStatus => 'Filter by Status';

  @override
  String get filterByDentist => 'Filter by Dentist';

  @override
  String get manageServices => 'Manage Services';

  @override
  String get addService => 'Add Service';

  @override
  String get editService => 'Edit Service';

  @override
  String get deleteService => 'Delete Service';

  @override
  String get deleteServiceConfirm =>
      'Are you sure you want to delete this service?';

  @override
  String get serviceAdded => 'Service added successfully';

  @override
  String get serviceUpdated => 'Service updated successfully';

  @override
  String get serviceDeleted => 'Service deleted successfully';

  @override
  String get serviceName => 'Service Name';

  @override
  String get serviceTitle => 'Service Title';

  @override
  String get serviceTitleHint => 'Enter service title';

  @override
  String get servicePrice => 'Price';

  @override
  String get servicePricHint => 'Enter price';

  @override
  String get serviceImage => 'Service Image';

  @override
  String get noUsers => 'No users found';

  @override
  String get manageUsers => 'Manage Users';

  @override
  String get userDetails => 'User Details';

  @override
  String get accountStatus => 'Account Status';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get toggleUserStatus => 'Toggle User Status';

  @override
  String get userActivated => 'User account activated';

  @override
  String get userDeactivated => 'User account deactivated';

  @override
  String get manageReviews => 'Manage Reviews';

  @override
  String get deleteReview => 'Delete Review';

  @override
  String get deleteReviewConfirm =>
      'Are you sure you want to delete this review?';

  @override
  String get reviewDeleted => 'Review deleted successfully';

  @override
  String get statistics => 'Statistics';

  @override
  String get appointmentsPerMonth => 'Appointments Per Month';

  @override
  String get appointmentsByStatus => 'Appointments by Status';

  @override
  String get topRatedDentists => 'Top Rated Dentists';

  @override
  String get topDentists => 'Top Dentists';

  @override
  String get totalAppointments => 'Total Appointments';

  @override
  String get completedAppointments => 'Completed Appointments';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get imagePickerTitle => 'Select Image';

  @override
  String get fromGallery => 'From Gallery';

  @override
  String get fromCamera => 'From Camera';

  @override
  String get uploadingImage => 'Uploading image...';

  @override
  String get deleteConfirmTitle => 'Confirm Delete';

  @override
  String get deleteConfirmMessage =>
      'This action cannot be undone. Are you sure?';

  @override
  String get notificationApproved => 'Your appointment has been approved';

  @override
  String get notificationRejected => 'Your appointment has been rejected';

  @override
  String get notificationCancelled => 'Your appointment has been cancelled';

  @override
  String get notificationReminder => 'Appointment reminder for tomorrow';

  @override
  String get appTagline => 'Your smile, our priority';

  @override
  String get payment => 'Payment';

  @override
  String get appointmentSummary => 'Appointment Summary';

  @override
  String get doctorLabel => 'Doctor';

  @override
  String get dateLabel => 'Date';

  @override
  String get timeLabel => 'Time';

  @override
  String doctorName(String name) {
    return 'Dr. $name';
  }

  @override
  String get depositAmount => 'Deposit Amount';

  @override
  String amountWithCurrency(String amount) {
    return '$amount JD';
  }

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get payAtClinic => 'Pay at the clinic';

  @override
  String get payAtClinicSubtitle => 'Pay the deposit when you arrive';

  @override
  String get payByCard => 'Pay deposit by card';

  @override
  String get payByCardSubtitle => 'Demo mode: no real charge';

  @override
  String get demoPaymentNotice =>
      'Online payment is in demo mode. No card is charged, so please don\'t enter real card details.';

  @override
  String get cardDetails => 'Card Details';

  @override
  String get cardNumber => 'Card Number';

  @override
  String get expiryDate => 'Expiry Date';

  @override
  String get cvv => 'CVV';

  @override
  String get cardNumberRequired => 'Card number is required';

  @override
  String get cardNumberInvalid => 'Enter a valid card number';

  @override
  String get expiryRequired => 'Expiry date is required';

  @override
  String get expiryInvalid => 'Enter a valid expiry (MM/YY)';

  @override
  String get cardExpired => 'Card is expired';

  @override
  String get cvvRequired => 'CVV is required';

  @override
  String get cvvInvalid => 'Enter a valid 3 or 4 digit CVV';

  @override
  String payDepositButton(String amount) {
    return 'Pay Deposit ($amount)';
  }

  @override
  String get paymentSuccessTitle => 'Payment Successful!';

  @override
  String get bookingPendingMessage =>
      'Your appointment has been booked.\nThe clinic will confirm it shortly.';

  @override
  String payAtClinicReminder(String amount) {
    return 'Please pay the deposit ($amount) when you arrive.';
  }

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get appointments => 'Appointments';

  @override
  String get users => 'Users';

  @override
  String get noAppointmentData => 'No appointment data';

  @override
  String get pleaseSelectRating => 'Please select a rating';

  @override
  String get selectAtLeastOneWorkingDay =>
      'Please select at least one working day';

  @override
  String get commentTooLong => 'Comment must be at most 1000 characters';

  @override
  String get ratingPoor => 'Poor';

  @override
  String get ratingFair => 'Fair';

  @override
  String get ratingGood => 'Good';

  @override
  String get ratingVeryGood => 'Very Good';

  @override
  String get ratingExcellent => 'Excellent';

  @override
  String get tapToRate => 'Tap to rate';

  @override
  String get notificationTitleApproved => 'Appointment Approved';

  @override
  String get notificationTitleRejected => 'Appointment Rejected';

  @override
  String get notificationTitleCancelled => 'Appointment Cancelled';

  @override
  String get notificationTitleCompleted => 'Appointment Completed';

  @override
  String get notificationCompleted =>
      'Your appointment has been completed. Thank you for visiting us!';

  @override
  String get errorUserNotFound => 'No account found with this email';

  @override
  String get errorWrongPassword => 'Incorrect password';

  @override
  String get errorInvalidCredential => 'Invalid email or password';

  @override
  String get errorEmailInUse => 'An account already exists with this email';

  @override
  String get errorInvalidEmail => 'Invalid email address';

  @override
  String get errorAccountDisabled =>
      'Your account has been disabled. Please contact the clinic.';

  @override
  String get errorTooManyRequests =>
      'Too many attempts. Please try again later';

  @override
  String get errorWeakPassword => 'Password is too weak';

  @override
  String get errorRequiresRecentLogin =>
      'Please sign in again to complete this action';

  @override
  String get errorProfileSaveFailed =>
      'Could not save your profile. Please check your connection and try again.';

  @override
  String get errorUserDataNotFound =>
      'Account data not found. Please contact the clinic.';

  @override
  String get errorPermissionDenied => 'You don\'t have permission to do this';

  @override
  String get errorNotFound => 'The requested item was not found';

  @override
  String get paid => 'Paid';

  @override
  String get loadMore => 'Load more';

  @override
  String get endTimeAfterStart => 'End time must be after start time';
}
