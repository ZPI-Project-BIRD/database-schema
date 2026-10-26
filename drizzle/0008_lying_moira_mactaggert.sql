ALTER TABLE "projects" ADD COLUMN "top_left" geometry(point) NOT NULL;--> statement-breakpoint
ALTER TABLE "projects" ADD COLUMN "bottom_right" geometry(point) NOT NULL;