-- CreateTable
CREATE TABLE "StationPlatformRule" (
    "id" TEXT NOT NULL,
    "stationId" TEXT NOT NULL,
    "lineSlug" TEXT NOT NULL,
    "direction" TEXT NOT NULL,
    "destination" TEXT,
    "platform" TEXT NOT NULL,
    "sourceName" TEXT NOT NULL,
    "sourceUrl" TEXT NOT NULL,
    "validFrom" DATE,
    "validTo" DATE,
    "verifiedAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "StationPlatformRule_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "StationPlatformRule_stationId_lineSlug_direction_idx" ON "StationPlatformRule"("stationId", "lineSlug", "direction");

-- CreateIndex
CREATE UNIQUE INDEX "StationPlatformRule_stationId_lineSlug_direction_destinatio_key" ON "StationPlatformRule"("stationId", "lineSlug", "direction", "destination");

-- AddForeignKey
ALTER TABLE "StationPlatformRule" ADD CONSTRAINT "StationPlatformRule_stationId_fkey" FOREIGN KEY ("stationId") REFERENCES "Station"("id") ON DELETE CASCADE ON UPDATE CASCADE;
