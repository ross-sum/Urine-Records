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
--  If not, write to the Free Software Foundation, 59 Temple Place-  --
--  Suite 330, Boston, MA 02111-1307, USA.                           --
--                                                                   --
-----------------------------------------------------------------------

with Gtk.Main, Gtk.Window;
with Urine_Record_Version;

procedure Urine_Records is
   Window : Gtk.Window.Gtk_Window;

   default_log_file_name : constant wide_string := 
                           "/var/log/urine_records.log";
   default_db_name       : constant wide_string := 
                           "/var/local/urine_records.db";
   
   package Parameters is new Generic_Command_Parameters
      (Urine_Record_Version.Version,
       "p,port,integer,5000,local port number to listen on;" &
       "x,db,string,"& default_db_name &
                 ",file name for the switch database XML;"&
       "l,log,string," & default_log_file_name & 
                 ",log file name with optional path;" &
       "d,debug,integer,0,debug level (0=none, 9=max)",
       0, false);
   use Parameters;


begin
   Urine_Record_Version.Register(revision => "$Revision: 1.0 $",
      for_module => "Urine_Records");
   if  Parameters.is_invalid_parameter or
   Parameters.is_help_parameter or
   Parameters.is_version_parameter then
      -- abort Urine_Records;
      return;
   end if;
   Gtk.Main.Init;
   Gtk.Window.Gtk_New (Window);
   Gtk.Window.Show (Window);
   Gtk.Main.Main;
end Urine_Records;