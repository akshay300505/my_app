class Validators {
  static String? Function(String?)? gmail;

  static String? Function(String?)? otp;

  static String? requiredField(String? v, {String msg = 'This field is required'}) {
    if (v == null || v.trim().isEmpty) return msg;
    return null;
  }

  static String? gmailOnly(String? v) {
    final req = requiredField(v, msg: 'Email is required');
    if (req != null) return req;

    final email = v!.trim();
    final ok = RegExp(r'^[^@\s]+@gmail\.com$').hasMatch(email);
    if (!ok) return 'Only @gmail.com emails are allowed';
    return null;
  }

  static String? password(String? v) {
    final req = requiredField(v, msg: 'Password is required');
    if (req != null) return req;
    if (v!.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? confirmPassword(String? v, String original) {
    final req = requiredField(v, msg: 'Confirm password is required');
    if (req != null) return req;
    if (v != original) return 'Passwords do not match';
    return null;
  }

  // Basic E.164-ish check; you can tighten this if you want
  static String? phone(String? v) {
    final req = requiredField(v, msg: 'Mobile number is required');
    if (req != null) return req;

    final raw = v!.trim();
    // Expect like +91XXXXXXXXXX
    if (!RegExp(r'^\+\d{10,15}$').hasMatch(raw)) {
      return 'Enter phone in international format, e.g. +91XXXXXXXXXX';
    }
    return null;
  }

  static String? otp6(String? v) {
    final req = requiredField(v, msg: 'OTP is required');
    if (req != null) return req;
    if (!RegExp(r'^\d{6}$').hasMatch(v!.trim())) return 'OTP must be 6 digits';
    return null;
  }
}