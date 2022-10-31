class AppHttpException implements Exception {
  final String msg;
  final int statusCode;

  AppHttpException({
    required this.msg,
    required this.statusCode,
  });

  @override
  String toString() {
    return msg;
  }
}
