 -----------------------------------------------------------------------
--                                                                   --
--               U R I N E _ R E C O R D _ V E R S I O N             --
--                                                                   --
--                     S p e c i f i c a t i o n                     --
--                                                                   --
--                           $Revision: 1.0 $                        --
--                                                                   --
--  Copyright (C) 2020  Hyper Quantum Pty Ltd.                       --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This  application  records both catheter  volumes  and  bladder  --
   --  volumes  for a patient or patients that have undergone  radical  --
   --  prostatectomy  (removal  of  the  prostate).    The   urologist  --
   --  typically wants to track the volumes to monitor recovery.        --
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
   with Generic_Versions;
package Urine_Record_Version is

   package Urine_Record_Versions is new Generic_Versions
   ("1.0.0", "Urine_Records");

   function Version return wide_string 
   renames Urine_Record_Versions.Version;
   function Application_Title return wide_string
   renames Urine_Record_Versions.Application_Title;
   function Application_Name return wide_string
   renames Urine_Record_Versions.Application_Name;
   function Computer_Name return wide_string
   renames Urine_Record_Versions.Computer_Name;
   procedure Register(revision, for_module : in wide_string)
   renames Urine_Record_Versions.Register;
   function Revision_List return wide_string
   renames Urine_Record_Versions.Revision_List;

end Urine_Record_Version;