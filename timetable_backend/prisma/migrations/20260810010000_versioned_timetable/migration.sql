CREATE TABLE "TimetableDataset" (
    "id" TEXT NOT NULL,
    "version" TEXT NOT NULL,
    "sourceName" TEXT NOT NULL,
    "sourceSha256" TEXT NOT NULL,
    "timezone" TEXT NOT NULL DEFAULT 'Asia/Jakarta',
    "validFrom" DATE NOT NULL,
    "validTo" DATE,
    "isActive" BOOLEAN NOT NULL DEFAULT false,
    "importedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    CONSTRAINT "TimetableDataset_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "ServiceCalendar" (
    "id" TEXT NOT NULL,
    "datasetId" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "monday" BOOLEAN NOT NULL DEFAULT true,
    "tuesday" BOOLEAN NOT NULL DEFAULT true,
    "wednesday" BOOLEAN NOT NULL DEFAULT true,
    "thursday" BOOLEAN NOT NULL DEFAULT true,
    "friday" BOOLEAN NOT NULL DEFAULT true,
    "saturday" BOOLEAN NOT NULL DEFAULT true,
    "sunday" BOOLEAN NOT NULL DEFAULT true,
    "excludesPublicHolidays" BOOLEAN NOT NULL DEFAULT false,
    CONSTRAINT "ServiceCalendar_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "TrainService" (
    "id" TEXT NOT NULL,
    "datasetId" TEXT NOT NULL,
    "calendarId" TEXT NOT NULL,
    "lineId" TEXT NOT NULL,
    "trainNumber" TEXT NOT NULL,
    "continuationTrainNumber" TEXT,
    "relation" TEXT NOT NULL,
    "direction" TEXT NOT NULL,
    "loopNumber" INTEGER,
    "sourcePage" INTEGER NOT NULL,
    "sourceRow" INTEGER NOT NULL,
    "isFullRacket" BOOLEAN NOT NULL DEFAULT false,
    "notes" TEXT NOT NULL DEFAULT '',
    CONSTRAINT "TrainService_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "TrainStopTime" (
    "id" TEXT NOT NULL,
    "serviceId" TEXT NOT NULL,
    "stationId" TEXT NOT NULL,
    "stationCode" TEXT NOT NULL,
    "sequence" INTEGER NOT NULL,
    "arrivalMinute" INTEGER,
    "departureMinute" INTEGER,
    "isPassThrough" BOOLEAN NOT NULL DEFAULT false,
    CONSTRAINT "TrainStopTime_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "TimetableDataset_version_key" ON "TimetableDataset"("version");
CREATE INDEX "TimetableDataset_isActive_idx" ON "TimetableDataset"("isActive");
CREATE INDEX "TimetableDataset_sourceSha256_idx" ON "TimetableDataset"("sourceSha256");
CREATE UNIQUE INDEX "TimetableDataset_single_active_key" ON "TimetableDataset"("isActive") WHERE "isActive" = true;
CREATE UNIQUE INDEX "ServiceCalendar_datasetId_code_key" ON "ServiceCalendar"("datasetId", "code");
CREATE UNIQUE INDEX "TrainService_datasetId_trainNumber_key" ON "TrainService"("datasetId", "trainNumber");
CREATE UNIQUE INDEX "TrainService_datasetId_sourcePage_sourceRow_direction_key" ON "TrainService"("datasetId", "sourcePage", "sourceRow", "direction");
CREATE INDEX "TrainService_datasetId_continuationTrainNumber_idx" ON "TrainService"("datasetId", "continuationTrainNumber");
CREATE INDEX "TrainService_lineId_direction_idx" ON "TrainService"("lineId", "direction");
CREATE UNIQUE INDEX "TrainStopTime_serviceId_sequence_key" ON "TrainStopTime"("serviceId", "sequence");
CREATE INDEX "TrainStopTime_stationId_departureMinute_idx" ON "TrainStopTime"("stationId", "departureMinute");
CREATE INDEX "TrainStopTime_serviceId_stationId_idx" ON "TrainStopTime"("serviceId", "stationId");

ALTER TABLE "ServiceCalendar" ADD CONSTRAINT "ServiceCalendar_datasetId_fkey" FOREIGN KEY ("datasetId") REFERENCES "TimetableDataset"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "TrainService" ADD CONSTRAINT "TrainService_datasetId_fkey" FOREIGN KEY ("datasetId") REFERENCES "TimetableDataset"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "TrainService" ADD CONSTRAINT "TrainService_calendarId_fkey" FOREIGN KEY ("calendarId") REFERENCES "ServiceCalendar"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "TrainService" ADD CONSTRAINT "TrainService_lineId_fkey" FOREIGN KEY ("lineId") REFERENCES "Line"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "TrainStopTime" ADD CONSTRAINT "TrainStopTime_serviceId_fkey" FOREIGN KEY ("serviceId") REFERENCES "TrainService"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "TrainStopTime" ADD CONSTRAINT "TrainStopTime_stationId_fkey" FOREIGN KEY ("stationId") REFERENCES "Station"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
