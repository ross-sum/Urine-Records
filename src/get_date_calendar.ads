-----------------------------------------------------------------------
--                                                                   --
--                 G E T   D A T E   C A L E N D A R                 --
--                                                                   --
--                     S p e c i f i c a t i o n                     --
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
with Gtkada.Builder;      use Gtkada.Builder;
with Calendar_Extensions; use Calendar_Extensions;
with Gtk.GEntry;
package Get_Date_Calendar is

   procedure Initialise_Calendar(Builder : in out Gtkada_Builder);
   procedure Show_Calendar(Builder : in Gtkada_Builder;
                           At_Field: in out Gtk.GEntry.Gtk_GEntry);
   
private
   procedure Get_Date_Calendar_Okay_CB 
                (Object : access Gtkada_Builder_Record'Class);
   procedure Get_Date_Calendar_Cancel_CB 
                (Object : access Gtkada_Builder_Record'Class);
   procedure Get_Date_Calendar_Today_CB 
                (Object : access Gtkada_Builder_Record'Class);
end Get_Date_Calendar;
