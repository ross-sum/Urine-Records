-----------------------------------------------------------------------
--                                                                   --
--                 G E T   D A T E   C A L E N D A R                 --
--                                                                   --
--                              B o d y                              --
--                                                                   --
--                           $Revision: 1.0 $                        --
--                                                                   --
--  Copyright (C) 2020  Hyper Quantum Pty Ltd.                       --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This  package  displays the calendar  selection  dialogue  box,  --
--  which is used to pick a date off the calendar.  It is typically  --
--  called by double-clicking on a date field.  It also contains  a  --
--  conversion  routine to handle date formats for loading  to  and  --
--  from the database.                                               --
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
-- with Calendar_Extensions; use Calendar_Extensions;
-- with Gtk.GEntry;
with Glib, Gtk.Widget, Gtk.Calendar;
with Error_Log;
with Urine_Record_Version;
with String_Conversions;
package body Get_Date_Calendar is

   the_entry : Gtk.GEntry.Gtk_GEntry;
    
   procedure Initialise_Calendar(Builder : in out Gtkada_Builder) is
   begin
      -- set up 
      Get_Date_Calendar_Today_CB(Builder);
         -- Register the handlers
      Register_Handler(Builder      => Builder,
                       Handler_Name => "btn_get_date_okay_clicked_cb",
                       Handler      => Get_Date_Calendar_Okay_CB'Access);
      Register_Handler(Builder      => Builder,
                       Handler_Name => "btn_get_date_cancel_clicked_cb",
                       Handler      => Get_Date_Calendar_Cancel_CB'Access);
      Register_Handler(Builder      => Builder,
                       Handler_Name => "btn_get_date_today_clicked_cb",
                       Handler      => Get_Date_Calendar_Today_CB'Access);
   end Initialise_Calendar;

   procedure Show_Calendar(Builder : in Gtkada_Builder;
                           At_Field: in out Gtk.GEntry.Gtk_GEntry) is
   begin
      Gtk.Widget.Show_All(Gtk.Widget.Gtk_Widget 
                        (Gtkada.Builder.Get_Object(Builder,
                                                   "dialogue_get_date")));
      the_entry := At_Field;
   end Show_Calendar;
   
   procedure Get_Date_Calendar_Okay_CB 
                (Object : access Gtkada_Builder_Record'Class) is
      use Gtk.Calendar, Glib;
      use Gtk.GEntry;
      use String_Conversions;
      the_calendar : Gtk.Calendar.Gtk_Calendar;
      year, 
      month, 
      day          : Glib.Guint;
      the_date     : Time;
   begin
      Error_Log.Debug_Data(at_level => 5, 
                           with_details=>"Get_Date_Calendar_Okay_CB: Start");
      -- get the date
      the_calendar := Gtk_Calendar(Get_Object(Gtkada_Builder(Object),
                                             "get_date_calendar"));
      Gtk.Calendar.Get_Date(the_calendar, year, month, day);
      -- return the date
      the_date := Time_Of(Year_Number(year), 
                          Month_Number(month+1), 
                          Day_Number(day), 0.0);
      Set_Text(the_entry, To_String(from_wide =>
               To_String(from_time => the_date, with_format => "dd/mm/yyyy")));
      -- and close the dialogue box
      Gtk.Widget.Hide(Gtk.Widget.Gtk_Widget 
                        (Gtkada.Builder.Get_Object(Gtkada_Builder(Object),
                                                   "dialogue_get_date")));
   end Get_Date_Calendar_Okay_CB;

   procedure Get_Date_Calendar_Cancel_CB 
                (Object : access Gtkada_Builder_Record'Class) is
   begin
      Error_Log.Debug_Data(at_level => 5, 
                           with_details=>"Get_Date_Calendar_Cancel_CB: Start");
      -- Just close the dialogue box
      Gtk.Widget.Hide(Gtk.Widget.Gtk_Widget 
                        (Gtkada.Builder.Get_Object(Gtkada_Builder(Object),
                                                   "dialogue_get_date")));
   end Get_Date_Calendar_Cancel_CB;

   procedure Get_Date_Calendar_Today_CB 
                (Object : access Gtkada_Builder_Record'Class) is
      use Glib;
      the_calendar : Gtk.Calendar.Gtk_Calendar;
      the_year  : Year_Number  := Year(Clock);
      the_month : Month_Number := Month(Clock);
      the_day   : Day_Number   := Day(Clock);
   begin
      Error_Log.Debug_Data(at_level => 5, 
                           with_details=>"Get_Date_Calendar_Today_CB: Start");
      the_calendar := Gtk.Calendar.Gtk_Calendar
                        (Gtkada.Builder.Get_Object(Gtkada_Builder(Object),
                                                   "get_date_calendar"));
      -- set the calendar to today's date
      Gtk.Calendar.Select_Month(the_calendar, 
                                Glib.Guint(the_month)-1, Glib.Guint(the_year));
      Gtk.Calendar.Select_Day(the_calendar, Glib.Guint(the_day));
   end Get_Date_Calendar_Today_CB;

begin
   Urine_Record_Version.Register(revision => "$Revision: v1.0.0$",
                                 for_module => "Get_Date_Calendar");
end Get_Date_Calendar;