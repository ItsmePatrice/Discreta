class StatusCodes {
  // Success Codes
  static const int ok = 200;
  static const int created = 201;
  static const int accepted = 202;

  // Client Error Codes
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int methodNotAllowed = 405;
  static const int conflict = 409;
  static const int tooManyRequests = 429;

  // Server Error Codes
  static const int internalServerError = 500;
}
