-----------------------------------------------------------------------
--                                                                   --
--             U R I N E   C O L O U R   S E L E C T O R             --
--                                                                   --
--                              B o d y                              --
--                                                                   --
--                           $Revision: 1.0 $                        --
--                                                                   --
--  Copyright (C) 2020  Hyper Quantum Pty Ltd.                       --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This package displays the urine colour selection dialogue  box,  --
--  which  is used to pick a colour off a chart.  It  is  typically  --
--  called by double-clicking on the urine colour combo-box field.   --
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
-- with Gtkada.Builder;      use Gtkada.Builder;
-- with Gtk.Combo_Box;
-- with GNATCOLL.SQL.Exec;
with Glib, Glib.Values, Gtk.Widget;
with Gtk.Tree_Selection, Gtk.Tree_Model, Gtk.List_Store;
with Gtk.Button, Gtk.Enums, Gtk.Image;
with Error_Log;
with Urine_Record_Version;
with String_Conversions;
with GNATCOLL.SQL.Exec.Tasking;
with GNATCOLL.SQL_BLOB;
with GNATCOLL.SQL;               use GNATCOLL.SQL;
with Database;                   use Database;
with dStrings;
with Ada.Sequential_IO;
package body Urine_Colour_Selector is

   -- type wavelength is new natural;  -- in nano metres
   -- subtype visible_spectrum is wavelength range 390 .. 750; -- nm
   -- number_of_blocks : positive := 16;
   -- colour_blocks : array(1..number_of_blocks) of visible_spectrum;

   the_entry        : Gtk.Combo_Box.Gtk_Combo_Box;
   selected_colour  : wavelength := 0;  -- colour wavelength selected
   the_builder      : Gtkada_Builder;

   procedure Initialise_Colour_Selector(Builder : in out Gtkada_Builder;
                             DB_Descr : GNATCOLL.SQL.Exec.Database_Description;
                             path_to_temp : string := "/tmp/") is
      use GNATCOLL.SQL.Exec, GNATCOLL.SQL_BLOB, dStrings;
      package Byte_IO is new Ada.Sequential_IO(byte);
      use Byte_IO;
      DB       : GNATCOLL.SQL.Exec.Database_Connection;
      Q_colour : SQL_Query;
      Q_string : text;
      R_colour : Forward_Cursor;
      colour_id: positive := 1;
   begin
      -- Set up the colour array
      DB:=GNATCOLL.SQL.Exec.Tasking.Get_Task_Connection(Description=>DB_Descr);
      Q_colour := SQL_Select
         (Fields  => ColourChart.Value & ColourChart.Colour & ColourChart.Image,
          From    => ColourChart,
          Where   => ColourChart.Value > 0,
          Order_By=> ColourChart.Value);
      R_colour.Fetch (Connection => DB, Query => Q_colour);
      if Success(DB) and then Has_Row(R_colour) then
         while Has_Row(R_colour) loop  -- while not end_of_table
            -- get the colour for the array number, colour_id
            colour_blocks(colour_id) := 
                             wavelength(Glib.Gint(Integer_Value(R_colour, 0)));
            -- write out the image into the temporary directory
            declare
               use string_conversions, Gtk.Image;
               output_file : file_type;
               the_image   : blob := Blob_Value(R_colour, 2);
               file_name   : constant string := path_to_temp &
                             Value(of_string=>Put_Into_String(item=>colour_id))
                             & ".png";
               image_name  : constant string := "image_" & 
                             Value(of_string=>Put_Into_String(item=>colour_id));
               image_widget: Gtk.Image.gtk_image;
            begin
               if Length(the_image) > 0 then
                  -- output the image file.
                  Create(output_file, Out_File, file_name);
                  for byte_number in 1 .. Length(the_image) loop
                     Write(output_file, Element(the_image, byte_number));
                  end loop;
                  Close(output_file);
                  -- set the image widget to point to it
                  image_widget := gtk_image(Get_Object(Builder, image_name));
                  Set(image => image_widget, Filename=> file_name);
               end if;
               exception
                  when Status_Error => null;  -- file already exists
            end;
            Next(R_colour);  -- next record(ColourChart)
            colour_id := colour_id + 1;
         end loop;
      end if;
      -- Register the handlers
      Register_Handler(Builder      => Builder,
                       Handler_Name => "btn_sel_colour_okay_clicked_cb",
                       Handler      => Colour_Selector_Okay_CB'Access);
      Register_Handler(Builder      => Builder,
                       Handler_Name => "btn_sel_colour_cancel_clicked_cb",
                       Handler      => Colour_Selector_Cancel_CB'Access);
      Register_Handler(Builder      => Builder,
                       Handler_Name => "image_1_clicked_cb",
                       Handler      => Colour_Selected_1_CB'Access);
      Register_Handler(Builder      => Builder,
                       Handler_Name => "image_2_clicked_cb",
                       Handler      => Colour_Selected_2_CB'Access);
      Register_Handler(Builder      => Builder,
                       Handler_Name => "image_3_clicked_cb",
                       Handler      => Colour_Selected_3_CB'Access);
      Register_Handler(Builder      => Builder,
                       Handler_Name => "image_4_clicked_cb",
                       Handler      => Colour_Selected_4_CB'Access);
      Register_Handler(Builder      => Builder,
                       Handler_Name => "image_5_clicked_cb",
                       Handler      => Colour_Selected_5_CB'Access);
      Register_Handler(Builder      => Builder,
                       Handler_Name => "image_6_clicked_cb",
                       Handler      => Colour_Selected_6_CB'Access);
      Register_Handler(Builder      => Builder,
                       Handler_Name => "image_7_clicked_cb",
                       Handler      => Colour_Selected_7_CB'Access);
      Register_Handler(Builder      => Builder,
                       Handler_Name => "image_8_clicked_cb",
                       Handler      => Colour_Selected_8_CB'Access);
      Register_Handler(Builder      => Builder,
                       Handler_Name => "image_9_clicked_cb",
                       Handler      => Colour_Selected_9_CB'Access);
      Register_Handler(Builder      => Builder,
                       Handler_Name => "image_10_clicked_cb",
                       Handler      => Colour_Selected_10_CB'Access);
      Register_Handler(Builder      => Builder,
                       Handler_Name => "image_11_clicked_cb",
                       Handler      => Colour_Selected_11_CB'Access);
      Register_Handler(Builder      => Builder,
                       Handler_Name => "image_12_clicked_cb",
                       Handler      => Colour_Selected_12_CB'Access);
      Register_Handler(Builder      => Builder,
                       Handler_Name => "image_13_clicked_cb",
                       Handler      => Colour_Selected_13_CB'Access);
      Register_Handler(Builder      => Builder,
                       Handler_Name => "image_14_clicked_cb",
                       Handler      => Colour_Selected_14_CB'Access);
      Register_Handler(Builder      => Builder,
                       Handler_Name => "image_15_clicked_cb",
                       Handler      => Colour_Selected_15_CB'Access);
      Register_Handler(Builder      => Builder,
                       Handler_Name => "image_16_clicked_cb",
                       Handler      => Colour_Selected_16_CB'Access);
   end Initialise_Colour_Selector;
   
   procedure Show_Colour_Selector(Builder : in Gtkada_Builder;
                                  At_Field: in out Gtk.Combo_Box.Gtk_Combo_Box)
   is
   begin
      Gtk.Widget.Show_All(Gtk.Widget.Gtk_Widget 
                            (Gtkada.Builder.Get_Object(Builder,
                                             "dialogue_select_urine_colour")));
      the_builder := Builder;
      the_entry   := At_Field;
   end Show_Colour_Selector;

   procedure Set_To_ID(combo      : Gtk.Combo_Box.gtk_combo_box;
                       list_store : string; id : wavelength) is
      -- Sets the Combo box to the specified identifier based on what
      -- that identifier is in the list store.
      use Gtk.Combo_Box, Gtk.Tree_Selection, Gtk.List_Store;
      iter     : Gtk.Tree_Model.gtk_tree_iter;
      store    : Gtk.List_Store.gtk_list_store;
      col_data : Glib.Values.GValue;
      rec_no   : natural := 0;
   begin
      store := gtk_list_store(Get_Object(the_builder, list_store));
      iter := Get_Iter_First(store);
      Get_Value(Tree_Model => store, Iter => iter, 
                   Column => 0, Value => col_data);
      while wavelength(Glib.Values.Get_Int(col_data)) /= id loop
         Next(store, iter);
         Get_Value(Tree_Model => store, Iter => iter, 
                      Column => 0, Value => col_data);
         rec_no := rec_no + 1;
      end loop;
      Set_Active(combo, Glib.Gint(rec_no));
   end Set_To_ID;
   
   procedure Colour_Selector_Okay_CB 
                (Object : access Gtkada_Builder_Record'Class) is
      use Glib;
      use Gtk.Combo_Box;
      use String_Conversions;
   begin
      Error_Log.Debug_Data(at_level => 5, 
                           with_details=>"Colour_Selector_Okay_CB: Start");
      -- return the selected colour
      if selected_colour in visible_spectrum'Range then
         Set_To_ID(the_entry, "liststore_cur_colour", selected_colour);
      end if;
      -- and close the dialogue box
      Gtk.Widget.Hide(Gtk.Widget.Gtk_Widget 
                        (Gtkada.Builder.Get_Object(Gtkada_Builder(Object),
                                             "dialogue_select_urine_colour")));
   end Colour_Selector_Okay_CB;
    
   procedure Colour_Selector_Cancel_CB 
                (Object : access Gtkada_Builder_Record'Class) is
   begin
      Error_Log.Debug_Data(at_level => 5, 
                           with_details=>"Colour_Selector_Cancel_CB: Start");
      -- Just close the dialogue box
      Gtk.Widget.Hide(Gtk.Widget.Gtk_Widget 
                        (Gtkada.Builder.Get_Object(Gtkada_Builder(Object),
                                             "dialogue_select_urine_colour")));
   end Colour_Selector_Cancel_CB;
    
   procedure Set_Button_Reliefs(Object : access Gtkada_Builder_Record'Class;
                                at_button : in natural) is
      use dStrings, Gtk.Button, GtkAda.Builder;
      the_button : Gtk.Button.Gtk_Button;
   begin
      -- First, clear all the reliefs
      for button_num in 1 .. 16 loop
         the_button := gtk_button(Get_Object(Object, "button_" & 
                         Value(of_string=>Put_Into_String(item=>button_num))));
         Set_Relief(the_button, Gtk.Enums.Relief_None);
      end loop;
      -- Then Set the relief of the desired button
      the_button := gtk_button(Get_Object(Object, "button_" & 
                         Value(of_string=>Put_Into_String(item=>at_button))));
      Set_Relief(the_button, Gtk.Enums.Relief_Normal);
   end Set_Button_Reliefs;
    
   procedure Colour_Selected_1_CB(Object : access Gtkada_Builder_Record'Class)
   is
   begin
      Error_Log.Debug_Data(at_level => 5, 
                           with_details=>"Colour_Selected_1_CB: Start");
      selected_colour := colour_blocks(1);
      Set_Button_Reliefs(Object, 1);
   end Colour_Selected_1_CB;
    
   procedure Colour_Selected_2_CB(Object : access Gtkada_Builder_Record'Class)
   is
   begin
      Error_Log.Debug_Data(at_level => 5, 
                           with_details=>"Colour_Selected_2_CB: Start");
      selected_colour := colour_blocks(2);
      Set_Button_Reliefs(Object, 2);
   end Colour_Selected_2_CB;
    
   procedure Colour_Selected_3_CB(Object : access Gtkada_Builder_Record'Class)
   is
   begin
      Error_Log.Debug_Data(at_level => 5, 
                           with_details=>"Colour_Selected_3_CB: Start");
      selected_colour := colour_blocks(3);
      Set_Button_Reliefs(Object, 3);
   end Colour_Selected_3_CB;
    
   procedure Colour_Selected_4_CB(Object : access Gtkada_Builder_Record'Class)
   is
   begin
      Error_Log.Debug_Data(at_level => 5, 
                           with_details=>"Colour_Selected_4_CB: Start");
      selected_colour := colour_blocks(4);
      Set_Button_Reliefs(Object, 4);
   end Colour_Selected_4_CB;
    
   procedure Colour_Selected_5_CB(Object : access Gtkada_Builder_Record'Class)
   is
   begin
      Error_Log.Debug_Data(at_level => 5, 
                           with_details=>"Colour_Selected_5_CB: Start");
      selected_colour := colour_blocks(5);
      Set_Button_Reliefs(Object, 5);
   end Colour_Selected_5_CB;
    
   procedure Colour_Selected_6_CB(Object : access Gtkada_Builder_Record'Class)
   is
   begin
      Error_Log.Debug_Data(at_level => 5, 
                           with_details=>"Colour_Selected_6_CB: Start");
      selected_colour := colour_blocks(6);
      Set_Button_Reliefs(Object, 6);
   end Colour_Selected_6_CB;
    
   procedure Colour_Selected_7_CB(Object : access Gtkada_Builder_Record'Class)
   is
   begin
      Error_Log.Debug_Data(at_level => 5, 
                           with_details=>"Colour_Selected_7_CB: Start");
      selected_colour := colour_blocks(1);
      Set_Button_Reliefs(Object, 7);
   end Colour_Selected_7_CB;
    
   procedure Colour_Selected_8_CB(Object : access Gtkada_Builder_Record'Class)
   is
   begin
      Error_Log.Debug_Data(at_level => 5, 
                           with_details=>"Colour_Selected_8_CB: Start");
      selected_colour := colour_blocks(8);
      Set_Button_Reliefs(Object, 8);
   end Colour_Selected_8_CB;
    
   procedure Colour_Selected_9_CB(Object : access Gtkada_Builder_Record'Class)
   is
   begin
      Error_Log.Debug_Data(at_level => 5, 
                           with_details=>"Colour_Selected_9_CB: Start");
      selected_colour := colour_blocks(9);
      Set_Button_Reliefs(Object, 9);
   end Colour_Selected_9_CB;
    
   procedure Colour_Selected_10_CB(Object : access Gtkada_Builder_Record'Class)
   is
   begin
      Error_Log.Debug_Data(at_level => 5, 
                           with_details=>"Colour_Selected_10_CB: Start");
      selected_colour := colour_blocks(10);
      Set_Button_Reliefs(Object, 10);
   end Colour_Selected_10_CB;
    
   procedure Colour_Selected_11_CB(Object : access Gtkada_Builder_Record'Class)
   is
   begin
      Error_Log.Debug_Data(at_level => 5, 
                           with_details=>"Colour_Selected_11_CB: Start");
      selected_colour := colour_blocks(11);
      Set_Button_Reliefs(Object, 11);
   end Colour_Selected_11_CB;
    
   procedure Colour_Selected_12_CB(Object : access Gtkada_Builder_Record'Class)
   is
   begin
      Error_Log.Debug_Data(at_level => 5, 
                           with_details=>"Colour_Selected_12_CB: Start");
      selected_colour := colour_blocks(12);
      Set_Button_Reliefs(Object, 12);
   end Colour_Selected_12_CB;
    
   procedure Colour_Selected_13_CB(Object : access Gtkada_Builder_Record'Class)
   is
   begin
      Error_Log.Debug_Data(at_level => 5, 
                           with_details=>"Colour_Selected_13_CB: Start");
      selected_colour := colour_blocks(13);
      Set_Button_Reliefs(Object, 13);
   end Colour_Selected_13_CB;
    
   procedure Colour_Selected_14_CB(Object : access Gtkada_Builder_Record'Class)
   is
   begin
      Error_Log.Debug_Data(at_level => 5, 
                           with_details=>"Colour_Selected_14_CB: Start");
      selected_colour := colour_blocks(14);
      Set_Button_Reliefs(Object, 14);
   end Colour_Selected_14_CB;
    
   procedure Colour_Selected_15_CB(Object : access Gtkada_Builder_Record'Class)
   is
   begin
      Error_Log.Debug_Data(at_level => 5, 
                           with_details=>"Colour_Selected_15_CB: Start");
      selected_colour := colour_blocks(15);
      Set_Button_Reliefs(Object, 15);
   end Colour_Selected_15_CB;
    
   procedure Colour_Selected_16_CB(Object : access Gtkada_Builder_Record'Class)
   is
   begin
      Error_Log.Debug_Data(at_level => 5, 
                           with_details=>"Colour_Selected_16_CB: Start");
      selected_colour := colour_blocks(16);
      Set_Button_Reliefs(Object, 16);
   end Colour_Selected_16_CB;
    
begin
   Urine_Record_Version.Register(revision => "$Revision: v1.0.0$",
                                 for_module => "Urine_Colour_Selector");
end Urine_Colour_Selector;
