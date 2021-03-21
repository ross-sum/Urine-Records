-----------------------------------------------------------------------
--                                                                   --
--             U R I N E   C O L O U R   S E L E C T O R             --
--                                                                   --
--                     S p e c i f i c a t i o n                     --
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
with Gtkada.Builder;      use Gtkada.Builder;
with Gtk.Combo_Box;
with GNATCOLL.SQL.Exec;
package Urine_Colour_Selector is

   type wavelength is new natural;  -- in nano metres
   subtype visible_spectrum is wavelength range 390 .. 750; -- nm
    
   procedure Initialise_Colour_Selector(Builder : in out Gtkada_Builder;
                             DB_Descr : GNATCOLL.SQL.Exec.Database_Description;
                             path_to_temp : string := "/tmp/");
   procedure Show_Colour_Selector(Builder :in Gtkada_Builder;
                                  At_Field:in out Gtk.Combo_Box.Gtk_Combo_Box);
   
private
   number_of_blocks : positive := 16;
   colour_blocks : array(1..number_of_blocks) of visible_spectrum;
   procedure Set_Button_Reliefs(Object : access Gtkada_Builder_Record'Class;
                                at_button : in natural);
   procedure Colour_Selector_Okay_CB 
                (Object : access Gtkada_Builder_Record'Class);
   procedure Colour_Selector_Cancel_CB 
                (Object : access Gtkada_Builder_Record'Class);
   procedure Colour_Selected_1_CB 
                (Object : access Gtkada_Builder_Record'Class);
   procedure Colour_Selected_2_CB 
                (Object : access Gtkada_Builder_Record'Class);
   procedure Colour_Selected_3_CB 
                (Object : access Gtkada_Builder_Record'Class);
   procedure Colour_Selected_4_CB 
                (Object : access Gtkada_Builder_Record'Class);
   procedure Colour_Selected_5_CB 
                (Object : access Gtkada_Builder_Record'Class);
   procedure Colour_Selected_6_CB 
                (Object : access Gtkada_Builder_Record'Class);
   procedure Colour_Selected_7_CB 
                (Object : access Gtkada_Builder_Record'Class);
   procedure Colour_Selected_8_CB 
                (Object : access Gtkada_Builder_Record'Class);
   procedure Colour_Selected_9_CB 
                (Object : access Gtkada_Builder_Record'Class);
   procedure Colour_Selected_10_CB 
                (Object : access Gtkada_Builder_Record'Class);
   procedure Colour_Selected_11_CB 
                (Object : access Gtkada_Builder_Record'Class);
   procedure Colour_Selected_12_CB 
                (Object : access Gtkada_Builder_Record'Class);
   procedure Colour_Selected_13_CB 
                (Object : access Gtkada_Builder_Record'Class);
   procedure Colour_Selected_14_CB 
                (Object : access Gtkada_Builder_Record'Class);
   procedure Colour_Selected_15_CB 
                (Object : access Gtkada_Builder_Record'Class);
   procedure Colour_Selected_16_CB 
                (Object : access Gtkada_Builder_Record'Class);
end Urine_Colour_Selector;
