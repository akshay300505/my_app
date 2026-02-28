class Validators {
  static String? gmail(String? v) {
    final value = (v ?? '').trim().toLowerCase();
    if (value.isEmpty) return "Email is required";
    final gmailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');
    if (!gmailRegex.hasMatch(value)) return "Use a valid @gmail.com email";
    return null;
  }

  static String? password(String? v) {
    final value = v ?? '';
    if (value.isEmpty) return "Password is required";
    if (value.length < 6) return "Password must be 6+ characters";
    return null;
  }

  static String? confirmPassword(String? v, String original) {
    final value = v ?? '';
    if (value.isEmpty) return "Confirm password is required";
    if (value != original) return "Passwords do not match";
    return null;
  }

  static String? phone(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return "Mobile number is required";
    if (!value.startsWith('+')) return "Use format like +91XXXXXXXXXX";
    if (value.length < 10) return "Enter a valid number";
    return null;
  }

  static String? otp(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return "OTP is required";
    if (value.length != 6) return "Enter 6 digit OTP";
    return null;
  }
}