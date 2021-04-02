-----------------------------------------------------------------------
--                                                                   --
--                   P A T I E N T   D E T A I L S                   --
--                                                                   --
--                     S p e c i f i c a t i o n                     --
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
with Gtkada.Builder;  use Gtkada.Builder;
with GNATCOLL.SQL.Exec;
with Calendar_Extensions;
package Patient_Details is


   procedure Initialise_Patient_Details(Builder : in out Gtkada_Builder;
                           DB_Descr : GNATCOLL.SQL.Exec.Database_Description);
   procedure Show_Patient_Details(Builder : in Gtkada_Builder);
   procedure Finalise;

private

   type mvt_types is (relative, absolute);
   type relative_movements is (first, back10, backward, forward, next10, last);
   type record_movement(mvt_type : mvt_types) is
      record
         case mvt_type is
            when relative =>
               movement : relative_movements := first;
            when absolute =>
               record_number : positive := 1;
         end case;
      end record;

   procedure Patient_Details_New_Selected_CB 
                (Object : access Gtkada_Builder_Record'Class);
   procedure Patient_Details_Undo_Selected_CB 
                (Object : access Gtkada_Builder_Record'Class);
   procedure Patient_Details_Save_Selected_CB 
                (Object : access Gtkada_Builder_Record'Class);
   procedure Patient_Details_Delete_Selected_CB 
                (Object : access Gtkada_Builder_Record'Class);
   procedure Patient_Details_Delete_Record 
                (Object : access Gtkada_Builder_Record'Class);
   procedure Patient_Details_Close_CB 
                (Object : access Gtkada_Builder_Record'Class);
   procedure Patient_Details_Field_Changed_CB
                (Object : access Gtkada_Builder_Record'Class);
   procedure Patient_Details_Date_Changed_CB
                (Object : access Gtkada_Builder_Record'Class);
   procedure Patient_Details_Number_Changed_CB
                (Object : access Gtkada_Builder_Record'Class);
   procedure Patient_Details_First_Clicked_CB
                (Object : access Gtkada_Builder_Record'Class);
   procedure Patient_Details_Previous_10_Clicked_CB
                (Object : access Gtkada_Builder_Record'Class);
   procedure Patient_Details_Previous_Clicked_CB
                (Object : access Gtkada_Builder_Record'Class);
   procedure Patient_Details_Next_Clicked_CB
                (Object : access Gtkada_Builder_Record'Class);
   procedure Patient_Details_Next_10_Clicked_CB
                (Object : access Gtkada_Builder_Record'Class);
   procedure Patient_Details_Last_Clicked_CB
                (Object : access Gtkada_Builder_Record'Class);
   procedure Patient_Details_Date_Button_Pressed_CB
                (Object : access Gtkada_Builder_Record'Class);
   procedure Patient_Details_KE_Select_changed_CB
                (Object : access Gtkada_Builder_Record'Class);
   procedure Btn_Patient_KE_First_Clicked_CB 
                (Object : access Gtkada_Builder_Record'Class);
   procedure Btn_Patient_KE_Last_Clicked_CB 
                (Object : access Gtkada_Builder_Record'Class);
   procedure Btn_Patient_KE_Add_Clicked_CB 
                (Object : access Gtkada_Builder_Record'Class);
   procedure Btn_Patient_KE_Undo_Clicked_CB 
                (Object : access Gtkada_Builder_Record'Class);
   procedure Btn_Patient_KE_Save_Clicked_CB 
                (Object : access Gtkada_Builder_Record'Class);
   procedure Btn_Patient_KE_Remove_Clicked_CB 
                (Object : access Gtkada_Builder_Record'Class);
   procedure Btn_Patient_KE_Remove_Record 
                (Object : access Gtkada_Builder_Record'Class);
   procedure Patient_Details_KE_Field_Changed_CB
                (Object : access Gtkada_Builder_Record'Class);
   procedure Patient_Details_KE_Date_Changed_CB
                (Object : access Gtkada_Builder_Record'Class);
   procedure Patient_Details_KE_Date_edited_CB
                (Object : access Gtkada_Builder_Record'Class);
   procedure Patient_Details_KE_Date_clicked_CB
                (Object : access Gtkada_Builder_Record'Class);
   procedure Patient_Details_KE_Event_edited_CB
                (Object : access Gtkada_Builder_Record'Class);
   procedure Patient_Details_KE_Desc_edited_CB
                (Object : access Gtkada_Builder_Record'Class);
   procedure Patient_Details_KE_Date_Button_Pressed_CB
                (Object : access Gtkada_Builder_Record'Class);

   function Number_of_PD_Records
                (Builder : access Gtkada_Builder_Record'Class) return natural;
   function Number_of_KE_Records
                (Builder : access Gtkada_Builder_Record'Class) return natural;
   procedure Clear_Patient_Details_Fields
                (Builder : access Gtkada_Builder_Record'Class);
   procedure Load_Patient_Details_Data
                (Builder   : access Gtkada_Builder_Record'Class;
                 record_no : record_movement; 
                 refresh   : boolean := false);

end Patient_Details;