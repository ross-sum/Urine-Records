-----------------------------------------------------------------------
--                                                                   --
--       C A T H E T E R   U R I N E   R E C O R D S   F O R M       --
--                                                                   --
--                     S p e c i f i c a t i o n                     --
--                                                                   --
--                           $Revision: 1.0 $                        --
--                                                                   --
--  Copyright (C) 2020  Hyper Quantum Pty Ltd.                       --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This  package  displays the catheter urine records  data  entry  --
--  form, which contains the information necessary to log all urine  --
--  volumes, colours and floaties (if any) that is bagged from  the  --
--  catheter.  It also records any leakage into pads (for instance,  --
--  from a spasm type effect).                                       --
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
with Gtkada.Builder;  use Gtkada.Builder;
with Glib.Object;
with GNATCOLL.SQL.Exec;
with Calendar_Extensions;
package Catheter_Urine_Records_Form is


   procedure Initialise_Catheter_Urine_Records(Builder : in out Gtkada_Builder;
                           DB_Descr : GNATCOLL.SQL.Exec.Database_Description);
   procedure Show_Catheter_Urine_Records(Builder : in Gtkada_Builder);
   procedure Finalise;

private
   use Calendar_Extensions;

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

   function Number_of_Records(Builder:access Gtkada_Builder_Record'Class)
                             return natural;
   procedure Clear_Catheter_Urine_Record_Fields
                   (Builder : access Gtkada_Builder_Record'Class);
   procedure Load_Catheter_Urine_Record_Data
                (Builder:access Gtkada_Builder_Record'Class;
                 record_no : record_movement; 
                 refresh   : boolean := false);
   procedure Catheter_Urine_Records_New_Selected_CB 
                (Object : access Gtkada_Builder_Record'Class);
   procedure Catheter_Urine_Records_Undo_Selected_CB 
                (Object : access Gtkada_Builder_Record'Class);
   procedure Catheter_Urine_Records_Save_Selected_CB 
                (Object : access Gtkada_Builder_Record'Class);
   procedure Catheter_Urine_Records_Delete_Selected_CB 
                (Object : access Gtkada_Builder_Record'Class);
   procedure Catheter_Urine_Records_Delete_Record 
                (Object : access Gtkada_Builder_Record'Class);
   procedure Catheter_Urine_Records_Close_CB 
                (Object : access Gtkada_Builder_Record'Class);
   procedure Catheter_Urine_Records_Field_Changed_CB
                (Object : access Gtkada_Builder_Record'Class);
   procedure Catheter_Urine_Records_Date_Changed_CB
                (Object : access Gtkada_Builder_Record'Class);
   procedure Catheter_Urine_Records_Time_Changed_CB
                (Object : access Gtkada_Builder_Record'Class);
   procedure Catheter_Urine_Records_Number_Changed_CB
                (Object : access Gtkada_Builder_Record'Class;
                 entry_name : string);
   procedure Catheter_Urine_Records_Vol_Changed_CB
                (Object : access Gtkada_Builder_Record'Class);
   procedure Catheter_Urine_Records_First_Clicked_CB
                (Object : access Gtkada_Builder_Record'Class);
   procedure Catheter_Urine_Records_Previous_10_Clicked_CB
                (Object : access Gtkada_Builder_Record'Class);
   procedure Catheter_Urine_Records_Previous_Clicked_CB
                (Object : access Gtkada_Builder_Record'Class);
   procedure Catheter_Urine_Records_Next_Clicked_CB
                (Object : access Gtkada_Builder_Record'Class);
   procedure Catheter_Urine_Records_Next_10_Clicked_CB
                (Object : access Gtkada_Builder_Record'Class);
   procedure Catheter_Urine_Records_Last_Clicked_CB
                (Object : access Gtkada_Builder_Record'Class);
   procedure Catheter_Urine_Records_Date_Button_Pressed_CB
                (Object : access Gtkada_Builder_Record'Class);
   procedure Catheter_Urine_Records_Colour_Button_Pressed_CB
                (Object : access Gtkada_Builder_Record'Class);

end Catheter_Urine_Records_Form;