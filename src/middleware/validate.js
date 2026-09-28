/**
 * Generic Request Validator Middleware using Zod schemas
 *
 * @param {import('zod').ZodSchema} schema - Zod schema to validate against
 * @param {'body' | 'query' | 'params'} source - Request property to validate ('body', 'query', or 'params')
 */
export const validate = (schema, source = 'body') => {
  return async (req, res, next) => {
    try {
      const parsedData = await schema.parseAsync(req[source]);
      req[source] = parsedData; // Replace with sanitized/transformed data
      next();
    } catch (error) {
      if (error.errors && Array.isArray(error.errors)) {
        const details = error.errors.map((err) => ({
          field: err.path.join('.'),
          message: err.message
        }));

        return res.status(400).json({
          success: false,
          message: 'Validation failed on input data',
          error: 'VALIDATION_ERROR',
          details
        });
      }

      next(error);
    }
  };
};
