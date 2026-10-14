import fs from "node:fs/promises";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {Workbook} from "@oai/artifact-tool";

const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),"..");
const source=await Workbook.fromCSV(await fs.readFile(path.join(root,"validation","PUBLICATION_VALIDATION.csv"),"utf8"),{sheetName:"Validation"});
await source.inspect({kind:"region",sheetId:"Validation",range:"A1:I8",maxChars:2500});
const values=source.worksheets.getItem("Validation").getUsedRange().values;
const header=values[0]; const ix=Object.fromEntries(header.map((x,i)=>[x,i]));
const rows=[["METRIC","PERIOD_TYPE","PERIOD","RESULT_FIELD","R_PACKAGE_VALUE","SEALED_AUTHORITY_VALUE","ABS_DIFF","REL_DIFF","TOLERANCE","STATUS"]];
for(const row of values.slice(1)) {
  const category=String(row[ix.CATEGORY]);
  if(!["ANNUAL_SERIES","DJF_SERIES","INFERENCE"].includes(category)) continue;
  const key=String(row[ix.KEY]); const pairs=Object.fromEntries(key.split("|").map(z=>z.split("=")));
  const field=String(row[ix.FIELD]);
  const periodType=category==="ANNUAL_SERIES"?"ANNUAL":category==="DJF_SERIES"?"DJF":String(pairs.PERIOD);
  const period=category==="ANNUAL_SERIES"?String(pairs.YEAR):category==="DJF_SERIES"?String(pairs.WINTER):`${pairs.PERIOD}:${field}`;
  const metric=category==="INFERENCE"?String(pairs.METRIC):field;
  rows.push([metric,periodType,period,category==="INFERENCE"?field:"NATIONAL_SERIES",row[ix.REPRODUCED_VALUE],row[ix.REFERENCE_VALUE],row[ix.ABS_DIFF],row[ix.REL_DIFF],row[ix.TOLERANCE],row[ix.STATUS]]);
}
const out=Workbook.create(); const sheet=out.worksheets.add("Parity"); sheet.getRangeByIndexes(0,0,rows.length,rows[0].length).values=rows;
const audit=await out.inspect({kind:"region",sheetId:"Parity",range:"A1:J10",maxChars:3000}); if(!audit) throw new Error("Parity inspection failed");
function csvCell(v){if(v===null||v===undefined)return"";const s=String(v);return /[",\r\n]/.test(s)?`"${s.replaceAll('"','""')}"`:s;}
const csv=sheet.getUsedRange().values.map(r=>r.map(csvCell).join(",")).join("\r\n")+"\r\n";
await fs.writeFile(path.join(root,"validation","FULL_R_VS_SEALED_HYBRID_PARITY.csv"),csv,"utf8");
process.stdout.write(`PARITY_ROWS=${rows.length-1}\nFULL_R_VS_SEALED_HYBRID_PARITY=${rows.slice(1).every(r=>r[9]==="PASS")?"PASS":"FAIL"}\n`);
