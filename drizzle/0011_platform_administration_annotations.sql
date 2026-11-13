CREATE TABLE "geoportal"."annotation_history" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"project_id" uuid NOT NULL,
	"detection_id" uuid NOT NULL,
	"action" text NOT NULL,
	"actor" varchar(16) NOT NULL,
	"occurred_at" timestamp with time zone DEFAULT now() NOT NULL,
	"before" jsonb,
	"after" jsonb NOT NULL
);
--> statement-breakpoint
CREATE TABLE "geoportal"."detection_annotations" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"project_id" uuid NOT NULL,
	"feature_id" text NOT NULL,
	"recognition_job_id" uuid,
	"source_detection_id" uuid,
	"bounds" jsonb NOT NULL,
	"deleted" boolean DEFAULT false NOT NULL,
	"version" integer DEFAULT 1 NOT NULL,
	"updated_by" varchar(16) NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"verified_by" varchar(16),
	"verified_at" timestamp with time zone,
	CONSTRAINT "detection_annotations_version" CHECK ("geoportal"."detection_annotations"."version" > 0),
	CONSTRAINT "detection_annotations_verification" CHECK (("geoportal"."detection_annotations"."verified_by" is null) = ("geoportal"."detection_annotations"."verified_at" is null))
);
--> statement-breakpoint
CREATE TABLE "project_processing" (
	"project_id" uuid PRIMARY KEY NOT NULL,
	"discovery_status" text DEFAULT 'PENDING' NOT NULL,
	"attempts" integer DEFAULT 0 NOT NULL,
	"attempt_token" uuid,
	"locked_until" timestamp with time zone,
	"last_error" text,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "project_processing_discovery_status" CHECK ("project_processing"."discovery_status" in ('PENDING', 'RUNNING', 'SUCCEEDED', 'FAILED'))
);
--> statement-breakpoint
ALTER TABLE "geoportal"."detections" DROP CONSTRAINT "detections_recognition_job_id_recognition_jobs_id_fk";
--> statement-breakpoint
ALTER TABLE "projects" DROP CONSTRAINT "projects_organization_id_organizations_id_fk";
--> statement-breakpoint
ALTER TABLE "geoportal"."recognition_jobs" DROP CONSTRAINT "recognition_jobs_project_id_projects_id_fk";
--> statement-breakpoint
ALTER TABLE "geoportal"."recognition_jobs" DROP CONSTRAINT "recognition_jobs_feature_id_features_id_fk";
--> statement-breakpoint
ALTER TABLE "geoportal"."recognition_jobs" ALTER COLUMN "status" SET DATA TYPE text;--> statement-breakpoint
-- Preserve the meaning of statuses from the historical enum when upgrading an existing database.
UPDATE "geoportal"."recognition_jobs" SET "status" = CASE "status"
    WHEN '0_STARTED' THEN '1_STARTED'
    WHEN '1_COMPLETED' THEN '2_FINISHED'
    ELSE "status" END;--> statement-breakpoint
ALTER TABLE "geoportal"."recognition_jobs" ALTER COLUMN "status" SET DEFAULT '0_PENDING'::text;--> statement-breakpoint
DROP TYPE "geoportal"."recognition_job_status";--> statement-breakpoint
CREATE TYPE "geoportal"."recognition_job_status" AS ENUM('0_PENDING', '1_STARTED', '2_FINISHED', '3_FAILED');--> statement-breakpoint
ALTER TABLE "geoportal"."recognition_jobs" ALTER COLUMN "status" SET DEFAULT '0_PENDING'::"geoportal"."recognition_job_status";--> statement-breakpoint
ALTER TABLE "geoportal"."recognition_jobs" ALTER COLUMN "status" SET DATA TYPE "geoportal"."recognition_job_status" USING "status"::"geoportal"."recognition_job_status";--> statement-breakpoint
-- Preserve the existing started_at default for callers that omit it.
ALTER TABLE "geoportal"."recognition_jobs" ALTER COLUMN "started_at" SET DEFAULT now();--> statement-breakpoint
-- Existing jobs predate this column. Use their start time as the best available
-- creation-time approximation, while retaining any creation times already stored.
ALTER TABLE "geoportal"."recognition_jobs" ADD COLUMN IF NOT EXISTS "created_at" timestamp;--> statement-breakpoint
UPDATE "geoportal"."recognition_jobs" SET "created_at" = "started_at" WHERE "created_at" IS NULL;--> statement-breakpoint
ALTER TABLE "geoportal"."recognition_jobs" ALTER COLUMN "created_at" SET DEFAULT now();--> statement-breakpoint
ALTER TABLE "geoportal"."recognition_jobs" ALTER COLUMN "created_at" SET NOT NULL;--> statement-breakpoint
ALTER TABLE "users" ADD COLUMN "auth_version" integer DEFAULT 0 NOT NULL;--> statement-breakpoint
ALTER TABLE "geoportal"."annotation_history" ADD CONSTRAINT "annotation_history_project_id_projects_id_fk" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "geoportal"."detection_annotations" ADD CONSTRAINT "detection_annotations_project_id_projects_id_fk" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "geoportal"."detection_annotations" ADD CONSTRAINT "detection_annotations_feature_id_features_id_fk" FOREIGN KEY ("feature_id") REFERENCES "geoportal"."features"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "geoportal"."detection_annotations" ADD CONSTRAINT "detection_annotations_recognition_job_id_recognition_jobs_id_fk" FOREIGN KEY ("recognition_job_id") REFERENCES "geoportal"."recognition_jobs"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "project_processing" ADD CONSTRAINT "project_processing_project_id_projects_id_fk" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "ix_annotation_history_project" ON "geoportal"."annotation_history" USING btree ("project_id","occurred_at");--> statement-breakpoint
CREATE INDEX "ix_detection_annotations_project" ON "geoportal"."detection_annotations" USING btree ("project_id");--> statement-breakpoint
ALTER TABLE "geoportal"."detections" ADD CONSTRAINT "detections_recognition_job_id_recognition_jobs_id_fk" FOREIGN KEY ("recognition_job_id") REFERENCES "geoportal"."recognition_jobs"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "projects" ADD CONSTRAINT "projects_organization_id_organizations_id_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "geoportal"."recognition_jobs" ADD CONSTRAINT "recognition_jobs_project_id_projects_id_fk" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "geoportal"."recognition_jobs" ADD CONSTRAINT "recognition_jobs_feature_id_features_id_fk" FOREIGN KEY ("feature_id") REFERENCES "geoportal"."features"("id") ON DELETE cascade ON UPDATE no action;
