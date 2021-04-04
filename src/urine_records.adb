 -----------------------------------------------------------------------
--                                                                   --
--                       U R I N E _ R E C O R D S                   --
--                                                                   --
--                               B o d y                             --
--                                                                   --
--                           $Revision: 1.0 $                        --
--                                                                   --
--  Copyright (C) 2020  Hyper Quantum Pty Ltd.                       --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This  application  records both catheter  volumes  and  bladder  --
 --  volumes  for a patient or patients that have undergone  radical  --
--  prostatectomy  (removal  of  the  prostate).    The   urologist  --
--  typically wants to track the volumes to monitor recovery.        --
--                                                                   --
--  Version History:                                                 --
--  $Log$
--                                                                   --
--  Urine_Records is free software; you can redistribute it  and/or  --
--  modify  it under terms of the GNU  General  Public  Licence  as  --
--  published by the Free Software Foundation; either version 2, or  --
--  (at   your  option)  any  later  version.    Urine_Records   is  --
--  distributed  in  hope that it will be useful, but  WITHOUT  ANY  --
--  WARRANTY; without even the implied warranty of  MERCHANTABILITY  --
--  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public  --
--  Licence for  more details.  You should have received a copy  of  --
--  the GNU General Public Licence distributed with  Urine_Records.  --
--  If  not,  write to the Free Software  Foundation,  51  Franklin  --
--  Street, Fifth Floor, Boston, MA 02110-1301, USA.                 --
--                                                                   --
-----------------------------------------------------------------------

with Urine_Record_Version;
with Main_Menu;
with Error_Log;
with dStrings; use dStrings;
with Generic_Command_Parameters;
with GNATCOLL.SQL.Sqlite;   -- or Postgres
with GNATCOLL.SQL.Exec;

procedure Urine_Records is

   default_log_file_name : constant wide_string := 
                           "/var/log/urine_records.log";
   default_db_name       : constant wide_string := 
                           "/var/local/urine_records.db";
   default_tex_name      : constant wide_string := 
                           "/usr/bin/pdflatex";
   default_pdf_name      : constant wide_string := 
                           "/usr/bin/xpdf";
   default_R_name        : constant wide_string := 
                           "/usr/bin/R";
   
   package Parameters is new Generic_Command_Parameters
      (Urine_Record_Version.Version,
       "x,db,string," & default_db_name &
                 ",path and file name for the urine records database;" &
       "t,tex,string," & default_tex_name &
                 ", Path to LaTex PDF output generator;" & 
       "p,pdf,string," & default_pdf_name &
                 ", Path to PDF display tool;" &
       "r,R,string," & default_R_name &
                 ", Path to GNU R graph generating tool;" &
       "l,log,string," & default_log_file_name & 
                 ",log file name with optional path;" &
       "d,debug,integer,0,debug level (0=none, 9=max)",
       0, false);
   use Parameters;

   DB_Descr : GNATCOLL.SQL.Exec.Database_Description;
   tex_path : text := Parameter(with_flag => flag_type'('t'));
   pdf_path : text := Parameter(with_flag => flag_type'('p'));
   R_path   : text := Parameter(with_flag => flag_type'('r'));
begin
   Urine_Record_Version.Register(revision => "$Revision: 1.0 $",
      for_module => "Urine_Records");
   if  Parameters.is_invalid_parameter or
   Parameters.is_help_parameter or
   Parameters.is_version_parameter then
      -- abort Urine_Records;
      return;
   end if;
   Error_Log.Set_Log_File_Name(
      Value(Parameter(with_name=>Value("log"))));
   Error_Log.Set_Debug_Level
         (to => Parameter(with_flag => flag_type'('d')) );
   Error_Log.Debug_Data(at_level => 1, 
                        with_details => "Urine_Records: Start processing");
   -- Set up the database
   DB_Descr := GNATCOLL.SQL.Sqlite.Setup
                            (Value(Parameter(with_flag => flag_type'('x'))));
   -- Bring up the main menu
   Main_Menu.Initialise_Main_Menu(Parameters.The_Usage, DB_Descr, 
                                  tex_path, pdf_path, R_path);
   -- Free up the database description when done
   GNATCOLL.SQL.Exec.Free (DB_Descr);
end Urine_Records;