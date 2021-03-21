-----------------------------------------------------------------------
--                                                                   --
--                       H E L P   M A N U A L                       --
--                                                                   --
--                              B o d y                              --
--                                                                   --
--                           $Revision: 1.0 $                        --
--                                                                   --
--  Copyright (C) 2020  Hyper Quantum Pty Ltd.                       --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This  package  displays the 'help-manual' dialogue  box,  which  --
--  contains details on how to use Urine_Records in every  respect,  --
--  including setting it up initially.                               --
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
with Gtk.Widget;
with Error_Log;
with Urine_Record_Version;
with String_Conversions;
package body Help_Manual is


   procedure Initialise_Manual(Builder : in out Gtkada_Builder) is
   begin
      -- set up 
      null;
         -- Register the handlers
      Register_Handler(Builder      => Builder,
                       Handler_Name => "button_close_manual_clicked_cb",
                       Handler      => Help_Manual_Close_CB'Access);
   end Initialise_Manual;

   procedure Show_Manual(Builder : in Gtkada_Builder) is
   begin
      Gtk.Widget.Show_All(Gtk.Widget.Gtk_Widget 
                        (Gtkada.Builder.Get_Object(Builder,"dialogue_manual")));
   end Show_Manual;
  
   procedure Help_Manual_Close_CB 
                (Object : access Gtkada_Builder_Record'Class) is
   begin
      Error_Log.Debug_Data(at_level => 5, 
                           with_details => "Help_Manual_Close_CB: Start");
      Gtk.Widget.Hide(Gtk.Widget.Gtk_Widget 
                        (Gtkada.Builder.Get_Object(Gtkada_Builder(Object),"dialogue_manual")));
   end Help_Manual_Close_CB;

begin
   Urine_Record_Version.Register(revision => "$Revision: v1.0.0$",
                                 for_module => "Help_Manual");
end Help_Manual;