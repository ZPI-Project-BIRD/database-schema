ALTER TABLE "geoportal"."features" ADD COLUMN "download_retry_count" integer DEFAULT 0 NOT NULL;--> statement-breakpoint
ALTER TABLE "geoportal"."features" ADD COLUMN "download_error" text;--> statement-breakpoint
ALTER TABLE "geoportal"."features" ADD COLUMN "tiling_retry_count" integer DEFAULT 0 NOT NULL;--> statement-breakpoint
ALTER TABLE "geoportal"."features" ADD COLUMN "tiling_error" text;--> statement-breakpoint
UPDATE "geoportal"."features" SET "downloaded" = true WHERE "downloaded_at" IS NOT NULL AND "downloaded" = false;
