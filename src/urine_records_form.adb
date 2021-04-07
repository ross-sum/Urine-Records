-----------------------------------------------------------------------
--                                                                   --
--                U R I N E   R E C O R D S   F O R M                --
--                                                                   --
--                              B o d y                              --
--                                                                   --
--                           $Revision: 1.0 $                        --
--                                                                   --
--  Copyright (C) 2020  Hyper Quantum Pty Ltd.                       --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This package displays the urine records data entry form,  which  --
--  contains information around each urination event. That includes  --
--  the volume, the pad weight (when a pad is changed), the kind of  --
--  pad  change, whether any urges or spasms were  experienced  and  --
--  how many, and whether a bowel motion was involved.  For spasms,  --
--  the  intensity  as measured through the amount of  overflow  is  --
--  recorded.   These  details  are recorded for the  time  of  the  --
--  urination event.                                                 --
--                                                                   --
--  A big thank you to Kevin O'Kane for his You Tube videos on  how  --
--  to use Glade.  Whilst his stuff is all in C, the information is  --
--  directly  translatable in many cases and, if not, it points  to  --
--  where  to look for how to do what you are  intending.   Kevin's  --
--  presentations are very informative.                              --
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
-- with Gtkada.Builder;  use Gtkada.Builder;
-- with Glib.Object;
-- with GNATCOLL.SQL.Exec;
-- with Calendar_Extensions;
with Gtk.Widget, Gtk.Grid;
with Gtk.Tool_Button;
with Gtk.GEntry, Gtk.Check_Button;
with Gtk.List_Store, Gtk.Tree_Model, Gtk.Tree_Selection, Gtk.Combo_Box;
with Gtk.Text_Iter;
with Gtk.Label, Gtk.Text_buffer;
with Glib, Glib.Values;
with Error_Log;
with String_Conversions;
with Urine_Record_Version;
with GNATCOLL.SQL.Exec.Tasking, GNATCOLL.SQL_Impl;
with GNATCOLL.SQL_Date_and_Time; use GNATCOLL.SQL_Date_and_Time;
with GNATCOLL.SQL;               use GNATCOLL.SQL;
with Database;                   use Database;
with Get_Date_Calendar;
with Check_For_Deletion;
with Error_Dialogue;
with dStrings;
package body Urine_Records_Form is

   -- private
   -- 
   --    type mvt_types is (relative, absolute);
   --    type relative_movements is (first, back10, backward, 
   --                                forward, next10, last);
   --    type record_movement(mvt_type : mvt_types) is
   --       record
   --          case mvt_type is
   --             when relative =>
   --                movement : relative_movements := first;
   --             when absolute =>
   --                record_number : natural := 1;
   --          end case;
   --       end record;

   DB              : GNATCOLL.SQL.Exec.Database_Connection;
   number_of_patients: natural := 0;
   -- Set up all the prepared queries
   UR_select       : constant GNATCOLL.SQL.Exec.Prepared_Statement :=
      GNATCOLL.SQL.Exec.Prepare 
           (SQL_Select(Fields  => UrineRecord.Patient & UrineRecord.UDate & 
                                  UrineRecord.UTime & UrineRecord.Volume &
                                  UrineRecord.PadVolume & UrineRecord.Hold & 
                                  UrineRecord.Leakage & UrineRecord.PadType &
                                  UrineRecord.No2 & UrineRecord.Urges &
                                  UrineRecord.Spasm & UrineRecord.SpasmCount &
                                  UrineRecord.Notes,
                       From    => UrineRecord,
                       Order_By=> UrineRecord.Patient & UrineRecord.UDate & 
                                  UrineRecord.UTime),
            On_Server => True,
            Use_Cache => True);
   UR_insert       : constant GNATCOLL.SQL.Exec.Prepared_Statement :=
      GNATCOLL.SQL.Exec.Prepare 
           (SQL_Insert(Values  => (UrineRecord.Patient   = Integer_Param(1)) &
                                  (UrineRecord.UDate     = tDate_Param (2)) &
                                  (UrineRecord.UTime     = tTime_Param (3)) &
                                  (UrineRecord.Volume    = Integer_Param(4)) &
                                  (UrineRecord.PadVolume = Integer_Param(5)) &
                                  (UrineRecord.Hold      = Integer_Param(6)) &
                                  (UrineRecord.Leakage   = Integer_Param(7)) &
                                  (UrineRecord.PadType   = Integer_Param(8)) &
                                  (UrineRecord.No2       = Boolean_Param(9)) &
                                  (UrineRecord.Urges     = Integer_Param(10)) &
                                  (UrineRecord.Spasm     = Integer_Param(11)) & 
                                  (UrineRecord.SpasmCount= Integer_Param(12)) &
                                  (UrineRecord.Notes     = Text_Param (13))),
            On_Server => True,
            Use_Cache => False);
   UR_update       : constant GNATCOLL.SQL.Exec.Prepared_Statement :=
      GNATCOLL.SQL.Exec.Prepare 
           (SQL_Update(Table => UrineRecord,
                       Set   => (UrineRecord.Patient   = Integer_Param(1)) &
                                (UrineRecord.UDate     = tDate_Param (2)) &
                                (UrineRecord.UTime     = tTime_Param (3)) &
                                (UrineRecord.Volume    = Integer_Param(4)) &
                                (UrineRecord.PadVolume = Integer_Param(5)) &
                                (UrineRecord.Hold      = Integer_Param(6)) &
                                (UrineRecord.Leakage   = Integer_Param(7)) &
                                (UrineRecord.PadType   = Integer_Param(8)) &
                                (UrineRecord.No2       = Boolean_Param(9)) &
                                (UrineRecord.Urges     = Integer_Param(10)) &
                                (UrineRecord.Spasm     = Integer_Param(11)) & 
                                (UrineRecord.SpasmCount= Integer_Param(12)) &
                                (UrineRecord.Notes     = Text_Param (13)),
                       Where => (UrineRecord.Patient = Integer_Param (14)) AND
                                (UrineRecord.UDate   = tDate_Param (15)) AND
                                (UrineRecord.UTime   = tTime_Param (16))),
            On_Server => True,
            Use_Cache => False);
   UR_delete       : constant GNATCOLL.SQL.Exec.Prepared_Statement :=
      GNATCOLL.SQL.Exec.Prepare 
           (SQL_Delete(From  => UrineRecord,
                       Where => (UrineRecord.Patient = Integer_Param (1)) AND
                                (UrineRecord.UDate   = tDate_Param (2)) AND
                                (UrineRecord.UTime   = tTime_Param (3))),
            On_Server => True,
            Use_Cache => False);
   R_urine_records : GNATCOLL.SQL.Exec.Direct_Cursor;

   function Number_of_Records(Builder : access Gtkada_Builder_Record'Class)
                              return natural is
      use GNATCOLL.SQL.Exec;
      Q_pd : SQL_Query;
      R_ur : Forward_Cursor;
   begin
      Q_pd := SQL_Select
         (Fields  => Apply (Func_Count, (UrineRecord.Patient)),
         From    => UrineRecord,
         Where   => UrineRecord.Patient >= 0);
      R_ur.Fetch (Connection => DB, Query => Q_pd);
   -- Load fields from the first record (if any)
      if not Success(DB) then
         return 0;  -- assume none
      elsif Success(DB) and then Has_Row(R_ur) then
         return Integer_Value (R_ur, 0);
      else -- there are none and the table can't exist
         return 0;
      end if;
   end Number_of_Records;

   procedure Set_To_ID(Builder    : access Gtkada_Builder_Record'Class;
                       combo      : Gtk.Combo_Box.gtk_combo_box;
                       list_store : string; id : natural) is
      -- Sets the Combo box to the specified identifier based on what
      -- that identifier is in the list store.
      use Gtk.Combo_Box, Gtk.Tree_Selection, Gtk.List_Store;
      iter     : Gtk.Tree_Model.gtk_tree_iter;
      store    : Gtk.List_Store.gtk_list_store;
      col_data : Glib.Values.GValue;
      rec_no   : natural := 0;
   begin
      store := gtk_list_store(Get_Object(Builder, list_store));
      iter := Get_Iter_First(store);
      Get_Value(Tree_Model => store, Iter => iter, 
                   Column => 0, Value => col_data);
      while Integer(Glib.Values.Get_Int(col_data)) /= id loop
         Next(store, iter);
         Get_Value(Tree_Model => store, Iter => iter, 
                      Column => 0, Value => col_data);
         rec_no := rec_no + 1;
      end loop;
      Set_Active(combo, Glib.Gint(rec_no));
   end Set_To_ID;
  
   procedure Clear_Urine_Record_Fields
                   (Builder : access Gtkada_Builder_Record'Class) is
      use Gtk.GEntry, Gtk.Check_Button, Gtk.Combo_Box, Gtk.Label;
      use Gtk.Text_Buffer;
      use String_Conversions, Calendar_Extensions;
      patient  : Gtk.Gentry.gtk_entry;
      the_date : Gtk.GEntry.gtk_entry;
      the_time : Gtk.GEntry.gtk_entry;
      blad_vol : Gtk.GEntry.gtk_entry;
      pad_vol  : Gtk.GEntry.gtk_entry;
      pad_type : Gtk.GEntry.gtk_entry;
      leakage  : Gtk.Combo_Box.gtk_combo_box;
      hold     : Gtk.Combo_Box.gtk_combo_box;
      urges    : Gtk.GEntry.gtk_entry;
      spasm    : Gtk.Combo_Box.gtk_combo_box;
      spasmcnt : Gtk.GEntry.gtk_entry;
      No2      : Gtk.Check_Button.gtk_check_button;
      notes_tb : Gtk.Text_Buffer.gtk_text_buffer;
      Bld      : Gtkada_Builder := Gtkada_Builder(Builder);
   begin
      -- Set up the fields
      declare
         use Gtkada.Builder;
      begin
         patient := gtk_entry(Get_Object(Builder, "ce_ur_name"));
         the_date:= gtk_entry(Get_Object(Builder,"entry_ur_date"));
         the_time:= gtk_entry(Get_Object(Builder,"entry_ur_time"));
         blad_vol:= gtk_entry(Get_Object(Builder,"entry_ur_volume"));
         pad_vol := gtk_entry(Get_Object(Builder,"entry_ur_pad_volume"));
         pad_type:= gtk_entry(Get_Object(Builder,"ce_ur_padtype"));
         leakage := gtk_combo_box(Get_Object(Builder,"combo_ur_leakage"));
         hold    := gtk_combo_box(Get_Object(Builder,"combo_ur_hold"));
         No2     := gtk_check_button(Get_Object(Builder,"chkbtn_no2"));
         spasm   := gtk_combo_box(Get_Object(Builder,"combo_ur_spasm"));
         spasmcnt:= gtk_entry(Get_Object(Builder,"entry_ur_spasm"));
         urges   := gtk_entry(Get_Object(Builder,"entry_ur_urges"));
         notes_tb:= gtk_text_buffer(Get_Object(Builder,"tb_ur_notes"));
      end;
      Error_Log.Debug_Data(at_level => 6, 
                           with_details => "Clear_Urine_Record_Fields: " &
                                                 " initialised fields.");
      -- Clear all fields or set to default (with current date and time)
      Set_Text(patient,     "");
      Set_Text(the_date, To_String(from_wide =>
               To_String(from_time => Clock, with_format => "dd/mm/yyyy")));
      Set_Text(the_time, To_String(from_wide =>
               To_String(from_time => Clock, with_format => "hh:nn:ss")));
      Set_Text(blad_vol,    "");
      Set_Text(pad_vol,     "0");
      Set_Text(pad_type,    "");
      Set_To_ID(Bld, leakage, "liststore_leakage", 0);
      Set_To_ID(Bld, hold,    "liststore_holds",   0);
      Set_Active(No2,       False);
      Set_Text(urges,       "0");
      Set_To_ID(Bld, spasm,   "liststore_spasms",  0);
      Set_Text(spasmcnt,    "0");
      Set_Text(notes_tb,    "");
   end Clear_Urine_Record_Fields;

   procedure Load_Urine_Record_Data(Builder:access Gtkada_Builder_Record'Class;
                                    record_no : record_movement; 
                                    refresh   : boolean := false) is
     
      use GNATCOLL.SQL.Exec;
      use String_Conversions, Calendar_Extensions;
      R_ur       : Direct_Cursor renames R_urine_records;
      total_recs : natural := Number_of_Records(Builder);
   begin  -- Load_Urine_Record_Data
      if refresh then  -- (re)run the query
         R_ur.Fetch (Connection => DB, Stmt => UR_select);
      end if;
      -- Go to the desired record
      case record_no.mvt_type is
         when absolute =>
            Absolute(R_ur, record_no.record_number);
         when relative =>
            case record_no.movement is
               when first    => First   (R_ur);
               when last     => Last    (R_ur);
               when backward => Relative(R_ur, -1);
               when forward  => Relative(R_ur, +1);
               when back10   => Relative(R_ur, -10);
               when next10   => Relative(R_ur, +10);
            end case;
      end case;
      -- Load fields from the first record (if any)
      if not Success(DB) then
         null;  -- take some action
      elsif Success(DB) and then Has_Row(R_ur) then
         -- Load up the fields with data
         declare
            rec_no   : Gtk.GEntry.gtk_entry;
            rec_cnt  : Gtk.Label.gtk_label;
            patientid: integer;
            patient  : Gtk.Combo_Box.gtk_combo_box;
            the_date : Gtk.GEntry.gtk_entry;
            the_time : Gtk.GEntry.gtk_entry;
            blad_vol : Gtk.GEntry.gtk_entry;
            pad_vol  : Gtk.GEntry.gtk_entry;
            pad_type : Gtk.Combo_Box.gtk_combo_box;
            pt_entry : Gtk.GEntry.gtk_entry;
            leakage  : Gtk.Combo_Box.gtk_combo_box;
            hold     : Gtk.Combo_Box.gtk_combo_box;
            urges    : Gtk.GEntry.gtk_entry;
            spasm    : Gtk.Combo_Box.gtk_combo_box;
            spasmcnt : Gtk.GEntry.gtk_entry;
            No2      : Gtk.Check_Button.gtk_check_button;
            notes_tb : Gtk.Text_Buffer.gtk_text_buffer;
            Bld      : Gtkada_Builder := Gtkada_Builder(Builder);
            use Gtk.GEntry, Gtk.Check_Button, Gtk.Combo_Box, Gtk.Label;
            use Gtk.Text_Buffer;
         begin
         -- Set up the fields
            declare
               use Gtkada.Builder;
            begin
               rec_no  := gtk_entry(Get_Object(Builder,"lbl_ur_record_no"));
               rec_cnt := gtk_label(Get_Object(Builder, "lbl_num_records"));
               patient := gtk_combo_box(Get_Object(Builder,
                                                "combo_ur_patient_name"));
               the_date:= gtk_entry(Get_Object(Builder,"entry_ur_date"));
               the_time:= gtk_entry(Get_Object(Builder,"entry_ur_time"));
               blad_vol:= gtk_entry(Get_Object(Builder,"entry_ur_volume"));
               pad_vol := gtk_entry(Get_Object(Builder,"entry_ur_pad_volume"));
               pad_type:=gtk_combo_box(Get_Object(Builder,"combo_ur_padtype"));
               pt_entry:= gtk_entry(Get_Object(Builder,"ce_ur_padtype"));
               leakage :=gtk_combo_box(Get_Object(Builder,"combo_ur_leakage"));
               hold    := gtk_combo_box(Get_Object(Builder,"combo_ur_hold"));
               No2     := gtk_check_button(Get_Object(Builder,"chkbtn_no2"));
               spasm   := gtk_combo_box(Get_Object(Builder,"combo_ur_spasm"));
               spasmcnt:= gtk_entry(Get_Object(Builder,"entry_ur_spasm"));
               urges   := gtk_entry(Get_Object(Builder,"entry_ur_urges"));
               notes_tb:= gtk_text_buffer(Get_Object(Builder,"tb_ur_notes"));
            end;
            Error_Log.Debug_Data(at_level => 6, 
                                 with_details => "Load_Urine_Record_Data: " &
                                                 " initialised fields.");
            -- Set the record number and the record count
            Set_Text(rec_no, Glib.UTF8_String(Integer'Image(Current(R_ur))));
            Set_Label(rec_cnt, Integer'Image(total_recs));
            -- Load up the patient details data into the fields
            patientid := Integer_Value (R_ur, 0);  -- keep for later use
            Set_To_ID(Bld, patient, "liststore_patients", patientid);
            Set_Text(the_date, To_String(from_wide => 
                                    To_String(from_time => Time(tDate_Value(R_ur, 1)),
                                              with_format => "dd/mm/yyyy")));
            Error_Log.Debug_Data(at_level => 6, 
                                 with_details => "Load_Urine_Record_Data: " &
                                                 " set up Date.");
            Set_Text(the_time, To_String(from_wide =>
                                    To_String(from_time => Time(tTime_Value(R_ur, 2)),
                                               with_format => "hh:nn:ss")));
            Error_Log.Debug_Data(at_level => 6, 
                                 with_details => "Load_Urine_Record_Data: " &
                                                 " set up Time.");
            Set_Text(blad_vol, Glib.UTF8_String(Value(R_ur, 3)));
            Set_Text(pad_vol,  Glib.UTF8_String(Value(R_ur, 4)));
            if not Is_Null(R_ur, 7) then
               Set_To_ID(Bld, pad_type, "liststore_padtypes",Integer_Value(R_ur,7));
               Error_Log.Debug_Data(at_level => 6, 
                                    with_details => "Load_Urine_Record_Data: "&
                                                    " set up pad_type.");
            else
               Set_Text(pt_entry, "");
            end if;
            Set_To_ID(Bld, leakage, "liststore_leakage",Integer_Value(R_ur,6));
            Set_To_ID(Bld, hold,    "liststore_holds",  Integer_Value(R_ur,5));
            Error_Log.Debug_Data(at_level => 6, 
                                 with_details => "Load_Urine_Record_Data: " &
                                                 " set up hold.");
            Set_Active(No2, Boolean_Value(R_ur, 8));-- set the No.2 check box
            Error_Log.Debug_Data(at_level => 6, 
                                 with_details => "Load_Urine_Record_Data: " &
                                                 " set up No2.");
            Set_Text(urges,    Glib.UTF8_String(Value(R_ur, 9)));
            Error_Log.Debug_Data(at_level => 6, 
                                 with_details => "Load_Urine_Record_Data: " &
                                                 " set up urges.");
            if Is_Null(R_ur, 10) then
               Set_To_ID(Bld, spasm,"liststore_spasms",0);
            else                                     
               Set_To_ID(Bld, spasm,"liststore_spasms",Integer_Value(R_ur,10));
            end if;
            Error_Log.Debug_Data(at_level => 6, 
                                 with_details => "Load_Urine_Record_Data: " &
                                                 " set up spasm.");
            if Is_Null(R_ur, 11) then
               Set_Text(spasmcnt, Glib.UTF8_String'("0"));
            else                                     
               Set_Text(spasmcnt, Glib.UTF8_String(Value(R_ur, 11)));
            end if;
            -- Notes is via a text buffer
            Set_Text(notes_tb, Glib.UTF8_String(Value(R_ur, 12)));
            Error_Log.Debug_Data(at_level => 6, 
                                 with_details => "Load_Urine_Record_Data: " &
                                                 " set up notes.");
         end;
         -- Grey out or activate the record movement buttons as necessary
         declare
            use Gtkada.Builder, Gtk.Tool_Button;
         begin
            Set_Sensitive(Gtk_Tool_Button(Get_Object(Builder, "tb_ur_first")), 
                          True);
            Set_Sensitive(Gtk_Tool_Button(Get_Object(Builder,
                                                     "tb_ur_previous")), True);
            Set_Sensitive(Gtk_Tool_Button(Get_Object(Builder, "tb_ur_next")),
                          True);
            Set_Sensitive(Gtk_Tool_Button(Get_Object(Builder, "tb_ur_last")),
                          True);
            if Current(R_ur) <= 1 then  -- at first record
               Set_Sensitive(Gtk_Tool_Button(Get_Object(Builder,
                                               "tb_ur_first")), False);
               Set_Sensitive(Gtk_Tool_Button(Get_Object(Builder,
                                               "tb_ur_previous")), False);
            end if;
            if Current(R_ur) >= total_recs then  -- at last record
               Set_Sensitive(Gtk_Tool_Button(Get_Object(Builder,"tb_ur_next")),
                             False);
               Set_Sensitive(Gtk_Tool_Button(Get_Object(Builder,"tb_ur_last")),
                             False);
            end if;
         end;
      else -- haven't stored any urine details yet.
         declare
            use Gtkada.Builder, Gtk.Tool_Button;
         begin
            Error_Log.Debug_Data(at_level => 6, 
                              with_details => "Load_Urine_Record_Data: " &
                                              " no urine records yet.");
            Set_Sensitive(Gtk_Tool_Button(Get_Object(Builder,"tb_ur_first")), 
                          False);
            Set_Sensitive(Gtk_Tool_Button(Get_Object(Builder,
                                                     "tb_ur_previous")),False);
            Set_Sensitive(Gtk_Tool_Button(Get_Object(Builder, "tb_ur_next")),
                          False);
            Set_Sensitive(Gtk_Tool_Button(Get_Object(Builder,"tb_ur_last")), 
                          False);
         end;
      end if;
      -- disable selectability (sensitive flag) of Store, Undo buttons
      Gtk.Tool_Button.Set_Sensitive(Gtk.Tool_Button.Gtk_Tool_Button
                   (Gtkada.Builder.Get_Object(Builder, "tb_ur_save")), False);
      Gtk.Tool_Button.Set_Sensitive(Gtk.Tool_Button.Gtk_Tool_Button
                   (Gtkada.Builder.Get_Object(Builder, "tb_ur_undo")), False);
      -- make Delete, Clear selectable (set sensitive flag)
      Gtk.Tool_Button.Set_Sensitive(Gtk.Tool_Button.Gtk_Tool_Button
                   (Gtkada.Builder.Get_Object(Builder, "tb_ur_delete")), True);
      Gtk.Tool_Button.Set_Sensitive(Gtk.Tool_Button.Gtk_Tool_Button
                   (Gtkada.Builder.Get_Object(Builder, "tb_ur_clear")), True);
      -- done
      Error_Log.Debug_Data(at_level => 5, 
                           with_details => "Load_Urine_Record_Data: Done");
   end Load_Urine_Record_Data;

   procedure Initialise_Urine_Records(Builder : in out Gtkada_Builder;
                          DB_Descr : GNATCOLL.SQL.Exec.Database_Description) is
      use GNATCOLL.SQL.Exec;
      procedure Load_Combo_Box(Q_lookup: SQL_Query; list_store_name: string;
                               fields : natural := 2) is
         R_list   : Forward_Cursor;
         store    : Gtk.List_Store.gtk_list_store;
         iter     : Gtk.Tree_Model.gtk_tree_iter;
         use Gtk.List_Store, String_Conversions;
      begin
         R_list.Fetch (Connection => DB, Query => Q_lookup);
         if Success(DB) and then Has_Row(R_list) then
            -- Set up the list store field
            store := gtk_list_store(
                          Gtkada.Builder.Get_Object(Builder, list_store_name));
            Clear(store);  -- empty the sub-table ready for the new data
            while Has_Row(R_list) loop  -- while not end_of_table
               Append(store, iter);
               -- PatientDetails (column_num): 0=Identifier, 1=Patient
               Set(store, iter, 0, Glib.Gint(Integer_Value(R_list, 0)));
               Set(store, iter, 1, Glib.UTF8_String(Value(R_list, 1)));
               if fields > 2 then
                  Set(store, iter, 2, Glib.Gint(Integer_Value(R_list, 2)));
                  Set(store, iter, 3, Glib.UTF8_String(Value(R_list, 3)));
               end if;
               Error_Log.Debug_Data(at_level => 6, 
                                    with_details=>"Initialise_Urine_Records: "&
                                              To_Wide_String(Value(R_list,1)));
               Next(R_list);  -- next_record(PatientDetails)
            end loop;
            Error_Log.Debug_Data(at_level => 5, 
                                 with_details => "Initialise_Urine_Records: " &
                                    To_Wide_String(list_store_name)&" loaded");
         end if;
      end Load_Combo_Box;
   
      Q_pd       : SQL_Query;
      Q_ptype    : SQL_Query;
      Q_leak     : SQL_Query;
      Q_hold     : SQL_Query;
      Q_spasm    : SQL_Query;
      R_pd       : Forward_Cursor;
      rec_no     : record_movement(relative);
   begin
      -- Set up: Open the relevant tables from the database
      DB:=GNATCOLL.SQL.Exec.Tasking.Get_Task_Connection(Description=>DB_Descr);
      -- Set up: load up the list of patients
      Q_pd := SQL_Select
         (Fields  => PatientDetails.Identifier & PatientDetails.Patient,
          From    => PatientDetails,
          Where   => PatientDetails.Identifier >= 0,
          Order_By=> PatientDetails.Patient);
      Load_Combo_Box(Q_lookup=> Q_pd, list_store_name => "liststore_patients");
      -- Set up: count the number of patients
      Q_pd:= SQL_Select(Fields=> Apply(Func_Count,(PatientDetails.Identifier)),
                        From  => PatientDetails,
                        Where => PatientDetails.Identifier >= 0);
      R_pd.Fetch (Connection => DB, Query => Q_pd);
      if Success(DB) and then Has_Row(R_pd) then
         number_of_patients:= Integer_Value (R_pd, 0);
      end if;
      -- Set up: load up the list of Pad Types
      Q_ptype := SQL_Select
            (Fields => PadSizes.ID & PadSizes.Brand & 
                       PadSizes.Size & PadSizes.Description,
             From    => PadSizes,
             Where   => PadSizes.ID >= 0,
             Order_By=> PadSizes.Brand);
      Load_Combo_Box(Q_lookup=> Q_ptype, 
                     list_store_name => "liststore_padtypes", fields => 4);
      -- Set up: load up the list of Leakage
      Q_leak := SQL_Select
            (Fields  => Leakage.Value & Leakage.Leakage,
             From    => Leakage,
             Where   => Leakage.Value >= 0,
             Order_By=> Leakage.Leakage);
      Load_Combo_Box(Q_lookup=> Q_leak, list_store_name =>"liststore_leakage");
      -- Set up: load up the list of Hold States
      Q_hold := SQL_Select
            (Fields  => HoldStates.ID & HoldStates.Description,
             From    => HoldStates,
             Where   => HoldStates.ID >= 0,
             Order_By=> HoldStates.Description);
      Load_Combo_Box(Q_lookup=> Q_hold, list_store_name =>"liststore_holds");
      -- Set up: load up the list of Spasm intensities
      Q_spasm := SQL_Select
            (Fields  => Spasms.Spasm & Spasms.Description,
             From    => Spasms,
             Where   => Spasms.Spasm >= 0,
             Order_By=> Spasms.Description);
      Load_Combo_Box(Q_lookup=> Q_spasm, list_store_name =>"liststore_spasms");
      -- Set up: load up the data for the first record (if any)
      Load_Urine_Record_Data(Builder => Builder, 
                             record_no => rec_no,
                             refresh => true);
      -- Register the handlers
      Register_Handler(Builder   => Builder,
                    Handler_Name => "file_new_ur_select_cb",
                    Handler      => Urine_Records_New_Selected_CB'Access);
      Register_Handler(Builder   => Builder,
                    Handler_Name => "file_undo_ur_activate_cb",
                    Handler      => Urine_Records_Undo_Selected_CB'Access);
      Register_Handler(Builder   => Builder,
                    Handler_Name => "file_save_ur_activate_cb",
                    Handler      => Urine_Records_Save_Selected_CB'Access);
      Register_Handler(Builder   => Builder,
                    Handler_Name => "file_delete_ur_activate_cb",
                    Handler      => Urine_Records_Delete_Selected_CB'Access);
      Register_Handler(Builder   => Builder,
                    Handler_Name => "file_close_ur_select_cb",
                    Handler      => Urine_Records_Close_CB'Access);
      Register_Handler(Builder   => Builder,
                    Handler_Name => "combo_ur_patient_name_changed_cb",
                    Handler      => Urine_Records_Field_Changed_CB'Access);
      Register_Handler(Builder   => Builder,
                    Handler_Name => "ur_field_changed_cb",
                    Handler      => Urine_Records_Field_Changed_CB'Access);
      Register_Handler(Builder   => Builder,
                    Handler_Name => "ur_date_changed_cb",
                    Handler      => Urine_Records_Date_Changed_CB'Access);
      Register_Handler(Builder   => Builder,
                    Handler_Name => "ur_time_changed_cb",
                    Handler      => Urine_Records_Time_Changed_CB'Access);
      Register_Handler(Builder   => Builder,
                    Handler_Name => "ur_vol_changed_cb",
                    Handler      => Urine_Records_Vol_Changed_CB'Access);
      Register_Handler(Builder   => Builder,
                    Handler_Name => "ur_padvol_changed_cb",
                    Handler      => Urine_Records_PadVol_Changed_CB'Access);
      Register_Handler(Builder   => Builder,
                    Handler_Name => "ur_spascnt_changed_cb",
                    Handler      => Urine_Records_SpasCnt_Changed_CB'Access);
      Register_Handler(Builder   => Builder,
                    Handler_Name => "ur_urges_changed_cb",
                    Handler      => Urine_Records_Urges_Changed_CB'Access);
      Register_Handler(Builder   => Builder,
                    Handler_Name => "view_ur_first_select_cb",
                    Handler      => Urine_Records_First_Clicked_CB'Access);
      Register_Handler(Builder   => Builder,
                    Handler_Name => "view_ur_prev_select_cb",
                    Handler      => Urine_Records_Previous_Clicked_CB'Access);
      Register_Handler(Builder   => Builder,
                    Handler_Name => "view_ur_prev_10_select_cb",
                    Handler      => Urine_Records_Previous_10_Clicked_CB'Access);
      Register_Handler(Builder   => Builder,
                    Handler_Name => "view_ur_next_select_cb",
                    Handler      => Urine_Records_Next_Clicked_CB'Access);
      Register_Handler(Builder   => Builder,
                    Handler_Name => "view_ur_next_10_select_cb",
                    Handler      => Urine_Records_Next_10_Clicked_CB'Access);
      Register_Handler(Builder   => Builder,
                    Handler_Name => "view_ur_last_select_cb",
                    Handler      => Urine_Records_Last_Clicked_CB'Access);
      Register_Handler(Builder   => Builder,
                    Handler_Name => "entry_ur_date_icon_press_cb",
                    Handler    => Urine_Records_Date_Button_Pressed_CB'Access);
      -- Set up the tab order
      declare
         ur_grid      : Gtk.Grid.Gtk_Grid := 
                             Gtk.Grid.Gtk_Grid(Get_Object(Builder, "grid_ur"));
         widget_chain : Gtk.Widget.Widget_List.Glist;
         use Gtk.Grid, Gtk.Widget, Gtk.Widget.Widget_List;
      begin
         -- Load the list with the tab order
         Append(widget_chain,Gtk_Widget(Get_Object(Builder,"combo_ur_patient_name")));
         Append(widget_chain,Gtk_Widget(Get_Object(Builder,"entry_ur_date")));
         Append(widget_chain,Gtk_Widget(Get_Object(Builder,"entry_ur_time")));
         Append(widget_chain,Gtk_Widget(Get_Object(Builder,"entry_ur_volume")));
         Append(widget_chain,Gtk_Widget(Get_Object(Builder,"entry_ur_pad_volume")));
         Append(widget_chain,Gtk_Widget(Get_Object(Builder,"combo_ur_padtype")));
         Append(widget_chain,Gtk_Widget(Get_Object(Builder,"combo_ur_leakage")));
         Append(widget_chain,Gtk_Widget(Get_Object(Builder,"combo_ur_hold")));
         Append(widget_chain,Gtk_Widget(Get_Object(Builder,"entry_ur_urges")));
         Append(widget_chain,Gtk_Widget(Get_Object(Builder,"chkbtn_no2")));
         Append(widget_chain,Gtk_Widget(Get_Object(Builder,"combo_ur_spasm")));
         Append(widget_chain,Gtk_Widget(Get_Object(Builder,"entry_ur_spasm")));
         Append(widget_chain,Gtk_Widget(Get_Object(Builder,"entry_ur_notes")));
         -- And set the list as the tab order
         Set_Focus_Chain(ur_grid, widget_chain);
      end;
   
   end Initialise_Urine_Records;

   procedure Show_Urine_Records(Builder : in Gtkada_Builder) is
   begin
      Gtk.Widget.Show_All(Gtk.Widget.Gtk_Widget 
                 (Gtkada.Builder.Get_Object(Builder,"form_urine_records")));
   end Show_Urine_Records;

   procedure Urine_Records_New_Selected_CB 
                (Object : access Gtkada_Builder_Record'Class) is
      use Gtkada.Builder, Gtk.Tool_Button, Gtk.Combo_Box;
      combo_patient : Gtk.Combo_Box.gtk_combo_box;
      can_focus     : boolean;
   begin
      -- Clear all fields
      Clear_Urine_Record_Fields(Gtkada_Builder(Object));
      -- Set the focus to the Patient drop-down list
      combo_patient := gtk_combo_box(Get_Object(Gtkada_Builder(Object), 
                                                "combo_ur_patient_name"));
      can_focus := Get_Can_Focus(combo_patient);
      Set_Can_Focus(combo_patient, true);
      Grab_Focus(combo_patient);
      Set_Can_Focus(combo_patient, can_focus);
      -- default patient if there is only one
      if number_of_patients = 1 then
         Set_Active(combo_patient, Glib.Gint(0));  -- zero based index
      end if;
      -- disable selectability (sensitive flag) of Store, Delete buttons
      Set_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object),
                                               "tb_ur_save")), False);
      Set_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object),
                                               "tb_ur_delete")), False);
      -- make Undo, Clear selectable (set sensitive flag)
      Set_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object),
                                               "tb_ur_undo")), True);
      Set_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object),
                                               "tb_ur_clear")), True);
      -- done
      Error_Log.Debug_Data(at_level => 5, 
                       with_details => "Urine_Records_New_Selected_CB: Done");
   end Urine_Records_New_Selected_CB;

   procedure Urine_Records_Undo_Selected_CB 
                (Object : access Gtkada_Builder_Record'Class) is
      use Gtkada.Builder, Gtk.Tool_Button, Gtk.GEntry;
      current_record : record_movement(absolute);
      rec_no         : Gtk.GEntry.gtk_entry;
   begin
      -- Get previous/current record number
      rec_no:=gtk_entry(Get_Object(Gtkada_Builder(Object),"lbl_ur_record_no"));
      current_record.record_number := Integer'Value(Get_Text(rec_no));
      -- check if Delete is greyed out (not sensitive).  If so then New
      if Get_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object),
                                               "tb_ur_delete")))
      then  -- Not a new entry - reset back to original
         Load_Urine_Record_Data(Builder   => Gtkada_Builder(Object),
                                record_no => current_record);
      else  -- New record - undo the new and go back to last record
         Load_Urine_Record_Data(Builder   => Gtkada_Builder(Object),
                                record_no => current_record);
      end if;
      -- done
      Error_Log.Debug_Data(at_level => 5, 
                       with_details => "Urine_Records_Undo_Selected_CB: Done");
   end Urine_Records_Undo_Selected_CB;

   procedure Urine_Records_Save_Selected_CB 
                (Object : access Gtkada_Builder_Record'Class) is
      use Gtkada.Builder, Gtk.Tool_Button;
      use GNATCOLL.SQL.Exec;
      function Get_Combo_ID(Builder : access Gtkada_Builder_Record'Class;
                            combo, 
                            liststore : Glib.UTF8_String) return integer is
         use Gtk.Combo_Box, Gtk.Tree_Selection, Gtk.List_Store, Glib, String_Conversions;
         iter     : Gtk.Tree_Model.gtk_tree_iter;
         store    : Gtk.List_Store.gtk_list_store;
         col_data : Glib.Values.GValue;
      begin
         store := gtk_list_store(Get_Object(Builder, liststore));
         if Get_Active(Gtk_Combo_Box_Record( 
                                  (Get_Object(Builder,combo).all))'Access) >= 0
         then
            iter  := Get_Active_Iter(Gtk_Combo_Box_Record( 
                                      (Get_Object(Builder,combo).all))'Access);
            Get_Value(store, iter, 0, col_data);
            return Integer(Glib.Values.Get_Int(col_data));
         else
            return -1;
         end if;
      end Get_Combo_ID;
      
      function Get_Check_Box(Builder  : access Gtkada_Builder_record'Class;
                             checkbox : Glib.UTF8_String) return boolean is
         use Gtk.Check_Button;
         chkbox : Gtk.Check_Button.gtk_check_button;
      begin
         chkbox := Gtk.Check_Button.gtk_check_button
                                (Gtkada.Builder.Get_Object(Builder, checkbox));
         return Get_Active(chkbox);
      end Get_Check_Box;
      
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
      
      function Get_Entry_Text(Builder : access Gtkada_Builder_Record'Class;
                            the_entry : Glib.UTF8_String) return string is
         use Gtk.GEntry, String_Conversions;
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
      
      function Get_Entry_Time(Builder : access Gtkada_Builder_Record'Class;
                              the_entry : Glib.UTF8_String) return tTime is
         use Calendar_Extensions, String_Conversions;
      begin  -- allows a format of hh:nn:ss or hh:nn
         if Get_Entry_Text(Builder, the_entry)'Length > 5 then -- with seconds
            return tTime(To_Time(from_string => 
                            To_Wide_String(Get_Entry_Text(Builder, the_entry)),
                                 with_format => "hh:nn:ss"));
         else -- without seconds
            return tTime(To_Time(from_string => 
                            To_Wide_String(Get_Entry_Text(Builder, the_entry)),
                                 with_format => "hh:nn"));
         end if;
      end Get_Entry_Time;
      
      current_record : record_movement(absolute);
      P_ur     : SQL_Parameters (1 .. 13);
      pad_type : integer := Get_Combo_ID(Object, "combo_ur_padtype",
                                          "liststore_padtypes");
      pt_param : SQL_Parameter;
   begin
      Error_Log.Debug_Data(at_level => 5, 
                       with_details => "Urine_Records_Save_Selected_CB: Start");
      -- Check we have a valid set of key fields
      if Get_Combo_ID(Object,"combo_ur_patient_name","liststore_patients")<=0
         or Get_Entry_Text(Object, "entry_ur_date")'Length = 0
         or Get_Entry_Text(Object, "entry_ur_time")'Length = 0
      then
         Error_Log.Debug_Data(at_level    =>6, 
                              with_details=>"Urine_Records_Save_Selected_CB: "&
                                            "missing key field");
         Error_Dialogue.Show_Error
             (Builder=>Gtkada_Builder(Object),
              message=>"One of either patient name, date or time is not set.");
         return;
      end if;
      -- Get the current record number
      current_record.record_number := Current(R_urine_records);
      -- Pad type is special because it can be null
      if pad_type < 0 then
         pt_param := Null_Parameter;
      else
         pt_param := +pad_type;
      end if;
      -- Get all the field values and load into the parameter list
      P_ur := (1 => +Get_Combo_ID(Object, "combo_ur_patient_name", 
                                          "liststore_patients"),     -- Patient
               2 => +Get_Entry_Date(Object, "entry_ur_date"),        -- UDate
               3 => +Get_Entry_Time(Object, "entry_ur_time"),        -- UTime
               4 => +Get_Entry_Number(Object, "entry_ur_volume"),    -- Volume
               5 => +Get_Entry_Number(Object, "entry_ur_pad_volume"),-- PadVol
               6 => +Get_Combo_ID(Object, "combo_ur_hold", 
                                          "liststore_holds"),        -- Hold
               7 => +Get_Combo_ID(Object, "combo_ur_leakage",
                                          "liststore_leakage"),      -- Leakage
               8 => pt_param,                                        -- PadType
               9 => +Get_Check_Box(Object, "chkbtn_no2"),            -- No2
               10=> +Get_Entry_Number(Object, "entry_ur_urges"),     -- Urges
               11=> +Get_Combo_ID(Object, "combo_ur_spasm",
                                          "liststore_spasms"),       -- Spasm
               12=> +Get_Entry_Number(Object, "entry_ur_spasm"),     -- SpasCnt
               13=> +Get_Text_View(Object, "tb_ur_notes"));          -- Notes
      -- check if Delete is greyed out (not sensitive).  If so then New
      if Get_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object),
                                               "tb_ur_delete")))
      then  -- Not a new entry - Update existing record
         -- build out the parameter list to include the current record's
         -- key fields
         declare
            p_ur_cond   : SQL_Parameters (1 .. 3) :=
                                     (1 => +Integer_Value(R_urine_records, 0),
                                      2 => +tDate_Value(R_urine_records, 1),
                                      3 => +tTime_Value(R_urine_records, 2));
            p_ur_update : SQL_Parameters (1 .. 16) := (P_ur & p_ur_cond);
         begin
            -- execute the update query
            Execute (Connection => DB, Stmt => UR_update, Params => P_ur_update);
            Commit_Or_Rollback (DB);
         end;
      else  -- New record - insert record
         -- First, insert the record
         Execute (Connection => DB, Stmt => UR_insert, Params => P_ur);
         Commit_Or_Rollback (DB);
         if Success(DB) then -- committed, not rolled back
            -- update the record count and go to the current record + 1
            current_record.record_number := current_record.record_number + 1;
         end if;
      end if;
      Error_Log.Debug_Data(at_level => 6, 
                       with_details => "Urine_Records_Save_Selected_CB: Saved");
      -- Finally, for insert or update, refresh the local list of records
      if Success(DB) then -- i.e. committed, not rolled back
         Load_Urine_Record_Data(Builder      => Gtkada_Builder(Object),
                                   record_no => current_record,
                                   refresh   => true);
      else -- some trouble saving
         Error_Dialogue.Show_Error
             (Builder => Gtkada_Builder(Object),
              message => "A database issue encountered saving the record.");
      end if;
      -- disable selectability (sensitive flag) of Store, Undo buttons
      Set_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object),
                                               "tb_ur_save")), False);
      Set_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object),
                                               "tb_ur_undo")), False);
      -- make Delete, Clear selectable (set sensitive flag)
      Set_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object),
                                               "tb_ur_delete")), True);
      Set_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object),
                                               "tb_ur_clear")), True);
      -- done
      Error_Log.Debug_Data(at_level => 5, 
                       with_details => "Urine_Records_Save_Selected_CB: Done");
   end Urine_Records_Save_Selected_CB;

   procedure Urine_Records_Delete_Selected_CB 
                (Object : access Gtkada_Builder_Record'Class) is
     -- Check that the user is sure (if so, the Urine_Records_Delete_Record
     -- is called).
      use Check_For_Deletion;
   begin
      Show_Are_You_Sure(Builder    => Gtkada_Builder(Object),
                        At_Handler => Urine_Records_Delete_Record'Access);
   end Urine_Records_Delete_Selected_CB;
   
   procedure Urine_Records_Delete_Record 
                (Object : access Gtkada_Builder_Record'Class) is
      use GNATCOLL.SQL.Exec;
      use Calendar_Extensions;
      use Gtkada.Builder;
      current_record : record_movement(absolute);
      patient_id     : natural;
      the_date       : tDate;
      the_time       : tTime;
   begin
      -- Get the current record
      current_record.record_number := Current(R_urine_records);
      patient_id := Integer_Value (R_urine_records, 0);
      the_date   := tDate_Value(R_urine_records, 1);
      the_time   := tTime_Value(R_urine_records, 2);
      -- Delete the current record
      declare
         -- use String_Conversions;
         P_ur : SQL_Parameters (1 .. 3) :=
                               (1 => +patient_id,
                                2 => +the_date,
                                3 => +the_time);
      begin
         Execute (Connection => DB, Stmt => UR_delete, Params => P_ur);
      end;
      --  Commit if both insertion succeeded, rollback otherwise
      Commit_Or_Rollback (DB);
      if Success(DB) then
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
      Load_Urine_Record_Data(Builder   => Gtkada_Builder(Object),
                             record_no => current_record,
                             refresh   => true);
      -- done
      Error_Log.Debug_Data(at_level => 5, 
                     with_details => "Urine_Records_Delete_Record: Done");
   end Urine_Records_Delete_Record;

   procedure Urine_Records_Close_CB 
             (Object : access Gtkada_Builder_Record'Class) is
   begin
      Error_Log.Debug_Data(at_level => 5, 
                        with_details => "Urine_Records_Close_CB: Start");
      Gtk.Widget.Hide(Gtk.Widget.Gtk_Widget 
                     (Gtkada.Builder.Get_Object(Gtkada_Builder(Object),
                      "form_urine_records")));
   end Urine_Records_Close_CB;

   procedure Urine_Records_Field_Changed_CB
             (Object : access Gtkada_Builder_Record'Class) is
             -- (Object : access Gtkada_Builder_Record'Class) is
      use Gtkada.Builder, Gtk.Tool_Button;
   begin
      Error_Log.Debug_Data(at_level => 5, 
            with_details => "Urine_Records_Field_Changed_CB: Start");
      -- enable selectability (sensitive flag) of Store, Undo buttons
      Set_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object),
                                               "tb_ur_save")), True);
      Set_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object), 
                                               "tb_ur_undo")), True);      
   end Urine_Records_Field_Changed_CB;
   
   procedure Urine_Records_Date_Changed_CB
             (Object : access Gtkada_Builder_Record'Class) is
     -- Allowed characters are '0'..'9', '/'
      use Gtkada.Builder, Gtk.Tool_Button, Gtk.GEntry;
      keyed_data : string := Get_Text(Gtk_Entry_Record
             (Get_Object(Gtkada_Builder(Object), "entry_ur_date").all)'Access);
      str_len   : natural := keyed_data'Length;
      last_char : character;
   begin
      Error_Log.Debug_Data(at_level => 5, 
            with_details => "Urine_Records_Date_Changed_CB: Start");
      if str_len > 0 then
         last_char := keyed_data(keyed_data'Last);
         case last_char is
            when '0'..'9' => null;  -- valid data
            when '/'      => null;  -- valid data
            when others =>
               str_len := str_len - 1;
         end case;
         Set_Text(Gtk_Entry_Record(Get_Object(Gtkada_Builder(Object), 
                                              "entry_ur_date").all)'Access,
                  keyed_data(keyed_data'First .. str_len));
      end if;   
      -- enable selectability (sensitive flag) of Store, Undo buttons
      Set_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object),
                                               "tb_ur_save")), True);
      Set_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object), 
                                               "tb_ur_undo")), True);      
   end Urine_Records_Date_Changed_CB;
   
   procedure Urine_Records_Time_Changed_CB
             (Object : access Gtkada_Builder_Record'Class) is
     -- Allowed characters are '0'..'9', ':', '.'
     -- If '.' entered, then substitute for ':'
      use Gtkada.Builder, Gtk.Tool_Button, Gtk.GEntry;
      keyed_data : string := Get_Text(Gtk_Entry_Record
             (Get_Object(Gtkada_Builder(Object), "entry_ur_time").all)'Access);
      str_len   : natural := keyed_data'Length;
      last_char : character;
   begin
      Error_Log.Debug_Data(at_level => 5, 
            with_details => "Urine_Records_Time_Changed_CB: Start");
      if str_len > 0 then
         last_char := keyed_data(keyed_data'Last);
         case last_char is
            when '0'..'9' => null;  -- valid data
            when ':'      => null;  -- valid data
            when '.'      => keyed_data(str_len) := ':';
            when others =>
               str_len := str_len - 1;
         end case;
         Set_Text(Gtk_Entry_Record(Get_Object(Gtkada_Builder(Object), 
                                              "entry_ur_time").all)'Access,
                  keyed_data(keyed_data'First .. str_len));
      end if;   
      -- enable selectability (sensitive flag) of Store, Undo buttons
      Set_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object),
                                               "tb_ur_save")), True);
      Set_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object), 
                                               "tb_ur_undo")), True);      
   end Urine_Records_Time_Changed_CB;
   
   procedure Urine_Records_Number_Changed_CB
             (Object : access Gtkada_Builder_Record'Class;
              entry_name : string) is
     -- Allowed characters are '0'..'9', '.'
      use Gtkada.Builder, Gtk.Tool_Button, Gtk.GEntry;
      -- the_entry  : Gtk_Entry := Gtk_Entry(Gtkada_Builder(Object));
      keyed_data : string := Get_Text(Gtk_Entry_Record
             (Get_Object(Gtkada_Builder(Object), entry_name).all)'Access);--FIX ME--
      str_len   : natural := keyed_data'Length;
      last_char : character;
   begin
      Error_Log.Debug_Data(at_level => 5, 
            with_details => "Urine_Records_Number_Changed_CB: Start");
      if str_len > 0 then
         last_char := keyed_data(keyed_data'Last);
         case last_char is
            when '0'..'9' => null;  -- valid data
            when '.'      => null;  -- valid data
            when others =>
               str_len := str_len - 1;
         end case;
         Set_Text(Gtk_Entry_Record(Get_Object(Gtkada_Builder(Object), 
                                              entry_name).all)'Access,--FIX ME--
                  keyed_data(keyed_data'First .. str_len));
      end if;   
      -- enable selectability (sensitive flag) of Store, Undo buttons
      Set_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object),
                                               "tb_ur_save")), True);
      Set_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object), 
                                               "tb_ur_undo")), True);      
   end Urine_Records_Number_Changed_CB;
   
   procedure Urine_Records_Vol_Changed_CB
                (Object : access Gtkada_Builder_Record'Class) is
   begin
      Urine_Records_Number_Changed_CB(Object, "entry_ur_volume");
   end Urine_Records_Vol_Changed_CB;
   
   procedure Urine_Records_PadVol_Changed_CB
                (Object : access Gtkada_Builder_Record'Class) is
   begin
      Urine_Records_Number_Changed_CB(Object, "entry_ur_pad_volume");
   end Urine_Records_PadVol_Changed_CB;
                
   procedure Urine_Records_SpasCnt_Changed_CB
                (Object : access Gtkada_Builder_Record'Class) is
   begin
      Urine_Records_Number_Changed_CB(Object, "entry_ur_spasm");
   end Urine_Records_SpasCnt_Changed_CB;
                
   procedure Urine_Records_Urges_Changed_CB
                (Object : access Gtkada_Builder_Record'Class) is
   begin
      Urine_Records_Number_Changed_CB(Object, "entry_ur_urges");
   end Urine_Records_Urges_Changed_CB;
   
   -- procedure Urine_Records_Pad_Type_Changed_CB
   --              (Object : access Gtkada_Builder_Record'Class) is
   --           -- (Object : access Gtkada_Builder_Record'Class) is
      -- use Gtkada.Builder, Gtk.Tool_Button;
      -- use Gtk.GEntry;
      -- use Gtk.Combo_Box, Gtk.Tree_Selection, Gtk.List_Store;
      -- use dStrings;
      -- iter     : Gtk.Tree_Model.gtk_tree_iter;
      -- store    : Gtk.List_Store.gtk_list_store;
      -- col_data : Glib.Values.GValue;
      -- combo_padtype : Gtk.GEntry.gtk_entry;
   -- begin
      -- Error_Log.Debug_Data(at_level => 5, 
         --    with_details => "Urine_Records_Pad_Type_Changed_CB: Start");
      -- combo_padtype := gtk_entry(Get_Object(Gtkada_Builder(Object),
         --                                    "ce_ur_padtype"));
      -- store := gtk_list_store(
         --              Get_Object(Gtkada_Builder(Object),"liststore_padtypes"));
      -- iter  := Get_Active_Iter(Gtk_Combo_Box_Record( 
         --                         Get_Object(Gtkada_Builder(Object),
         --                                    "combo_ur_padtype").all)'Access);
      -- Get_Value(store, iter, 0, col_data);
      -- Error_Log.Debug_Data(at_level => 6, 
         -- with_details => "Urine_Records_Pad_Type_Changed_CB: Selected "&
         --                  String_Conversions.To_Wide_String(
         --                     Get_Text(gtk_entry(combo_padtype))) & " - ID "&
         --                  String_Conversions.To_Wide_String(Glib.Gint'Image(
         --                                      Glib.Values.Get_Int(col_data))));
   --    -- enable selectability (sensitive flag) of Store, Undo buttons
      -- Set_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object),
         --                                       "tb_ur_save")), True);
      -- Set_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object), 
         --                                       "tb_ur_undo")), True);      
   -- 
   -- end Urine_Records_Pad_Type_Changed_CB;
   
   procedure Urine_Records_No2_Changed_CB
             (Object : access Gtkada_Builder_Record'Class) is
      use Gtkada.Builder, Gtk.Tool_Button;
      use Gtk.Check_Button;
      cb_no2 : Gtk.Check_Button.gtk_check_button;
      checked: boolean;
   begin
      Error_Log.Debug_Data(at_level => 5, 
            with_details => "Urine_Records_No2_Changed_CB: Start");
      cb_no2 := Gtk.Check_Button.gtk_check_button
                          (Gtkada.Builder.Get_Object(Gtkada_Builder(Object),
                                                     "chkbtn_no2"));
      checked := Get_Active(cb_no2);
      -- enable selectability (sensitive flag) of Store, Undo buttons
      Set_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object),
                                               "tb_ur_save")), True);
      Set_Sensitive(Gtk_Tool_Button(Get_Object(Gtkada_Builder(Object), 
                                               "tb_ur_undo")), True);      
   end Urine_Records_No2_Changed_CB;

   procedure Urine_Records_First_Clicked_CB
                (Object : access Gtkada_Builder_Record'Class) is
      direction : record_movement(relative) := (relative, first);
   begin
      Load_Urine_Record_Data(Builder => Gtkada_Builder(Object),
                             record_no => direction);
   end Urine_Records_First_Clicked_CB;

   procedure Urine_Records_Previous_10_Clicked_CB
                (Object : access Gtkada_Builder_Record'Class) is
      direction : record_movement(relative) := (relative, back10);
   begin
      Load_Urine_Record_Data(Builder => Gtkada_Builder(Object),
                             record_no => direction);
   end Urine_Records_Previous_10_Clicked_CB;
 
   procedure Urine_Records_Previous_Clicked_CB
                (Object : access Gtkada_Builder_Record'Class) is
      direction : record_movement(relative) := (relative, backward);
   begin
      Load_Urine_Record_Data(Builder => Gtkada_Builder(Object),
                             record_no => direction);
   end Urine_Records_Previous_Clicked_CB;

   procedure Urine_Records_Next_Clicked_CB
                (Object : access Gtkada_Builder_Record'Class) is
      direction : record_movement(relative) := (relative, forward);
   begin
      Load_Urine_Record_Data(Builder => Gtkada_Builder(Object),
                             record_no => direction);
   end Urine_Records_Next_Clicked_CB;
   
   procedure Urine_Records_Next_10_Clicked_CB
                (Object : access Gtkada_Builder_Record'Class) is
      direction : record_movement(relative) := (relative, next10);
   begin
      Load_Urine_Record_Data(Builder => Gtkada_Builder(Object),
                             record_no => direction);
   end Urine_Records_Next_10_Clicked_CB;

   procedure Urine_Records_Last_Clicked_CB
                (Object : access Gtkada_Builder_Record'Class) is
      direction : record_movement(relative) := (relative, last);
   begin
      Load_Urine_Record_Data(Builder => Gtkada_Builder(Object),
                             record_no => direction);
   end Urine_Records_Last_Clicked_CB;

   procedure Urine_Records_Date_Button_Pressed_CB
                (Object : access Gtkada_Builder_Record'Class) is
      use Gtkada.Builder, Gtk.GEntry, Get_Date_Calendar;
      date_entry : Gtk_GEntry := Gtk_GEntry(Get_Object(Gtkada_Builder(Object),
                                                       "entry_ur_date"));
   begin
      Error_Log.Debug_Data(at_level => 5, 
            with_details => "Urine_Records_Date_Button_Pressed_CB: Start");
      -- Pop up the date calendar, act upon it
      Get_Date_Calendar.Show_Calendar(Builder  => Gtkada_Builder(Object),
                                      At_Field => date_entry);
   end Urine_Records_Date_Button_Pressed_CB;

   procedure Finalise is
   begin
      GNATCOLL.SQL.Exec.Free (DB);
   end Finalise;

begin
   Urine_Record_Version.Register(revision => "$Revision: v1.0.0$",
                              for_module => "Urine_Records_Form");
end Urine_Records_Form;
