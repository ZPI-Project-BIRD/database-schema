import { decimal, integer, pgSchema, pgTable, text, timestamp } from "drizzle-orm/pg-core";

export const geoportal = pgSchema("geoportal");

export const features = geoportal.table("features", {
  id: text().primaryKey(),
  colorSpace: text("color_space").notNull(),
  pixelSize: decimal("pixel_size", { precision: 10, scale: 2 }).notNull(),
  datasetDate: timestamp("dataset_date").notNull(),
  fileSize: integer("file_size").notNull(),
  downloadedAt: timestamp("downloaded_at"),
});
