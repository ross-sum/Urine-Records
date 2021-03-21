-----------------------------------------------------------------------
--                                                                   --
--                        H E L P   A B O U T                        --
--                                                                   --
--                     S p e c i f i c a t i o n                     --
--                                                                   --
--                           $Revision: 1.0 $                        --
--                                                                   --
--  Copyright (C) 2020  Hyper Quantum Pty Ltd.                       --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This  package  displays  the help  about  dialogue  box,  which  --
--  contains  details about the application,  specifically  general  --
--  details,  revision details and usage information (i.e.  how  to  --
--  launch urine_records).                                           --
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
with dStrings;        use dStrings;
package Help_About is


   procedure Initialise_Help_About(Builder : in out Gtkada_Builder;
                                   usage : in text);
   procedure Show_Help_About(Builder : in Gtkada_Builder);

private

   procedure Help_About_Close_CB 
                (Object : access Gtkada_Builder_Record'Class);
   function Help_Hide_On_Delete
      (Object : access Glib.Object.GObject_Record'Class) return Boolean;

end Help_About;