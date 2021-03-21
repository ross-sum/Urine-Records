------------------------------------------------------------------------------
--                             G N A T C O L L                              --
--                                                                          --
--                     Copyright (C) 2016-2018, AdaCore                     --
--                                                                          --
-- This library is free software;  you can redistribute it and/or modify it --
-- under terms of the  GNU General Public Licence  as published by the Free --
-- Software  Foundation;  either version 3,  or (at your  option) any later --
-- version. This library is distributed in the hope that it will be useful, --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE.                            --
--                                                                          --
-- You should have received a copy of the GNU General Public Licence and    --
-- a copy of the GCC Runtime Library Exception along with this program;     --
-- see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
-- <http://www.gnu.org/licenses/>.                                          --
--                                                                   --
--                          S Q L   B L O B                          --
--                                                                   --
--                              B o d y                              --
--                                                                   --
--                           $Revision: 1.0 $                        --
--                                                                   --
--  Copyright (C) 2021  Hyper Quantum Pty Ltd.                       --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This  package  provides the BLOB (Binary  Large  OBject)  field  --
--  access to and from a database table such that the BLOB field is  --
--  treated  in  the  table as just a blob (or an  array  of  byte,  --
--  represented as characters from 0 (NULL) to 255, that represents  --
--  a blob).                                                         --
--  This  edition  of dealing with a BLOB assumes that  the  format  --
--  stored in the data base is textual (but not as a UTF-8,  rather  --
--  as a traditional ASCII character array).                         --
--                                                                   --
-----------------------------------------------------------------------

-- with GNATCOLL.SQL_Impl;    use GNATCOLL.SQL_Impl;
-- with GNATCOLL.SQL.Exec;    use GNATCOLL.SQL.Exec;
-- with Ada.Strings.Unbounded;
package body GNATCOLL.SQL_BLOB is
   use Ada.Strings.Unbounded;

   function Class_Value
            (Self : Forward_Cursor'Class; Field : Field_Index) return string is
   -- (Value (Self, Field)) with Inline_Always;
   -- translates the class into the call to GNATCOLL.SQL.Exec.Value
   -- for Self : Forward_Cursor
   begin
      return Value (Self, Field);
   end Class_Value;
   pragma Inline_Always (Class_Value);
   
   -- type byte is new characater range Character'Val(0)..Character'Val(255);
   -- type tBlob is new Ada.Strings.Unbounded.Unbounded_String;
   --package tBlob_Fields is new GNATCOLL.SQL_Impl.Field_Types 
   --                                 (tBlob, tBlob_To_SQL, SQL_Parameter_tBlob);
   -- type SQL_Field_tBlob is new tBlob_Fields.Field with null record;

   function Blob_To_SQL (Format: GNATCOLL.SQL_Impl.Formatter'Class; T : Blob;
                         Quote : boolean := false) return string is
   begin
      return To_String (Source => Unbounded_String(T));
   end Blob_To_SQL;

   function SQL_To_Blob (D : String; Quote : boolean := false) return Blob is
   begin
      if Quote then
         return blob(Ada.Strings.Unbounded.To_Unbounded_String 
                                                   (Source => '"' & D & '"'));
      else
         return blob(Ada.Strings.Unbounded.To_Unbounded_String (Source => D));
      end if;
   end SQL_To_Blob;
   
   function Blob_Value (Self  : GNATCOLL.SQL.Exec.Direct_Cursor; 
                        Field : GNATCOLL.SQL.Exec.Field_Index) return Blob is
      Val : constant String := Class_Value (Self, Field);
   begin
      if Val = "" then
         return blob(Null_Unbounded_String);
      else
         return SQL_To_Blob(Val);
      end if;
   end Blob_Value;
   
   function Blob_Value (Self  : GNATCOLL.SQL.Exec.Forward_Cursor; 
                        Field : GNATCOLL.SQL.Exec.Field_Index) return Blob is
   begin
      return blob(GNATCOLL.SQL.Exec.Unbounded_Value(Self,Field));
      exception
         when others =>  -- default on error is an empty blob
            return blob(Null_Unbounded_String);
   end Blob_Value;
   
   function "+" (Value : Blob) return SQL_Parameter is
      R : SQL_Parameter;
      P : SQL_Parameter_Blob;
   begin
      P.Val := Value;
      R.Set (P);
      return R;
   end "+";
   
   --byte and blob operations
   
   procedure Clear(the_blob : in out blob) is
   begin
      the_blob := blob(Null_Unbounded_String);
   end Clear;
   
   function Element(in_blob : blob; at_position : in positive) return byte is
   begin
      return byte(Ada.Strings.Unbounded.Element(Unbounded_String(in_blob), 
                                                at_position));
   end Element;
   
   function "&" (the_blob : blob; the_byte : byte) return blob is
   begin
      return blob(Ada.Strings.Unbounded."&"(Unbounded_String(the_blob),
                                            Character(the_byte)));
   end "&";
   
   function "&" (the_byte : byte; the_blob : blob) return blob is
   begin
      return blob(Ada.Strings.Unbounded."&"(Character(the_byte),
                                            Unbounded_String(the_blob)));
   end "&";
   
   function Length(of_the_blob : in blob) return natural is
   begin
      return Ada.Strings.Unbounded.Length(Unbounded_String(of_the_blob));
   end Length;

end GNATCOLL.SQL_BLOB;
