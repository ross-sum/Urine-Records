#!/bin/sh
# This script creates the Sqlite database, executing the DDL script
#
# Create the database:
# we could run this from a data definition list file viz:
#   sqlite3 urine_records.db < database_schema.ddl
# but we have already set up gnatcoll_db2ada
gnatcoll_sqlite2ada -dbtype=sqlite -createdb -dbmodel=database_schema.dbmodel -dbname=urine_records.db

# Set up the blob fields to load.  Requires tobase64 to be on the search path.
tobase64 -i 1.png -o 1.b64
tobase64 -i 2.png -o 2.b64
tobase64 -i 3.png -o 3.b64
tobase64 -i 4.png -o 4.b64
tobase64 -i 5.png -o 5.b64
tobase64 -i 6.png -o 6.b64
tobase64 -i 7.png -o 7.b64
tobase64 -i 8.png -o 8.b64
tobase64 -i 9.png -o 9.b64
tobase64 -i 10.png -o 10.b64
tobase64 -i 11.png -o 11.b64
tobase64 -i 12.png -o 12.b64
tobase64 -i 13.png -o 13.b64
tobase64 -i 14.png -o 14.b64
tobase64 -i 15.png -o 15.b64
tobase64 -i 16.png -o 16.b64
tobase64 -i ../src/urine_records.png -o urine_records.b64
tobase64 -i ../src/toilet_action.jpeg -o toilet_action.b64

# Load up the default data:
/usr/local/bin/sqlite3 urine_records.db < default_data.sql
sqlite3 urine_records.db < default_reports.sql

# Clean up the base 64 fields after their being used
rm *.b64

# Create the Ada packages for the database (database.ads, database.adb...)
gnatcoll_sqlite2ada -dbtype=sqlite -api database -dbmodel=database_schema.dbmodel
# Add in dependency for GNATCOLL.SQL_Date_and_Time and GNATCOLL.SQL_Blob in
# with clauses at top of database.ads:
sed  -i '2i with GNATCOLL.SQL_Date_and_Time; use  GNATCOLL.SQL_Date_and_Time;' database.ads
sed  -i '2i with GNATCOLL.SQL_BLOB; use  GNATCOLL.SQL_BLOB;' database.ads
# In database.ads, Convert SQL_Field_Date to SQL_Field_tDate and convert
# SQL_Field_Time to SQL_Field_tTime.
sed -i 's/SQL_Field_Date/SQL_Field_tDate/g' database.ads
sed -i 's/SQL_Field_Time/SQL_Field_tTime/g' database.ads
# In database_names.ads, add in NC_Image and N_Image just before end of package
sed -i '115i   NC_Image : aliased constant String := """Image""";' database_names.ads
sed -i '116i   N_Image : constant Cst_String_Access := NC_Image'"'"'Access;' database_names.ads
# In database.ads, add in Image : SQL_Field_Blob at row 94.
sed -i '94i     Image : SQL_Field_Blob (Ta_Colourchart, Instance, N_Image, Index);' database.ads
#
# and move the Ada pacages to ../src
mv database.ad? ../src/
mv database_names.ads ../src/

