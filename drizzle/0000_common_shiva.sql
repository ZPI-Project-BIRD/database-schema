CREATE SCHEMA "geoportal";
--> statement-breakpoint
CREATE TABLE "geoportal"."features" (
	"id" text PRIMARY KEY NOT NULL,
	"colorSpace" text NOT NULL,
	"pixel_size" numeric(2) NOT NULL,
	"dataset_date" timestamp NOT NULL,
	"file_size" integer NOT NULL,
	"downloaded_at" timestamp
);
