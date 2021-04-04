   -----------------------------------------------------------------------
   --                                                                   --
   --                           T O   B A S E 6 4                       --
   --                                                                   --
   --                             P r o j e c t                         --
   --                                                                   --
   --                           $Revision: 1.0 $                        --
   --                                                                   --
   --  Copyright (C) 2021  Hyper Quantum Pty Ltd.                       --
   --  Written by Ross Summerfield.                                     --
   --                                                                   --
   --  This application converts a blob to Base 64 format.              --
   --                                                                   --
   --  Version History:                                                 --
   --  $Log$
   --                                                                   --
   --  ToBase64  is  free  software; you can  redistribute  it  and/or  --
   --  modify  it under terms of the GNU  General  Public  Licence  as  --
   --  published by the Free Software Foundation; either version 2, or  --
   --  (at  your option) any later version.  ToBase64  is  distributed  --
   --  in  hope  that  it will be useful, but  WITHOUT  ANY  WARRANTY;  --
   --  without even the implied warranty of MERCHANTABILITY or FITNESS  --
   --  FOR  A PARTICULAR PURPOSE.  See the GNU General Public  Licence  --
   --  for  more details.  You should have received a copy of the  GNU  --
   --  General Public Licence distributed with ToBase64. If not, write  --
   --  to  the  Free Software Foundation, 51  Franklin  Street,  Fifth  --
   --  Floor, Boston, MA 02110-1301, USA.                               --
   --                                                                   --
   -----------------------------------------------------------------------

with ToBase64_Version;
with Error_Log;
with dStrings; use dStrings;
with Ada.Sequential_IO;
with Ada.Text_IO;         use Ada.Text_IO;
with Blobs, Blobs.Base_64; use Blobs, Blobs.Base_64;
with String_Conversions;
with Generic_Command_Parameters;
procedure ToBase64 is

   default_log_file_name : constant wide_string := 
                           "/tmp/tobase64.log";
   default_ip_name       : constant wide_string := 
                           "stdinput";
   default_op_name      : constant wide_string := 
                           "stdoutput";
   
   package Parameters is new Generic_Command_Parameters
      (ToBase64_Version.Version,
       "i,input,string," & default_ip_name &
                 ",BLOB format input file name;" &
       "o,output,string," & default_op_name &
                 ", Base 64 output file name;" & 
       "l,log,string," & default_log_file_name & 
                 ",log file name with optional path;" &
       "d,debug,integer,0,debug level (0=none, 9=max)",
       0, false);
   use Parameters;

   package Blobs_IO is new Ada.Sequential_IO(byte);
   use Blobs_IO;
   
   use String_Conversions;
   
   blob_length : natural := 0;
   a_byte      : byte;
   blob_file   : Blobs_IO.File_Type;
   base64_file : Ada.Text_IO.File_Type;
begin
   ToBase64_Version.Register(revision => "$Revision: 1.0 $",
      for_module => "Urine_Records");
   if  Parameters.is_invalid_parameter or
   Parameters.is_help_parameter or
   Parameters.is_version_parameter then
      -- abort Urine_Records;
      return;
   end if;
   Error_Log.Set_Log_File_Name(Value(Parameter(with_name=>Value("log"))));
   Error_Log.Set_Debug_Level(to => Parameter(with_flag => flag_type'('d')) );
   Error_Log.Debug_Data(at_level => 1, 
                        with_details => "ToBase64: Start processing");
   -- Open the input file containing the blob to convert
   Open(file => blob_file, mode => In_File, 
        name => Value(Parameter(with_flag=>flag_type'('i'))));
   Error_Log.Debug_Data(at_level => 2, 
                        with_details => "ToBase64: Getting BLOB length");
   -- Get the blob length
   while not End_Of_File(blob_file) loop
      Read(blob_file, a_byte);
      blob_length := blob_length + 1;
   end loop;
   Error_Log.Debug_Data(at_level => 3, 
                        with_details => "ToBase64: Blob length is " & 
                                        To_Wide_String(blob_length'Image) & 
                                        " bytes long.");
   -- Open the output file for sending the Base 64 converted blob to
   Create(file => base64_file, mode => Out_File, 
          name => Value(Parameter(with_flag=>flag_type'('o'))));
   Error_Log.Debug_Data(at_level => 2, 
                        with_details => "ToBase64: reading in the BLOB");
   -- Now read in a blob, process it and write it out
   Reset(blob_file);  -- Rewind for re-reading
   declare
      the_blob : blob(1..blob_length);
      current_byte: natural := 1;
   begin
      -- First, read in the blob
      while not End_Of_File(blob_file) loop
         Read(blob_file, the_blob(current_byte));
         current_byte := current_byte + 1;
      end loop;
      Error_Log.Debug_Data(at_level => 2, 
                           with_details => "ToBase64: Writing out the BLOB");
      -- Convert and write out the blob
      Put(base64_file, Encode(the_blob=>the_blob));
      Flush(base64_file);
   end;
   Error_Log.Debug_Data(at_level => 2, 
                        with_details => "ToBase64: Closing up");
   -- And close up
   Close(base64_file);
   Close(blob_file);
   Error_Log.Debug_Data(at_level => 2, 
                        with_details => "ToBase64: Done.");
end ToBase64;