import fs from "node:fs/promises";
import path from "node:path";
import crypto from "node:crypto";
import { fileURLToPath } from "node:url";
import { Workbook } from "@oai/artifact-tool";

const packageRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");

function csvCell(value) {
  if (value === null || value === undefined) return "";
  const text = String(value);
  return /[",\r\n]/.test(text) ? `"${text.replaceAll('"','""')}"` : text;
}

async function writeCsv(relativePath, rows) {
  const wb = Workbook.create();
  const sheet = wb.worksheets.add("Data");
  sheet.getRangeByIndexes(0, 0, rows.length, rows[0].length).values = rows;
  const audit = await wb.inspect({kind:"region", sheetId:"Data", range:`A1:${String.fromCharCode(64+rows[0].length)}${Math.min(rows.length,8)}`, maxChars:3000});
  if (!audit || !sheet.getUsedRange()) throw new Error(`Artifact-tool inspection failed for ${relativePath}`);
  const values = sheet.getRangeByIndexes(0,0,rows.length,rows[0].length).values;
  const csv = values.map(row => row.map(csvCell).join(",")).join("\r\n") + "\r\n";
  const target = path.join(packageRoot, relativePath);
  await fs.mkdir(path.dirname(target), {recursive:true});
  await fs.writeFile(target, csv, "utf8");
}

const stationRows = [
  ["DATE","STATION_ID","X","Y","TX_C","TN_C","RAIN_MM","QC_FLAG"],
  ["2000-12-15","S1",0,0,20,10,30,"OK"], ["2000-12-15","S2",2,0,22,12,20,"OK"], ["2000-12-15","S3",0,2,24,14,10,"OK"],
  ["2001-01-15","S1",0,0,18,8,40,"OK"], ["2001-01-15","S2",2,0,20,10,30,"OK"], ["2001-01-15","S3",0,2,22,12,20,"OK"],
  ["2001-02-15","S1",0,0,21,11,15,"OK"], ["2001-02-15","S2",2,0,23,13,25,"OK"], ["2001-02-15","S3",0,2,25,15,35,"OK"]
];
const climatologyRows = [["STATION_ID","X","Y","TEMP_CLIMATOLOGY_C","RAIN_CLIMATOLOGY_MM"],["S1",0,0,14,300],["S2",2,0,16,250],["S3",0,2,18,200]];
const gridRows = [["GRID_ID","X","Y","INTERSECTION_AREA","TEMP_CLIMATOLOGY_C","RAIN_CLIMATOLOGY_MM"],["G1",0,0,1,14,300],["G2",1,0,2,15,275],["G3",0,1,3,16,250],["G4",1,1,4,17,225]];
const dictionaryRows = [["FILE","FIELD","TYPE","UNIT","DESCRIPTION"],
 ["demo_station_observations.csv","DATE","date","YYYY-MM-DD","Synthetic daily demonstration date"],
 ["demo_station_observations.csv","STATION_ID","text","none","Synthetic station identifier; not an IMS identifier"],
 ["demo_station_observations.csv","X/Y","numeric","arbitrary distance units","Synthetic projected coordinates"],
 ["demo_station_observations.csv","TX_C/TN_C","numeric","degC","Synthetic daily maximum/minimum temperature"],
 ["demo_station_observations.csv","RAIN_MM","numeric","mm","Synthetic daily rainfall"],
 ["demo_station_climatology.csv","TEMP_CLIMATOLOGY_C","numeric","degC","Synthetic station climatology"],
 ["demo_station_climatology.csv","RAIN_CLIMATOLOGY_MM","numeric","mm","Synthetic station rainfall climatology"],
 ["demo_grid.csv","INTERSECTION_AREA","numeric","arbitrary area units","Known polygon-intersection weight"],
 ["demo_grid.csv","TEMP_CLIMATOLOGY_C","numeric","degC","Synthetic grid climatology"],
 ["demo_grid.csv","RAIN_CLIMATOLOGY_MM","numeric","mm","Synthetic grid rainfall climatology"]];
const expectedRows = [["CHECK","INPUT","EXPECTED_VALUE","TOLERANCE","DERIVATION"],
 ["KELVIN_TO_CELSIUS","273.15 K",0,1e-12,"273.15 - 273.15"],
 ["AREA_WEIGHTED_MEAN","values 10,20; weights 1,3",17.5,1e-12,"(10*1+20*3)/(1+3)"],
 ["IDW_EXACT_STATION","target equals S1",10,1e-12,"Exact-location rule"],
 ["IMS_TMEAN","TX=25; TN=15",20,1e-12,"(25+15)/2"],
 ["RAIN_CALIBRATION","100 mm uncalibrated",128.24239753736433,1e-12,"100 multiplied once by study-specific factor"],
 ["DJF_ASSIGNMENT","2000-12-15",2000,0,"December belongs to winter starting in the same calendar year"]];

const licenseRows = [["SOURCE_NAME","PROVIDER","PRODUCT","DATA_ROLE","OFFICIAL_SOURCE","ACCESS_MODE","REGISTRATION_REQUIRED","TOKEN_REQUIRED","VERSION","DOI","LICENSE_NAME","LICENSE_SOURCE","REDISTRIBUTION_STATUS","RAW_DATA_BUNDLED","PROCESSED_DATA_BUNDLED","RETRIEVAL_DATE","NOTES"],
 ["IMS raw observations","Israel Meteorological Service","Historical QC-controlled databases and operational 10-/1-minute API","Station observations","https://ims.gov.il/en/ObservationDataAPI","Provider reacquisition",true,true,"Provider-current; frozen request metadata required","","IMS terms of use","https://ims.gov.il/sites/default/files/inline-files/termsofuse_en.pdf","UNCLEAR_REQUIRES_PROVIDER_CONFIRMATION",false,false,"2026-09-01","Raw bytes excluded; authorization and redistribution confirmation required."],
 ["IMS station metadata","Israel Meteorological Service","IMS station/database metadata","Station identity, coordinates, coverage","https://ims.gov.il/en","Official documentation/download",false,false,"Provider-current","","IMS terms of use","https://ims.gov.il/sites/default/files/inline-files/termsofuse_en.pdf","UNCLEAR_REQUIRES_PROVIDER_CONFIRMATION",false,false,"2026-09-01","Package includes no raw IMS station metadata bytes."],
 ["IMS derived national series","SIECC analysis derived from IMS","Six-metric processed publication series","IMS temperature and rainfall national aggregates","Package provenance plus IMS official source","Frozen compact publication reproduction",false,false,"Publication v0.1.0","","MIT applies to package code; source rights remain with provider","IMS terms plus package LICENSE","REDISTRIBUTED_WITH_ATTRIBUTION",false,true,"2026-09-01","Processed values bundled for reproducibility. Redistributed with attribution by author decision (14 Oct 2026); IMS terms of use URL recorded 2026-09-01. Cite IMS."],
 ["Synthetic demonstration data","SIECC Long Weather Project","Known-answer synthetic fixture","Credential-free demonstration","Package-generated","Bundled",false,false,"0.1.0","","MIT","LICENSE.md","PUBLIC_REDISTRIBUTION_CONFIRMED",true,true,"2026-09-01","Entirely synthetic; no IMS bytes or identifiers."],
 ["IMS documentation/metadata links","Israel Meteorological Service","Public API and database documentation","Acquisition instructions","https://ims.gov.il/en/ObservationDataAPI","Public web documentation",false,false,"Provider-current","","Website/IMS terms","https://ims.gov.il/sites/default/files/inline-files/termsofuse_en.pdf","REDISTRIBUTION_WITH_ATTRIBUTION",false,false,"2026-09-01","Links and paraphrased documentation only."],
 ["ERA5","Copernicus Climate Change Service / ECMWF","ERA5 monthly averaged single levels","Air temperature and humidity inputs","https://cds.climate.copernicus.eu/datasets/reanalysis-era5-single-levels-monthly-means","CDS account and API",true,true,"Requested dataset version recorded at retrieval","10.24381/cds.f17050d7","Licence to use Copernicus Products","https://cds.climate.copernicus.eu/terms","REDISTRIBUTION_WITH_ATTRIBUTION",false,true,"2026-09-01","Compact derived national series bundled; large source fields reacquired from CDS."],
 ["ERA5-HEAT","Copernicus Climate Change Service / ECMWF","Thermal comfort indices derived from ERA5","UTCI and MRT","https://cds.climate.copernicus.eu/datasets/derived-utci-historical","CDS account and API",true,true,"v1.1","10.24381/cds.553b7518","Licence to use Copernicus Products","https://cds.climate.copernicus.eu/terms","REDISTRIBUTION_WITH_ATTRIBUTION",false,true,"2026-09-01","Version v1.1 is fixed in acquisition records; future versions must not silently replace it."],
 ["National polygon/grid geometry","SIECC processing assets","Fixed national support and 5-km grid","Spatial aggregation","Package provenance","Frozen/local",false,false,"Publication frozen","","Project/source-specific","Package provenance","PUBLIC_REDISTRIBUTION_CONFIRMED",false,false,"2026-09-01","Only compact derived series are in this reviewer release."]];

await writeCsv("inst/extdata/demo_station_observations.csv", stationRows);
await writeCsv("inst/extdata/demo_station_climatology.csv", climatologyRows);
await writeCsv("inst/extdata/demo_grid.csv", gridRows);
await writeCsv("inst/extdata/DEMO_DATA_DICTIONARY.csv", dictionaryRows);
await writeCsv("inst/extdata/DEMO_EXPECTED_RESULTS.csv", expectedRows);
await writeCsv("DATA_SOURCE_AND_LICENSE_MANIFEST.csv", licenseRows);

const referenceDir = path.join(packageRoot,"inst","reference");
const tracePath = path.join(referenceDir,"final_figure_trace.csv");
const traceWorkbook = await Workbook.fromCSV(await fs.readFile(tracePath,"utf8"),{sheetName:"Trace"});
const traceSheet = traceWorkbook.worksheets.getItem("Trace");
const traceValues = traceSheet.getUsedRange().values;
const traceHeader = traceValues[0];
for (const columnName of ["SOURCE_AUTHORITY_FILE","TREND_AUTHORITY_FILE"]) {
  const columnIndex = traceHeader.indexOf(columnName);
  for (let rowIndex=1; rowIndex<traceValues.length; rowIndex++) traceValues[rowIndex][columnIndex] = path.win32.basename(String(traceValues[rowIndex][columnIndex]));
}
await writeCsv("inst/reference/final_figure_trace.csv", traceValues);
const refNames = (await fs.readdir(referenceDir)).filter(name => name.endsWith(".csv")).sort();
const hashRows = [["FILE","SIZE_BYTES","SHA256"]];
for (const name of refNames) {
  const bytes = await fs.readFile(path.join(referenceDir,name));
  hashRows.push([name,bytes.length,crypto.createHash("sha256").update(bytes).digest("hex")]);
}
await writeCsv("inst/reference/hashes/reference_hashes.csv", hashRows);

process.stdout.write(`ARTIFACT_TOOL_CSVS_CREATED=7\nREFERENCE_HASH_ROWS=${hashRows.length-1}\n`);
