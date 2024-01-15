# Urine Records
$Date:$

## Description
This is an application to store urine records for prostate cancer survivors to 
use during recovery from a radical prostatectomy.   This application would 
typically be used by patients to assist their urologist. It could be used in 
the early stages of post radical prostatectomy surgery (as was my case). The 
application records urine volumes from the catheter (including urine colour) as 
well as post catheter removal. This includes measuring pad volumes, taken from 
the pad weight. The application is built on a Sqlite database. It also uses 
Glade for providing the user interface and therefore GtkAda. The Glade XML file 
is kept in the configuration table of the database.

As it uses a component that has a dependency on sockets, it uses the AdaSockets 
library. For the database interaction, it uses GNATCOLL.sqlite. I have yet to 
successfully port either of these to Windows, so the application is only 
available on Linux (or any X-Window style Unix).

## Licence
This software is licensed under the terms and conditions of the GPL.

## Installation
Prior to installation, create the necessary directories to build into:
   `mkdir obj_amd64  obj_arm  obj_pi  obj_pi64  obj_x86`

To install, type `make` at the  top level directory, then type `sudo make install`.

