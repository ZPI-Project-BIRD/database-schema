-- Also repair databases that applied the earlier version of migration 0011.
-- Existing created_at values are retained: genuine creation times cannot be
-- distinguished safely from timestamps assigned by that earlier migration.
ALTER TABLE "geoportal"."recognition_jobs" ALTER COLUMN "started_at" SET DEFAULT now();
