-----------------------------------------------------------------------
--                                                                   --
--                   P A T I E N T   D E T A I L S                   --
--                                                                   --
 --                              B o d y                              --
--                                                                   --
--                           $Revision: 1.0 $                        --
--                                                                   --
--  Copyright (C) 2020  Hyper Quantum Pty Ltd.                       --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This  package  provides an interlock mechanism to  the  patient  --
--  details data entry form.                                         --
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
with Error_Log;
package body Urine_Records_Interlocks is

   protected body Interlock is
      procedure Lock is
      begin
         Error_Log.Debug_Data(at_level => 7, 
                              with_details => "Interlock.Lock: Start");
         locked := true;
      end Lock;
      procedure Release is
      begin
         Error_Log.Debug_Data(at_level => 7, 
                              with_details => "Interlock.Release: Start");
         locked := false;
      end Release;
      function Is_Locked return boolean is
      begin
         Error_Log.Debug_Data(at_level => 7, 
                              with_details => "Interlock.Is_Locked: Start");
         return locked;
      end Is_Locked;
   -- private
      -- locked : boolean := false;
   end Interlock;
   -- type interlock_access is access all Interlock;

end Urine_Records_Interlocks;