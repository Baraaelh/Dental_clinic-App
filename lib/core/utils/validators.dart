class Validators {
  const Validators._();

  static String? validateEmail(String? value, {String? requiredMsg, String? invalidMsg}) {
    if (value == null || value.trim().isEmpty) {
      return requiredMsg ?? 'Email is required';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return invalidMsg ?? 'Please enter a valid email';
    }
    return null;
  }

  static String? validatePassword(
    String? value, {
    String? requiredMsg,
    String? shortMsg,
    String? uppercaseMsg,
    String? numberMsg,
  }) {
    if (value == null || value.isEmpty) {
      return requiredMsg ?? 'Password is required';
    }
    if (value.length < 8) {
      return shortMsg ?? 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return uppercaseMsg ?? 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return numberMsg ?? 'Password must contain at least one number';
    }
    return null;
  }

  static String? validateConfirmPassword(
    String? value,
    String password, {
    String? requiredMsg,
    String? mismatchMsg,
  }) {
    if (value == null || value.isEmpty) {
      return requiredMsg ?? 'Confirm password is required';
    }
    if (value != password) {
      return mismatchMsg ?? 'Passwords do not match';
    }
    return null;
  }

  static String? validateName(String? value, {String? requiredMsg, String? shortMsg}) {
    if (value == null || value.trim().isEmpty) {
      return requiredMsg ?? 'Name is required';
    }
    if (value.trim().length < 2) {
      return shortMsg ?? 'Name must be at least 2 characters';
    }
    return null;
  }

  static String? validatePhone(String? value, {String? requiredMsg, String? invalidMsg}) {
    if (value == null || value.trim().isEmpty) {
      return requiredMsg ?? 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^\+?[0-9]{8,15}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return invalidMsg ?? 'Please enter a valid phone number';
    }
    return null;
  }

  static String? validateRequired(String? value, {String? message}) {
    if (value == null || value.trim().isEmpty) {
      return message ?? 'This field is required';
    }
    return null;
  }

  static String? validateComment(String? value, {String? requiredMsg, String? shortMsg}) {
    if (value == null || value.trim().isEmpty) {
      return requiredMsg ?? 'Comment is required';
    }
    if (value.trim().length < 10) {
      return shortMsg ?? 'Comment must be at least 10 characters';
    }
    // Firestore rules reject comments longer than this.
    if (value.trim().length > 1000) {
      return 'Comment must be at most 1000 characters';
    }
    return null;
  }

  static String? validatePrice(String? value, {String? requiredMsg, String? invalidMsg}) {
    if (value == null || value.trim().isEmpty) {
      return requiredMsg ?? 'Price is required';
    }
    final price = double.tryParse(value.trim());
    if (price == null || price < 0) {
      return invalidMsg ?? 'Please enter a valid price';
    }
    return null;
  }
}
