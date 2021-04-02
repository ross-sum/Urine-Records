-----------------------------------------------------------------------
--                                                                   --
--                C H E C K   F O R   D E L E T I O N                --
--                                                                   --
--                              B o d y                              --
--                                                                   --
--                           $Revision: 1.0 $                        --
--                                                                   --
--  Copyright (C) 2020  Hyper Quantum Pty Ltd.                       --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This  package displays the 'Are you Sure?' dialogue box,  which  --
--  is used to get a confirmation that the user wishes to delete  a  --
--  record.  It is typically called by either clicking on a  delete  --
--  button  or selecting delete from the menu.  If confirmed,  then  --
--  it executes a call-back that is passed to it.                    --
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
with Gtk.Widget;
with Error_Log;
with Urine_Record_Version;
package body Check_For_Deletion is

   -- type Delete_Handler is access procedure
   --    (Builder : access Gtkada_Builder_Record'Class);

   the_delete_callback : Delete_Handler;
    
   procedure Initialise(Builder : in out Gtkada_Builder) is
   begin
      -- set up 
      null;
         -- Register the handlers
      Register_Handler(Builder      => Builder,
                       Handler_Name => "btn_areyousure_okay_clicked_cb",
                       Handler      => Check_For_Deletion_Okay_CB'Access);
      Register_Handler(Builder      => Builder,
                       Handler_Name => "btn_areyousure_cancel_clicked_cb",
                       Handler      => Check_For_Deletion_Cancel_CB'Access);
   end Initialise;
   
   procedure Show_Are_You_Sure(Builder : in Gtkada_Builder;
                               At_Handler: in Delete_Handler) is
   begin
      Gtk.Widget.Show_All(Gtk.Widget.Gtk_Widget 
                        (Gtkada.Builder.Get_Object(Builder,
                                                   "dialogue_are_you_sure")));
      the_delete_callback := At_Handler;
   end Show_Are_You_Sure;
   
   procedure Check_For_Deletion_Okay_CB 
                (Object : access Gtkada_Builder_Record'Class) is
      -- use Glib;
      -- use Gtk.GEntry;
      -- use String_Conversions;
   begin
      Error_Log.Debug_Data(at_level => 5, 
                           with_details=>"Check_For_Deletion_Okay_CB: Start");
      -- execute the call-back
      the_delete_callback(Object);
      -- and close the dialogue box
      Gtk.Widget.Hide(Gtk.Widget.Gtk_Widget 
                        (Gtkada.Builder.Get_Object(Gtkada_Builder(Object),
                                                   "dialogue_are_you_sure")));
   end Check_For_Deletion_Okay_CB;

   procedure Check_For_Deletion_Cancel_CB 
                (Object : access Gtkada_Builder_Record'Class) is
   begin
      Error_Log.Debug_Data(at_level => 5, 
                           with_details=>"Check_For_Deletion_Cancel_CB: Start");
      -- Just close the dialogue box
      Gtk.Widget.Hide(Gtk.Widget.Gtk_Widget 
                        (Gtkada.Builder.Get_Object(Gtkada_Builder(Object),
                                                   "dialogue_are_you_sure")));
   end Check_For_Deletion_Cancel_CB;
                
begin
   Urine_Record_Version.Register(revision => "$Revision: v1.0.0$",
                                 for_module => "Check_For_Deletion");
end Check_For_Deletion;
