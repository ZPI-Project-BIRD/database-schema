CREATE TYPE "geoportal"."feature_download_status" AS ENUM('0_PENDING', '1_DOWNLOADING', '2_DOWNLOADED', '3_FAILED');--> statement-breakpoint
CREATE TYPE "geoportal"."feature_tiling_status" AS ENUM('0_PENDING', '1_PROCESSING', '2_COMPLETED', '3_FAILED');--> statement-breakpoint
CREATE TABLE "geoportal"."project_features" (
	"project_id" uuid NOT NULL,
	"feature_id" text NOT NULL,
	"discovered_at" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "project_features_pk" PRIMARY KEY("project_id","feature_id")
);
--> statement-breakpoint
ALTER TABLE "users" DROP CONSTRAINT "users_ban_reason_with_ban";--> statement-breakpoint
ALTER TABLE "memberships" ALTER COLUMN "role" SET DATA TYPE text;--> statement-breakpoint
ALTER TABLE "memberships" ALTER COLUMN "role" SET DEFAULT '1_VIEWER'::text;--> statement-breakpoint
DROP TYPE "public"."membership_role";--> statement-breakpoint
CREATE TYPE "public"."membership_role" AS ENUM('1_VIEWER', '2_ANNOTATOR', '3_EDITOR', '4_OWNER');--> statement-breakpoint
ALTER TABLE "memberships" ALTER COLUMN "role" SET DEFAULT '1_VIEWER'::"public"."membership_role";--> statement-breakpoint
ALTER TABLE "memberships" ALTER COLUMN "role" SET DATA TYPE "public"."membership_role" USING "role"::"public"."membership_role";--> statement-breakpoint
ALTER TABLE "geoportal"."features" ALTER COLUMN "file_size" DROP NOT NULL;--> statement-breakpoint
ALTER TABLE "geoportal"."features" ADD COLUMN "source_url" text NOT NULL;--> statement-breakpoint
ALTER TABLE "geoportal"."features" ADD COLUMN "object_name" text;--> statement-breakpoint
ALTER TABLE "geoportal"."features" ADD COLUMN "created_at" timestamp DEFAULT now() NOT NULL;--> statement-breakpoint
ALTER TABLE "geoportal"."features" ADD COLUMN "updated_at" timestamp DEFAULT now() NOT NULL;--> statement-breakpoint
ALTER TABLE "geoportal"."features" ADD COLUMN "tiled_at" timestamp;--> statement-breakpoint
ALTER TABLE "projects" ADD COLUMN "name" text NOT NULL;--> statement-breakpoint
ALTER TABLE "geoportal"."project_features" ADD CONSTRAINT "project_features_project_id_projects_id_fk" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "geoportal"."project_features" ADD CONSTRAINT "project_features_feature_id_features_id_fk" FOREIGN KEY ("feature_id") REFERENCES "geoportal"."features"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "ix_project_features_feature_id" ON "geoportal"."project_features" USING btree ("feature_id");--> statement-breakpoint
ALTER TABLE "geoportal"."features" DROP COLUMN "downloaded";--> statement-breakpoint
ALTER TABLE "geoportal"."features" DROP COLUMN "tiled";--> statement-breakpoint
ALTER TABLE "users" ADD CONSTRAINT "users_ban_reason_with_ban" CHECK (("users"."ban_reason" is null) = ("users"."banned_at" is null));