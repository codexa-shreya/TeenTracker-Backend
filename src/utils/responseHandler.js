/**
 * Standardized Success Response Helper
 */
export const sendSuccess = (res, statusCode = 200, message = 'Success', data = null, meta = null) => {
  const response = {
    success: true,
    message,
    ...(data !== null && { data }),
    ...(meta !== null && { meta })
  };
  return res.status(statusCode).json(response);
};

/**
 * Standardized Error Response Helper
 */
export const sendError = (res, statusCode = 500, message = 'Internal Server Error', error = null, details = null) => {
  const response = {
    success: false,
    message,
    ...(error !== null && { error }),
    ...(details !== null && { details })
  };
  return res.status(statusCode).json(response);
};
