ALTER TABLE "Station"
ADD COLUMN "officialName" TEXT,
ADD COLUMN "isBoardingAllowed" BOOLEAN NOT NULL DEFAULT true;

CREATE TABLE "StationPublicCode" (
    "id" TEXT NOT NULL,
    "stationId" TEXT NOT NULL,
    "lineId" TEXT NOT NULL,
    "code" TEXT NOT NULL,

    CONSTRAINT "StationPublicCode_pkey" PRIMARY KEY ("id")
);

INSERT INTO "StationPublicCode" ("id", "stationId", "lineId", "code")
SELECT
    'public-code-' || md5(n."id" || ':' || n."lineId"),
    n."stationId",
    n."lineId",
    CASE n."mapId"
        WHEN 'tanjung_priok' THEN 'TP04'
        WHEN 'parung_panjang' THEN 'R12'
        WHEN 'cilejit' THEN 'R14'
        WHEN 'daru' THEN 'R15'
        WHEN 'tenjo' THEN 'R16'
        WHEN 'tigaraksa' THEN 'R18'
        WHEN 'cikoya' THEN 'R19'
        WHEN 'maja' THEN 'R20'
        WHEN 'citeras' THEN 'R21'
        WHEN 'rangkasbitung' THEN 'R22'
        ELSE n."code"
    END
FROM "StationNode" n
WHERE n."mapId" <> 'jis';

CREATE UNIQUE INDEX "StationPublicCode_stationId_lineId_key"
ON "StationPublicCode"("stationId", "lineId");

CREATE UNIQUE INDEX "StationPublicCode_lineId_code_key"
ON "StationPublicCode"("lineId", "code");

CREATE INDEX "StationPublicCode_code_idx" ON "StationPublicCode"("code");

ALTER TABLE "StationPublicCode"
ADD CONSTRAINT "StationPublicCode_stationId_fkey"
FOREIGN KEY ("stationId") REFERENCES "Station"("id")
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "StationPublicCode"
ADD CONSTRAINT "StationPublicCode_lineId_fkey"
FOREIGN KEY ("lineId") REFERENCES "Line"("id")
ON DELETE CASCADE ON UPDATE CASCADE;
