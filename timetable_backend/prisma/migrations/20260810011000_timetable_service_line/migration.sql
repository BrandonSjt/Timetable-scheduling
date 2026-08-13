ALTER TABLE "TrainService" ADD COLUMN "lineSlug" TEXT NOT NULL DEFAULT '';
ALTER TABLE "TrainService" ALTER COLUMN "lineSlug" DROP DEFAULT;
ALTER TABLE "TrainService" DROP CONSTRAINT "TrainService_lineId_fkey";
DROP INDEX "TrainService_lineId_direction_idx";
ALTER TABLE "TrainService" DROP COLUMN "lineId";
CREATE INDEX "TrainService_datasetId_lineSlug_direction_idx" ON "TrainService"("datasetId", "lineSlug", "direction");
