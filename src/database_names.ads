with GNATCOLL.SQL; use GNATCOLL.SQL;
package database_Names is
   pragma Style_Checks (Off);
   TC_Catheterleakage : aliased constant String := """CatheterLeakage""";
   Ta_Catheterleakage : constant Cst_String_Access := TC_Catheterleakage'Access;
   TC_Catheterurinerecord : aliased constant String := """CatheterUrineRecord""";
   Ta_Catheterurinerecord : constant Cst_String_Access := TC_Catheterurinerecord'Access;
   TC_Colourchart : aliased constant String := """ColourChart""";
   Ta_Colourchart : constant Cst_String_Access := TC_Colourchart'Access;
   TC_Configurations : aliased constant String := """Configurations""";
   Ta_Configurations : constant Cst_String_Access := TC_Configurations'Access;
   TC_Floaties : aliased constant String := """Floaties""";
   Ta_Floaties : constant Cst_String_Access := TC_Floaties'Access;
   TC_Holdstates : aliased constant String := """HoldStates""";
   Ta_Holdstates : constant Cst_String_Access := TC_Holdstates'Access;
   TC_Keyevents : aliased constant String := """KeyEvents""";
   Ta_Keyevents : constant Cst_String_Access := TC_Keyevents'Access;
   TC_Leakage : aliased constant String := """Leakage""";
   Ta_Leakage : constant Cst_String_Access := TC_Leakage'Access;
   TC_Padsizes : aliased constant String := """PadSizes""";
   Ta_Padsizes : constant Cst_String_Access := TC_Padsizes'Access;
   TC_Patientdetails : aliased constant String := """PatientDetails""";
   Ta_Patientdetails : constant Cst_String_Access := TC_Patientdetails'Access;
   TC_Queries : aliased constant String := """Queries""";
   Ta_Queries : constant Cst_String_Access := TC_Queries'Access;
   TC_Reports : aliased constant String := """Reports""";
   Ta_Reports : constant Cst_String_Access := TC_Reports'Access;
   TC_Spasms : aliased constant String := """Spasms""";
   Ta_Spasms : constant Cst_String_Access := TC_Spasms'Access;
   TC_Urinerecord : aliased constant String := """UrineRecord""";
   Ta_Urinerecord : constant Cst_String_Access := TC_Urinerecord'Access;
   TC_Urinerecords : aliased constant String := """urineRecords""";
   Ta_Urinerecords : constant Cst_String_Access := TC_Urinerecords'Access;

   NC_Addressline1 : aliased constant String := """AddressLine1""";
   N_Addressline1 : constant Cst_String_Access := NC_AddressLine1'Access;
   NC_Addressline2 : aliased constant String := """AddressLine2""";
   N_Addressline2 : constant Cst_String_Access := NC_AddressLine2'Access;
   NC_Brand : aliased constant String := """Brand""";
   N_Brand : constant Cst_String_Access := NC_Brand'Access;
   NC_Colour : aliased constant String := """Colour""";
   N_Colour : constant Cst_String_Access := NC_Colour'Access;
   NC_Country : aliased constant String := """Country""";
   N_Country : constant Cst_String_Access := NC_Country'Access;
   NC_Description : aliased constant String := """Description""";
   N_Description : constant Cst_String_Access := NC_Description'Access;
   NC_Detformat : aliased constant String := """DetFormat""";
   N_Detformat : constant Cst_String_Access := NC_DetFormat'Access;
   NC_Details : aliased constant String := """Details""";
   N_Details : constant Cst_String_Access := NC_Details'Access;
   NC_Event : aliased constant String := """Event""";
   N_Event : constant Cst_String_Access := NC_Event'Access;
   NC_Eventdate : aliased constant String := """EventDate""";
   N_Eventdate : constant Cst_String_Access := NC_EventDate'Access;
   NC_Filename : aliased constant String := """Filename""";
   N_Filename : constant Cst_String_Access := NC_Filename'Access;
   NC_Floatie : aliased constant String := """Floatie""";
   N_Floatie : constant Cst_String_Access := NC_Floatie'Access;
   NC_Floaties : aliased constant String := """Floaties""";
   N_Floaties : constant Cst_String_Access := NC_Floaties'Access;
   NC_Hasgraph : aliased constant String := """HasGraph""";
   N_Hasgraph : constant Cst_String_Access := NC_HasGraph'Access;
   NC_Hold : aliased constant String := """Hold""";
   N_Hold : constant Cst_String_Access := NC_Hold'Access;
   NC_Id : aliased constant String := """ID""";
   N_Id : constant Cst_String_Access := NC_ID'Access;
   NC_Identifier : aliased constant String := """Identifier""";
   N_Identifier : constant Cst_String_Access := NC_Identifier'Access;
   NC_Latex : aliased constant String := """LaTex""";
   N_Latex : constant Cst_String_Access := NC_LaTex'Access;
   NC_Leakage : aliased constant String := """Leakage""";
   N_Leakage : constant Cst_String_Access := NC_Leakage'Access;
   NC_Name : aliased constant String := """Name""";
   N_Name : constant Cst_String_Access := NC_Name'Access;
   NC_No2 : aliased constant String := """No2""";
   N_No2 : constant Cst_String_Access := NC_No2'Access;
   NC_Notes : aliased constant String := """Notes""";
   N_Notes : constant Cst_String_Access := NC_Notes'Access;
   NC_Padtype : aliased constant String := """PadType""";
   N_Padtype : constant Cst_String_Access := NC_PadType'Access;
   NC_Padvolume : aliased constant String := """PadVolume""";
   N_Padvolume : constant Cst_String_Access := NC_PadVolume'Access;
   NC_Patient : aliased constant String := """Patient""";
   N_Patient : constant Cst_String_Access := NC_Patient'Access;
   NC_Priceperpack : aliased constant String := """PricePerPack""";
   N_Priceperpack : constant Cst_String_Access := NC_PricePerPack'Access;
   NC_Q_Number : aliased constant String := """Q_Number""";
   N_Q_Number : constant Cst_String_Access := NC_Q_Number'Access;
   NC_Qtyperpack : aliased constant String := """QtyPerPack""";
   N_Qtyperpack : constant Cst_String_Access := NC_QtyPerPack'Access;
   NC_R : aliased constant String := """R""";
   N_R : constant Cst_String_Access := NC_R'Access;
   NC_Referraldate : aliased constant String := """ReferralDate""";
   N_Referraldate : constant Cst_String_Access := NC_ReferralDate'Access;
   NC_Sql : aliased constant String := """SQL""";
   N_Sql : constant Cst_String_Access := NC_SQL'Access;
   NC_Size : aliased constant String := """Size""";
   N_Size : constant Cst_String_Access := NC_Size'Access;
   NC_Spasm : aliased constant String := """Spasm""";
   N_Spasm : constant Cst_String_Access := NC_Spasm'Access;
   NC_Spasmcount : aliased constant String := """SpasmCount""";
   N_Spasmcount : constant Cst_String_Access := NC_SpasmCount'Access;
   NC_State : aliased constant String := """State""";
   N_State : constant Cst_String_Access := NC_State'Access;
   NC_Targettbl : aliased constant String := """TargetTbl""";
   N_Targettbl : constant Cst_String_Access := NC_TargetTbl'Access;
   NC_Town : aliased constant String := """Town""";
   N_Town : constant Cst_String_Access := NC_Town'Access;
   NC_Udate : aliased constant String := """UDate""";
   N_Udate : constant Cst_String_Access := NC_UDate'Access;
   NC_Utime : aliased constant String := """UTime""";
   N_Utime : constant Cst_String_Access := NC_UTime'Access;
   NC_Urges : aliased constant String := """Urges""";
   N_Urges : constant Cst_String_Access := NC_Urges'Access;
NC_Image : aliased constant String := """Image""";
N_Image : constant Cst_String_Access := NC_Image'Access;
   NC_Value : aliased constant String := """Value""";
   N_Value : constant Cst_String_Access := NC_Value'Access;
   NC_Volume : aliased constant String := """Volume""";
   N_Volume : constant Cst_String_Access := NC_Volume'Access;
end database_Names;
