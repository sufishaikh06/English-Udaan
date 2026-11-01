const { z } = require('zod');

const environmentSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.coerce.number().int().min(1).max(65535).default(3000),
  CORS_ORIGIN: z.string().default('http://localhost:3000'),
  MONGODB_URI: z.string().optional(),
  MONGODB_DATABASE: z.string().default('test'),
  // Firebase project ID — required for Phase 15 auth endpoints.
  // Obtain from the Firebase console. This is NOT a secret.
  FIREBASE_PROJECT_ID: z.string().optional(),
  // AI provider for dictionary lookups (Phase 16).
  // Supported values: 'openai' | 'google'
  // The key is a secret — never commit it or return it to the client.
  AI_PROVIDER: z.enum(['openai', 'google']).optional(),
  AI_API_KEY: z.string().optional(),
  AI_MODEL: z.string().optional(),
});

function loadEnvironment(environment = process.env) {
  const parsed = environmentSchema.safeParse(environment);
  if (!parsed.success) {
    const messages = parsed.error.issues
      .map((issue) => `${issue.path.join('.')}: ${issue.message}`)
      .join(', ');
    throw new Error(`Invalid environment configuration: ${messages}`);
  }

  return parsed.data;
}

module.exports = { loadEnvironment };
