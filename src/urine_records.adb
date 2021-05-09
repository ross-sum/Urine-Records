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
with String_Conversions;
with Generic_Command_Parameters;
with GNATCOLL.SQL.Sqlite;   -- or Postgres
with GNATCOLL.SQL.Exec;
with GNATCOLL.SQL, GNATCOLL.SQL.Exec.Tasking, GNATCOLL.SQL_BLOB;
with Database;
with Ada.Sequential_IO;
with Ada.Text_IO;

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
   default_path_to_temp  : constant wide_string :=
                           "/tmp/";
   
   package Parameters is new Generic_Command_Parameters
      (Urine_Record_Version.Version,
       "z,temp,string," & default_path_to_temp &
                 ",path to the system writable temporary directory;" &
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
       "d,debug,integer,0,debug level (0=none 9=max)",
       0, false);
   use Parameters;
   
   procedure Load_Configuration_Parameters(
                         for_database : GNATCOLL.SQL.Exec.Database_Description;
                         at_temp_path : string) is
      use GNATCOLL.SQL, Database;
      use GNATCOLL.SQL.Exec, GNATCOLL.SQL_BLOB;
      package Byte_IO is new Ada.Sequential_IO(byte);
      DB       : GNATCOLL.SQL.Exec.Database_Connection;
      Q_config : SQL_Query;
      R_config : Forward_Cursor;
   begin
      DB:=GNATCOLL.SQL.Exec.Tasking.Get_Task_Connection(Description=>for_database);
      Q_config := SQL_Select
         (Fields  => Configurations.ID & Configurations.Name & 
                     Configurations.DetFormat & Configurations.Details,
          From    => Configurations,
          Where   => Configurations.ID > 0,
          Order_By=> Configurations.ID);
      R_config.Fetch (Connection => DB, Query => Q_config);
      if Success(DB) and then Has_Row(R_config) then
         while Has_Row(R_config) loop  -- while not end_of_table
            -- get the configuration data for the Name thing, and write out
            if Value(R_config, 2) = "B" then -- reformatting on the way
               declare
                  use string_conversions, Byte_IO;
                  output_file : file_type;
                  the_data    : blob := Blob_Value(R_config, 3);
                  file_name   : constant string := at_temp_path &
                                                   Value(R_config, 1);
               begin
                  if Length(the_data) > 0 then
                     Create(output_file, Out_File, file_name);
                     for byte_number in 1 .. Length(the_data) loop
                        Write(output_file, Element(the_data, byte_number));
                     end loop;
                     Close(output_file);
                  end if;
                  exception
                     when Status_Error => null;  -- file already exists
               end;
            else  -- just write out
               declare
                  use string_conversions, Ada.Text_IO;
                  output_file : Ada.Text_IO.file_type;
                  the_data    : String := Value(R_config, 3);
                  file_name   : constant string := at_temp_path &
                                                   Value(R_config, 1);
               begin
                  if the_data'Length > 0 then
                     Create(output_file, Out_File, file_name);
                     Put(output_file, the_data);
                     Close(output_file);
                  end if;
                  exception
                     when Ada.Text_IO.Status_Error => 
                        null;  -- file already exists
               end;
            end if;
            Next(R_config);  -- next record(Configurations)
         end loop;
      end if;
   end Load_Configuration_Parameters;

   DB_Descr : GNATCOLL.SQL.Exec.Database_Description;
   tex_path : text := Parameter(with_flag => flag_type'('t'));
   pdf_path : text := Parameter(with_flag => flag_type'('p'));
   R_path   : text := Parameter(with_flag => flag_type'('r'));
   temp_path: text := Parameter(with_flag => flag_type'('z'));
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
   -- Load in the configuration data
   Load_Configuration_Parameters(for_database => DB_Descr, 
                                 at_temp_path => Value(temp_path));
   -- Bring up the main menu
   Main_Menu.Initialise_Main_Menu(Parameters.The_Usage, DB_Descr, 
                                  tex_path, pdf_path, R_path,Value(temp_path));
   -- Free up the database description when done
   GNATCOLL.SQL.Exec.Free (DB_Descr);
end Urine_Records;