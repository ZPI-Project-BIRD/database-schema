import { sql } from "drizzle-orm";
import {
  boolean,
  decimal,
  integer,
  jsonb,
  pgSchema,
  pgTable,
  text,
  timestamp,
  uuid,
  geometry,
  varchar,
  uniqueIndex,
  check,
  primaryKey,
  pgEnum,
  index,
  bigint,
} from "drizzle-orm/pg-core";

export type DetectionBounds = Record<string, unknown>;

export const users = pgTable(
  "users",
  {
    id: uuid().primaryKey().defaultRandom(),
    friendlyName: varchar("friendly_name", { length: 256 }).notNull(),

    username: varchar({ length: 16 }).notNull(),
    passwordHash: text("password_hash").notNull(),

    isAdmin: boolean("is_admin").default(false).notNull(),

    bannedAt: timestamp("banned_at"),
    banReason: text("ban_reason"),
  },
  (t) => [
    uniqueIndex("uq_users_email").on(t.username),
    check("users_ban_reason_with_ban", sql`(${t.banReason} is null) = (${t.bannedAt} is null)`),
  ],
);

export const role = pgEnum("membership_role", ["1_VIEWER", "2_ANNOTATOR", "3_EDITOR", "4_OWNER"]);

export const memberships = pgTable(
  "memberships",
  {
    userId: uuid("user_id").notNull(),
    organizationId: uuid("organization_id").notNull(),
    role: role().default("1_VIEWER").notNull(),
  },
  (t) => [primaryKey({ columns: [t.userId, t.organizationId] })],
);

export const organizations = pgTable("organizations", {
  id: uuid().primaryKey().defaultRandom(),
  name: varchar({ length: 256 }).notNull(),
});

export const projects = pgTable("projects", {
  id: uuid().primaryKey().defaultRandom(),
  name: text().notNull(),
  organizationId: uuid("organization_id")
    .references(() => organizations.id)
    .notNull(),
  topLeft: geometry("top_left", { type: "point", mode: "xy", srid: 4326 }).notNull(),
  bottomRight: geometry("bottom_right", { type: "point", mode: "xy", srid: 4326 }).notNull(),
});

export const geoportal = pgSchema("geoportal");

export const features = geoportal.table(
  "features",
  {
    id: text().primaryKey(),

    sourceUrl: text("source_url").notNull(),
    colorSpace: text("color_space").notNull(),
    fileSize: integer("file_size"),
    objectName: text("object_name"),
    pixelSize: decimal("pixel_size", {
      precision: 10,
      scale: 2,
      mode: "number",
    }).notNull(),
    datasetDate: timestamp("dataset_date").notNull(),

    createdAt: timestamp("created_at").defaultNow().notNull(),
    updatedAt: timestamp("updated_at").defaultNow().notNull(),
    downloadedAt: timestamp("downloaded_at"),
  },
  (t) => [],
);

export const projectFeatures = geoportal.table(
  "project_features",
  {
    projectId: uuid("project_id")
      .references(() => projects.id, { onDelete: "cascade" })
      .notNull(),

    featureId: text("feature_id")
      .references(() => features.id, { onDelete: "cascade" })
      .notNull(),

    discoveredAt: timestamp("discovered_at").defaultNow().notNull(),
  },
  (t) => [
    primaryKey({
      name: "project_features_pk",
      columns: [t.projectId, t.featureId],
    }),

    index("ix_project_features_feature_id").on(t.featureId),
  ],
);

export const recognitionJobStatus = geoportal.enum("recognition_job_status", [
  "0_PENDING",
  "1_STARTED",
  "2_FINISHED",
  "3_FAILED",
]);

export const recognitionJobs = geoportal.table("recognition_jobs", {
  id: uuid().primaryKey().defaultRandom(),
  projectId: uuid("project_id").references(() => projects.id),
  featureId: text("feature_id").references(() => features.id),
  startedAt: timestamp("started_at").notNull().defaultNow(),
  finishedAt: timestamp("finished_at"),
  status: recognitionJobStatus().notNull().default("0_PENDING"),
  error: text(),
});

export const detections = geoportal.table("detections", {
  id: uuid().primaryKey().defaultRandom(),
  recognitionJobId: uuid("recognition_job_id")
    .references(() => recognitionJobs.id)
    .notNull(),
  bounds: jsonb(),
});
