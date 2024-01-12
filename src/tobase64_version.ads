   -----------------------------------------------------------------------
   --                                                                   --
   --                           T O   B A S E 6 4                       --
   --                                                                   --
   --                             P r o j e c t                         --
   --                                                                   --
   --                           $Revision: 1.0 $                        --
   --                                                                   --
   --  Copyright (C) 2021  Hyper Quantum Pty Ltd.                       --
   --  Written by Ross Summerfield.                                     --
   --                                                                   --
   --  This application converts a blob to Base 64 format.              --
   --                                                                   --
   --  Version History:                                                 --
   --  $Log$
   --                                                                   --
   --  ToBase64  is  free  software; you can  redistribute  it  and/or  --
   --  modify  it under terms of the GNU  General  Public  Licence  as  --
   --  published by the Free Software Foundation; either version 2, or  --
   --  (at  your option) any later version.  ToBase64  is  distributed  --
   --  in  hope  that  it will be useful, but  WITHOUT  ANY  WARRANTY;  --
   --  without even the implied warranty of MERCHANTABILITY or FITNESS  --
   --  FOR  A PARTICULAR PURPOSE.  See the GNU General Public  Licence  --
   --  for  more details.  You should have received a copy of the  GNU  --
   --  General Public Licence distributed with ToBase64. If not, write  --
   --  to  the  Free Software Foundation, 51  Franklin  Street,  Fifth  --
   --  Floor, Boston, MA 02110-1301, USA.                               --
   --                                                                   --
   -----------------------------------------------------------------------
with Generic_Versions;
package ToBase64_Version is

   package ToBase64_Versions is new Generic_Versions
   ("1.0.0", "ToBase64");

   function Version return wide_string 
   renames ToBase64_Versions.Version;
   function Application_Title return wide_string
   renames ToBase64_Versions.Application_Title;
   function Application_Name return wide_string
   renames ToBase64_Versions.Application_Name;
   function Computer_Name return wide_string
   renames ToBase64_Versions.Computer_Name;
   procedure Register(revision, for_module : in wide_string)
   renames ToBase64_Versions.Register;
   function Revision_List return wide_string
   renames ToBase64_Versions.Revision_List;

end ToBase64_Version;
