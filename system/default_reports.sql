INSERT INTO Reports VALUES (1, "Catheter Recordings", "catherrecs", 0, "", "");
INSERT INTO Reports VALUES (2, "Urine Recordings", "urinerecs", 0, "", "");
INSERT INTO Reports VALUES (3, "Pad Volumes", "padvolumes", 0 , "", "");
INSERT INTO Reports VALUES (4, "Daily Volume", "dailyvol", 1, "", "");
INSERT INTO Queries VALUES (1, 1, "", "DROP TABLE Temp1;");
INSERT INTO Queries VALUES (2, 1, "", "DROP TABLE Temp1;");
INSERT INTO Queries VALUES (2, 2, "", "CREATE TABLE Temp1 (Patient VARCHAR(80), UDate DATE, UTime TIME, Volume INTEGER, PadVol INTEGER, Pad VARCHAR(20), Hold VARCHAR(20), Leakage VARCHAR(15), No2 BOOLEAN, Spasm VARCHAR(20), Notes TEXT);");
INSERT INTO Queries VALUES (2, 3, "Temp1", "SELECT PD.Patient, UR.UDate, UR.UTime, UR.Volume, ( UR.PadVolume - ( CASE WHEN UR.Leakage < 2 THEN 0 ELSE ( SELECT P.Size FROM PadSizes P WHERE P.ID = UR.PadType ) - ( CASE WHEN UR.Leakage > 2 THEN ( SELECT DISTINCT PP.Size FROM PadSizes PP WHERE PP.ID = 1 ) ELSE 0 END ) END ) ) AS PadVol, PS.Brand AS Pad, H.Description AS Hold, L.Leakage, UR.No2, ( CASE WHEN UR.Spasm IS NULL THEN '-' ELSE ( SELECT S.Description FROM Spasms S WHERE UR.Spasm = S.Spasm ) END ) AS Spasm, UR.Notes FROM UrineRecord UR LEFT JOIN PadSizes PS ON ( UR.PadType = PS.ID ), Leakage L, HoldStates H, PatientDetails PD WHERE UR.Hold = H.ID AND L.Value = UR.Leakage AND PD.Identifier = UR.Patient;");
INSERT INTO Queries VALUES (3, 1, "", "DROP TABLE Temp1;");
INSERT INTO Queries VALUES (3, 2, "", "CREATE TABLE Temp1 (Patient VARCHAR(80), UDate DATE, UTime TIME, PadVol INTEGER);");
INSERT INTO Queries VALUES (3, 3, "Temp1", "SELECT PD.Patient, UR.UDate, UR.UTime, ( UR.PadVolume - P.Size - ( CASE WHEN UR.Leakage > 2 THEN ( SELECT DISTINCT PP.Size FROM PadSizes PP WHERE PP.ID = 1 ) ELSE 0 END ) ) AS PadVol FROM UrineRecord UR, PadSizes P, PatientDetails PD WHERE P.ID = UR.PadType AND PD.Identifier = UR.Patient AND UR.PadType IS NOT NULL AND UR.Leakage > 1 AND UR.UDate > '2020-06-15';");
INSERT INTO Queries VALUES (4, 1, "", "DROP TABLE Temp1;");
INSERT INTO Queries VALUES (4, 2, "", "CREATE TABLE Temp1 (Patient VARCHAR(80), UDate DATE, Volume INTEGER, PadVol INTEGER, Pads INTEGER);");
INSERT INTO Queries VALUES (4, 3, "Temp1", "SELECT PD.Patient, UR.UDate, SUM(UR.Volume) AS Volume, SUM(UR.PadVolume - (CASE WHEN UR.Leakage < 2 THEN 0 ELSE (SELECT P.Size FROM PadSizes P WHERE P.ID = UR.PadType) - (CASE WHEN UR.Leakage > 2 THEN (SELECT DISTINCT PP.Size FROM PadSizes PP WHERE PP.ID = 1) ELSE 0 END) END)) AS PadVol, COUNT(UR.PadType) AS Pads FROM UrineRecord UR, PatientDetails PD WHERE PD.Identifier = UR.Patient AND UR.UDate < date('now') GROUP BY PD.Patient, UR.UDate;");
INSERT INTO Queries VALUES (4, 4, "", "DROP TABLE Temp2;");
INSERT INTO Queries VALUES (4, 5, "", "CREATE TABLE Temp2 AS SELECT UDate, Volume * 100.00 / (Volume + PadVol) AS PercentVol, PadVol * 100.00 / (Volume + PadVol ) AS PercentPadVol, Pads AS PadCount FROM Temp1;");
UPDATE Reports SET LaTex="%% LyX 2.3.2 initially created this file.  For more info, see http://www.lyx.org/.
%% Do not edit unless you really know what you are doing (i.e. you know LaTex).
\batchmode
\makeatletter
\def\input@path{{/tmp/}}
\makeatother
\documentclass[australian]{article}
\usepackage[T1]{fontenc}
\usepackage[latin9]{inputenc}
\usepackage[landscape,a4paper]{geometry}
\geometry{verbose,tmargin=1.5cm,bmargin=1.5cm,lmargin=2cm,rmargin=2cm,headheight=0.5cm,headsep=0.5cm,footskip=0.7cm}
\usepackage{array}
\usepackage{longtable}

