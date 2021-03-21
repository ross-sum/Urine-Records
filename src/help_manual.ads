-----------------------------------------------------------------------
--                                                                   --
--                       H E L P   M A N U A L                       --
--                                                                   --
--                     S p e c i f i c a t i o n                     --
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
--  If not, write to the Free Software Foundation, 59 Temple Place-  --
--  Suite 330, Boston, MA 02111-1307, USA.                           --
--                                                                   --
-----------------------------------------------------------------------
with Gtkada.Builder;  use Gtkada.Builder;
package Help_Manual is


   procedure Initialise_Manual(Builder : in out Gtkada_Builder);
   procedure Show_Manual(Builder : in Gtkada_Builder);

private

   procedure Help_Manual_Close_CB 
                (Object : access Gtkada_Builder_Record'Class);

end Help_Manual;