import fs from "node:fs/promises";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {Workbook} from "@oai/artifact-tool";
const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),"..");
for(const name of ["SECRET_SCAN_REPORT.csv","PRIVACY_SCAN_REPORT.csv","PATH_PORTABILITY_SCAN_REPORT.csv"]){
  const file=path.join(root,name); const wb=await Workbook.fromCSV(await fs.readFile(file,"utf8"),{sheetName:"Scan"});
  const audit=await wb.inspect({kind:"region",sheetId:"Scan",range:"A1:D5",maxChars:2000}); if(!audit)throw new Error(`Scan inspection failed: ${name}`);
  const rows=wb.worksheets.getItem("Scan").getUsedRange().values;
  const esc=v=>{if(v===null||v===undefined)return"";const s=String(v);return /[",\r\n]/.test(s)?`"${s.replaceAll('"','""')}"`:s};
  await fs.writeFile(file,rows.map(r=>r.map(esc).join(",")).join("\r\n")+"\r\n","utf8");
}
process.stdout.write("ARTIFACT_TOOL_SCAN_REPORTS_NORMALIZED=3\n");