\makeatletter

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% LyX specific LaTeX commands.
%% Because html converters don't know tabularnewline
\providecommand{\tabularnewline}{\\}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Textclass specific LaTeX commands.
\newcommand{\lyxaddress}[1]{
	\par {\raggedright #1
	\vspace{1.4em}
	\noindent\par}
}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% User specified LaTeX commands.
\usepackage{fancyhdr}  \pagestyle{fancy}
\lhead{} \chead{}  \rhead{}
\lfoot{Printed: \today}  \cfoot{Page \thepage}  \rfoot{Urine Recordings Report}
\renewcommand\headrulewidth{2pt}
\renewcommand\footrulewidth{0.4pt}

\makeatother

\usepackage{babel}
\begin{document}
«QUERY 1:SELECT DISTINCT Patient, SUM(PadVol) AS Vol FROM Temp1; »
\chead{Patient : «FIELD:1»}

\lyxaddress{\begin{center}
\textbf{\huge{}Urine Records for «FIELD:1»}
\par\end{center}}

\begin{longtable}[c]{>{\raggedright}p{1.3cm}>{\raggedleft}p{1.5cm}>{\raggedleft}p{1.6cm}>{\raggedright}p{3cm}>{\raggedright}p{1.5cm}>{\raggedright}p{2.7cm}>{\centering}p{1cm}>{\raggedright}p{2.4cm}>{\raggedright}m{9cm}}
\textbf{\large{}Time} &
\textbf{\large{}Volume} &
\textbf{\large{}Pad Vol} &
\textbf{\large{}Pad} &
\textbf{\large{}Hold} &
\textbf{\large{}Leakage} &
\textbf{\large{}No 2} &
\textbf{\large{}Spasm} &
\textbf{\large{}Notes}\tabularnewline
\hline 
\endhead
«QUERY 2:SELECT DISTINCT Patient, date(UDate), strftime('%d/%m/%Y',date(UDate)) AS UDate2, SUM(Volume) AS Volume, SUM(PadVol) AS Vol FROM Temp1 WHERE Patient=?1  GROUP BY Patient, UDate; »
«FIELD:3» & & & & & & & & \tabularnewline
«QUERY 3:SELECT DISTINCT Patient, date(UDate), UTime, Volume, PadVol, Pad, Hold, Leakage, No2, Spasm, Notes FROM Temp1 WHERE Patient=?1 AND UDate=?2; »
«FIELD:3» & «FIELD:4» & «FIELD:5» & «FIELD:6» & «FIELD:7» & «FIELD:8» & «FIELD:9» & «FIELD:10» & {\scriptsize{}«FIELD:11»}\tabularnewline
«END QUERY 3»
\cline{2-3} \cline{3-3} 
 & «FIELD:4» & «FIELD:5» & & & & & & \tabularnewline
«END QUERY 2»
\end{longtable}

«END QUERY 1»

\end{document}
"
WHERE ID = 2;
UPDATE Reports SET LaTex="%% LyX 2.3.2 initially created this file.  For more info, see http://www.lyx.org/.
%% Do not edit unless you really know what you are doing (i.e. you know LaTex).
\batchmode
\makeatletter
\def\input@path{{/tmp/}}
\makeatother
\documentclass[australian]{article}
\usepackage[T1]{fontenc}
\usepackage[latin9]{inputenc}
\usepackage[a4paper]{geometry}
\geometry{verbose,tmargin=1.5cm,bmargin=1.5cm,lmargin=2cm,rmargin=2cm,headheight=0.5cm,headsep=0.5cm,footskip=0.7cm}
\setcounter{secnumdepth}{1}
\setcounter{tocdepth}{1}
\usepackage{array}
\usepackage{longtable}

