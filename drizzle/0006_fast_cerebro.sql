CREATE TYPE "geoportal"."recognition_job_status" AS ENUM('0_STARTED', '1_COMPLETED', '2_FINISHED', '3_FAILED');--> statement-breakpoint
CREATE TABLE "geoportal"."detections" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"recognition_job_id" uuid NOT NULL,
	"bounds" jsonb
);
--> statement-breakpoint
CREATE TABLE "projects" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "geoportal"."recognition_jobs" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"project_id" uuid,
	"feature_id" text,
	"started_at" timestamp DEFAULT now() NOT NULL,
	"finished_at" timestamp,
	"status" "geoportal"."recognition_job_status" DEFAULT '0_STARTED' NOT NULL,
	"error" text
);
--> statement-breakpoint
ALTER TABLE "geoportal"."detections" ADD CONSTRAINT "detections_recognition_job_id_recognition_jobs_id_fk" FOREIGN KEY ("recognition_job_id") REFERENCES "geoportal"."recognition_jobs"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "geoportal"."recognition_jobs" ADD CONSTRAINT "recognition_jobs_project_id_projects_id_fk" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "geoportal"."recognition_jobs" ADD CONSTRAINT "recognition_jobs_feature_id_features_id_fk" FOREIGN KEY ("feature_id") REFERENCES "geoportal"."features"("id") ON DELETE no action ON UPDATE no action;