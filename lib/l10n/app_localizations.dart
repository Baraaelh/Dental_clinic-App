import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'Dental Clinic'**
  String get appName;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetConnection;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllRead;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @onboarding1Title.
  ///
  /// In en, this message translates to:
  /// **'Expert Dental Care'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Connect with the best dental specialists for your needs'**
  String get onboarding1Subtitle;

  /// No description provided for @onboarding2Title.
  ///
  /// In en, this message translates to:
  /// **'Easy Booking'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule appointments with just a few taps'**
  String get onboarding2Subtitle;

  /// No description provided for @onboarding3Title.
  ///
  /// In en, this message translates to:
  /// **'Track Your Health'**
  String get onboarding3Title;

  /// No description provided for @onboarding3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your dental history and appointments in one place'**
  String get onboarding3Subtitle;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmMessage;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get emailHint;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get confirmPasswordHint;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get fullNameHint;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @phoneNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get phoneNumberHint;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive a reset link'**
  String get forgotPasswordSubtitle;

  /// No description provided for @sendResetEmail.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Email'**
  String get sendResetEmail;

  /// No description provided for @resetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent. Please check your inbox.'**
  String get resetEmailSent;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccount;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get haveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailMessage.
  ///
  /// In en, this message translates to:
  /// **'A verification email has been sent to your email address. Please verify before logging in.'**
  String get verifyEmailMessage;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get emailInvalid;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordNeedsUppercase.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one uppercase letter'**
  String get passwordNeedsUppercase;

  /// No description provided for @passwordNeedsNumber.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one number'**
  String get passwordNeedsNumber;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @nameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get nameTooShort;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneRequired;

  /// No description provided for @phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get phoneInvalid;

  /// No description provided for @commentRequired.
  ///
  /// In en, this message translates to:
  /// **'Comment is required'**
  String get commentRequired;

  /// No description provided for @commentTooShort.
  ///
  /// In en, this message translates to:
  /// **'Comment must be at least 10 characters'**
  String get commentTooShort;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @bookAppointment.
  ///
  /// In en, this message translates to:
  /// **'Book Appointment'**
  String get bookAppointment;

  /// No description provided for @myAppointments.
  ///
  /// In en, this message translates to:
  /// **'My Appointments'**
  String get myAppointments;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @featuredDentists.
  ///
  /// In en, this message translates to:
  /// **'Featured Dentists'**
  String get featuredDentists;

  /// No description provided for @clinicServices.
  ///
  /// In en, this message translates to:
  /// **'Clinic Services'**
  String get clinicServices;

  /// No description provided for @upcomingAppointment.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Appointment'**
  String get upcomingAppointment;

  /// No description provided for @noUpcomingAppointments.
  ///
  /// In en, this message translates to:
  /// **'No upcoming appointments'**
  String get noUpcomingAppointments;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @dentists.
  ///
  /// In en, this message translates to:
  /// **'Dentists'**
  String get dentists;

  /// No description provided for @dentistDetails.
  ///
  /// In en, this message translates to:
  /// **'Dentist Details'**
  String get dentistDetails;

  /// No description provided for @searchDentists.
  ///
  /// In en, this message translates to:
  /// **'Search dentists...'**
  String get searchDentists;

  /// No description provided for @specialization.
  ///
  /// In en, this message translates to:
  /// **'Specialization'**
  String get specialization;

  /// No description provided for @experience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get experience;

  /// No description provided for @experienceYears.
  ///
  /// In en, this message translates to:
  /// **'{years} years of experience'**
  String experienceYears(int years);

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @workingDays.
  ///
  /// In en, this message translates to:
  /// **'Working Days'**
  String get workingDays;

  /// No description provided for @workingHours.
  ///
  /// In en, this message translates to:
  /// **'Working Hours'**
  String get workingHours;

  /// No description provided for @averageRating.
  ///
  /// In en, this message translates to:
  /// **'Average Rating'**
  String get averageRating;

  /// No description provided for @totalReviews.
  ///
  /// In en, this message translates to:
  /// **'{count} reviews'**
  String totalReviews(int count);

  /// No description provided for @noDentists.
  ///
  /// In en, this message translates to:
  /// **'No dentists found'**
  String get noDentists;

  /// No description provided for @noDentistsForFilter.
  ///
  /// In en, this message translates to:
  /// **'No dentists found for this specialization'**
  String get noDentistsForFilter;

  /// No description provided for @clinicServicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Our Services'**
  String get clinicServicesTitle;

  /// No description provided for @serviceDetails.
  ///
  /// In en, this message translates to:
  /// **'Service Details'**
  String get serviceDetails;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @noServices.
  ///
  /// In en, this message translates to:
  /// **'No services available'**
  String get noServices;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get selectTime;

  /// No description provided for @availableSlots.
  ///
  /// In en, this message translates to:
  /// **'Available Slots'**
  String get availableSlots;

  /// No description provided for @bookedSlots.
  ///
  /// In en, this message translates to:
  /// **'Already Booked'**
  String get bookedSlots;

  /// No description provided for @confirmBooking.
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking'**
  String get confirmBooking;

  /// No description provided for @bookingSuccess.
  ///
  /// In en, this message translates to:
  /// **'Appointment Booked Successfully!'**
  String get bookingSuccess;

  /// No description provided for @bookingSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your appointment has been submitted. You will receive a confirmation soon.'**
  String get bookingSuccessMessage;

  /// No description provided for @slotAlreadyBooked.
  ///
  /// In en, this message translates to:
  /// **'This time slot is already booked. Please select another.'**
  String get slotAlreadyBooked;

  /// No description provided for @selectDateFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a date first'**
  String get selectDateFirst;

  /// No description provided for @selectTimeFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a time slot'**
  String get selectTimeFirst;

  /// No description provided for @noSlotsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No time slots available'**
  String get noSlotsAvailable;

  /// No description provided for @duplicateAppointment.
  ///
  /// In en, this message translates to:
  /// **'You already have an appointment at this time'**
  String get duplicateAppointment;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @appointmentDetails.
  ///
  /// In en, this message translates to:
  /// **'Appointment Details'**
  String get appointmentDetails;

  /// No description provided for @dentistName.
  ///
  /// In en, this message translates to:
  /// **'Dentist'**
  String get dentistName;

  /// No description provided for @appointmentDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get appointmentDate;

  /// No description provided for @appointmentTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get appointmentTime;

  /// No description provided for @appointmentStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get appointmentStatus;

  /// No description provided for @cancelAppointment.
  ///
  /// In en, this message translates to:
  /// **'Cancel Appointment'**
  String get cancelAppointment;

  /// No description provided for @cancelAppointmentConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel Appointment'**
  String get cancelAppointmentConfirmTitle;

  /// No description provided for @cancelAppointmentConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this appointment?'**
  String get cancelAppointmentConfirmMessage;

  /// No description provided for @appointmentCancelled.
  ///
  /// In en, this message translates to:
  /// **'Appointment cancelled successfully'**
  String get appointmentCancelled;

  /// No description provided for @noAppointments.
  ///
  /// In en, this message translates to:
  /// **'No appointments found'**
  String get noAppointments;

  /// No description provided for @noUpcomingAppointmentsHistory.
  ///
  /// In en, this message translates to:
  /// **'No upcoming appointments'**
  String get noUpcomingAppointmentsHistory;

  /// No description provided for @noHistoryAppointments.
  ///
  /// In en, this message translates to:
  /// **'No past appointments'**
  String get noHistoryAppointments;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @statusTimeline.
  ///
  /// In en, this message translates to:
  /// **'Status Timeline'**
  String get statusTimeline;

  /// No description provided for @appointmentRequested.
  ///
  /// In en, this message translates to:
  /// **'Appointment Requested'**
  String get appointmentRequested;

  /// No description provided for @appointmentReviewed.
  ///
  /// In en, this message translates to:
  /// **'Appointment Reviewed'**
  String get appointmentReviewed;

  /// No description provided for @appointmentFinished.
  ///
  /// In en, this message translates to:
  /// **'Appointment Finished'**
  String get appointmentFinished;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @writeReview.
  ///
  /// In en, this message translates to:
  /// **'Write a Review'**
  String get writeReview;

  /// No description provided for @yourRating.
  ///
  /// In en, this message translates to:
  /// **'Your Rating'**
  String get yourRating;

  /// No description provided for @yourComment.
  ///
  /// In en, this message translates to:
  /// **'Your Comment'**
  String get yourComment;

  /// No description provided for @commentHint.
  ///
  /// In en, this message translates to:
  /// **'Share your experience...'**
  String get commentHint;

  /// No description provided for @reviewSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Review submitted successfully'**
  String get reviewSubmitted;

  /// No description provided for @noReviews.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviews;

  /// No description provided for @ratingBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Rating Breakdown'**
  String get ratingBreakdown;

  /// No description provided for @cannotReview.
  ///
  /// In en, this message translates to:
  /// **'You can only review dentists you have completed appointments with'**
  String get cannotReview;

  /// No description provided for @alreadyReviewed.
  ///
  /// In en, this message translates to:
  /// **'You have already reviewed this dentist'**
  String get alreadyReviewed;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @notificationRead.
  ///
  /// In en, this message translates to:
  /// **'Notification marked as read'**
  String get notificationRead;

  /// No description provided for @allNotificationsRead.
  ///
  /// In en, this message translates to:
  /// **'All notifications marked as read'**
  String get allNotificationsRead;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhoto;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChanged;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @callUs.
  ///
  /// In en, this message translates to:
  /// **'Call Us'**
  String get callUs;

  /// No description provided for @whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// No description provided for @emailUs.
  ///
  /// In en, this message translates to:
  /// **'Email Us'**
  String get emailUs;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @followUs.
  ///
  /// In en, this message translates to:
  /// **'Follow Us'**
  String get followUs;

  /// No description provided for @adminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboard;

  /// No description provided for @totalPatients.
  ///
  /// In en, this message translates to:
  /// **'Total Patients'**
  String get totalPatients;

  /// No description provided for @todaysAppointments.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Appointments'**
  String get todaysAppointments;

  /// No description provided for @pendingApprovals.
  ///
  /// In en, this message translates to:
  /// **'Pending Approvals'**
  String get pendingApprovals;

  /// No description provided for @totalDentists.
  ///
  /// In en, this message translates to:
  /// **'Total Dentists'**
  String get totalDentists;

  /// No description provided for @recentAppointments.
  ///
  /// In en, this message translates to:
  /// **'Recent Appointments'**
  String get recentAppointments;

  /// No description provided for @manageDentists.
  ///
  /// In en, this message translates to:
  /// **'Manage Dentists'**
  String get manageDentists;

  /// No description provided for @addDentist.
  ///
  /// In en, this message translates to:
  /// **'Add Dentist'**
  String get addDentist;

  /// No description provided for @editDentist.
  ///
  /// In en, this message translates to:
  /// **'Edit Dentist'**
  String get editDentist;

  /// No description provided for @deleteDentist.
  ///
  /// In en, this message translates to:
  /// **'Delete Dentist'**
  String get deleteDentist;

  /// No description provided for @deleteDentistConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this dentist?'**
  String get deleteDentistConfirm;

  /// No description provided for @dentistAdded.
  ///
  /// In en, this message translates to:
  /// **'Dentist added successfully'**
  String get dentistAdded;

  /// No description provided for @dentistUpdated.
  ///
  /// In en, this message translates to:
  /// **'Dentist updated successfully'**
  String get dentistUpdated;

  /// No description provided for @dentistDeleted.
  ///
  /// In en, this message translates to:
  /// **'Dentist deleted successfully'**
  String get dentistDeleted;

  /// No description provided for @dentistImage.
  ///
  /// In en, this message translates to:
  /// **'Dentist Image'**
  String get dentistImage;

  /// No description provided for @selectWorkingDays.
  ///
  /// In en, this message translates to:
  /// **'Select Working Days'**
  String get selectWorkingDays;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get endTime;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Enter description'**
  String get descriptionHint;

  /// No description provided for @manageAppointments.
  ///
  /// In en, this message translates to:
  /// **'Manage Appointments'**
  String get manageAppointments;

  /// No description provided for @approveAppointment.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approveAppointment;

  /// No description provided for @rejectAppointment.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get rejectAppointment;

  /// No description provided for @markCompleted.
  ///
  /// In en, this message translates to:
  /// **'Mark Completed'**
  String get markCompleted;

  /// No description provided for @appointmentApproved.
  ///
  /// In en, this message translates to:
  /// **'Appointment approved'**
  String get appointmentApproved;

  /// No description provided for @appointmentRejected.
  ///
  /// In en, this message translates to:
  /// **'Appointment rejected'**
  String get appointmentRejected;

  /// No description provided for @appointmentCompleted.
  ///
  /// In en, this message translates to:
  /// **'Appointment marked as completed'**
  String get appointmentCompleted;

  /// No description provided for @filterByStatus.
  ///
  /// In en, this message translates to:
  /// **'Filter by Status'**
  String get filterByStatus;

  /// No description provided for @filterByDentist.
  ///
  /// In en, this message translates to:
  /// **'Filter by Dentist'**
  String get filterByDentist;

  /// No description provided for @manageServices.
  ///
  /// In en, this message translates to:
  /// **'Manage Services'**
  String get manageServices;

  /// No description provided for @addService.
  ///
  /// In en, this message translates to:
  /// **'Add Service'**
  String get addService;

  /// No description provided for @editService.
  ///
  /// In en, this message translates to:
  /// **'Edit Service'**
  String get editService;

  /// No description provided for @deleteService.
  ///
  /// In en, this message translates to:
  /// **'Delete Service'**
  String get deleteService;

  /// No description provided for @deleteServiceConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this service?'**
  String get deleteServiceConfirm;

  /// No description provided for @serviceAdded.
  ///
  /// In en, this message translates to:
  /// **'Service added successfully'**
  String get serviceAdded;

  /// No description provided for @serviceUpdated.
  ///
  /// In en, this message translates to:
  /// **'Service updated successfully'**
  String get serviceUpdated;

  /// No description provided for @serviceDeleted.
  ///
  /// In en, this message translates to:
  /// **'Service deleted successfully'**
  String get serviceDeleted;

  /// No description provided for @serviceName.
  ///
  /// In en, this message translates to:
  /// **'Service Name'**
  String get serviceName;

  /// No description provided for @serviceTitle.
  ///
  /// In en, this message translates to:
  /// **'Service Title'**
  String get serviceTitle;

  /// No description provided for @serviceTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Enter service title'**
  String get serviceTitleHint;

  /// No description provided for @servicePrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get servicePrice;

  /// No description provided for @servicePricHint.
  ///
  /// In en, this message translates to:
  /// **'Enter price'**
  String get servicePricHint;

  /// No description provided for @serviceImage.
  ///
  /// In en, this message translates to:
  /// **'Service Image'**
  String get serviceImage;

  /// No description provided for @noUsers.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get noUsers;

  /// No description provided for @manageUsers.
  ///
  /// In en, this message translates to:
  /// **'Manage Users'**
  String get manageUsers;

  /// No description provided for @userDetails.
  ///
  /// In en, this message translates to:
  /// **'User Details'**
  String get userDetails;

  /// No description provided for @accountStatus.
  ///
  /// In en, this message translates to:
  /// **'Account Status'**
  String get accountStatus;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @toggleUserStatus.
  ///
  /// In en, this message translates to:
  /// **'Toggle User Status'**
  String get toggleUserStatus;

  /// No description provided for @userActivated.
  ///
  /// In en, this message translates to:
  /// **'User account activated'**
  String get userActivated;

  /// No description provided for @userDeactivated.
  ///
  /// In en, this message translates to:
  /// **'User account deactivated'**
  String get userDeactivated;

  /// No description provided for @manageReviews.
  ///
  /// In en, this message translates to:
  /// **'Manage Reviews'**
  String get manageReviews;

  /// No description provided for @deleteReview.
  ///
  /// In en, this message translates to:
  /// **'Delete Review'**
  String get deleteReview;

  /// No description provided for @deleteReviewConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this review?'**
  String get deleteReviewConfirm;

  /// No description provided for @reviewDeleted.
  ///
  /// In en, this message translates to:
  /// **'Review deleted successfully'**
  String get reviewDeleted;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @appointmentsPerMonth.
  ///
  /// In en, this message translates to:
  /// **'Appointments Per Month'**
  String get appointmentsPerMonth;

  /// No description provided for @appointmentsByStatus.
  ///
  /// In en, this message translates to:
  /// **'Appointments by Status'**
  String get appointmentsByStatus;

  /// No description provided for @topRatedDentists.
  ///
  /// In en, this message translates to:
  /// **'Top Rated Dentists'**
  String get topRatedDentists;

  /// No description provided for @topDentists.
  ///
  /// In en, this message translates to:
  /// **'Top Dentists'**
  String get topDentists;

  /// No description provided for @totalAppointments.
  ///
  /// In en, this message translates to:
  /// **'Total Appointments'**
  String get totalAppointments;

  /// No description provided for @completedAppointments.
  ///
  /// In en, this message translates to:
  /// **'Completed Appointments'**
  String get completedAppointments;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @imagePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Image'**
  String get imagePickerTitle;

  /// No description provided for @fromGallery.
  ///
  /// In en, this message translates to:
  /// **'From Gallery'**
  String get fromGallery;

  /// No description provided for @fromCamera.
  ///
  /// In en, this message translates to:
  /// **'From Camera'**
  String get fromCamera;

  /// No description provided for @uploadingImage.
  ///
  /// In en, this message translates to:
  /// **'Uploading image...'**
  String get uploadingImage;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. Are you sure?'**
  String get deleteConfirmMessage;

  /// No description provided for @notificationApproved.
  ///
  /// In en, this message translates to:
  /// **'Your appointment has been approved'**
  String get notificationApproved;

  /// No description provided for @notificationRejected.
  ///
  /// In en, this message translates to:
  /// **'Your appointment has been rejected'**
  String get notificationRejected;

  /// No description provided for @notificationCancelled.
  ///
  /// In en, this message translates to:
  /// **'Your appointment has been cancelled'**
  String get notificationCancelled;

  /// No description provided for @notificationReminder.
  ///
  /// In en, this message translates to:
  /// **'Appointment reminder for tomorrow'**
  String get notificationReminder;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Your smile, our priority'**
  String get appTagline;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @appointmentSummary.
  ///
  /// In en, this message translates to:
  /// **'Appointment Summary'**
  String get appointmentSummary;

  /// No description provided for @doctorLabel.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get doctorLabel;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// No description provided for @doctorName.
  ///
  /// In en, this message translates to:
  /// **'Dr. {name}'**
  String doctorName(String name);

  /// No description provided for @depositAmount.
  ///
  /// In en, this message translates to:
  /// **'Deposit Amount'**
  String get depositAmount;

  /// No description provided for @amountWithCurrency.
  ///
  /// In en, this message translates to:
  /// **'{amount} JD'**
  String amountWithCurrency(String amount);

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @payAtClinic.
  ///
  /// In en, this message translates to:
  /// **'Pay at the clinic'**
  String get payAtClinic;

  /// No description provided for @payAtClinicSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pay the deposit when you arrive'**
  String get payAtClinicSubtitle;

  /// No description provided for @payByCard.
  ///
  /// In en, this message translates to:
  /// **'Pay deposit by card'**
  String get payByCard;

  /// No description provided for @payByCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Demo mode: no real charge'**
  String get payByCardSubtitle;

  /// No description provided for @demoPaymentNotice.
  ///
  /// In en, this message translates to:
  /// **'Online payment is in demo mode. No card is charged, so please don\'t enter real card details.'**
  String get demoPaymentNotice;

  /// No description provided for @cardDetails.
  ///
  /// In en, this message translates to:
  /// **'Card Details'**
  String get cardDetails;

  /// No description provided for @cardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get cardNumber;

  /// No description provided for @expiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get expiryDate;

  /// No description provided for @cvv.
  ///
  /// In en, this message translates to:
  /// **'CVV'**
  String get cvv;

  /// No description provided for @cardNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Card number is required'**
  String get cardNumberRequired;

  /// No description provided for @cardNumberInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid card number'**
  String get cardNumberInvalid;

  /// No description provided for @expiryRequired.
  ///
  /// In en, this message translates to:
  /// **'Expiry date is required'**
  String get expiryRequired;

  /// No description provided for @expiryInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid expiry (MM/YY)'**
  String get expiryInvalid;

  /// No description provided for @cardExpired.
  ///
  /// In en, this message translates to:
  /// **'Card is expired'**
  String get cardExpired;

  /// No description provided for @cvvRequired.
  ///
  /// In en, this message translates to:
  /// **'CVV is required'**
  String get cvvRequired;

  /// No description provided for @cvvInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 3 or 4 digit CVV'**
  String get cvvInvalid;

  /// No description provided for @payDepositButton.
  ///
  /// In en, this message translates to:
  /// **'Pay Deposit ({amount})'**
  String payDepositButton(String amount);

  /// No description provided for @paymentSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful!'**
  String get paymentSuccessTitle;

  /// No description provided for @bookingPendingMessage.
  ///
  /// In en, this message translates to:
  /// **'Your appointment has been booked.\nThe clinic will confirm it shortly.'**
  String get bookingPendingMessage;

  /// No description provided for @payAtClinicReminder.
  ///
  /// In en, this message translates to:
  /// **'Please pay the deposit ({amount}) when you arrive.'**
  String payAtClinicReminder(String amount);

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @appointments.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get appointments;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @noAppointmentData.
  ///
  /// In en, this message translates to:
  /// **'No appointment data'**
  String get noAppointmentData;

  /// No description provided for @pleaseSelectRating.
  ///
  /// In en, this message translates to:
  /// **'Please select a rating'**
  String get pleaseSelectRating;

  /// No description provided for @selectAtLeastOneWorkingDay.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one working day'**
  String get selectAtLeastOneWorkingDay;

  /// No description provided for @commentTooLong.
  ///
  /// In en, this message translates to:
  /// **'Comment must be at most 1000 characters'**
  String get commentTooLong;

  /// No description provided for @ratingPoor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get ratingPoor;

  /// No description provided for @ratingFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get ratingFair;

  /// No description provided for @ratingGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get ratingGood;

  /// No description provided for @ratingVeryGood.
  ///
  /// In en, this message translates to:
  /// **'Very Good'**
  String get ratingVeryGood;

  /// No description provided for @ratingExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get ratingExcellent;

  /// No description provided for @tapToRate.
  ///
  /// In en, this message translates to:
  /// **'Tap to rate'**
  String get tapToRate;

  /// No description provided for @notificationTitleApproved.
  ///
  /// In en, this message translates to:
  /// **'Appointment Approved'**
  String get notificationTitleApproved;

  /// No description provided for @notificationTitleRejected.
  ///
  /// In en, this message translates to:
  /// **'Appointment Rejected'**
  String get notificationTitleRejected;

  /// No description provided for @notificationTitleCancelled.
  ///
  /// In en, this message translates to:
  /// **'Appointment Cancelled'**
  String get notificationTitleCancelled;

  /// No description provided for @notificationTitleCompleted.
  ///
  /// In en, this message translates to:
  /// **'Appointment Completed'**
  String get notificationTitleCompleted;

  /// No description provided for @notificationCompleted.
  ///
  /// In en, this message translates to:
  /// **'Your appointment has been completed. Thank you for visiting us!'**
  String get notificationCompleted;

  /// No description provided for @errorUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'No account found with this email'**
  String get errorUserNotFound;

  /// No description provided for @errorWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password'**
  String get errorWrongPassword;

  /// No description provided for @errorInvalidCredential.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get errorInvalidCredential;

  /// No description provided for @errorEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'An account already exists with this email'**
  String get errorEmailInUse;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get errorInvalidEmail;

  /// No description provided for @errorAccountDisabled.
  ///
  /// In en, this message translates to:
  /// **'Your account has been disabled. Please contact the clinic.'**
  String get errorAccountDisabled;

  /// No description provided for @errorTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again later'**
  String get errorTooManyRequests;

  /// No description provided for @errorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak'**
  String get errorWeakPassword;

  /// No description provided for @errorRequiresRecentLogin.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again to complete this action'**
  String get errorRequiresRecentLogin;

  /// No description provided for @errorProfileSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save your profile. Please check your connection and try again.'**
  String get errorProfileSaveFailed;

  /// No description provided for @errorUserDataNotFound.
  ///
  /// In en, this message translates to:
  /// **'Account data not found. Please contact the clinic.'**
  String get errorUserDataNotFound;

  /// No description provided for @errorPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to do this'**
  String get errorPermissionDenied;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'The requested item was not found'**
  String get errorNotFound;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get loadMore;

  /// No description provided for @endTimeAfterStart.
  ///
  /// In en, this message translates to:
  /// **'End time must be after start time'**
  String get endTimeAfterStart;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
