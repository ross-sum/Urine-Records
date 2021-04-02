-----------------------------------------------------------------------
--                                                                   --
--                C H E C K   F O R   D E L E T I O N                --
--                                                                   --
--                     S p e c i f i c a t i o n                     --
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
with Gtkada.Builder;      use Gtkada.Builder;
package Check_For_Deletion is

   type Delete_Handler is access procedure
      (Builder : access Gtkada_Builder_Record'Class);
      
   procedure Initialise(Builder : in out Gtkada_Builder);
   procedure Show_Are_You_Sure(Builder    : in Gtkada_Builder;
                               At_Handler : in Delete_Handler);
   
private
   procedure Check_For_Deletion_Okay_CB 
                (Object : access Gtkada_Builder_Record'Class);
   procedure Check_For_Deletion_Cancel_CB 
                (Object : access Gtkada_Builder_Record'Class);
                
end Check_For_Deletion;
