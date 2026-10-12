import { defineConfig } from "drizzle-kit";

if (!import.meta.env["DATABASE_URL"]) {
  throw new Error(`DATABASE_URL environment variable is required`);
}

export default defineConfig({
  dialect: "postgresql",
  schema: "./schema.ts",
  dbCredentials: {
    url: import.meta.env["DATABASE_URL"],
  },
});
