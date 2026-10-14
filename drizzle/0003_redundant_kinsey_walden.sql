ALTER TABLE "geoportal"."features" ADD COLUMN "downloaded" boolean DEFAULT false NOT NULL;--> statement-breakpoint
UPDATE "geoportal"."features" SET "downloaded" = true WHERE "downloaded_at" IS NOT NULL;--> statement-breakpoint
ALTER TABLE "geoportal"."features" ADD COLUMN "tiled" boolean DEFAULT false NOT NULL;
