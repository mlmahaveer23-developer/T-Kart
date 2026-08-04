/// Shared validation rules so every form (auth, checkout, profile) applies
/// identical logic instead of re-implementing regexes per screen.
class Validators {
  const Validators._();

  static final RegExp _emailRegex =
      RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,}$');
  static final RegExp _indianPhoneRegex = RegExp(r'^[6-9]\d{9}$');

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? indianPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (!_indianPhoneRegex.hasMatch(value.trim())) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  static String? notEmpty(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }
    return null;
  }

  static String? otp(String? value, {int length = 6}) {
    if (value == null || value.trim().length != length) {
      return 'Enter the $length-digit code';
    }
    if (!RegExp(r'^\d+$').hasMatch(value.trim())) {
      return 'Code must be numeric';
    }
    return null;
  }

  static String? pincode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Pincode is required';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(value.trim())) {
      return 'Enter a valid 6-digit pincode';
    }
    return null;
  }
}
