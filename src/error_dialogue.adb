-----------------------------------------------------------------------
--                                                                   --
--                    D I A L O G U E   E R R O R                    --
--                                                                   --
--                              B o d y                              --
--                                                                   --
--                           $Revision: 1.0 $                        --
--                                                                   --
--  Copyright (C) 2020  Hyper Quantum Pty Ltd.                       --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This  package  displays a specified error message in a dialogue  --
--  box,  which is requested for display by an event in a window.    --
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
with Gtk.Widget, Gtk.Label;
with Error_Log;
with Urine_Record_Version;
package body Error_Dialogue is


   procedure Initialise_Dialogue(Builder : in out Gtkada_Builder) is
   begin
         -- Register the handlers
      Register_Handler(Builder      => Builder,
                       Handler_Name => "dialogue_error_okay_clicked_cb",
                       Handler      => Error_Dialogue_Close_CB'Access);
   end Initialise_Dialogue;
   
   procedure Show_Error(Builder : in Gtkada_Builder;
                        message : in string) is
      use Gtk.Label;
      the_message : gtk_label;
   begin
      the_message := Gtk_Label(Builder.Get_Object("label_error_message"));
      the_message.Set_Label(message);
      Gtk.Widget.Show_All(Gtk.Widget.Gtk_Widget 
                        (Gtkada.Builder.Get_Object(Builder,"dialogue_error")));
   end Show_Error;

   procedure Error_Dialogue_Close_CB 
                (Object : access Gtkada_Builder_Record'Class) is
   begin
      Error_Log.Debug_Data(at_level => 5, 
                           with_details => "Error_Dialogue_Close_CB: Start");
      Gtk.Widget.Hide(Gtk.Widget.Gtk_Widget 
         (Gtkada.Builder.Get_Object(Gtkada_Builder(Object),"dialogue_error")));
   end Error_Dialogue_Close_CB;

begin
   Urine_Record_Version.Register(revision => "$Revision: v1.0.0$",
                                 for_module => "Error_Dialogue");
end Error_Dialogue;