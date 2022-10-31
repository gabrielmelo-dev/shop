class AppAuthException implements Exception {

  static const Map<String, String> errors = {
    'EMAIL_EXISTS': 'Email already in use',
    'OPERATION_NOT_ALLOWED': 'Operation not allowed',
    'TOO_MANY_ATTEMPTS_TRY_LATER': 'Too many attemtps, try later',
    'EMAIL_NOT_FOUND': 'Email not found',
    'INVALID_PASSWORD': 'Invalid password',
    'USER_DISABLED': 'User account has been disabled'
  };

  final String key;

  AppAuthException(this.key);

  @override
  String toString() {
    return errors[key] ?? 'An error occurred during the authentication process';
  }
}