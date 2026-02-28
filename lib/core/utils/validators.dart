class Validators {
  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return "Email required";
    if (!v.contains('@')) return "Invalid email";
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return "Password required";
    if (v.length < 6) return "Password must be 6+ characters";
    return null;
  }

  static String? confirmPassword(String? v, String original) {
    if (v == null || v.isEmpty) return "Confirm password required";
    if (v != original) return "Passwords do not match";
    return null;
  }

  static String? phone(String? v) {
    if (v == null || v.trim().isEmpty) return "Phone number required";
    // Expect +91XXXXXXXXXX etc.
    if (!v.startsWith('+') || v.length < 10) return "Use format like +91XXXXXXXXXX";
    return null;
  }

  static String? otp(String? v) {
    if (v == null || v.trim().isEmpty) return "OTP required";
    if (v.length < 6) return "Enter 6 digit OTP";
    return null;
  }
}