\makeatletter

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% LyX specific LaTeX commands.
%% Because html converters don't know tabularnewline
\providecommand{\tabularnewline}{\\}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Textclass specific LaTeX commands.
\newcommand{\lyxaddress}[1]{
	\par {\raggedright #1
	\vspace{1.4em}
	\noindent\par}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% User specified LaTeX commands.
\usepackage{babel}

\usepackage{fancyhdr}  \pagestyle{fancy}
\lhead{} \chead{}  \rhead{}
\lfoot{Printed: \today}  \cfoot{Page \thepage}  \rfoot{Pad Volume Report}
\renewcommand\headrulewidth{2pt}
\renewcommand\footrulewidth{0.4pt}

\makeatother

\usepackage{babel}
\begin{document}
«QUERY 1:SELECT DISTINCT Patient, SUM(PadVol) AS Vol, strftime('%d/%m/%Y',date('now')) as TodaysDate FROM Temp1; »
\chead{Patient : «FIELD:1»}
\lyxaddress{\textbf{\huge{}Pad Volume Report for «FIELD:1»}}

\begin{longtable}[c]{>{\raggedright}p{4cm}>{\raggedright}p{4cm}>{\raggedleft}p{4cm}}
\textbf{\large{}Date} &
\textbf{\large{}Time} &
\textbf{\large{}Volume}\tabularnewline
\endhead
\hline 
«QUERY 2:SELECT DISTINCT Patient, date(UDate), strftime('%d/%m/%Y',date(UDate)) AS UDate2, SUM(PadVol) AS Vol FROM Temp1 WHERE Patient=?1  GROUP BY Patient, UDate; »
«FIELD:3» & & \tabularnewline
«QUERY 3:SELECT DISTINCT Patient, date(UDate), UTime, PadVol FROM Temp1 WHERE Patient=?1 AND UDate=?2; »
 & «FIELD:3» & «FIELD:4»\tabularnewline
«END QUERY 3»
\cline{3-3} 
 &  & «FIELD:4»\tabularnewline
«END QUERY 2»
\end{longtable}

«END QUERY 1»

\end{document}
"
WHERE ID=3;
UPDATE Reports SET R="## Constants ##
## --------- ##
## Set up the source table names
tbltemp1  <- ""Temp1""
tbltemp2  <- ""Temp2""
## Set up the target file names
outputfile    <- ""result1.eps""
graphtitle1   <- ""Ratio of Measured to Pad Volumes for ""
graphtitle2   <- ""%age controlled urine and %age leakage to pad""
bordercolours <- c(""darkblue"")
linecolours   <- c(""green"",""blue"",""red"")
labels        <- c(""% Vol"",""% Pad Vol"",""Pad Count"")
## Get the source table data
library(DBI)
db <- dbConnect(RSQLite::SQLite(), ""«PARAM:4»"")
userids <- dbGetQuery(db, ""SELECT DISTINCT Patient FROM Temp1"")
result  <- dbReadTable(db, tbltemp2)
## Plot the results
# ploty    <- c(0,max(onemode$amp))
# fm       <- lm(PumpPwr ~ amp, data=onemode)
# plotx    <- c(fm[1]$coefficients[1],
#               fm[1]$coefficients[2] * max(onemode$amp) + fm[1]$coefficients[1])
postscript(outputfile, horizontal=FALSE,
           onefile=FALSE,height=6, width=6,pointsize=10)
plot(x=result$UDate,y=result$PercentVol, type=""l"", col=linecolours[1], col.axis=bordercolours,
     xlab=""Date"", ylab=""%"", cex=1.1)
# points(onemode$PumpPwr, onemode$amp, col=linecolours[1], pch=18)
# text(xy.coords(0.8,1), pos=4, cex=1.1,
#      eval(substitute(expression(R^2 == rsqd), 
#                      list(rsqd = round(summary(fm)$adj.r.squared,4)))) )
dev.off()
## Disconnect from the database
dbDisconnect(db)
## Clean up ##
## -------- ##
rm(result, db, tbltemp1, tbltemp2, userids)
rm(outputfile)
rm(graphtitle1, graphtitle2, bordercolours, linecolours, labels)
# Exit
q()
"
WHERE ID=4;
UPDATE Reports SET LaTex="%% LyX 2.3.2 initially created this file.  For more info, see http://www.lyx.org/.
%% Do not edit unless you really know what you are doing (i.e. you know LaTex).
\batchmode
\makeatletter
\def\input@path{{/tmp/}}
\makeatother
\documentclass[australian]{article}
\usepackage[T1]{fontenc}
\usepackage[latin9]{inputenc}
\usepackage[landscape,a4paper]{geometry}
\geometry{verbose,tmargin=1.5cm,bmargin=1.2cm,lmargin=2cm,rmargin=2cm,headheight=0.5cm,headsep=0.5cm,footskip=0.5cm}
\usepackage{graphicx}
\usepackage{epstopdf} %converting to PDF
\usepackage{babel}
\begin{document}
\includegraphics[width=1\linewidth]{result1}
\end{document}
"
WHERE ID=4;