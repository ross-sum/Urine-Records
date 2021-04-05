-----------------------------------------------------------------------
--                                                                   --
--                         M A I N   M E N U                         --
--                                                                   --
--                     S p e c i f i c a t i o n                     --
--                                                                   --
--                           $Revision: 1.0 $                        --
--                                                                   --
--  Copyright (C) 2020  Hyper Quantum Pty Ltd.                       --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This  package displays the main menu form,  which contains  the  --
--  buttons  necessary to display the various data entry  forms  as  --
--  well  as  to display various reports.  It  also  contains  menu  --
--  items   to   handle  help  operations  and  for   closing   the  --
--  application.                                                     --
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
with Gtkada.Builder;  use Gtkada.Builder;
with Gtk.Button, Gtk.Menu_Item;
with dStrings;        use dStrings;
with GNATCOLL.SQL.Exec;
package Main_Menu is


   procedure Initialise_Main_Menu(usage : in text;
                           DB_Descr : GNATCOLL.SQL.Exec.Database_Description;
                           with_tex_path : text;
                           with_pdf_path : text;
                           with_R_path   : text;
                           path_to_temp  : string := "/tmp/";
                           glade_filename: string := "urine_records.glade");

private

   procedure Menu_File_New_Select_CB  
                (Object : access Gtkada_Builder_Record'Class);
   procedure Menu_File_Exit_Select_CB  
                (Object : access Gtkada_Builder_Record'Class);
   procedure Menu_Manual_Select_CB
                (Object : access Gtkada_Builder_Record'Class);
   procedure Menu_Help_About_Select_CB 
                (Object : access Gtkada_Builder_Record'Class);
   procedure Btn_Patient_Details_Clicked_CB 
                (Object : access Gtkada_Builder_Record'Class);
   procedure Btn_Catheter_Urine_Records_Clicked_CB
                (Object : access Gtkada_Builder_Record'Class);
   procedure Btn_Urine_Records_Clicked_CB
                (Object : access Gtkada_Builder_Record'Class);
    
    -- Print the specified report (given the report name from the menu item or
    -- button).
   procedure Urine_Records_Report_Clicked_CB(label : string);
      -- Print the specified report (for the defined report Name).
   procedure Urine_Records_Report_Clicked_CB
                (Object : access Gtk.Menu_Item.Gtk_Menu_Item_Record'Class);
       -- Get the name of the report menu item and then print the report.
   procedure Urine_Records_Report_Clicked_CB
                (Object : access Gtk.Button.Gtk_Button_Record'Class);
       -- Get the name of the report button and then print the report.

end Main_Menu;