args <- commandArgs(trailingOnly=TRUE)
root <- if(length(args)) normalizePath(args[1],winslash="/",mustWork=TRUE) else normalizePath(".",winslash="/",mustWork=TRUE)
all <- list.files(root,recursive=TRUE,full.names=TRUE,all.files=TRUE,include.dirs=FALSE)
all <- gsub("\\\\","/",all)
rel <- substring(all,nchar(root)+2L)
excluded <- grepl("^(validation|archives|SIECCLongWeather[.]Rcheck|[.]git)(/|$)",rel) | basename(rel)%in%c("SECRET_SCAN_REPORT.csv","PRIVACY_SCAN_REPORT.csv","PATH_PORTABILITY_SCAN_REPORT.csv") | grepl("[.](tar[.]gz|zip|docx|png|pdf|rds)$",rel,ignore.case=TRUE)
files <- all[!excluded]; rel <- rel[!excluded]
text_ext <- grepl("[.](R|Rmd|md|txt|csv|tsv|yaml|yml|json|cff|mjs|ps1|Rd|example|gitignore|Rbuildignore)$",files,ignore.case=TRUE) | basename(files)%in%c("DESCRIPTION","NAMESPACE","CITATION","LICENSE")
read_text <- function(f) paste(readLines(f,warn=FALSE,encoding="UTF-8"),collapse="\n")
texts <- setNames(lapply(files[text_ext],read_text),rel[text_ext])
scan_texts <- texts[!names(texts)%in%c("scripts/run_repository_scans.R")]

secret_patterns <- c("GitHub personal token"="gh[pousr]_[A-Za-z0-9_]{20,}","AWS access key"="AKIA[0-9A-Z]{16}","Assigned IMS token"="IMS_API_TOKEN[ \\t]*=[ \\t]*[^ \\t\\r\\n#]+","Assigned CDS key"="CDSAPI_KEY[ \\t]*=[ \\t]*[^ \\t\\r\\n#]+","Private key block"="BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY")
secret_hits <- list(); k<-0L
for(f in names(scan_texts)) for(label in names(secret_patterns)) if(grepl(secret_patterns[[label]],scan_texts[[f]],perl=TRUE)){k<-k+1L;secret_hits[[k]]<-data.frame(FILE=f,PATTERN=label,STATUS="FAIL",stringsAsFactors=FALSE)}
secret <- if(k) do.call(rbind,secret_hits) else data.frame(FILE="",PATTERN="",STATUS="PASS",stringsAsFactors=FALSE)
secret$SECRETS_FOUND <- k

tabular <- files[grepl("[.](csv|tsv)$",files,ignore.case=TRUE)]
privacy_terms <- "(^|_)(participant|subject|patient|gps|latitude|longitude|health|assessment_date|social_outcome|personal_id)(_|$)"
privacy_hits<-list(); p<-0L
for(f in tabular){sep<-if(grepl("[.]tsv$",f,ignore.case=TRUE))"\t" else ","; h<-names(tryCatch(utils::read.table(f,sep=sep,header=TRUE,nrows=1,check.names=FALSE,quote='\"',comment.char=""),error=function(e)data.frame())); bad<-h[grepl(privacy_terms,h,ignore.case=TRUE,perl=TRUE)]; if(length(bad)){p<-p+1L;privacy_hits[[p]]<-data.frame(FILE=substring(normalizePath(f,winslash="/"),nchar(root)+2L),FIELD=paste(bad,collapse="|"),STATUS="FAIL",stringsAsFactors=FALSE)}}
privacy<-if(p)do.call(rbind,privacy_hits)else data.frame(FILE="",FIELD="",STATUS="PASS",stringsAsFactors=FALSE); privacy$PARTICIPANT_DATA_FOUND<-p

path_patterns<-c("drive_path"="C:[\\\\/]","user_dir_windows"="[A-Za-z]:[\\\\/]+Users[\\\\/]","user_dir_unix"="(^|[\\s\"'(=])/(Users|home)/[^/\\s\"']+","wsl_mount"="/mnt/[a-z]/Users/","cloud_sync_folder"="O(?:n)eDrive")
path_hits<-list(); q<-0L
for(f in names(scan_texts)) for(label in names(path_patterns)) if(grepl(path_patterns[[label]],scan_texts[[f]],ignore.case=TRUE,perl=TRUE)){q<-q+1L;path_hits[[q]]<-data.frame(FILE=f,PATTERN=label,STATUS="FAIL",stringsAsFactors=FALSE)}
path_report<-if(q)do.call(rbind,path_hits)else data.frame(FILE="",PATTERN="",STATUS="PASS",stringsAsFactors=FALSE); path_report$ABSOLUTE_LOCAL_PATHS_FOUND<-q

utils::write.csv(secret,file.path(root,"SECRET_SCAN_REPORT.csv"),row.names=FALSE,na="")
utils::write.csv(privacy,file.path(root,"PRIVACY_SCAN_REPORT.csv"),row.names=FALSE,na="")
utils::write.csv(path_report,file.path(root,"PATH_PORTABILITY_SCAN_REPORT.csv"),row.names=FALSE,na="")
cat("SECRETS_FOUND=",k,"\nPARTICIPANT_DATA_FOUND=",p,"\nABSOLUTE_LOCAL_PATHS_FOUND=",q,"\n",sep="")
if(k+p+q>0) quit(status=1L)
