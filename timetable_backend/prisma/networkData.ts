export type ServiceType = 'KRL' | 'LRT' | 'MRT';

export type NetworkNode = {
  mapId: string;
  code: string;
  publicCode?: string | null;
  lineSlug: string;
  sequence: number;
  x: number;
  y: number;
  isTransit: boolean;
};

export type NetworkStation = {
  slug: string;
  name: string;
  officialName?: string;
  operationalCode?: string;
  isBoardingAllowed?: boolean;
  lineSlugs?: readonly string[];
  publicCodes?: ReadonlyArray<{ lineSlug: string; code: string }>;
  lineInfo: string;
  statusText: string;
  isTransit: boolean;
  isAccessible: boolean;
  isLrt: boolean;
  isKrl: boolean;
  isMrt: boolean;
  aliases: readonly string[];
  nodes: readonly NetworkNode[];
};

type NetworkLine = {
  slug: string;
  name: string;
  color: string;
  serviceType: ServiceType;
  nodeCodes: readonly string[];
};

type NetworkData = {
  stations: readonly NetworkStation[];
  lines: readonly NetworkLine[];
  transfers: ReadonlyArray<{ from: string; to: string; walkingTime: number }>;
};

// Canonical snapshot derived from the approved KAIACCES mobile schematic.
// The backend owns this copy so production seeding never depends on a local Flutter path.
export const networkData = {
  "stations": [
    {
      "slug": "bundaran-hi",
      "name": "Bundaran HI",
      "officialName": "Bundaran HI Bank Jakarta",
      "lineInfo": "MRT Lin Utara - Selatan",
      "statusText": "Stasiun Utama · 3 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": false,
      "isMrt": true,
      "aliases": [
        "Bundaran HI Bank Jakarta"
      ],
      "nodes": [
        {
          "mapId": "bundaran_hi",
          "code": "M13",
          "lineSlug": "mrt",
          "sequence": 0,
          "x": 1075,
          "y": 810,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "dukuh-atas",
      "name": "Dukuh Atas",
      "officialName": "Dukuh Atas BNI",
      "lineInfo": "MRT, LRT Jabodebek, & KRL",
      "statusText": "Transit Utama · 3 menit",
      "isTransit": true,
      "isAccessible": true,
      "isLrt": true,
      "isKrl": true,
      "isMrt": true,
      "aliases": [
        "Dukuh Atas BNI"
      ],
      "nodes": [
        {
          "mapId": "dukuh_atas",
          "code": "M12",
          "lineSlug": "mrt",
          "sequence": 1,
          "x": 1075,
          "y": 915,
          "isTransit": true
        }
      ]
    },
    {
      "slug": "setiabudi",
      "name": "Setiabudi",
      "officialName": "Setiabudi Astra",
      "lineInfo": "MRT, LRT Jabodebek, & KRL",
      "statusText": "Transit Aksesibel · 4 menit",
      "isTransit": true,
      "isAccessible": true,
      "isLrt": true,
      "isKrl": true,
      "isMrt": true,
      "aliases": [
        "Setiabudi Astra"
      ],
      "nodes": [
        {
          "mapId": "setiabudi",
          "code": "M11",
          "lineSlug": "mrt",
          "sequence": 2,
          "x": 955,
          "y": 1155,
          "isTransit": true
        }
      ]
    },
    {
      "slug": "bendungan-hilir",
      "name": "Bendungan Hilir",
      "lineInfo": "MRT Lin Utara - Selatan",
      "statusText": "Lancar · 5 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": false,
      "isMrt": true,
      "aliases": [],
      "nodes": [
        {
          "mapId": "bendungan_hilir",
          "code": "M10",
          "lineSlug": "mrt",
          "sequence": 3,
          "x": 835,
          "y": 1275,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "istora-mandiri",
      "name": "Istora Mandiri",
      "lineInfo": "MRT Lin Utara - Selatan",
      "statusText": "Lancar · 4 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": false,
      "isMrt": true,
      "aliases": [],
      "nodes": [
        {
          "mapId": "istora",
          "code": "M09",
          "lineSlug": "mrt",
          "sequence": 4,
          "x": 745,
          "y": 1365,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "senayan",
      "name": "Senayan",
      "officialName": "Senayan Mastercard",
      "lineInfo": "MRT Lin Utara - Selatan",
      "statusText": "Lancar · 5 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": false,
      "isMrt": true,
      "aliases": [
        "Senayan Mastercard"
      ],
      "nodes": [
        {
          "mapId": "senayan",
          "code": "M08",
          "lineSlug": "mrt",
          "sequence": 5,
          "x": 700,
          "y": 1530,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "asean-hq",
      "name": "ASEAN HQ",
      "officialName": "ASEAN Headquarters",
      "lineInfo": "MRT Lin Utara - Selatan",
      "statusText": "Lancar · 6 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": false,
      "isMrt": true,
      "aliases": [],
      "nodes": [
        {
          "mapId": "asean",
          "code": "M07",
          "lineSlug": "mrt",
          "sequence": 6,
          "x": 700,
          "y": 1635,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "blok-m",
      "name": "Blok M",
      "officialName": "Blok M BCA",
      "lineInfo": "MRT Lin Utara - Selatan",
      "statusText": "Lift & Eskalator",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": false,
      "isMrt": true,
      "aliases": [
        "Blok M BCA"
      ],
      "nodes": [
        {
          "mapId": "blok_m",
          "code": "M06",
          "lineSlug": "mrt",
          "sequence": 7,
          "x": 700,
          "y": 1740,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "blok-a",
      "name": "Blok A",
      "lineInfo": "MRT Lin Utara - Selatan",
      "statusText": "Lancar · 4 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": false,
      "isMrt": true,
      "aliases": [],
      "nodes": [
        {
          "mapId": "blok_a",
          "code": "M05",
          "lineSlug": "mrt",
          "sequence": 8,
          "x": 700,
          "y": 1845,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "haji-nawi",
      "name": "Haji Nawi",
      "lineInfo": "MRT Lin Utara - Selatan",
      "statusText": "Lancar · 5 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": false,
      "isMrt": true,
      "aliases": [],
      "nodes": [
        {
          "mapId": "haji_nawi",
          "code": "M04",
          "lineSlug": "mrt",
          "sequence": 9,
          "x": 700,
          "y": 1950,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "cipete-raya",
      "name": "Cipete Raya",
      "officialName": "Cipete Raya TUKU",
      "lineInfo": "MRT Lin Utara - Selatan",
      "statusText": "Lancar · 5 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": false,
      "isMrt": true,
      "aliases": [
        "Cipete Raya TUKU"
      ],
      "nodes": [
        {
          "mapId": "cipete_raya",
          "code": "M03",
          "lineSlug": "mrt",
          "sequence": 10,
          "x": 700,
          "y": 2055,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "fatmawati",
      "name": "Fatmawati",
      "officialName": "Fatmawati Indomaret",
      "lineInfo": "MRT Lin Utara - Selatan",
      "statusText": "Lancar · 4 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": false,
      "isMrt": true,
      "aliases": [
        "Fatmawati Indomaret"
      ],
      "nodes": [
        {
          "mapId": "fatmawati",
          "code": "M02",
          "lineSlug": "mrt",
          "sequence": 11,
          "x": 565,
          "y": 2160,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "lebak-bulus",
      "name": "Lebak Bulus",
      "officialName": "Lebak Bulus Bank Syariah Indonesia",
      "lineInfo": "MRT Lin Utara - Selatan",
      "statusText": "Terminus · 3 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": false,
      "isMrt": true,
      "aliases": [
        "Lebak Bulus BSI"
      ],
      "nodes": [
        {
          "mapId": "lebak_bulus",
          "code": "M01",
          "lineSlug": "mrt",
          "sequence": 12,
          "x": 325,
          "y": 2160,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "jakarta-kota",
      "name": "Jakarta Kota",
      "lineInfo": "KRL Lin Bogor & Tanjung Priok",
      "statusText": "Transit Terminus · 5 menit",
      "isTransit": true,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "jakarta_kota_bk",
          "code": "B01",
          "lineSlug": "bogor",
          "sequence": 0,
          "x": 1000,
          "y": 264,
          "isTransit": true
        },
        {
          "mapId": "jakarta_kota_tp",
          "code": "TP01",
          "lineSlug": "tanjung_priok",
          "sequence": 0,
          "x": 1000,
          "y": 240,
          "isTransit": true
        }
      ]
    },
    {
      "slug": "jayakarta",
      "name": "Jayakarta",
      "lineInfo": "KRL Lin Bogor",
      "statusText": "Lancar · 4 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "jayakarta",
          "code": "B02",
          "lineSlug": "bogor",
          "sequence": 1,
          "x": 1150,
          "y": 345,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "mangga-besar",
      "name": "Mangga Besar",
      "lineInfo": "KRL Lin Bogor",
      "statusText": "Lancar · 4 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "mangga_besar",
          "code": "B03",
          "lineSlug": "bogor",
          "sequence": 2,
          "x": 1150,
          "y": 465,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "sawah-besar",
      "name": "Sawah Besar",
      "lineInfo": "KRL Lin Bogor",
      "statusText": "Lancar · 5 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "sawah_besar",
          "code": "B04",
          "lineSlug": "bogor",
          "sequence": 3,
          "x": 1150,
          "y": 585,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "juanda",
      "name": "Juanda",
      "lineInfo": "KRL Lin Bogor",
      "statusText": "Peron Ramai · 4 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "juanda",
          "code": "B05",
          "lineSlug": "bogor",
          "sequence": 4,
          "x": 1150,
          "y": 705,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "gambir",
      "name": "Gambir",
      "operationalCode": "GMR",
      "isBoardingAllowed": false,
      "lineSlugs": [
        "bogor"
      ],
      "publicCodes": [
        {
          "lineSlug": "bogor",
          "code": "B06"
        }
      ],
      "lineInfo": "KRL Lin Bogor (lintas langsung)",
      "statusText": "Tidak melayani naik/turun",
      "isTransit": false,
      "isAccessible": false,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": []
    },
    {
      "slug": "gondangdia",
      "name": "Gondangdia",
      "lineInfo": "KRL Lin Bogor",
      "statusText": "Lancar · 4 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "gondangdia",
          "code": "B07",
          "lineSlug": "bogor",
          "sequence": 5,
          "x": 1225,
          "y": 945,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "cikini",
      "name": "Cikini",
      "lineInfo": "KRL Lin Bogor",
      "statusText": "Lancar · 5 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "cikini",
          "code": "B08",
          "lineSlug": "bogor",
          "sequence": 6,
          "x": 1300,
          "y": 1020,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "manggarai",
      "name": "Manggarai",
      "lineInfo": "KRL Lin Bogor & Cikarang",
      "statusText": "Transit Utama · 3 menit",
      "isTransit": true,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "manggarai_bk",
          "code": "B09",
          "lineSlug": "bogor",
          "sequence": 7,
          "x": 1390,
          "y": 1110,
          "isTransit": false
        },
        {
          "mapId": "manggarai_cb",
          "code": "C13",
          "lineSlug": "cikarang_loop",
          "sequence": 14,
          "x": 1375,
          "y": 1125,
          "isTransit": true
        }
      ]
    },
    {
      "slug": "tebet",
      "name": "Tebet",
      "lineInfo": "KRL Lin Bogor",
      "statusText": "Lancar · 4 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "tebet",
          "code": "B10",
          "lineSlug": "bogor",
          "sequence": 8,
          "x": 1555,
          "y": 1425,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "cawang",
      "name": "Cawang",
      "lineInfo": "KRL Lin Bogor & transit pejalan kaki ke LRT Cikoko",
      "statusText": "Transit Cikoko · 5 menit berjalan kaki",
      "isTransit": true,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "cawang_krl",
          "code": "B11",
          "lineSlug": "bogor",
          "sequence": 9,
          "x": 1555,
          "y": 1575,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "cawang-lrt",
      "name": "Cawang LRT",
      "officialName": "Cawang",
      "lineInfo": "LRT Jabodebek Lin Bekasi & Cibubur",
      "statusText": "Transit antarlini LRT",
      "isTransit": true,
      "isAccessible": true,
      "isLrt": true,
      "isKrl": false,
      "isMrt": false,
      "aliases": ["LRT Cawang"],
      "nodes": [
        {
          "mapId": "cawang_lrt_bk",
          "code": "BK08",
          "lineSlug": "lrt_bekasi",
          "sequence": 7,
          "x": 1900,
          "y": 1644,
          "isTransit": true
        },
        {
          "mapId": "cawang_lrt_cb",
          "code": "CB08",
          "lineSlug": "lrt_cibubur",
          "sequence": 7,
          "x": 1900,
          "y": 1656,
          "isTransit": true
        }
      ]
    },
    {
      "slug": "duren-kalibata",
      "name": "Duren Kalibata",
      "lineInfo": "KRL Lin Bogor",
      "statusText": "Lancar · 5 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "duren_kalibata",
          "code": "B12",
          "lineSlug": "bogor",
          "sequence": 10,
          "x": 1555,
          "y": 1725,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "pasar-minggu-baru",
      "name": "Pasar Minggu Baru",
      "lineInfo": "KRL Lin Bogor",
      "statusText": "Lancar · 4 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "pasar_minggu_baru",
          "code": "B13",
          "lineSlug": "bogor",
          "sequence": 11,
          "x": 1555,
          "y": 1800,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "pasar-minggu",
      "name": "Pasar Minggu",
      "lineInfo": "KRL Lin Bogor",
      "statusText": "Lancar · 5 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "pasar_minggu",
          "code": "B14",
          "lineSlug": "bogor",
          "sequence": 12,
          "x": 1555,
          "y": 1875,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "tanjung-barat",
      "name": "Tanjung Barat",
      "lineInfo": "KRL Lin Bogor",
      "statusText": "Lancar · 4 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "tanjung_barat",
          "code": "B15",
          "lineSlug": "bogor",
          "sequence": 13,
          "x": 1555,
          "y": 2025,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "lenteng-agung",
      "name": "Lenteng Agung",
      "lineInfo": "KRL Lin Bogor",
      "statusText": "Lancar · 5 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "lenteng_agung",
          "code": "B16",
          "lineSlug": "bogor",
          "sequence": 14,
          "x": 1555,
          "y": 2175,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "univ-pancasila",
      "name": "Univ. Pancasila",
      "officialName": "Universitas Pancasila",
      "lineInfo": "KRL Lin Bogor",
      "statusText": "Lancar · 4 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "univ_pancasila",
          "code": "B17",
          "lineSlug": "bogor",
          "sequence": 15,
          "x": 1555,
          "y": 2325,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "univ-indonesia",
      "name": "Univ. Indonesia",
      "officialName": "Universitas Indonesia",
      "lineInfo": "KRL Lin Bogor",
      "statusText": "Lancar · 5 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "univ_indonesia",
          "code": "B18",
          "lineSlug": "bogor",
          "sequence": 16,
          "x": 1555,
          "y": 2475,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "pondok-cina",
      "name": "Pondok Cina",
      "lineInfo": "KRL Lin Bogor",
      "statusText": "Lancar · 4 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "pondok_cina",
          "code": "B19",
          "lineSlug": "bogor",
          "sequence": 17,
          "x": 1555,
          "y": 2625,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "depok-baru",
      "name": "Depok Baru",
      "lineInfo": "KRL Lin Bogor",
      "statusText": "Lancar · 5 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "depok_baru",
          "code": "B20",
          "lineSlug": "bogor",
          "sequence": 18,
          "x": 1555,
          "y": 2775,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "depok",
      "name": "Depok",
      "lineInfo": "KRL Lin Bogor",
      "statusText": "Peron Ramai · 4 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "depok",
          "code": "B21",
          "lineSlug": "bogor",
          "sequence": 19,
          "x": 1660,
          "y": 2925,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "citayam",
      "name": "Citayam",
      "lineInfo": "KRL Lin Bogor & Cabang Nambo",
      "statusText": "Transit Cabang · 5 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "citayam",
          "code": "B22",
          "lineSlug": "bogor_nambo",
          "sequence": 0,
          "x": 1765,
          "y": 2925,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "bojong-gede",
      "name": "Bojong Gede",
      "lineInfo": "KRL Lin Bogor",
      "statusText": "Lancar · 5 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "bojong_gede",
          "code": "B23",
          "lineSlug": "bogor",
          "sequence": 21,
          "x": 1870,
          "y": 2925,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "cilebut",
      "name": "Cilebut",
      "lineInfo": "KRL Lin Bogor",
      "statusText": "Lancar · 4 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "cilebut",
          "code": "B24",
          "lineSlug": "bogor",
          "sequence": 22,
          "x": 1975,
          "y": 2925,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "bogor",
      "name": "Bogor",
      "lineInfo": "KRL Lin Bogor",
      "statusText": "Terminus · 5 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "bogor",
          "code": "B26",
          "lineSlug": "bogor",
          "sequence": 23,
          "x": 2080,
          "y": 2925,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "pondok-rajeg",
      "name": "Pondok Rajeg",
      "lineInfo": "KRL Cabang Nambo",
      "statusText": "Lancar · 6 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "pondok_rajeg",
          "code": "b23",
          "lineSlug": "bogor_nambo",
          "sequence": 1,
          "x": 1885,
          "y": 2775,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "cibinong",
      "name": "Cibinong",
      "lineInfo": "KRL Cabang Nambo",
      "statusText": "Lancar · 7 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "cibinong",
          "code": "b24",
          "lineSlug": "bogor_nambo",
          "sequence": 2,
          "x": 1960,
          "y": 2775,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "gunung-putri",
      "name": "Gunung Putri",
      "lineInfo": "KRL Cabang Nambo",
      "statusText": "Lancar · 8 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "gunung_putri",
          "code": "b25",
          "lineSlug": "bogor_nambo",
          "sequence": 3,
          "x": 2035,
          "y": 2775,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "nambo",
      "name": "Nambo",
      "lineInfo": "KRL Cabang Nambo",
      "statusText": "Terminus Cabang · 8 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "nambo",
          "code": "b26",
          "lineSlug": "bogor_nambo",
          "sequence": 4,
          "x": 2110,
          "y": 2775,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "cikarang",
      "name": "Cikarang",
      "lineInfo": "KRL Lin Cikarang Timur",
      "statusText": "Terminus Timur · 6 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "cikarang",
          "code": "C26",
          "lineSlug": "cikarang_east",
          "sequence": 11,
          "x": 2770,
          "y": 1230,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "metland-telagamurni",
      "name": "Metland Telagamurni",
      "officialName": "Metland Telaga Murni",
      "lineInfo": "KRL Lin Cikarang",
      "statusText": "Lancar · 5 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "metland_telagamurni",
          "code": "C25",
          "lineSlug": "cikarang_east",
          "sequence": 10,
          "x": 2680,
          "y": 1230,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "cibitung",
      "name": "Cibitung",
      "lineInfo": "KRL Lin Cikarang",
      "statusText": "Lancar · 6 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "cibitung",
          "code": "C24",
          "lineSlug": "cikarang_east",
          "sequence": 9,
          "x": 2590,
          "y": 1230,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "tambun",
      "name": "Tambun",
      "lineInfo": "KRL Lin Cikarang",
      "statusText": "Lancar · 5 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "tambun",
          "code": "C23",
          "lineSlug": "cikarang_east",
          "sequence": 8,
          "x": 2500,
          "y": 1230,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "bekasi-timur",
      "name": "Bekasi Timur",
      "lineInfo": "KRL Lin Cikarang",
      "statusText": "Lancar · 5 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "bekasi_timur",
          "code": "C22",
          "lineSlug": "cikarang_east",
          "sequence": 7,
          "x": 2410,
          "y": 1230,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "bekasi",
      "name": "Bekasi",
      "lineInfo": "KRL Lin Cikarang",
      "statusText": "Transit Utama · 4 menit",
      "isTransit": true,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "bekasi",
          "code": "C21",
          "lineSlug": "cikarang_east",
          "sequence": 6,
          "x": 2320,
          "y": 1230,
          "isTransit": true
        }
      ]
    },
    {
      "slug": "kranji",
      "name": "Kranji",
      "lineInfo": "KRL Lin Cikarang",
      "statusText": "Lancar · 4 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "kranji",
          "code": "C20",
          "lineSlug": "cikarang_east",
          "sequence": 5,
          "x": 2230,
          "y": 1230,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "cakung",
      "name": "Cakung",
      "lineInfo": "KRL Lin Cikarang",
      "statusText": "Lancar · 5 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "cakung",
          "code": "C19",
          "lineSlug": "cikarang_east",
          "sequence": 4,
          "x": 2140,
          "y": 1230,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "klender-baru",
      "name": "Klender Baru",
      "lineInfo": "KRL Lin Cikarang",
      "statusText": "Lancar · 4 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "klender_baru",
          "code": "C18",
          "lineSlug": "cikarang_east",
          "sequence": 3,
          "x": 2050,
          "y": 1230,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "buaran",
      "name": "Buaran",
      "lineInfo": "KRL Lin Cikarang",
      "statusText": "Lancar · 4 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "buaran",
          "code": "C17",
          "lineSlug": "cikarang_east",
          "sequence": 2,
          "x": 1960,
          "y": 1230,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "klender",
      "name": "Klender",
      "lineInfo": "KRL Lin Cikarang",
      "statusText": "Lancar · 5 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "klender",
          "code": "C16",
          "lineSlug": "cikarang_east",
          "sequence": 1,
          "x": 1870,
          "y": 1230,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "jatinegara",
      "name": "Jatinegara",
      "lineInfo": "KRL Lin Cikarang Loop & East",
      "statusText": "Transit Utama · 4 menit",
      "isTransit": true,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "jatinegara",
          "code": "C15",
          "lineSlug": "cikarang_east",
          "sequence": 0,
          "x": 1690,
          "y": 1230,
          "isTransit": true
        }
      ]
    },
    {
      "slug": "matraman",
      "name": "Matraman",
      "lineInfo": "KRL Lin Cikarang",
      "statusText": "Lancar · 4 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "matraman",
          "code": "C14",
          "lineSlug": "cikarang_loop",
          "sequence": 15,
          "x": 1540,
          "y": 1230,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "sudirman",
      "name": "Sudirman",
      "lineInfo": "KRL Lin Cikarang & MRT",
      "statusText": "Transit Sudirman · 3 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": true,
      "aliases": [],
      "nodes": [
        {
          "mapId": "sudirman",
          "code": "C12",
          "lineSlug": "cikarang_loop",
          "sequence": 13,
          "x": 1105,
          "y": 1005,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "bni-city",
      "name": "BNI City",
      "lineInfo": "KRL Cikarang & Kereta Bandara",
      "statusText": "Transit Bandara · 5 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "bni_city",
          "code": "C11a",
          "lineSlug": "cikarang_loop",
          "sequence": 12,
          "x": 1000,
          "y": 1005,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "karet",
      "name": "Karet",
      "lineInfo": "KRL Lin Cikarang",
      "statusText": "Lancar · 4 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "karet",
          "code": "C11",
          "lineSlug": "cikarang_loop",
          "sequence": 11,
          "x": 700,
          "y": 1005,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "tanah-abang",
      "name": "Tanah Abang",
      "lineInfo": "KRL Lin Cikarang & Rangkasbitung",
      "statusText": "Transit Utama · 4 menit",
      "isTransit": true,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "tanah_abang_r",
          "code": "R01",
          "lineSlug": "rangkasbitung",
          "sequence": 0,
          "x": 550,
          "y": 825,
          "isTransit": true
        },
        {
          "mapId": "tanah_abang_c",
          "code": "C10",
          "lineSlug": "cikarang_loop",
          "sequence": 10,
          "x": 550,
          "y": 825,
          "isTransit": true
        }
      ]
    },
    {
      "slug": "duri",
      "name": "Duri",
      "lineInfo": "KRL Lin Cikarang & Tangerang",
      "statusText": "Transit Tangerang · 4 menit",
      "isTransit": true,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "duri_c",
          "code": "C09",
          "lineSlug": "cikarang_loop",
          "sequence": 9,
          "x": 550,
          "y": 675,
          "isTransit": true
        },
        {
          "mapId": "duri_t",
          "code": "T01",
          "lineSlug": "tangerang",
          "sequence": 0,
          "x": 550,
          "y": 675,
          "isTransit": true
        }
      ]
    },
    {
      "slug": "angke",
      "name": "Angke",
      "lineInfo": "KRL Lin Cikarang Loop",
      "statusText": "Terminus Loop · 5 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "angke",
          "code": "C08",
          "lineSlug": "cikarang_loop",
          "sequence": 8,
          "x": 550,
          "y": 525,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "kp-bandan",
      "name": "Kp. Bandan",
      "officialName": "Kampung Bandan",
      "lineInfo": "KRL Lin Cikarang & Priok",
      "statusText": "Transit Loop Utara · 5 menit",
      "isTransit": true,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "kampung_bandan",
          "code": "C07",
          "lineSlug": "cikarang_loop",
          "sequence": 7,
          "x": 1270,
          "y": 255,
          "isTransit": true
        },
        {
          "mapId": "kampung_bandan_tp",
          "code": "TP02",
          "lineSlug": "tanjung_priok",
          "sequence": 1,
          "x": 1270,
          "y": 240,
          "isTransit": true
        }
      ]
    },
    {
      "slug": "rajawali",
      "name": "Rajawali",
      "lineInfo": "KRL Lin Cikarang Loop",
      "statusText": "Lancar · 4 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "rajawali",
          "code": "C06",
          "lineSlug": "cikarang_loop",
          "sequence": 6,
          "x": 1450,
          "y": 450,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "kemayoran",
      "name": "Kemayoran",
      "lineInfo": "KRL Lin Cikarang Loop",
      "statusText": "Lancar · 5 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "kemayoran",
          "code": "C05",
          "lineSlug": "cikarang_loop",
          "sequence": 5,
          "x": 1450,
          "y": 570,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "pasar-senen",
      "name": "Pasar Senen",
      "lineInfo": "KRL Lin Cikarang Loop",
      "statusText": "Stasiun Besar · 4 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "pasar_senen",
          "code": "C04",
          "lineSlug": "cikarang_loop",
          "sequence": 4,
          "x": 1450,
          "y": 690,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "gang-sentiong",
      "name": "Gang Sentiong",
      "lineInfo": "KRL Lin Cikarang Loop",
      "statusText": "Lancar · 4 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "gang_sentiong",
          "code": "C03",
          "lineSlug": "cikarang_loop",
          "sequence": 3,
          "x": 1480,
          "y": 900,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "kramat",
      "name": "Kramat",
      "lineInfo": "KRL Lin Cikarang Loop",
      "statusText": "Lancar · 5 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "kramat",
          "code": "C02",
          "lineSlug": "cikarang_loop",
          "sequence": 2,
          "x": 1540,
          "y": 960,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "pondok-jati",
      "name": "Pondok Jati",
      "lineInfo": "KRL Lin Cikarang Loop",
      "statusText": "Lancar · 4 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "pondok_jati",
          "code": "C01",
          "lineSlug": "cikarang_loop",
          "sequence": 1,
          "x": 1600,
          "y": 1110,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "grogol",
      "name": "Grogol",
      "lineInfo": "KRL Lin Tangerang",
      "statusText": "Lancar · 4 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "grogol",
          "code": "T02",
          "lineSlug": "tangerang",
          "sequence": 1,
          "x": 490,
          "y": 675,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "pesing",
      "name": "Pesing",
      "lineInfo": "KRL Lin Tangerang",
      "statusText": "Lancar · 5 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "pesing",
          "code": "T03",
          "lineSlug": "tangerang",
          "sequence": 2,
          "x": 420,
          "y": 715,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "taman-kota",
      "name": "Taman Kota",
      "lineInfo": "KRL Lin Tangerang",
      "statusText": "Lancar · 4 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "taman_kota",
          "code": "T04",
          "lineSlug": "tangerang",
          "sequence": 3,
          "x": 350,
          "y": 755,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "bojong-indah",
      "name": "Bojong Indah",
      "lineInfo": "KRL Lin Tangerang",
      "statusText": "Lancar · 4 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "bojong_indah",
          "code": "T05",
          "lineSlug": "tangerang",
          "sequence": 4,
          "x": 270,
          "y": 755,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "rawa-buaya",
      "name": "Rawa Buaya",
      "lineInfo": "KRL Lin Tangerang",
      "statusText": "Lancar · 5 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "rawa_buaya",
          "code": "T06",
          "lineSlug": "tangerang",
          "sequence": 5,
          "x": 190,
          "y": 755,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "kalideres",
      "name": "Kalideres",
      "lineInfo": "KRL Lin Tangerang",
      "statusText": "Lancar · 4 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "kalideres",
          "code": "T07",
          "lineSlug": "tangerang",
          "sequence": 6,
          "x": 110,
          "y": 755,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "poris",
      "name": "Poris",
      "lineInfo": "KRL Lin Tangerang",
      "statusText": "Lancar · 5 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "poris",
          "code": "T08",
          "lineSlug": "tangerang",
          "sequence": 7,
          "x": 30,
          "y": 755,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "batu-ceper",
      "name": "Batu Ceper",
      "lineInfo": "KRL Lin Tangerang & Airport",
      "statusText": "Transit Bandara · 4 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "batu_ceper",
          "code": "T09",
          "lineSlug": "tangerang",
          "sequence": 8,
          "x": -50,
          "y": 755,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "tanah-tinggi",
      "name": "Tanah Tinggi",
      "lineInfo": "KRL Lin Tangerang",
      "statusText": "Lancar · 4 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "tanah_tinggi",
          "code": "T10",
          "lineSlug": "tangerang",
          "sequence": 9,
          "x": -130,
          "y": 755,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "tangerang",
      "name": "Tangerang",
      "lineInfo": "KRL Lin Tangerang",
      "statusText": "Terminus · 5 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "tangerang",
          "code": "T11",
          "lineSlug": "tangerang",
          "sequence": 10,
          "x": -210,
          "y": 755,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "palmerah",
      "name": "Palmerah",
      "lineInfo": "KRL Lin Rangkasbitung",
      "statusText": "Lancar · 4 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "palmerah",
          "code": "R02",
          "lineSlug": "rangkasbitung",
          "sequence": 1,
          "x": 520,
          "y": 895,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "kebayoran",
      "name": "Kebayoran",
      "lineInfo": "KRL Lin Rangkasbitung",
      "statusText": "Lancar · 5 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "kebayoran",
          "code": "R03",
          "lineSlug": "rangkasbitung",
          "sequence": 2,
          "x": 490,
          "y": 965,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "pondok-ranji",
      "name": "Pondok Ranji",
      "lineInfo": "KRL Lin Rangkasbitung",
      "statusText": "Lancar · 4 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "pondok_ranji",
          "code": "R04",
          "lineSlug": "rangkasbitung",
          "sequence": 3,
          "x": 450,
          "y": 1045,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "jurangmangu",
      "name": "Jurangmangu",
      "lineInfo": "KRL Lin Rangkasbitung",
      "statusText": "Lancar · 5 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "jurangmangu",
          "code": "R05",
          "lineSlug": "rangkasbitung",
          "sequence": 4,
          "x": 410,
          "y": 1085,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "sudimara",
      "name": "Sudimara",
      "lineInfo": "KRL Lin Rangkasbitung",
      "statusText": "Lancar · 4 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "sudimara",
          "code": "R06",
          "lineSlug": "rangkasbitung",
          "sequence": 5,
          "x": 370,
          "y": 1125,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "rawa-buntu",
      "name": "Rawa Buntu",
      "lineInfo": "KRL Lin Rangkasbitung",
      "statusText": "Lancar · 5 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "rawa_buntu",
          "code": "R07",
          "lineSlug": "rangkasbitung",
          "sequence": 6,
          "x": 270,
          "y": 1165,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "serpong",
      "name": "Serpong",
      "lineInfo": "KRL Lin Rangkasbitung",
      "statusText": "Lancar · 4 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "serpong",
          "code": "R08",
          "lineSlug": "rangkasbitung",
          "sequence": 7,
          "x": 230,
          "y": 1165,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "cisauk",
      "name": "Cisauk",
      "lineInfo": "KRL Lin Rangkasbitung",
      "statusText": "Lancar · 5 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "cisauk",
          "code": "R09",
          "lineSlug": "rangkasbitung",
          "sequence": 8,
          "x": 190,
          "y": 1165,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "cicayur",
      "name": "Cicayur",
      "lineInfo": "KRL Lin Rangkasbitung",
      "statusText": "Lancar · 5 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "cicayur",
          "code": "R10",
          "lineSlug": "rangkasbitung",
          "sequence": 9,
          "x": 150,
          "y": 1165,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "jatake",
      "name": "Jatake",
      "operationalCode": "JTK",
      "isBoardingAllowed": true,
      "lineSlugs": [
        "rangkasbitung"
      ],
      "lineInfo": "KRL Lin Rangkasbitung",
      "statusText": "Melayani naik/turun",
      "isTransit": false,
      "isAccessible": false,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": []
    },
    {
      "slug": "parung-panjang",
      "name": "Parung Panjang",
      "lineInfo": "KRL Lin Rangkasbitung",
      "statusText": "Stasiun Antara · 6 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "parung_panjang",
          "code": "R11",
          "publicCode": "R12",
          "lineSlug": "rangkasbitung",
          "sequence": 10,
          "x": 110,
          "y": 1165,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "cilejit",
      "name": "Cilejit",
      "lineInfo": "KRL Lin Rangkasbitung",
      "statusText": "Lancar · 6 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "cilejit",
          "code": "R12",
          "publicCode": "R14",
          "lineSlug": "rangkasbitung",
          "sequence": 11,
          "x": 70,
          "y": 1165,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "daru",
      "name": "Daru",
      "lineInfo": "KRL Lin Rangkasbitung",
      "statusText": "Lancar · 7 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "daru",
          "code": "R13",
          "publicCode": "R15",
          "lineSlug": "rangkasbitung",
          "sequence": 12,
          "x": 30,
          "y": 1165,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "tenjo",
      "name": "Tenjo",
      "lineInfo": "KRL Lin Rangkasbitung",
      "statusText": "Lancar · 7 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "tenjo",
          "code": "R14",
          "publicCode": "R16",
          "lineSlug": "rangkasbitung",
          "sequence": 13,
          "x": -10,
          "y": 1165,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "tigaraksa",
      "name": "Tigaraksa",
      "lineInfo": "KRL Lin Rangkasbitung",
      "statusText": "Lancar · 8 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "tigaraksa",
          "code": "R15",
          "publicCode": "R18",
          "lineSlug": "rangkasbitung",
          "sequence": 14,
          "x": -50,
          "y": 1165,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "cikoya",
      "name": "Cikoya",
      "lineInfo": "KRL Lin Rangkasbitung",
      "statusText": "Lancar · 8 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "cikoya",
          "code": "R16",
          "publicCode": "R19",
          "lineSlug": "rangkasbitung",
          "sequence": 15,
          "x": -90,
          "y": 1165,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "maja",
      "name": "Maja",
      "lineInfo": "KRL Lin Rangkasbitung",
      "statusText": "Stasiun Antara · 8 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "maja",
          "code": "R17",
          "publicCode": "R20",
          "lineSlug": "rangkasbitung",
          "sequence": 16,
          "x": -130,
          "y": 1165,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "citeras",
      "name": "Citeras",
      "lineInfo": "KRL Lin Rangkasbitung",
      "statusText": "Lancar · 9 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "citeras",
          "code": "R18",
          "publicCode": "R21",
          "lineSlug": "rangkasbitung",
          "sequence": 17,
          "x": -170,
          "y": 1165,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "rangkasbitung",
      "name": "Rangkasbitung",
      "lineInfo": "KRL Lin Rangkasbitung",
      "statusText": "Terminus Barat · 10 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "rangkasbitung",
          "code": "R19",
          "publicCode": "R22",
          "lineSlug": "rangkasbitung",
          "sequence": 18,
          "x": -210,
          "y": 1165,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "ancol",
      "name": "Ancol",
      "lineInfo": "KRL Lin Tanjung Priok",
      "statusText": "Lancar · 6 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "ancol",
          "code": "TP03",
          "lineSlug": "tanjung_priok",
          "sequence": 2,
          "x": 1450,
          "y": 240,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "jakarta-int-stadium",
      "name": "Jakarta Int. Stadium",
      "lineInfo": "KRL Lin Tanjung Priok",
      "statusText": "Akses Stadium · 7 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "jis",
          "code": "TP04",
          "publicCode": null,
          "lineSlug": "tanjung_priok",
          "sequence": 3,
          "x": 1600,
          "y": 240,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "tanjung-priok",
      "name": "Tanjung Priok",
      "lineInfo": "KRL Lin Tanjung Priok",
      "statusText": "Terminus Pelabuhan · 8 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": false,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "tanjung_priok",
          "code": "TP05",
          "publicCode": "TP04",
          "lineSlug": "tanjung_priok",
          "sequence": 4,
          "x": 1720,
          "y": 90,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "halim",
      "name": "Halim",
      "lineInfo": "LRT Jabodebek & KCIC Whoosh",
      "statusText": "Intermodal KCIC · 4 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": true,
      "isKrl": false,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "halim",
          "code": "BK09",
          "lineSlug": "lrt_bekasi",
          "sequence": 8,
          "x": 2050,
          "y": 1644,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "dukuh-atas-lrt",
      "name": "Dukuh Atas LRT",
      "officialName": "Dukuh Atas Bank Syariah Indonesia",
      "lineInfo": "LRT Jabodebek (Bekasi & Cibubur)",
      "statusText": "Terminus LRT · 3 menit",
      "isTransit": true,
      "isAccessible": true,
      "isLrt": true,
      "isKrl": false,
      "isMrt": false,
      "aliases": [
        "Dukuh Atas BNI",
        "Dukuh Atas LRT"
      ],
      "nodes": [
        {
          "mapId": "dukuh_atas_lrt_bk",
          "code": "BK01",
          "lineSlug": "lrt_bekasi",
          "sequence": 0,
          "x": 1180,
          "y": 1119,
          "isTransit": true
        },
        {
          "mapId": "dukuh_atas_lrt_cb",
          "code": "CB01",
          "lineSlug": "lrt_cibubur",
          "sequence": 0,
          "x": 1180,
          "y": 1131,
          "isTransit": true
        }
      ]
    },
    {
      "slug": "setiabudi-lrt",
      "name": "Setiabudi LRT",
      "officialName": "Setiabudi",
      "lineInfo": "LRT Jabodebek",
      "statusText": "Lancar · 4 menit",
      "isTransit": true,
      "isAccessible": true,
      "isLrt": true,
      "isKrl": false,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "setiabudi_lrt_bk",
          "code": "BK02",
          "lineSlug": "lrt_bekasi",
          "sequence": 1,
          "x": 1306,
          "y": 1245,
          "isTransit": false
        },
        {
          "mapId": "setiabudi_lrt_cb",
          "code": "CB02",
          "lineSlug": "lrt_cibubur",
          "sequence": 1,
          "x": 1294,
          "y": 1245,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "rasuna-said",
      "name": "Rasuna Said",
      "lineInfo": "LRT Jabodebek",
      "statusText": "Lancar · 4 menit",
      "isTransit": true,
      "isAccessible": true,
      "isLrt": true,
      "isKrl": false,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "rasuna_said_bk",
          "code": "BK03",
          "lineSlug": "lrt_bekasi",
          "sequence": 2,
          "x": 1306,
          "y": 1365,
          "isTransit": false
        },
        {
          "mapId": "rasuna_said_cb",
          "code": "CB03",
          "lineSlug": "lrt_cibubur",
          "sequence": 2,
          "x": 1294,
          "y": 1365,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "kuningan",
      "name": "Kuningan",
      "lineInfo": "LRT Jabodebek",
      "statusText": "Lancar · 5 menit",
      "isTransit": true,
      "isAccessible": true,
      "isLrt": true,
      "isKrl": false,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "kuningan_bk",
          "code": "BK04",
          "lineSlug": "lrt_bekasi",
          "sequence": 3,
          "x": 1306,
          "y": 1485,
          "isTransit": false
        },
        {
          "mapId": "kuningan_cb",
          "code": "CB04",
          "lineSlug": "lrt_cibubur",
          "sequence": 3,
          "x": 1294,
          "y": 1485,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "pancoran",
      "name": "Pancoran",
      "officialName": "Pancoran bank bjb",
      "lineInfo": "LRT Jabodebek",
      "statusText": "Lancar · 4 menit",
      "isTransit": true,
      "isAccessible": true,
      "isLrt": true,
      "isKrl": false,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "pancoran_bk",
          "code": "BK05",
          "lineSlug": "lrt_bekasi",
          "sequence": 4,
          "x": 1450,
          "y": 1644,
          "isTransit": false
        },
        {
          "mapId": "pancoran_cb",
          "code": "CB05",
          "lineSlug": "lrt_cibubur",
          "sequence": 4,
          "x": 1450,
          "y": 1656,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "cikoko",
      "name": "Cikoko",
      "lineInfo": "LRT Jabodebek & KRL Cawang",
      "statusText": "Transit Cawang · 4 menit",
      "isTransit": true,
      "isAccessible": true,
      "isLrt": true,
      "isKrl": true,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "cikoko_bk",
          "code": "BK06",
          "lineSlug": "lrt_bekasi",
          "sequence": 5,
          "x": 1600,
          "y": 1644,
          "isTransit": false
        },
        {
          "mapId": "cikoko_cb",
          "code": "CB06",
          "lineSlug": "lrt_cibubur",
          "sequence": 5,
          "x": 1600,
          "y": 1656,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "ciliwung",
      "name": "Ciliwung",
      "lineInfo": "LRT Jabodebek",
      "statusText": "Lancar · 5 menit",
      "isTransit": true,
      "isAccessible": true,
      "isLrt": true,
      "isKrl": false,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "ciliwung_bk",
          "code": "BK07",
          "lineSlug": "lrt_bekasi",
          "sequence": 6,
          "x": 1750,
          "y": 1644,
          "isTransit": false
        },
        {
          "mapId": "ciliwung_cb",
          "code": "CB07",
          "lineSlug": "lrt_cibubur",
          "sequence": 6,
          "x": 1750,
          "y": 1656,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "jatibening-baru",
      "name": "Jatibening Baru",
      "officialName": "Jati Bening Baru",
      "lineInfo": "LRT Jabodebek Lin Bekasi",
      "statusText": "Lancar · 5 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": true,
      "isKrl": false,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "jatibening_baru",
          "code": "BK10",
          "lineSlug": "lrt_bekasi",
          "sequence": 9,
          "x": 2200,
          "y": 1644,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "cikunir-1",
      "name": "Cikunir 1",
      "lineInfo": "LRT Jabodebek Lin Bekasi",
      "statusText": "Lancar · 5 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": true,
      "isKrl": false,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "cikunir_1",
          "code": "BK11",
          "lineSlug": "lrt_bekasi",
          "sequence": 10,
          "x": 2350,
          "y": 1644,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "cikunir-2",
      "name": "Cikunir 2",
      "lineInfo": "LRT Jabodebek Lin Bekasi",
      "statusText": "Lancar · 6 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": true,
      "isKrl": false,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "cikunir_2",
          "code": "BK12",
          "lineSlug": "lrt_bekasi",
          "sequence": 11,
          "x": 2500,
          "y": 1644,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "bekasi-barat",
      "name": "Bekasi Barat",
      "lineInfo": "LRT Jabodebek Lin Bekasi",
      "statusText": "Lancar · 5 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": true,
      "isKrl": false,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "bekasi_barat",
          "code": "BK13",
          "lineSlug": "lrt_bekasi",
          "sequence": 12,
          "x": 2650,
          "y": 1644,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "jati-mulya",
      "name": "Jati Mulya",
      "lineInfo": "LRT Jabodebek Lin Bekasi",
      "statusText": "Terminus Bekasi · 6 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": true,
      "isKrl": false,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "jatimulya",
          "code": "BK14",
          "lineSlug": "lrt_bekasi",
          "sequence": 13,
          "x": 2800,
          "y": 1644,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "taman-mini",
      "name": "Taman Mini",
      "officialName": "TMII",
      "lineInfo": "LRT Jabodebek Lin Cibubur",
      "statusText": "Lancar · 6 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": true,
      "isKrl": false,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "taman_mini",
          "code": "CB09",
          "lineSlug": "lrt_cibubur",
          "sequence": 8,
          "x": 1960,
          "y": 1806,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "kampung-rambutan",
      "name": "Kampung Rambutan",
      "lineInfo": "LRT Jabodebek Lin Cibubur",
      "statusText": "Transit Terminal · 6 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": true,
      "isKrl": false,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "kampung_rambutan",
          "code": "CB10",
          "lineSlug": "lrt_cibubur",
          "sequence": 9,
          "x": 1960,
          "y": 1956,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "ciracas",
      "name": "Ciracas",
      "lineInfo": "LRT Jabodebek Lin Cibubur",
      "statusText": "Lancar · 7 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": true,
      "isKrl": false,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "ciracas",
          "code": "CB11",
          "lineSlug": "lrt_cibubur",
          "sequence": 10,
          "x": 1960,
          "y": 2106,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "harjamukti",
      "name": "Harjamukti",
      "lineInfo": "LRT Jabodebek Lin Cibubur",
      "statusText": "Terminus Cibubur · 7 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": true,
      "isKrl": false,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "harjamukti",
          "code": "CB12",
          "lineSlug": "lrt_cibubur",
          "sequence": 11,
          "x": 1960,
          "y": 2256,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "pegangsaan-dua",
      "name": "Pegangsaan Dua",
      "lineInfo": "LRT Jakarta",
      "statusText": "Depo & Terminus · 5 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": true,
      "isKrl": false,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "pegangsaan_dua",
          "code": "S01",
          "lineSlug": "lrt_jakarta",
          "sequence": 0,
          "x": 1900,
          "y": 375,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "boulevard-utara",
      "name": "Boulevard Utara",
      "lineInfo": "LRT Jakarta",
      "statusText": "Akses Mal Kelapa Gading",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": true,
      "isKrl": false,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "boulevard_utara",
          "code": "S02",
          "lineSlug": "lrt_jakarta",
          "sequence": 1,
          "x": 1900,
          "y": 480,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "boulevard-selatan",
      "name": "Boulevard Selatan",
      "lineInfo": "LRT Jakarta",
      "statusText": "Lancar · 4 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": true,
      "isKrl": false,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "boulevard_selatan",
          "code": "S03",
          "lineSlug": "lrt_jakarta",
          "sequence": 2,
          "x": 1900,
          "y": 585,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "pulomas",
      "name": "Pulomas",
      "lineInfo": "LRT Jakarta",
      "statusText": "Lancar · 4 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": true,
      "isKrl": false,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "pulomas",
          "code": "S04",
          "lineSlug": "lrt_jakarta",
          "sequence": 3,
          "x": 1900,
          "y": 690,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "equestrian",
      "name": "Equestrian",
      "lineInfo": "LRT Jakarta",
      "statusText": "Lancar · 5 menit",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": true,
      "isKrl": false,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "equestrian",
          "code": "S05",
          "lineSlug": "lrt_jakarta",
          "sequence": 4,
          "x": 1900,
          "y": 795,
          "isTransit": false
        }
      ]
    },
    {
      "slug": "velodrome",
      "name": "Velodrome",
      "lineInfo": "LRT Jakarta",
      "statusText": "Terminus Rawamangun",
      "isTransit": false,
      "isAccessible": true,
      "isLrt": true,
      "isKrl": false,
      "isMrt": false,
      "aliases": [],
      "nodes": [
        {
          "mapId": "velodrome",
          "code": "S06",
          "lineSlug": "lrt_jakarta",
          "sequence": 5,
          "x": 1750,
          "y": 795,
          "isTransit": false
        }
      ]
    }
  ],
  "lines": [
    {
      "slug": "bogor",
      "name": "KRL Lin Bogor",
      "color": "#E53935",
      "serviceType": "KRL",
      "nodeCodes": [
        "B01",
        "B02",
        "B03",
        "B04",
        "B05",
        "B07",
        "B08",
        "B09",
        "B10",
        "B11",
        "B12",
        "B13",
        "B14",
        "B15",
        "B16",
        "B17",
        "B18",
        "B19",
        "B20",
        "B21",
        "B22",
        "B23",
        "B24",
        "B26"
      ]
    },
    {
      "slug": "bogor_nambo",
      "name": "KRL Cabang Nambo",
      "color": "#E53935",
      "serviceType": "KRL",
      "nodeCodes": [
        "B22",
        "b23",
        "b24",
        "b25",
        "b26"
      ]
    },
    {
      "slug": "cikarang_loop",
      "name": "KRL Cikarang Loop",
      "color": "#00BCD4",
      "serviceType": "KRL",
      "nodeCodes": [
        "C15",
        "C01",
        "C02",
        "C03",
        "C04",
        "C05",
        "C06",
        "C07",
        "C08",
        "C09",
        "C10",
        "C11",
        "C11a",
        "C12",
        "C13",
        "C14",
        "C15"
      ]
    },
    {
      "slug": "cikarang_east",
      "name": "KRL Cikarang Timur",
      "color": "#00BCD4",
      "serviceType": "KRL",
      "nodeCodes": [
        "C15",
        "C16",
        "C17",
        "C18",
        "C19",
        "C20",
        "C21",
        "C22",
        "C23",
        "C24",
        "C25",
        "C26"
      ]
    },
    {
      "slug": "tangerang",
      "name": "KRL Lin Tangerang",
      "color": "#795548",
      "serviceType": "KRL",
      "nodeCodes": [
        "T01",
        "T02",
        "T03",
        "T04",
        "T05",
        "T06",
        "T07",
        "T08",
        "T09",
        "T10",
        "T11"
      ]
    },
    {
      "slug": "tanjung_priok",
      "name": "KRL Lin Tanjung Priok",
      "color": "#E91E63",
      "serviceType": "KRL",
      "nodeCodes": [
        "TP01",
        "TP02",
        "TP03",
        "TP04",
        "TP05"
      ]
    },
    {
      "slug": "rangkasbitung",
      "name": "KRL Lin Rangkasbitung",
      "color": "#43A047",
      "serviceType": "KRL",
      "nodeCodes": [
        "R01",
        "R02",
        "R03",
        "R04",
        "R05",
        "R06",
        "R07",
        "R08",
        "R09",
        "R10",
        "R11",
        "R12",
        "R13",
        "R14",
        "R15",
        "R16",
        "R17",
        "R18",
        "R19"
      ]
    },
    {
      "slug": "mrt",
      "name": "MRT Jakarta",
      "color": "#D81B60",
      "serviceType": "MRT",
      "nodeCodes": [
        "M13",
        "M12",
        "M11",
        "M10",
        "M09",
        "M08",
        "M07",
        "M06",
        "M05",
        "M04",
        "M03",
        "M02",
        "M01"
      ]
    },
    {
      "slug": "lrt_bekasi",
      "name": "LRT Jabodebek (Bekasi)",
      "color": "#007E33",
      "serviceType": "LRT",
      "nodeCodes": [
        "BK01",
        "BK02",
        "BK03",
        "BK04",
        "BK05",
        "BK06",
        "BK07",
        "BK08",
        "BK09",
        "BK10",
        "BK11",
        "BK12",
        "BK13",
        "BK14"
      ]
    },
    {
      "slug": "lrt_cibubur",
      "name": "LRT Jabodebek (Cibubur)",
      "color": "#003399",
      "serviceType": "LRT",
      "nodeCodes": [
        "CB01",
        "CB02",
        "CB03",
        "CB04",
        "CB05",
        "CB06",
        "CB07",
        "CB08",
        "CB09",
        "CB10",
        "CB11",
        "CB12"
      ]
    },
    {
      "slug": "lrt_jakarta",
      "name": "LRT Jakarta",
      "color": "#F16522",
      "serviceType": "LRT",
      "nodeCodes": [
        "S01",
        "S02",
        "S03",
        "S04",
        "S05",
        "S06"
      ]
    }
  ],
  "transfers": [
    {
      "from": "Dukuh Atas",
      "to": "Dukuh Atas LRT",
      "walkingTime": 7
    },
    {
      "from": "Setiabudi",
      "to": "Setiabudi LRT",
      "walkingTime": 7
    },
    {
      "from": "Cikoko",
      "to": "Cawang",
      "walkingTime": 5
    }
  ]
} as const satisfies NetworkData;
