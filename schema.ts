import { decimal, integer, pgSchema, pgTable, text, timestamp } from "drizzle-orm/pg-core";

const geoportal = pgSchema("geoportal");

export const features = geoportal.table("features", {
  id: text().primaryKey(),
  colorSpace: text().notNull(),
  pixelSize: decimal("pixel_size", { precision: 2 }).notNull(),
  datasetDate: timestamp("dataset_date").notNull(),
  fileSize: integer("file_size").notNull(),
  downloadedAt: timestamp("downloaded_at"),
});
