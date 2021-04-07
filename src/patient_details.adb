-----------------------------------------------------------------------
--                                                                   --
--                   P A T I E N T   D E T A I L S                   --
--                                                                   --
  --                              B o d y                              --
--                                                                   --
--                           $Revision: 1.0 $                        --
--                                                                   --
--  Copyright (C) 2020  Hyper Quantum Pty Ltd.                       --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This package displays the patient details data entry form, which 
--  contains .                                                     --
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
-- with Gtkada.Builder;  use Gtkada.Builder;
-- with GNATCOLL.SQL.Exec;
-- with Calendar_Extensions;
with Gtk.Widget, Gtk.Grid;
with Gtk.Tool_Button;
with Gtk.GEntry, Gtk.Check_Button, Gtk.Text_Buffer, Gtk.Text_Iter;
with Gtk.Label;
with Glib, Glib.Values;
with Gtk.List_Store, Gtk.Tree_Model, Gtk.Tree_View, Gtk.Tree_Selection;
with Gtk.Tree_Row_Reference, Gtk.Tree_Selection;
with Error_Log;
with String_Conversions;
with Urine_Record_Version;
with Get_Date_Calendar;
with Check_For_Deletion;
with GNATCOLL.SQL.Exec.Tasking;
with GNATCOLL.SQL_Date_and_Time; use GNATCOLL.SQL_Date_and_Time;
with GNATCOLL.SQL;               use GNATCOLL.SQL;
with Database;                   use Database;
with Error_Dialogue;
with dStrings;
with Urine_Records_Interlocks;   use Urine_Records_Interlocks;
package body Patient_Details is

   pDB : GNATCOLL.SQL.Exec.Database_Connection;
   PD_select       : constant GNATCOLL.SQL.Exec.Prepared_Statement :=
      GNATCOLL.SQL.Exec.Prepare 
           (SQL_Select(Fields  => PatientDetails.Identifier & 
                                  PatientDetails.Patient &
                                  PatientDetails.AddressLine1 & 
                                  PatientDetails.AddressLine2 &
                                  PatientDetails.Town & PatientDetails.State &
                                  PatientDetails.Country & 
                                  PatientDetails.ReferralDate,
                       From    => PatientDetails,
                       Where   => PatientDetails.Identifier >= 0,
                       Order_By=> PatientDetails.Identifier),
            On_Server => True,
            Use_Cache => True);
   PD_insert       : constant GNATCOLL.SQL.Exec.Prepared_Statement :=
      GNATCOLL.SQL.Exec.Prepare 
           (SQL_Insert(Values  =>(PatientDetails.Identifier= Integer_Param(1))&
                                 (PatientDetails.Patient     = Text_Param(2)) &
                                 (PatientDetails.AddressLine1= Text_Param(3)) &
                                 (PatientDetails.AddressLine2= Text_Param(4)) &
                                 (PatientDetails.Town        = Text_Param(5)) &
                                 (PatientDetails.State       = Text_Param(6)) &
                                 (PatientDetails.Country     = Text_Param(7)) &
                                 (PatientDetails.ReferralDate=tDate_Param(8))),
            On_Server => True,
            Use_Cache => False);
   PD_update       : constant GNATCOLL.SQL.Exec.Prepared_Statement :=
      GNATCOLL.SQL.Exec.Prepare 
           (SQL_Update(Table => PatientDetails,
                       Set   => (PatientDetails.Identifier = Integer_Param(1))&
                                (PatientDetails.Patient     = Text_Param(2)) &
                                (PatientDetails.AddressLine1= Text_Param(3)) &
                                (PatientDetails.AddressLine2= Text_Param(4)) &
                                (PatientDetails.Town        = Text_Param(5)) &
                                (PatientDetails.State       = Text_Param(6)) &
                                (PatientDetails.Country     = Text_Param(7)) &
                                (PatientDetails.ReferralDate=tDate_Param(8)),
                       Where => (PatientDetails.Identifier =Integer_Param(9))),
            On_Server => True,
            Use_Cache => False);
   PD_delete       : constant GNATCOLL.SQL.Exec.Prepared_Statement :=
      GNATCOLL.SQL.Exec.Prepare 
           (SQL_Delete(From  => PatientDetails,
                       Where => (PatientDetails.Identifier=Integer_Param(1))),
            On_Server => True,
            Use_Cache => False);
   KE_insert       : constant GNATCOLL.SQL.Exec.Prepared_Statement :=
      GNATCOLL.SQL.Exec.Prepare 
           (SQL_Insert(Values  =>(KeyEvents.Patient   = Integer_Param(1)) &
                                 (KeyEvents.EventDate = tDate_Param(2)) &
                                 (KeyEvents.Event     = Text_Param(3)) &
                                 (KeyEvents.Details   = Text_Param(4))),
            On_Server => True,
            Use_Cache => False);
   KE_update       : constant GNATCOLL.SQL.Exec.Prepared_Statement :=
      GNATCOLL.SQL.Exec.Prepare 
           (SQL_Update(Table => KeyEvents,
                       Set   => (KeyEvents.Patient      = Integer_Param(1))&
                                (KeyEvents.EventDate    = tDate_Param(2)) &
                                (KeyEvents.Event        = Text_Param(3)) &
                                (KeyEvents.Details      = Text_Param(4)),
                       Where => (KeyEvents.Patient   = Integer_Param(5)) AND 
                                (KeyEvents.EventDate = tDate_Param(6))),
            On_Server => True,
            Use_Cache => False);
   KE_delete       : constant GNATCOLL.SQL.Exec.Prepared_Statement :=
      GNATCOLL.SQL.Exec.Prepare 
           (SQL_Delete(From  => KeyEvents,
                       Where => (KeyEvents.Patient=Integer_Param(1)) AND 
                                (KeyEvents.EventDate=tDate_Param(2))),
            On_Server => True,
            Use_Cache => False);
   R_patient_details : GNATCOLL.SQL.Exec.Direct_Cursor;
   last_row : Gtk.Tree_Row_Reference.Gtk_Tree_Row_Reference := 
                       Gtk.Tree_Row_Reference.Null_Gtk_Tree_Row_Reference;
   last_ke_date  : dStrings.text;
   last_ke_event : dStrings.text;
   last_ke_desc  : dStrings.text;
   treeview_interlock : Urine_Records_Interlocks.Interlock;

   procedure Initialise_Patient_Details(Builder : in out Gtkada_Builder;
                          DB_Descr : GNATCOLL.SQL.Exec.Database_Description) is
      use GNATCOLL.SQL.Exec;
      rec_no     : record_movement(relative);
   begin
      -- Set up: configure the tree view for the sub-table (see documentation
      -- at http://scentric.net/tutorial/treeview-tutorial.html and at
      -- http://scentric.net/tutorial/treeview-tutorial.html)
      null;
      -- Set up: Open the relevant tables from the database
      pDB:=GNATCOLL.SQL.Exec.Tasking.Get_Task_Connection(Description=>DB_Descr);
      -- Set up: load up the data for the first record (if any)
      Load_Patient_Details_Data(Builder => Builder, 
                             record_no => rec_no,
                             refresh => true);
      -- Register the handlers (see pg 16 of GtkAda user guide)
      Register_Handler(Builder      => Builder,
                       Handler_Name => "file_new_pd_select_cb",
                       Handler      => Patient_Details_New_Selected_CB'Access);
      Register_Handler(Builder      => Builder,
                       Handler_Name => "file_undo_pd_activate_cb",
                       Handler      => Patient_Details_Undo_Selected_CB'Access);
      Register_Handler(Builder      => Builder,
                       Handler_Name => "file_save_pd_activate_cb",
                       Handler      => Patient_Details_Save_Selected_CB'Access);
      Register_Handler(Builder      => Builder,
                       Handler_Name => "file_delete_pd_activate_cb",
                       Handler      => Patient_Details_Delete_Selected_CB'Access);
      Register_Handler(Builder      => Builder,
                       Handler_Name => "file_close_pd_select_cb",
                       Handler      => Patient_Details_Close_CB'Access);
      Register_Handler(Builder      => Builder,
                       Handler_Name => "pd_field_changed_cb",
                       Handler      => Patient_Details_Field_Changed_CB'Access);
      Register_Handler(Builder      => Builder,
                       Handler_Name => "pd_date_changed_cb",
                       Handler      => Patient_Details_Date_Changed_CB'Access);
      Register_Handler(Builder   => Builder,
                       Handler_Name => "pd_number_changed_cb",
                       Handler      => Patient_Details_Number_Changed_CB'Access);
      Register_Handler(Builder      => Builder,
                       Handler_Name => "view_pd_first_select_cb",
                       Handler      => Patient_Details_First_Clicked_CB'Access);
      Register_Handler(Builder      => Builder,
                       Handler_Name => "view_pd_prev_select_cb",
                       Handler      => Patient_Details_Previous_Clicked_CB'Access);
      Register_Handler(Builder      => Builder,
                       Handler_Name => "view_pd_prev_10_select_cb",
                       Handler      => Patient_Details_Previous_10_Clicked_CB'Access);
      Register_Handler(Builder      => Builder,
                       Handler_Name => "view_pd_next_select_cb",
                       Handler      => Patient_Details_Next_Clicked_CB'Access);
      Register_Handler(Builder      => Builder,
                       Handler_Name => "view_pd_next_10_select_cb",
                       Handler      => Patient_Details_Next_10_Clicked_CB'Access);
      Register_Handler(Builder      => Builder,
                       Handler_Name => "view_pd_last_select_cb",
                       Handler      => Patient_Details_Last_Clicked_CB'Access);
      Register_Handler(Builder      => Builder,
                       Handler_Name => "entry_pd_date_icon_press_cb",
                       Handler    => Patient_Details_Date_Button_Pressed_CB'Access);
      Register_Handler(Builder      => Builder,
                       Handler_Name => "btn_patient_ke_first_clicked_cb",
                       Handler      => Btn_Patient_KE_First_Clicked_CB'Access);
      Register_Handler(Builder      => Builder,
                       Handler_Name => "btn_patient_ke_last_clicked_cb",
                       Handler      => Btn_Patient_KE_Last_Clicked_CB'Access);
      Register_Handler(Builder      => Builder,
                       Handler_Name => "btn_patient_ke_add_clicked_cb",
                       Handler      => Btn_Patient_KE_Add_Clicked_CB'Access);
      Register_Handler(Builder      => Builder,
                       Handler_Name => "btn_patient_ke_undo_clicked_cb",
                       Handler      => Btn_Patient_KE_Undo_Clicked_CB'Access);
      Register_Handler(Builder      => Builder,
                       Handler_Name => "btn_patient_ke_save_clicked_cb",
                       Handler      => Btn_Patient_KE_Save_Clicked_CB'Access);
      Register_Handler(Builder      => Builder,
                       Handler_Name => "btn_patient_ke_remove_clicked_cb",
                       Handler      => Btn_Patient_KE_Remove_Clicked_CB'Access);
      Register_Handler(Builder      => Builder,
                       Handler_Name => "ke_field_changed_cb",
                       Handler    => Patient_Details_KE_Field_Changed_CB'Access);
      Register_Handler(Builder      => Builder,
                       Handler_Name => "ke_date_changed_cb",
                       Handler      => Patient_Details_KE_Date_Changed_CB'Access);
      Register_Handler(Builder      => Builder,
                       Handler_Name => "edit_ke_date_edited_cb",
                       Handler      => Patient_Details_KE_Date_edited_CB'Access);
      Register_Handler(Builder      => Builder,
                       Handler_Name => "patient_ke_date_clicked_cb",
                       Handler      => Patient_Details_KE_Date_clicked_CB'Access);
      Register_Handler(Builder      => Builder,
                       Handler_Name => "edit_ke_event_edited_cb",
                       Handler      => Patient_Details_KE_Event_edited_CB'Access);
      Register_Handler(Builder      => Builder,
                       Handler_Name => "edit_ke_description_edited_cb",
                       Handler      => Patient_Details_KE_Desc_edited_CB'Access);
      Register_Handler(Builder      => Builder,
                       Handler_Name => "pd_ke_select_changed_cb",
                       Handler      => Patient_Details_KE_Select_changed_CB'Access);
      Register_Handler(Builder      => Builder,
                       Handler_Name => "entry_ke_date_icon_press_cb",
                       Handler    => Patient_Details_KE_Date_Button_Pressed_CB'Access);
      
      -- Set up the tab order
      declare
         ur_grid      : Gtk.Grid.Gtk_Grid := 
                             Gtk.Grid.Gtk_Grid(Get_Object(Builder, "grid_pd"));
         widget_chain : Gtk.Widget.Widget_List.Glist;
         use Gtk.Grid, Gtk.Widget, Gtk.Widget.Widget_List;
      begin
         -- Load the list with the tab order
         Append(widget_chain,Gtk_Widget(Get_Object(Builder,"entry_patient_identifer")));
         Append(widget_chain,Gtk_Widget(Get_Object(Builder,"entry_patient_name")));
         Append(widget_chain,Gtk_Widget(Get_Object(Builder,"entry_address_line_1")));
         Append(widget_chain,Gtk_Widget(Get_Object(Builder,"entry_address_line_2")));
         Append(widget_chain,Gtk_Widget(Get_Object(Builder,"entry_town")));
         Append(widget_chain,Gtk_Widget(Get_Object(Builder,"entry_state")));
         Append(widget_chain,Gtk_Widget(Get_Object(Builder,"entry_country")));
         Append(widget_chain,Gtk_Widget(Get_Object(Builder,"entry_referral_date")));
         -- And set the list as the tab order
         Set_Focus_Chain(ur_grid, widget_chain);
      end;
      
   end Initialise_Patient_Details;
   
   procedure Show_Patient_Details(Builder : in Gtkada_Builder) is
   begin
      Gtk.Widget.Show_All(Gtk.Widget.Gtk_Widget 
                  (Gtkada.Builder.Get_Object(Builder,"form_patient_details")));
   end Show_Patient_Details;

   procedure Patient_Details_New_Selected_CB 
                (Object : access Gtkada_Builder_Record'Class) is
      use Gtkada.Builder, Gtk.Tool_Button, Gtk.GEntry;
      entry_patient : Gtk.GEntry.gtk_entry;
      can_focus     : boolean;
   begin
      -- Clear all fields
      Clear_Patient_Details_Fields(Gtkada_Builder(Object));
      -- Set a default patient number.
      entry_patient := gtk_entry(Get_Object(Gtkada_Builder(Object), 
                                                "entry_patient_identifer"));
      Set_Text(entry_patient, 
               Glib.UTF8_String(Integer'Image(Number_of_PD_Records(Object)+1)));
      -- Set the focus to the Patient number field  -- DOESN'T WORK!
      can_focus := Get_Can_Focus(entry_patient);
      Set_Can_Focus(entry_patient, true);
      Grab_Focus(entry_patient);
      Set_Can_Focus(entry_patient, can_focus);
      -- disable selectability (sensitive flag) of Store, Delete buttons
      Set_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object),
                                               "tb_pd_save")), False);
      Set_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object),
                                               "tb_pd_delete")), False);
      -- make Undo, Clear selectable (set sensitive flag)
      Set_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object),
                                               "tb_pd_undo")), True);
      Set_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object),
                                               "tb_pd_clear")), True);
      -- done
      Error_Log.Debug_Data(at_level => 5, 
                      with_details => "Patient_Details_New_Selected_CB: Done");
   end Patient_Details_New_Selected_CB;

   procedure Patient_Details_Undo_Selected_CB 
                (Object : access Gtkada_Builder_Record'Class) is
      use Gtkada.Builder, Gtk.Tool_Button, Gtk.GEntry;
      current_record : record_movement(absolute);
      rec_no         : Gtk.GEntry.gtk_entry;
   begin
      -- Get previous/current record number
      rec_no:=gtk_entry(Get_Object(Gtkada_Builder(Object),"lbl_pd_record_no"));
      current_record.record_number := Integer'Value(Get_Text(rec_no));
      -- check if Delete is greyed out (not sensitive).  If so then New
      if Get_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object),
                                               "tb_pd_delete")))
      then  -- Not a new entry - reset back to original
         Load_Patient_Details_Data(Builder   => Gtkada_Builder(Object),
                                   record_no => current_record);
      else  -- New record - undo the new and go back to last record
         Load_Patient_Details_Data(Builder   => Gtkada_Builder(Object),
                                   record_no => current_record);
      end if;
      -- done
      Error_Log.Debug_Data(at_level => 5, 
                     with_details => "Patient_Details_Undo_Selected_CB: Done");
   end Patient_Details_Undo_Selected_CB;

   procedure Patient_Details_Save_Selected_CB 
                (Object : access Gtkada_Builder_Record'Class) is
      use Gtkada.Builder, Gtk.Tool_Button;
      use GNATCOLL.SQL.Exec;
      
      function Get_Entry_Text(Builder : access Gtkada_Builder_Record'Class;
                            the_entry : Glib.UTF8_String) return string is
         use Gtk.GEntry;
         entry_box : Gtk.GEntry.gtk_entry;
      begin
         entry_box := gtk_entry(Get_Object(Builder, the_entry));
         return Get_Text(gtk_entry(entry_box));
      end Get_Entry_Text;
      
      function Get_Entry_Number(Builder : access Gtkada_Builder_Record'Class;
                            the_entry : Glib.UTF8_String) return natural is
         use dStrings;
         the_number : text;
      begin
         the_number := Value(from=>Get_Entry_Text(Builder, the_entry));
         return Get_Integer_From_String(the_number);
      end Get_Entry_Number;
      
      function Get_Entry_Date(Builder : access Gtkada_Builder_Record'Class;
                              the_entry : Glib.UTF8_String) return tDate is
         use Calendar_Extensions, String_Conversions, dStrings;
         the_date : text;
      begin
         the_date := Value(from=>Get_Entry_Text(Builder, the_entry));
         if Length(the_date) <= 2 then -- just day specified, assume this month
            the_date := the_date & "/" & 
                         To_String(from_time=> Clock, with_format=> "mm/yyyy");
         elsif Length(the_date) <= 5 then -- no year specified, assume current
            the_date := the_date & "/" & 
                         To_String(from_time=> Clock, with_format=> "yyyy");
         end if;
         return tDate(To_Time(from_string =>  Value(the_date),
                              with_format => "dd/mm/yyyy"));
      end Get_Entry_Date;
      
      procedure Load_Combo_Box(Q_lookup: SQL_Query; list_store_name: string) is
         R_list   : Forward_Cursor;
         store    : Gtk.List_Store.gtk_list_store;
         iter     : Gtk.Tree_Model.gtk_tree_iter;
         use Gtk.List_Store, String_Conversions;
      begin
         R_list.Fetch (Connection => pDB, Query => Q_lookup);
         if Success(pDB) and then Has_Row(R_list) then
            -- Set up the list store field
            store := gtk_list_store(
                          Gtkada.Builder.Get_Object(Object, list_store_name));
            Clear(store);  -- empty the sub-table ready for the new data
            while Has_Row(R_list) loop  -- while not end_of_table
               Append(store, iter);
               -- PatientDetails (column_num): 0=Identifier, 1=Patient
               Set(store, iter, 0, Glib.Gint(Integer_Value(R_list, 0)));
               Set(store, iter, 1, Glib.UTF8_String(Value(R_list, 1)));
               Error_Log.Debug_Data(at_level => 6, 
                            with_details=>"Patient_Details_Save_Selected_CB: "&
                                              To_Wide_String(Value(R_list,1)));
               Next(R_list);  -- next_record(PatientDetails)
            end loop;
            Error_Log.Debug_Data(at_level => 5, 
                            with_details=>"Patient_Details_Save_Selected_CB: "&
                                    To_Wide_String(list_store_name)&" loaded");
         end if;
      end Load_Combo_Box;
      
      current_record : record_movement(absolute);
      P_pd      : SQL_Parameters (1 .. 8);
      add_line2 : string := Get_Entry_Text(Object, "entry_address_line_2");
      al2_param : SQL_Parameter;
   begin  -- Patient_Details_Save_Selected_CB
      Error_Log.Debug_Data(at_level => 5, 
                    with_details => "Patient_Details_Save_Selected_CB: Start");
      -- Get the current record number
      current_record.record_number := Current(R_patient_details);
      -- Address Line 2 is special because it can be null
      if add_line2'Length = 0 then
         al2_param := Null_Parameter;
      else
         al2_param := +add_line2;
      end if;
      -- Get all the field values and load into the parameter list
      P_pd := (1 => +Get_Entry_Text(Object, "entry_patient_identifer"), -- Identifer
               2 => +Get_Entry_Text(Object, "entry_patient_name"),      -- Patient
               3 => +Get_Entry_Text(Object, "entry_address_line_1"),    -- AddressLine1
               4 => al2_param,                                          -- AddressLine2
               5 => +Get_Entry_Text(Object, "entry_town"),              -- Town
               6 => +Get_Entry_Text(Object, "entry_state"),             -- State
               7 => +Get_Entry_Text(Object, "entry_country"),           -- Country
               8 => +Get_Entry_Date(Object, "entry_referral_date"));    -- ReferralDate
      -- check if Delete is greyed out (not sensitive).  If so then New
      if Get_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object),
                                               "tb_pd_delete")))
      then  -- Not a new entry - Update existing record
         -- build out the parameter list to include the current record's
         -- key fields
         declare
            p_pd_cond   : SQL_Parameters (1 .. 1) :=
                                   (1 => +Integer_Value(R_patient_details, 0));
            p_pd_update : SQL_Parameters (1 .. 9) := (P_pd & p_pd_cond);
         begin
            -- execute the update query
            Execute (Connection=> pDB, Stmt=> PD_update, Params=> P_pd_update);
            Commit_Or_Rollback (pDB);
         end;
      else  -- New record - insert record
         -- First, insert the record
         Execute (Connection => pDB, Stmt => PD_insert, Params => P_pd);
         Commit_Or_Rollback (pDB);
         if Success(pDB) then -- committed, not rolled back
            -- update the record count and go to the current record + 1
            current_record.record_number := current_record.record_number + 1;
         end if;
      end if;
      Error_Log.Debug_Data(at_level => 6, 
                    with_details => "Patient_Details_Save_Selected_CB: Saved");
      -- Finally, for insert or update, refresh the local list of records
      if Success(pDB) then -- i.e. committed, not rolled back
         Load_Patient_Details_Data(Builder   => Gtkada_Builder(Object),
                                   record_no => current_record,
                                   refresh   => true);
         declare
            Q_pd       : SQL_Query;
         begin
            Q_pd := SQL_Select
               (Fields  => PatientDetails.Identifier & PatientDetails.Patient,
                From    => PatientDetails,
                Where   => PatientDetails.Identifier >= 0,
                Order_By=> PatientDetails.Patient);
            Load_Combo_Box(Q_lookup        => Q_pd, 
                           list_store_name => "liststore_patients");
         end;
      else -- some trouble saving
         Error_Dialogue.Show_Error
             (Builder => Gtkada_Builder(Object),
              message => "A database issue encountered saving the record.");
      end if;
      -- disable selectability (sensitive flag) of Store, Undo buttons
      Set_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object),
                                               "tb_pd_save")), False);
      Set_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object),
                                               "tb_pd_undo")), False);
      -- make Delete, Clear selectable (set sensitive flag)
      Set_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object),
                                               "tb_pd_delete")), True);
      Set_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object),
                                               "tb_pd_clear")), True);
      -- done
      Error_Log.Debug_Data(at_level => 5, 
                     with_details => "Patient_Details_Save_Selected_CB: Done");
   end Patient_Details_Save_Selected_CB;

   procedure Patient_Details_Delete_Selected_CB 
                (Object : access Gtkada_Builder_Record'Class) is
     -- Check that the user is sure (if so, the Patient_Details_Delete_Record
     -- is called).
      use Check_For_Deletion;
   begin
      Show_Are_You_Sure(Builder    => Gtkada_Builder(Object),
                        At_Handler => Patient_Details_Delete_Record'Access);
   end Patient_Details_Delete_Selected_CB;
                
   procedure Patient_Details_Delete_Record 
                (Object : access Gtkada_Builder_Record'Class) is
      use GNATCOLL.SQL.Exec;
      use Calendar_Extensions;
      use Gtkada.Builder;
      current_record : record_movement(absolute);
      patient_id     : natural;
   begin
      -- Get the current record
      current_record.record_number := Current(R_patient_details);
      patient_id := Integer_Value (R_patient_details, 0);
      -- Delete the current record
      declare
         -- use String_Conversions;
         P_pd : SQL_Parameters (1 .. 1) := (1 => +patient_id);
      begin
         Execute (Connection => pDB, Stmt => PD_delete, Params => P_pd);
      end;
      --  Commit if delete succeeded, rollback otherwise
      Commit_Or_Rollback (pDB);
      if Success(pDB) then
      -- Go to current record - 1 if not first (otherwise go to 1)
         if current_record.record_number > 1 then
            current_record.record_number := current_record.record_number - 1;
         end if;
      else -- some trouble deleting
         Error_Dialogue.Show_Error
             (Builder => Gtkada_Builder(Object),
              message => "A database issue encountered deleting the record.");
      end if;
      -- Refresh and go to the current record
      Load_Patient_Details_Data(Builder   => Gtkada_Builder(Object),
                             record_no => current_record,
                             refresh   => true);
      -- done
      Error_Log.Debug_Data(at_level => 5, 
                   with_details => "Patient_Details_Delete_Record: Done");
   end Patient_Details_Delete_Record;

   procedure Patient_Details_Close_CB 
                (Object : access Gtkada_Builder_Record'Class) is
   begin
      Error_Log.Debug_Data(at_level => 5, 
                           with_details => "Patient_Details_Close_CB: Start");
      Gtk.Widget.Hide(Gtk.Widget.Gtk_Widget 
                        (Gtkada.Builder.Get_Object(Gtkada_Builder(Object),
                                                   "form_patient_details")));
   end Patient_Details_Close_CB;

   procedure Patient_Details_KE_Select_changed_CB
                (Object : access Gtkada_Builder_Record'Class) is
      -- Selected Row of record has changed - update fields
      use Gtkada.Builder, Gtk.Tree_View, Gtk.Tree_Selection, Gtk.List_Store;
      use Gtk.Tool_Button, Gtk.Tree_Model;
      use Gtk.GEntry, Gtk.Text_Buffer;
      model    : Gtk.Tree_Model.Gtk_Tree_Model;
      iter     : Gtk.Tree_Model.gtk_tree_iter;
      store    : Gtk.List_Store.gtk_list_store;
      ke_select: Gtk.Tree_Selection.gtk_tree_selection;
      col_data : Glib.Values.GValue;
      ke_date  : Gtk.GEntry.gtk_entry;
      ke_event : Gtk.Text_Buffer.gtk_text_buffer;
      ke_desc  : Gtk.Text_Buffer.gtk_text_buffer;
   begin
      Error_Log.Debug_Data(at_level => 5, 
                with_details => "Patient_Details_KE_Select_changed_CB: Start");
      -- Get the hook into the currently selected record
      ke_select:= Get_Selection(Gtk_Tree_View_Record( 
                      (Get_Object(Object,"key_events_tree_view").all))'Access);
      store := gtk_list_store(Get_Object(Object,"key_events_table"));
      Get_Selected(ke_select, model, iter);
      -- hook in the Zoom tab fields
      ke_date := gtk_entry(Get_Object(Object,"entry_ke_date"));
      ke_event:= gtk_text_buffer(Get_Object(Object,"tb_pd_ke_event"));
      ke_desc := gtk_text_buffer(Get_Object(Object,"tb_pd_ke_desc"));
      -- load data into the Zoom tab fields
      treeview_interlock.Lock;
      Get_Value(store, iter, 0, col_data);
      Set_Text(ke_date, Glib.Values.Get_String(col_data));
      Get_Value(store, iter, 1, col_data); 
      Set_Text(ke_event, Glib.Values.Get_String(col_data));
      Get_Value(store, iter, 2, col_data); 
      Set_Text(ke_desc, Glib.Values.Get_String(col_data));
      treeview_interlock.Release;
      -- make Delete, selectable (set sensitive flag)
      Gtk.Tool_Button.Set_Sensitive(Gtk.Tool_Button.Gtk_Tool_Button
          (Gtkada.Builder.Get_Object(Object, "btn_patient_ke_remove")), True);
      -- make Undo, Save not selectable (reset sensitive flag)
      Gtk.Tool_Button.Set_Sensitive(Gtk.Tool_Button.Gtk_Tool_Button
          (Gtkada.Builder.Get_Object(Object, "btn_patient_ke_undo")), False);
      Gtk.Tool_Button.Set_Sensitive(Gtk.Tool_Button.Gtk_Tool_Button
          (Gtkada.Builder.Get_Object(Object, "btn_patient_ke_save")), False);
      -- make First, Last Record selectable or not as appropriate
      Gtk.Tool_Button.Set_Sensitive(Gtk.Tool_Button.Gtk_Tool_Button
          (Gtkada.Builder.Get_Object(Object, "btn_patient_ke_first")), 
           (iter /= Get_Iter_First(store)));
      Gtk.Tool_Button.Set_Sensitive(Gtk.Tool_Button.Gtk_Tool_Button
          (Gtkada.Builder.Get_Object(Object, "btn_patient_ke_last")), 
           (iter /= Get_Iter_First(store)));
   end Patient_Details_KE_Select_changed_CB;

   procedure Btn_Patient_KE_First_Clicked_CB 
                (Object : access Gtkada_Builder_Record'Class) is
      use Gtkada.Builder,Gtk.List_Store;
      use Gtk.Tree_View, Gtk.Tree_Selection;
      store    : Gtk.List_Store.gtk_list_store;
      iter     : Gtk.Tree_Model.gtk_tree_iter;
      tree_view: Gtk.Tree_View.gtk_tree_view;
      selected : Gtk.Tree_Selection.gtk_tree_selection;
   begin
      Error_Log.Debug_Data(at_level => 5, 
                     with_details => "Btn_Patient_KE_First_Clicked_CB: Start");
      -- set the iter to point to the first row
      store     := gtk_list_store(Get_Object(Object, "key_events_table"));
      iter      := Get_Iter_First(store);
      tree_view := gtk_tree_view(Get_Object(Object, "key_events_tree_view"));
      selected  := Get_Selection(tree_view);
      -- select the row pointed to by iter and scroll to it
      Select_Iter(selected, iter);  -- set the tree view selection to iter
      null;
   end Btn_Patient_KE_First_Clicked_CB;
   
   procedure Btn_Patient_KE_Last_Clicked_CB 
                (Object : access Gtkada_Builder_Record'Class) is
      use Gtkada.Builder, Gtk.List_Store, Gtk.Tree_Row_Reference;
      use Gtk.Tree_View, Gtk.Tree_Selection;
      store    : Gtk.List_Store.gtk_list_store;
      iter     : Gtk.Tree_Model.gtk_tree_iter;
      tree_view: Gtk.Tree_View.gtk_tree_view;
      selected : Gtk.Tree_Selection.gtk_tree_selection;
   begin
      Error_Log.Debug_Data(at_level => 5, 
                      with_details => "Btn_Patient_KE_Last_Clicked_CB: Start");
      -- set the iter to point to the last row
      store     := gtk_list_store(Get_Object(Object, "key_events_table"));
      iter      := Get_Iter(store, Get_Path(last_row));
      tree_view := gtk_tree_view(Get_Object(Object, "key_events_tree_view"));
      selected  := Get_Selection(tree_view);
      -- select the row pointed to by iter and scroll to it
      Select_Iter(selected, iter);  -- set the tree view selection to iter
      null;
   end Btn_Patient_KE_Last_Clicked_CB;

   procedure Btn_Patient_KE_Add_Clicked_CB 
                (Object : access Gtkada_Builder_Record'Class) is
      -- Add a new Key Event row
      use Gtkada.Builder, Gtk.Tool_Button, Gtk.Tree_View, Gtk.Tree_Model;
      use Gtk.Tree_Selection, Gtk.List_Store;
      model    : Gtk.Tree_Model.Gtk_Tree_Model;
      store    : Gtk.List_Store.gtk_list_store;
      ke_select: Gtk.Tree_Selection.gtk_tree_selection;
      current  : Gtk.Tree_Model.gtk_tree_iter;
      new_iter : Gtk.Tree_Model.gtk_tree_iter;
   begin
      Error_Log.Debug_Data(at_level => 5, 
                       with_details => "Btn_Patient_KE_Add_Clicked_CB: Start");
      store := gtk_list_store(Get_Object(Object, "key_events_table"));
      ke_select:= Get_Selection(Gtk_Tree_View_Record((Get_Object(Object,
                                         "key_events_tree_view").all))'Access);
      Get_Selected(ke_select, model, current);
      if current = Null_Iter then  -- number of rows = 0
         Insert(store, new_iter, 0);
      else
         Insert_Before(store, new_iter, current);
         Previous(store, current);
         Select_Iter(ke_select, current);  -- select the added blank row
      end if;
      -- new_iter now points to the inserted row
      -- disable selectability (sensitive flag) of Add, Store, Delete buttons
      Set_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object),
                                               "btn_patient_ke_add")), False);
      Set_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object),
                                               "btn_patient_ke_save")), False);
      Set_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object),
                                              "btn_patient_ke_remove")),False);
      -- make Undo, Clear selectable (set sensitive flag)
      Set_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object),
                                               "btn_patient_ke_undo")), True);
      Set_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object),
                                               "tb_pd_clear")), True);
   end Btn_Patient_KE_Add_Clicked_CB;

   procedure Btn_Patient_KE_Undo_Clicked_CB 
                (Object : access Gtkada_Builder_Record'Class) is
      use Gtkada.Builder, Gtk.Tool_Button, Gtk.GEntry, dStrings;
      use Gtk.Tree_View, Gtk.Tree_Model, Gtk.Tree_Selection, Gtk.List_Store;
      use GNATCOLL.SQL.Exec;
      current_record : record_movement(absolute);
      model    : Gtk.Tree_Model.Gtk_Tree_Model;
      store    : Gtk.List_Store.gtk_list_store;
      ke_select: Gtk.Tree_Selection.gtk_tree_selection;
      iter     : Gtk.Tree_Model.gtk_tree_iter;
      the_data : Glib.Values.GValue;
   begin
      Error_Log.Debug_Data(at_level => 5, 
                       with_details => "Btn_Patient_KE_Undo_Clicked_CB: Start");
      -- Get previous/current record number for both patient and events
      current_record.record_number := Current(R_patient_details);
      -- Get a pointer to the row in the tree view
      store := gtk_list_store(Get_Object(GtkAda_Builder(Object),
                                         "key_events_table"));
      ke_select:= Get_Selection(Gtk_Tree_View_Record( 
                                (Get_Object(Gtkada_Builder(Object),
                                         "key_events_tree_view").all))'Access);
      treeview_interlock.Lock;
      -- check if Delete is greyed out (not sensitive).  If so then New
      if Get_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object),
                                               "btn_patient_ke_remove")))
      then  -- Not a new entry - reset back to original
         -- restore current row data
         Get_Selected(ke_select, model, iter);
         Glib.Values.Init_Set_String (the_data, Value(last_ke_date));
         Set_Value(store, iter, 0, the_data);
         Glib.Values.Init_Set_String (the_data, Value(last_ke_event));
         Set_Value(store, iter, 1, the_data);
         Glib.Values.Init_Set_String (the_data, Value(last_ke_desc));
         Set_Value(store, iter, 2, the_data);
      else  -- New record - undo the new and go back to last record
         -- delete new row
         -- Get the pointer current record key field
         Get_Selected(ke_select, model, iter);
         -- and delete it.
         Remove(store, iter);
      end if;
      -- No need to touch the database - it's unchanged.
      treeview_interlock.Release;
      Set_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object),
                                               "btn_patient_ke_add")), True);
      -- done
      Error_Log.Debug_Data(at_level => 5, 
                       with_details => "Urine_Records_Undo_Selected_CB: Done");
   end Btn_Patient_KE_Undo_Clicked_CB;

   procedure Btn_Patient_KE_Save_Clicked_CB 
                (Object : access Gtkada_Builder_Record'Class) is
      use Gtkada.Builder, Gtk.Tool_Button;
      use Gtk.Tree_View, Gtk.Tree_Selection;
      use GNATCOLL.SQL.Exec;
      
      function Get_Entry_Text(Builder : access Gtkada_Builder_Record'Class;
                            the_entry : Glib.UTF8_String) return string is
         use Gtk.GEntry;
         entry_box : Gtk.GEntry.gtk_entry;
      begin
         entry_box := gtk_entry(Get_Object(Builder, the_entry));
         return Get_Text(gtk_entry(entry_box));
      end Get_Entry_Text;
      
      function Get_Text_View(Builder : access Gtkada_Builder_Record'Class;
                             the_tv  : Glib.UTF8_String) return string is
         use Gtk.Text_Buffer, Gtk.Text_Iter;
         tb_box : Gtk.Text_Buffer.gtk_text_buffer;
         start  : Gtk.Text_Iter.gtk_text_iter;
         enditr : Gtk.Text_Iter.gtk_text_iter;
      begin
         tb_box := gtk_text_buffer(Get_Object(Builder, the_tv));
         Get_Start_Iter(tb_box, start);
         Get_End_Iter(tb_box, enditr);
         return Get_Text(tb_box, start, enditr);
      end Get_Text_View;
      
      function Get_Entry_Number(Builder : access Gtkada_Builder_Record'Class;
                            the_entry : Glib.UTF8_String) return natural is
         use dStrings;
         the_number : text;
      begin
         the_number := Value(from=>Get_Entry_Text(Builder, the_entry));
         return Get_Integer_From_String(the_number);
      end Get_Entry_Number;
      
      function Get_Entry_Date(Builder : access Gtkada_Builder_Record'Class;
                              the_entry : Glib.UTF8_String) return tDate is
         use Calendar_Extensions, String_Conversions, dStrings;
         the_date : text;
      begin
         the_date := Value(from=>Get_Entry_Text(Builder, the_entry));
         if Length(the_date) <= 2 then -- just day specified, assume this month
            the_date := the_date & "/" & 
                         To_String(from_time=> Clock, with_format=> "mm/yyyy");
         elsif Length(the_date) <= 5 then -- no year specified, assume current
            the_date := the_date & "/" & 
                         To_String(from_time=> Clock, with_format=> "yyyy");
         end if;
         return tDate(To_Time(from_string =>  Value(the_date),
                              with_format => "dd/mm/yyyy"));
      end Get_Entry_Date;
      
      current_record : record_movement(absolute);
      P_pd     : SQL_Parameters (1 .. 4);
      tree_view: Gtk.Tree_View.gtk_tree_view;
      selected : Gtk.Tree_Selection.gtk_tree_selection;
      model    : Gtk.Tree_Model.Gtk_Tree_Model;
      iter     : Gtk.Tree_Model.gtk_tree_iter;
   begin  -- Btn_Patient_KE_Save_Clicked_CB
      Error_Log.Debug_Data(at_level => 5, 
                       with_details => "Btn_Patient_KE_Save_Clicked_CB: Start");
      -- Get the current record number for both patient and events
      current_record.record_number := Current(R_patient_details);
      tree_view := gtk_tree_view(Get_Object(Object, "key_events_tree_view"));
      selected  := Get_Selection(tree_view);
      Get_Selected(selected, model, iter);
      -- Get all the field values and load into the parameter list
      P_pd := (1 => +Get_Entry_Number(Object, "entry_patient_identifer"),-- Patient
               2 => +Get_Entry_Date(Object, "entry_ke_date"),      -- EventDate
               3 => +Get_Text_View(Object, "tb_pd_ke_event"),      -- Event
               4 => +Get_Text_View(Object, "tb_pd_ke_desc"));      -- Details
      -- check if Add is greyed out (not sensitive).  If so then New
      if Get_Sensitive(Gtk_Tool_Button(Get_Object(Object,
                                                  "btn_patient_ke_add")))
      then  -- Not a new entry - Update existing record
         -- build out the parameter list to include the current record's
         -- key fields
         Error_Log.Debug_Data(at_level => 6, 
                       with_details => "Btn_Patient_KE_Save_Clicked_CB: Update");
         declare
            use Calendar_Extensions, dStrings;
            p_pd_cond : SQL_Parameters (1 .. 2) :=
                           (1=>+Integer_Value(R_patient_details,0),
                            2=>+tDate(To_Time(from_string=>Value(last_ke_date),
                                              with_format=>"dd/mm/yyyy")));
            p_pd_update : SQL_Parameters (1 .. 6) := (P_pd & p_pd_cond);
         begin
            -- execute the update query
            Execute (Connection => pDB, Stmt => KE_update, Params => P_pd_update);
            Commit_Or_Rollback (pDB);
         end;
      else  -- New record - insert record
         -- First, insert the record
         Error_Log.Debug_Data(at_level => 6, 
                       with_details => "Btn_Patient_KE_Save_Clicked_CB: New");
         Execute (Connection => pDB, Stmt => KE_insert, Params => P_pd);
         Commit_Or_Rollback (pDB);
         if Success(pDB) then -- committed, not rolled back
            -- update the record count and go to the current record + 1
            null;--current_record.record_number := current_record.record_number + 1;
         end if;
      end if;
      Error_Log.Debug_Data(at_level => 6, 
                       with_details => "Btn_Patient_KE_Save_Clicked_CB: Saved");
      -- Finally, for insert or update, refresh the local list of records
      if Success(pDB) then -- i.e. committed, not rolled back
         Load_Patient_Details_Data(Builder   => Gtkada_Builder(Object),
                                   record_no => current_record,
                                   refresh   => true);
         -- then point back to the correct Event row  ****DOESN'T WORK****
         Select_Iter(selected, iter);  -- set the tree view selection to iter
      else -- some trouble saving
         Error_Dialogue.Show_Error
             (Builder => Gtkada_Builder(Object),
              message => "A database issue encountered saving the record.");
      end if;
      -- disable selectability (sensitive flag) of Store, Undo buttons
      Set_Sensitive(Gtk_Tool_Button(Get_Object(Object,
                                               "btn_patient_ke_save")), False);
      Set_Sensitive(Gtk_Tool_Button(Get_Object(Object,
                                               "btn_patient_ke_undo")), False);
      -- make Add, Delete, Clear selectable (set sensitive flag)
      Set_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object),
                                               "btn_patient_ke_add")), True);
      Set_Sensitive(Gtk_Tool_Button(Get_Object(Object,
                                               "btn_patient_ke_remove")),True);
      Set_Sensitive(Gtk_Tool_Button(Get_Object(Object,
                                               "tb_pd_clear")), True);
      -- done
      null;
   end Btn_Patient_KE_Save_Clicked_CB;

   procedure Btn_Patient_KE_Remove_Clicked_CB 
                (Object : access Gtkada_Builder_Record'Class) is
      -- Check that the user is sure (if so, the Btn_Patient_KE_Remove_Record
      -- is called).
      use Check_For_Deletion;
   begin
      Show_Are_You_Sure(Builder    => Gtkada_Builder(Object),
                        At_Handler => Btn_Patient_KE_Remove_Record'Access);
   end Btn_Patient_KE_Remove_Clicked_CB;
   
   procedure Btn_Patient_KE_Remove_Record 
                (Object : access Gtkada_Builder_Record'Class) is
      -- Delete the Key Events record that is the current row
      use Gtkada.Builder, Gtk.Tree_View, Gtk.Tree_Model;
      use Gtk.Tree_Selection, Gtk.List_Store;
      use String_Conversions, Calendar_Extensions;
      use GNATCOLL.SQL.Exec;
      model    : Gtk.Tree_Model.Gtk_Tree_Model;
      store    : Gtk.List_Store.gtk_list_store;
      ke_select: Gtk.Tree_Selection.gtk_tree_selection;
      current  : Gtk.Tree_Model.gtk_tree_iter;
      ke_date  : tDate;
      patient  : natural := Integer_Value(R_patient_details, 0);
      col_data : Glib.Values.GValue;
   begin
      Error_Log.Debug_Data(at_level => 5, 
                    with_details => "Btn_Patient_KE_Remove_Record: Start");
      -- Get the current record key field
      store := gtk_list_store(Get_Object(GtkAda_Builder(Object),
                                         "key_events_table"));
      ke_select:= Get_Selection(Gtk_Tree_View_Record( 
                                (Get_Object(Gtkada_Builder(Object),
                                         "key_events_tree_view").all))'Access);
      Get_Selected(ke_select, model, current);
      Get_Value(store, current, 0, col_data);
      ke_date := tDate(To_Time(from_string =>  
                              To_Wide_String(Glib.Values.Get_String(col_data)),
                               with_format => "dd/mm/yyyy"));
      -- Delete from the database
      declare
         -- use String_Conversions;
         P_ke : SQL_Parameters (1 .. 2) := (1 => +patient,
                                            2 => +ke_date);
      begin
         Execute (Connection => pDB, Stmt => KE_delete, Params => P_ke);
      end;
      --  Commit if delete succeeded, rollback otherwise
      Commit_Or_Rollback (pDB);
      if Success(pDB) then
         -- Delete from the list store
         Remove(store, current);
         Error_Log.Debug_Data(at_level => 6, 
                     with_details => "Btn_Patient_KE_Remove_Record: Deleted");
      else -- some trouble deleting
         Error_Dialogue.Show_Error
             (Builder => Gtkada_Builder(Object),
              message => "A database issue encountered deleting the record.");
      end if;
   end Btn_Patient_KE_Remove_Record;

   procedure Patient_Details_KE_Field_Changed_CB
             (Object : access Gtkada_Builder_Record'Class) is
      use Gtkada.Builder, Gtk.Tool_Button, dStrings;
      use Gtk.Tree_View, Gtk.Tree_Selection, Gtk.List_Store, Glib.Values;
      
      function Get_Text_View(Builder : access Gtkada_Builder_Record'Class;
                             the_tv  : Glib.UTF8_String) return string is
         use Gtk.Text_Buffer, Gtk.Text_Iter;
         tb_box : Gtk.Text_Buffer.gtk_text_buffer;
         start  : Gtk.Text_Iter.gtk_text_iter;
         enditr : Gtk.Text_Iter.gtk_text_iter;
      begin
         tb_box := gtk_text_buffer(Get_Object(Builder, the_tv));
         Get_Start_Iter(tb_box, start);
         Get_End_Iter(tb_box, enditr);
         return Get_Text(tb_box, start, enditr);
      end Get_Text_View;
   
      tree_view : Gtk.Tree_View.gtk_tree_view;
      model     : Gtk.Tree_Model.gtk_tree_model;
      store     : Gtk.List_Store.gtk_list_store;
      selected  : Gtk.Tree_Selection.gtk_tree_selection;
      iter      : Gtk.Tree_Model.gtk_tree_iter;
      the_data  : Glib.Values.GValue;
   begin
      Error_Log.Debug_Data(at_level => 5, 
            with_details => "Patient_Details_KE_Field_Changed_CB: Start");
      store := gtk_list_store(Get_Object(Object,"key_events_table"));
      tree_view := gtk_tree_view(Get_Object(Object,"key_events_tree_view"));
      selected  := Get_Selection(tree_view);
      Get_Selected(selected, model, iter);
      if not Get_Sensitive(Gtk_Tool_Button(Get_Object(Object,
                                                      "btn_patient_ke_save")))
         then
         Get_Value(store, iter, 0, the_data);
         last_ke_date := Value(Glib.Values.Get_String(the_data));
         Get_Value(store, iter, 1, the_data);
         last_ke_event:= Value(Glib.Values.Get_String(the_data));
         Get_Value(store, iter, 2, the_data);
         last_ke_desc := Value(Glib.Values.Get_String(the_data));
      end if;
      -- ensure fields in the table view match the Zoom tab if editing
      if Get_Sensitive(Gtk_Tool_Button(Get_Object(Object,
                                                  "btn_patient_ke_save"))) and
         (not treeview_interlock.Is_Locked)
      then
         Glib.Values.Init_Set_String (the_data,
                                      Get_Text_View(Object, "tb_pd_ke_event"));
         Set_Value(store, iter, 1, the_data);
         Glib.Values.Init_Set_String (the_data,
                                      Get_Text_View(Object, "tb_pd_ke_desc"));
         Set_Value(store, iter, 2, the_data);
      end if;
      -- enable selectability (sensitive flag) of Store, Undo buttons
      Set_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object),
                                               "btn_patient_ke_save")), True);
      Set_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object), 
                                               "btn_patient_ke_undo")), True);
   end Patient_Details_KE_Field_Changed_CB;
   
   procedure Patient_Details_KE_Date_Changed_CB
             (Object : access Gtkada_Builder_Record'Class) is
     -- Allowed characters are '0'..'9', '/'
      use Gtkada.Builder, Gtk.Tool_Button, Gtk.GEntry, dStrings;
      use Gtk.Tree_View, Gtk.Tree_Selection, Gtk.List_Store, Glib.Values;
      keyed_data: string  := Get_Text(Gtk_Entry_Record
                              (Get_Object(Object,"entry_ke_date").all)'Access);
      str_len   : natural := keyed_data'Length;
      last_char : character;
      tree_view : Gtk.Tree_View.gtk_tree_view;
      model     : Gtk.Tree_Model.gtk_tree_model;
      store     : Gtk.List_Store.gtk_list_store;
      selected  : Gtk.Tree_Selection.gtk_tree_selection;
      iter      : Gtk.Tree_Model.gtk_tree_iter;
      the_data  : Glib.Values.GValue;
   begin
      Error_Log.Debug_Data(at_level => 5, 
            with_details => "Patient_Details_KE_Date_Changed_CB: Start");
      if str_len > 0 then
         last_char := keyed_data(keyed_data'Last);
         case last_char is
            when '0'..'9' => null;  -- valid data
            when '/'      => null;  -- valid data
            when others =>
               str_len := str_len - 1;
         end case;
            -- Set the Date field on the Zoom tab
         Set_Text(Gtk_Entry_Record(Get_Object(Object, 
                                              "entry_ke_date").all)'Access,
                  keyed_data(keyed_data'First .. str_len));
         -- And set the Date field on the List tab
         store := gtk_list_store(Get_Object(Object,"key_events_table"));
         tree_view := gtk_tree_view(Get_Object(Object,"key_events_tree_view"));
         selected  := Get_Selection(tree_view);
         Get_Selected(selected, model, iter);
         if not Get_Sensitive(Gtk_Tool_Button(Get_Object(Object,
                                                       "btn_patient_ke_save")))
         then
            Get_Value(store, iter, 0, the_data);
            last_ke_date := Value(Glib.Values.Get_String(the_data));
            Get_Value(store, iter, 1, the_data);
            last_ke_event:= Value(Glib.Values.Get_String(the_data));
            Get_Value(store, iter, 2, the_data);
            last_ke_desc := Value(Glib.Values.Get_String(the_data));
         end if;
         Glib.Values.Init_Set_String (the_data,
                                      keyed_data(keyed_data'First .. str_len));
         Set_Value(store, iter, 0, the_data);
      end if;   
      -- enable selectability (sensitive flag) of Store, Undo buttons
      Set_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object),
                                               "btn_patient_ke_save")), True);
      Set_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object), 
                                               "btn_patient_ke_undo")), True);
   end Patient_Details_KE_Date_Changed_CB;

   procedure Patient_Details_KE_Date_Button_Pressed_CB
                (Object : access Gtkada_Builder_Record'Class) is
      use Gtkada.Builder, Gtk.GEntry, Get_Date_Calendar;
      date_entry : Gtk_GEntry := Gtk_GEntry(Get_Object(Object,
                                                       "entry_ke_date"));
   begin
      Error_Log.Debug_Data(at_level => 5, 
            with_details=> "Patient_Details_KE_Date_Button_Pressed_CB: Start");
      -- Pop up the date calendar, act upon it
      Get_Date_Calendar.Show_Calendar(Builder  => Gtkada_Builder(Object),
                                      At_Field => date_entry);
   end Patient_Details_KE_Date_Button_Pressed_CB;

   procedure Patient_Details_KE_Date_edited_CB
                (Object : access Gtkada_Builder_Record'Class) is
      use Gtkada.Builder, Gtk.Tree_View, Gtk.Tree_Model;
      use Gtk.Tree_Selection, Gtk.List_Store;
      use Gtk.GEntry;
      model    : Gtk.Tree_Model.Gtk_Tree_Model;
      store    : Gtk.List_Store.gtk_list_store;
      ke_select: Gtk.Tree_Selection.gtk_tree_selection;
      iter     : Gtk.Tree_Model.gtk_tree_iter;
      col_data : Glib.Values.GValue;
      ke_date  : Gtk.GEntry.gtk_entry;
   begin
      Error_Log.Debug_Data(at_level => 5, 
                   with_details => "Patient_Details_KE_Date_edited_CB: Start");
      store := gtk_list_store(Get_Object(GtkAda_Builder(Object),
                                         "key_events_table"));
      ke_select:= Get_Selection(Gtk_Tree_View_Record( 
                                (Get_Object(Gtkada_Builder(Object),
                                         "key_events_tree_view").all))'Access);
      Get_Selected(ke_select, model, iter);
      Get_Value(store, iter, 0, col_data);
      ke_date := gtk_entry(Get_Object(Object,"entry_ke_date"));
      Set_Text(ke_date, Glib.Values.Get_String(col_data));
      -- do the equivalent of gtk_tree_model_get(model,&iter,COL_NAME,&name,-1);
      -- then do the equivalent of gtk_list_store_set(liststore,&iter,0,"Joe",-1);
      -- then update the record in the database
   end Patient_Details_KE_Date_edited_CB;
   
   procedure Patient_Details_KE_Date_clicked_CB
                (Object : access Gtkada_Builder_Record'Class) is
      use Get_Date_Calendar;
   begin
      Error_Log.Debug_Data(at_level => 5, 
                  with_details => "Patient_Details_KE_Date_clicked_CB: Start");
      -- Show_Calendar(Builder => Gtkada_Builder(Object));
      null;
   end Patient_Details_KE_Date_clicked_CB;

   procedure Patient_Details_KE_Event_edited_CB
                (Object : access Gtkada_Builder_Record'Class) is
   begin
      Error_Log.Debug_Data(at_level => 5, 
                  with_details => "Patient_Details_KE_Event_edited_CB: Start");
      null;
   end Patient_Details_KE_Event_edited_CB;

   procedure Patient_Details_KE_Desc_edited_CB
                (Object : access Gtkada_Builder_Record'Class) is
   begin
      Error_Log.Debug_Data(at_level => 5, 
                   with_details => "Patient_Details_KE_Desc_edited_CB: Start");
      null;
   end Patient_Details_KE_Desc_edited_CB;

   procedure Patient_Details_Field_Changed_CB
             (Object : access Gtkada_Builder_Record'Class) is
      use Gtkada.Builder, Gtk.Tool_Button;
   begin
      Error_Log.Debug_Data(at_level => 5, 
            with_details => "Patient_Details_Field_Changed_CB: Start");
      -- enable selectability (sensitive flag) of Store, Undo buttons
      Set_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object),
                                               "tb_pd_save")), True);
      Set_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object), 
                                               "tb_pd_undo")), True);      
   end Patient_Details_Field_Changed_CB;
   
   procedure Patient_Details_Date_Changed_CB
             (Object : access Gtkada_Builder_Record'Class) is
     -- Allowed characters are '0'..'9', '/'
      use Gtkada.Builder, Gtk.Tool_Button, Gtk.GEntry;
      keyed_data : string := Get_Text(Gtk_Entry_Record
        (Get_Object(Gtkada_Builder(Object),"entry_referral_date").all)'Access);
      str_len   : natural := keyed_data'Length;
      last_char : character;
   begin
      Error_Log.Debug_Data(at_level => 5, 
            with_details => "Patient_Details_Date_Changed_CB: Start");
      if str_len > 0 then
         last_char := keyed_data(keyed_data'Last);
         case last_char is
            when '0'..'9' => null;  -- valid data
            when '/'      => null;  -- valid data
            when others =>
               str_len := str_len - 1;
         end case;
         Set_Text(Gtk_Entry_Record(Get_Object(Gtkada_Builder(Object), 
                                            "entry_referral_date").all)'Access,
                  keyed_data(keyed_data'First .. str_len));
      end if;   
      -- enable selectability (sensitive flag) of Store, Undo buttons
      Set_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object),
                                               "tb_pd_save")), True);
      Set_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object), 
                                               "tb_pd_undo")), True);      
   end Patient_Details_Date_Changed_CB;
   
   procedure Patient_Details_Number_Changed_CB
             (Object : access Gtkada_Builder_Record'Class) is
     -- Allowed characters are '0'..'9', '.'
      use Gtkada.Builder, Gtk.Tool_Button, Gtk.GEntry;
      -- the_entry  : Gtk_Entry := Gtk_Entry(Gtkada_Builder(Object));
      entry_name : constant string := "entry_patient_identifer";
      keyed_data : string := Get_Text(Gtk_Entry_Record
             (Get_Object(Gtkada_Builder(Object), entry_name).all)'Access);
      str_len   : natural := keyed_data'Length;
      last_char : character;
   begin
      Error_Log.Debug_Data(at_level => 5, 
            with_details => "Patient_Details_Number_Changed_CB: Start");
      if str_len > 0 then
         last_char := keyed_data(keyed_data'Last);
         case last_char is
            when '0'..'9' => null;  -- valid data
            when '.'      => null;  -- valid data
            when others =>
               str_len := str_len - 1;
         end case;
         Set_Text(Gtk_Entry_Record(Get_Object(Gtkada_Builder(Object), 
                                              entry_name).all)'Access,
                  keyed_data(keyed_data'First .. str_len));
      end if;   
      -- enable selectability (sensitive flag) of Store, Undo buttons
      Set_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object),
                                               "tb_pd_save")), True);
      Set_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object), 
                                               "tb_pd_undo")), True);      
   end Patient_Details_Number_Changed_CB;

   procedure Patient_Details_First_Clicked_CB
                (Object : access Gtkada_Builder_Record'Class) is
      direction : record_movement(relative) := (relative, first);
   begin
      Load_Patient_Details_Data(Builder => Gtkada_Builder(Object),
                                record_no => direction);
   end Patient_Details_First_Clicked_CB;

   procedure Patient_Details_Previous_10_Clicked_CB
                (Object : access Gtkada_Builder_Record'Class) is
      direction : record_movement(relative) := (relative, back10);
   begin
      Load_Patient_Details_Data(Builder => Gtkada_Builder(Object),
                                record_no => direction);
   end Patient_Details_Previous_10_Clicked_CB;
 
   procedure Patient_Details_Previous_Clicked_CB
                (Object : access Gtkada_Builder_Record'Class) is
      direction : record_movement(relative) := (relative, backward);
   begin
      Load_Patient_Details_Data(Builder => Gtkada_Builder(Object),
                                record_no => direction);
   end Patient_Details_Previous_Clicked_CB;

   procedure Patient_Details_Next_Clicked_CB
                (Object : access Gtkada_Builder_Record'Class) is
      direction : record_movement(relative) := (relative, forward);
   begin
      Load_Patient_Details_Data(Builder => Gtkada_Builder(Object),
                                record_no => direction);
   end Patient_Details_Next_Clicked_CB;
   
   procedure Patient_Details_Next_10_Clicked_CB
                (Object : access Gtkada_Builder_Record'Class) is
      direction : record_movement(relative) := (relative, next10);
   begin
      Load_Patient_Details_Data(Builder => Gtkada_Builder(Object),
                                record_no => direction);
   end Patient_Details_Next_10_Clicked_CB;

   procedure Patient_Details_Last_Clicked_CB
                (Object : access Gtkada_Builder_Record'Class) is
      direction : record_movement(relative) := (relative, last);
   begin
      Load_Patient_Details_Data(Builder => Gtkada_Builder(Object),
                             record_no => direction);
   end Patient_Details_Last_Clicked_CB;

   procedure Patient_Details_Date_Button_Pressed_CB
                (Object : access Gtkada_Builder_Record'Class) is
      use Gtkada.Builder, Gtk.GEntry, Get_Date_Calendar;
      date_entry : Gtk_GEntry := Gtk_GEntry(Get_Object(Gtkada_Builder(Object),
                                                       "entry_referral_date"));
   begin
      Error_Log.Debug_Data(at_level => 5, 
            with_details => "Patient_Details_Date_Button_Pressed_CB: Start");
      -- Pop up the date calendar, act upon it
      Get_Date_Calendar.Show_Calendar(Builder  => Gtkada_Builder(Object),
                                      At_Field => date_entry);
   end Patient_Details_Date_Button_Pressed_CB;
   
   function Number_of_PD_Records(Builder : access Gtkada_Builder_Record'Class)
                              return natural is
      use GNATCOLL.SQL.Exec;
      Q_pd : SQL_Query;
      R_pd : Forward_Cursor;
   begin
      Q_pd := SQL_Select
         (Fields  => Apply (Func_Count, (PatientDetails.Identifier)),
         From    => PatientDetails,
         Where   => PatientDetails.Identifier >= 0);
      R_pd.Fetch (Connection => pDB, Query => Q_pd);
   -- Load fields from the first record (if any)
      if not Success(pDB) then
         return 0;  -- assume none
      elsif Success(pDB) and then Has_Row(R_pd) then
         return Integer_Value (R_pd, 0);
      else -- there are none and the table can't exist
         return 0;
      end if;
   end Number_of_PD_Records;

   function Number_of_KE_Records(Builder : access Gtkada_Builder_Record'Class)
                              return natural is
      use GNATCOLL.SQL.Exec;
      Q_pd : SQL_Query;
      R_pd : Forward_Cursor;
   begin
      Q_pd := SQL_Select
         (Fields  => Apply (Func_Count, (KeyEvents.Patient)),
         From    => KeyEvents,
         Where   => KeyEvents.Patient >= 0);
      R_pd.Fetch (Connection => pDB, Query => Q_pd);
   -- Load fields from the first record (if any)
      if not Success(pDB) then
         return 0;  -- assume none
      elsif Success(pDB) and then Has_Row(R_pd) then
         return Integer_Value (R_pd, 0);
      else -- there are none and the table can't exist
         return 0;
      end if;
   end Number_of_KE_Records;
  
   procedure Clear_Patient_Details_Fields
                   (Builder : access Gtkada_Builder_Record'Class) is
      use Gtk.GEntry, Gtk.Check_Button, Gtk.Label;
      use String_Conversions, Calendar_Extensions;
      identifier  : Gtk.Gentry.gtk_entry;
      patient     : Gtk.Gentry.gtk_entry;
      address_ln1 : Gtk.GEntry.gtk_entry;
      address_ln2 : Gtk.GEntry.gtk_entry;
      town        : Gtk.GEntry.gtk_entry;
      state       : Gtk.GEntry.gtk_entry;
      country     : Gtk.GEntry.gtk_entry;
      referral    : Gtk.GEntry.gtk_entry;
      Bld         : Gtkada_Builder := Gtkada_Builder(Builder);
   begin
      -- Set up the fields
      declare
         use Gtkada.Builder;
      begin
         identifier:= gtk_entry(Get_Object(Builder,"entry_patient_identifer"));
         patient    := gtk_entry(Get_Object(Builder,"entry_patient_name"));
         address_ln1:= gtk_entry(Get_Object(Builder,"entry_address_line_1"));
         address_ln2:= gtk_entry(Get_Object(Builder,"entry_address_line_2"));
         town       := gtk_entry(Get_Object(Builder,"entry_town"));
         state      := gtk_entry(Get_Object(Builder,"entry_state"));
         country    := gtk_entry(Get_Object(Builder,"entry_country"));
         referral   := gtk_entry(Get_Object(Builder,"entry_referral_date"));
      end;
      Error_Log.Debug_Data(at_level => 6, 
                           with_details => "Clear_Patient_Details_Fields: " &
                                                 " initialised fields.");
      Set_Text(identifier,  "");
      Set_Text(patient,     "");
      Set_Text(address_ln1, "");
      Set_Text(address_ln2, "");
      Set_Text(town,        "");
      Set_Text(state,       "");
      Set_Text(country,     "");
      Set_Text(referral, To_String(from_wide =>
               To_String(from_time => Clock, with_format => "dd/mm/yyyy")));
      declare
         use Gtk.List_Store;
         store : Gtk.List_Store.gtk_list_store;
      begin
         store := gtk_list_store(
                        Gtkada.Builder.Get_Object(Builder,"key_events_table"));
         Clear(store);
      end;
   end Clear_Patient_Details_Fields;

   procedure Load_Patient_Details_Data
                   (Builder   : access Gtkada_Builder_Record'Class;
                    record_no : record_movement; 
                    refresh   : boolean := false) is
      use GNATCOLL.SQL.Exec;
      use String_Conversions, Calendar_Extensions;
      patientid  : integer;
      R_pd       : Direct_Cursor renames R_patient_details;
      total_recs : natural := Number_of_PD_Records(Builder);
   begin  -- Load_Patient_Details_Data
      if refresh then  -- (re)run the query
         R_pd.Fetch (Connection => pDB, Stmt => PD_select);
      end if;
      -- Go to the desired record
      case record_no.mvt_type is
         when absolute =>
            Absolute(R_pd, record_no.record_number);
         when relative =>
            case record_no.movement is
               when first    => First   (R_pd);
               when last     => Last    (R_pd);
               when backward => Relative(R_pd, -1);
               when forward  => Relative(R_pd, +1);
               when back10   => Relative(R_pd, -10);
               when next10   => Relative(R_pd, +10);
            end case;
      end case;
      -- Load fields from the first record (if any)
      if not Success(pDB) then
         null;  -- take some action
      elsif Success(pDB) and then Has_Row(R_pd) then
         -- Load up the fields with data
         declare
            rec_no   : Gtk.GEntry.gtk_entry;
            rec_cnt  : Gtk.Label.gtk_label;
            the_id   : Gtk.GEntry.gtk_entry;
            patient  : Gtk.GEntry.gtk_entry;
            addr_ln1 : Gtk.GEntry.gtk_entry;
            addr_ln2 : Gtk.GEntry.gtk_entry;
            town     : Gtk.GEntry.gtk_entry;
            state    : Gtk.GEntry.gtk_entry;
            country  : Gtk.GEntry.gtk_entry;
            referral : Gtk.GEntry.gtk_entry;
            use Gtk.GEntry, Gtk.Label;
         begin
         -- see http://scentric.net/tutorial/sec-treemodel-add-rows.html
         -- Set up the main patient details record fields
            declare
               use Gtkada.Builder;
            begin
               rec_no  := gtk_entry(Get_Object(Builder,"lbl_pd_record_no"));
               rec_cnt := gtk_label(Get_Object(Builder,"lbl_pd_num_records"));
               the_id  := gtk_entry(Get_Object(Builder,"entry_patient_identifer"));
               patient := gtk_entry(Get_Object(Builder,"entry_patient_name"));
               addr_ln1:= gtk_entry(Get_Object(Builder,"entry_address_line_1"));
               addr_ln2:= gtk_entry(Get_Object(Builder,"entry_address_line_2"));
               town := gtk_entry(Get_Object(Builder,"entry_town"));
               state:= gtk_entry(Get_Object(Builder,"entry_state"));
               country := gtk_entry(Get_Object(Builder,"entry_country"));
               referral:= gtk_entry(Get_Object(Builder,"entry_referral_date"));
            end;
            Error_Log.Debug_Data(at_level => 6, 
                                 with_details => "Load_Patient_Details_Data: "&
                                                 " initialised fields.");
            -- Set the record number and the record count
          -- Load up the head data
            Set_Text(rec_no, Glib.UTF8_String(Integer'Image(Current(R_pd))));
            Set_Label(rec_cnt, Integer'Image(total_recs));
            -- Load up the patient details data into the fields
            patientid := Integer_Value (R_pd, 0);  -- keep for later use
            Set_Text(the_id, Glib.UTF8_String(Integer'Image(patientid)));
            Error_Log.Debug_Data(at_level => 6, 
                                 with_details => "Load_Patient_Details_Data: "&
                                                 " set up Patient ID.");
            Set_Text(patient, Glib.UTF8_String(Value(R_pd, 1)));
            Set_Text(addr_ln1, Glib.UTF8_String(Value(R_pd, 2)));
            Set_Text(addr_ln2, Glib.UTF8_String(Value(R_pd, 3)));
            Set_Text(town, Glib.UTF8_String(Value(R_pd, 4)));
            Set_Text(state, Glib.UTF8_String(Value(R_pd, 5)));
            Set_Text(country, Glib.UTF8_String(Value(R_pd, 6)));
            Set_Text(referral, To_String(from_wide => 
                             To_String(from_time => Time(tDate_Value(R_pd, 7)),
                                       with_format => "dd/mm/yyyy")));
            Error_Log.Debug_Data(at_level => 6, 
                                 with_details => "Load_Patient_Details_Data: "&
                                                 " set up Referral Date.");
         end;  -- loading up main table data for patient
      -- Set up: load up the sub-table data (if any)
         declare
            model    : Gtk.Tree_Model.gtk_tree_model;
            store    : Gtk.List_Store.gtk_list_store;
            iter     : Gtk.Tree_Model.gtk_tree_iter;
            the_data : Glib.Values.GValue;
            Q_events : SQL_Query;
            R_events : Forward_Cursor;
            use Gtk.List_Store, Gtk.Tree_Row_Reference, Gtk.Tree_Model;
         begin
         -- see http://scentric.net/tutorial/sec-treemodel-add-rows.html
         -- Set up the list store field
            store := gtk_list_store(
                        Gtkada.Builder.Get_Object(Builder,"key_events_table"));
         -- Start the data load
            Clear(store);  -- empty the sub-table ready for the new data
         -- Select * FROM KeyEvents WHERE Patient = Patient_ID:
            Q_events := SQL_Select
               (Fields => KeyEvents.EventDate & 
                       KeyEvents.Event & KeyEvents.Details,
               From   => KeyEvents,
               Where  => KeyEvents.Patient = patientid);
            R_events.Fetch (Connection => pDB, Query => Q_events);
            while Has_Row(R_events) loop  -- while not end_of_table(KeyEvents)
               Append(store, iter);
               for column_num in 0 .. 2 loop
                  -- KeyEvents (column_num+1): 1=EventDate, 2=Event, 3=Details
                  if column_num = 0 then
                     Glib.Values.Init_Set_String (the_data,
                        To_String(from_wide => 
                           To_String(from_time=>Time(tDate_Value(R_events,0)),
                                     with_format => "dd/mm/yyyy")));
                  else
                     Glib.Values.Init_Set_String (the_data, 
                                      Value(R_events,Field_Index(column_num)));
                  end if;
                  Set_Value(store, iter, Glib.Gint(column_num), the_data);
                  -- Set the new last row
                  Free(last_row);
                  model := To_Interface(store);
                  Gtk_New(last_row, model, Get_Path(store, iter));
               end loop;
               Next(R_events);  -- next_record(KeyEvents)
            end loop;
         end;  -- setting up sub-table data
         -- Grey out or activate the record movement buttons as necessary
         declare
            use Gtkada.Builder, Gtk.Tool_Button;
         begin
            Set_Sensitive(Gtk_Tool_Button(Get_Object(Builder, "tb_pd_first")), 
                          True);
            Set_Sensitive(Gtk_Tool_Button(Get_Object(Builder,
                                                     "tb_pd_previous")), True);
            Set_Sensitive(Gtk_Tool_Button(Get_Object(Builder, "tb_pd_next")),
                          True);
            Set_Sensitive(Gtk_Tool_Button(Get_Object(Builder, "tb_pd_last")),
                          True);
            if Current(R_pd) <= 1 then  -- at first record
               Set_Sensitive(Gtk_Tool_Button(Get_Object(Builder,
                                               "tb_pd_first")), False);
               Set_Sensitive(Gtk_Tool_Button(Get_Object(Builder,
                                               "tb_pd_previous")), False);
            end if;
            if Current(R_pd) >= total_recs then  -- at last record
               Set_Sensitive(Gtk_Tool_Button(Get_Object(Builder,"tb_pd_next")),
                             False);
               Set_Sensitive(Gtk_Tool_Button(Get_Object(Builder,"tb_pd_last")),
                             False);
            end if;
         end;
      else -- haven't stored any patient details yet.
         declare
            use Gtkada.Builder, Gtk.Tool_Button;
         begin
            Error_Log.Debug_Data(at_level => 6, 
                              with_details => "Load_Patient_Details_Data: " &
                                              " no urine records yet.");
            Set_Sensitive(Gtk_Tool_Button(Get_Object(Builder,"tb_pd_first")), 
                          False);
            Set_Sensitive(Gtk_Tool_Button(Get_Object(Builder,
                                                     "tb_ur_previous")),False);
            Set_Sensitive(Gtk_Tool_Button(Get_Object(Builder, "tb_pd_next")),
                          False);
            Set_Sensitive(Gtk_Tool_Button(Get_Object(Builder,"tb_pd_last")), 
                          False);
         end;
      end if;
      -- disable selectability (sensitive flag) of Store, Undo buttons
      Gtk.Tool_Button.Set_Sensitive(Gtk.Tool_Button.Gtk_Tool_Button
                   (Gtkada.Builder.Get_Object(Builder, "tb_pd_save")), False);
      Gtk.Tool_Button.Set_Sensitive(Gtk.Tool_Button.Gtk_Tool_Button
                   (Gtkada.Builder.Get_Object(Builder, "tb_pd_undo")), False);
      -- make Delete, Clear selectable (set sensitive flag)
      Gtk.Tool_Button.Set_Sensitive(Gtk.Tool_Button.Gtk_Tool_Button
                   (Gtkada.Builder.Get_Object(Builder, "tb_pd_delete")), True);
      Gtk.Tool_Button.Set_Sensitive(Gtk.Tool_Button.Gtk_Tool_Button
                   (Gtkada.Builder.Get_Object(Builder, "tb_pd_clear")), True);
      -- done
      Error_Log.Debug_Data(at_level => 5, 
                           with_details => "Load_Patient_Details_Data: Done");
   end Load_Patient_Details_Data;

   procedure Finalise is
   begin
      -- GNATCOLL.SQL.Exec.Free (pDB); -- Gives 'double free' error if uncommented
      null;
   end Finalise;

begin
   Urine_Record_Version.Register(revision => "$Revision: v1.0.0$",
                                 for_module => "Patient_Details");
end Patient_Details;
