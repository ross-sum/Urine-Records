-----------------------------------------------------------------------
--                                                                   --
--                U R I N E   R E C O R D S   F O R M                --
--                                                                   --
--                     S p e c i f i c a t i o n                     --
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
with Gtkada.Builder;  use Gtkada.Builder;
with Glib.Object;
with GNATCOLL.SQL.Exec;
with Calendar_Extensions;
package Urine_Records_Form is


   procedure Initialise_Urine_Records(Builder : in out Gtkada_Builder;
                           DB_Descr : GNATCOLL.SQL.Exec.Database_Description);
   procedure Show_Urine_Records(Builder : in Gtkada_Builder);
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
   procedure Clear_Urine_Record_Fields
                   (Builder : access Gtkada_Builder_Record'Class);
   procedure Load_Urine_Record_Data(Builder:access Gtkada_Builder_Record'Class;
                                    record_no : record_movement; 
                                    refresh   : boolean := false);
   procedure Urine_Records_New_Selected_CB 
                (Object : access Gtkada_Builder_Record'Class);
   procedure Urine_Records_Undo_Selected_CB 
                (Object : access Gtkada_Builder_Record'Class);
   procedure Urine_Records_Save_Selected_CB 
                (Object : access Gtkada_Builder_Record'Class);
   procedure Urine_Records_Delete_Selected_CB 
                (Object : access Gtkada_Builder_Record'Class);
   procedure Urine_Records_Delete_Record 
                (Object : access Gtkada_Builder_Record'Class);
   procedure Urine_Records_Close_CB 
                (Object : access Gtkada_Builder_Record'Class);
   procedure Urine_Records_Field_Changed_CB
                (Object : access Gtkada_Builder_Record'Class);
   procedure Urine_Records_Date_Changed_CB
                (Object : access Gtkada_Builder_Record'Class);
   procedure Urine_Records_Time_Changed_CB
                (Object : access Gtkada_Builder_Record'Class);
   procedure Urine_Records_Number_Changed_CB
                (Object : access Gtkada_Builder_Record'Class;
                 entry_name : string);
   procedure Urine_Records_Vol_Changed_CB
                (Object : access Gtkada_Builder_Record'Class);
   procedure Urine_Records_PadVol_Changed_CB
                (Object : access Gtkada_Builder_Record'Class);
   procedure Urine_Records_SpasCnt_Changed_CB
                (Object : access Gtkada_Builder_Record'Class);
   procedure Urine_Records_Urges_Changed_CB
                (Object : access Gtkada_Builder_Record'Class);
   procedure Urine_Records_First_Clicked_CB
                (Object : access Gtkada_Builder_Record'Class);
   procedure Urine_Records_Previous_10_Clicked_CB
                (Object : access Gtkada_Builder_Record'Class);
   procedure Urine_Records_Previous_Clicked_CB
                (Object : access Gtkada_Builder_Record'Class);
   procedure Urine_Records_Next_Clicked_CB
                (Object : access Gtkada_Builder_Record'Class);
   procedure Urine_Records_Next_10_Clicked_CB
                (Object : access Gtkada_Builder_Record'Class);
   procedure Urine_Records_Last_Clicked_CB
                (Object : access Gtkada_Builder_Record'Class);
   procedure Urine_Records_Date_Button_Pressed_CB
                (Object : access Gtkada_Builder_Record'Class);

end Urine_Records_Form;