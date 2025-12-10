const StatusCodes = {
  // Success Codes
  ok: 200,
  created: 201,
  accepted: 202,

  // Client Error Codes
  badRequest: 400,
  unauthorized: 401,
  forbidden: 403,
  notFound: 404,
  methodNotAllowed: 405,
  conflict: 409,
  tooManyRequests: 429,
  internalServerError: 500,
};

export default StatusCodes;
