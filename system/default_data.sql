INSERT INTO PadSizes VALUES (1,"Nappy",64,"Depend Real Fit for Men underwear large nappies (Tena For Men are 68g)",8,13.00);
INSERT INTO PadSizes VALUES (2,"Sana Super Extra",32,"Aldi Sana Super Extra Large",10,0);
INSERT INTO PadSizes VALUES (3,"Sana Extra", 28, "Aldi Sana Extra Pad",12,3.39);
INSERT INTO PadSizes VALUES (4,"Poise Extra", 30, "Poise Extra Plus Pads with the skinnier centre, so you piss out the side (value pk)",12,4.99);
INSERT INTO PadSizes VALUES (5,"Tena Extra", 24, "Tena Pads in Extra long length size",20,6.93);
INSERT INTO PadSizes VALUES (6,"Tena Maxi", 46, "Tena Maxi Night ‘over-night’ extra wide and extra long pads",14,6.95);
INSERT INTO PadSizes VALUES (7,"Libra Maternity",8,"Libra Maternity extra long pads with wings",10,2.71);
INSERT INTO PadSizes VALUES (8,"Stayfree Super",8,"Heavy volume with wings",18,4.49);
INSERT INTO PadSizes VALUES (9,"Menguards",26,"Depend Men guards pads for men (wide top of pad",20,12.99);
INSERT INTO PadSizes VALUES (10,"Sana Normal",16,"Aldi Sana Normal Pad",14,3.39);
INSERT INTO PadSizes VALUES (11,"Poise Regular",22,"Poise regular pads for bladder leakage, also with the skinnier centre",12,6.99);
INSERT INTO CatheterLeakage VALUES ("New Pad",-1,"No substantial leakage – pad changed for cleanliness");
INSERT INTO CatheterLeakage VALUES ("None",0,"No leakage around the outside of the catheter");
INSERT INTO CatheterLeakage VALUES ("Small",1,"Wets a tissue paper at the ouside of the catheter");
INSERT INTO CatheterLeakage VALUES ("Medium",2,"Wets into layered tissue paper under the penis");
INSERT INTO CatheterLeakage VALUES ("Large",3,"Wets through tissue paper and wets the pad");
INSERT INTO CatheterLeakage VALUES ("Pad change",4,"Pad so drenched that it needs changing");
INSERT INTO CatheterLeakage VALUES ("Urinate",5,"Bladder full, urinated, but pad not so wet");
INSERT INTO CatheterLeakage VALUES ("Urinate&PC",6,"Bladder full, urinated, and pad needs changing");
INSERT INTO Leakage VALUES ("None",0,"No detectable leakage");
INSERT INTO Leakage VALUES ("Some",1,"Some leakage detectable, but not enough to change pads");
INSERT INTO Leakage VALUES ("Pad change",2,"Just need to change pad");
INSERT INTO Leakage VALUES ("Pad&Clean",3,"Pad change and, for freshness, nappy change");
INSERT INTO Leakage VALUES ("Pad &Nappy",4,"Pad change and nappy change as both full");
INSERT INTO ColourChart VALUES (570,"Blonde");
INSERT INTO ColourChart VALUES (573,"Yellow");
INSERT INTO ColourChart VALUES (575,"Daffodil");
INSERT INTO ColourChart VALUES (580,"Lemon");
INSERT INTO ColourChart VALUES (585,"Butter");
INSERT INTO ColourChart VALUES (590,"Pineapple");
INSERT INTO ColourChart VALUES (595,"Bumblebee");
INSERT INTO ColourChart VALUES (600,"Tuscan sun");
INSERT INTO ColourChart VALUES (605,"Mustard");
INSERT INTO ColourChart VALUES (610,"Gold");
INSERT INTO ColourChart VALUES (615,"Apricot");
INSERT INTO ColourChart VALUES (620,"Orange");
INSERT INTO ColourChart VALUES (625,"Squash");
INSERT INTO ColourChart VALUES (630,"Tiger");
INSERT INTO ColourChart VALUES (635,"Yam");
INSERT INTO ColourChart VALUES (640,"Fire");
INSERT INTO Floaties VALUES ("None",0,"No floaties in urine");
INSERT INTO Floaties VALUES ("Small",1,"Small white floaties in urine");
INSERT INTO Floaties VALUES ("Medium",2,"In addition to above, some small tissue components");
INSERT INTO Floaties VALUES ("Large",3,"Large tissue components in urine");
INSERT INTO Floaties VALUES ("Blood clots",4,"Blood clots material in urine");
INSERT INTO HoldStates VALUES (0,"-");
INSERT INTO HoldStates VALUES (1,"Fail");
INSERT INTO HoldStates VALUES (2,"Partial");
INSERT INTO HoldStates VALUES (3,"Okay");
INSERT INTO Spasms VALUES (0,"None");
INSERT INTO Spasms VALUES (1,"Minor");
INSERT INTO Spasms VALUES (2,"Underwear overflow");
INSERT INTO Spasms VALUES (3,"Trousers+ overflow");
ALTER TABLE ColourChart ADD COLUMN Image blob;
.load ./fileio.so
UPDATE ColourChart SET Image=readfile('1.b64') WHERE Value=570;
UPDATE ColourChart SET Image=readfile('2.b64') WHERE Value=573;
UPDATE ColourChart SET Image=readfile('3.b64') WHERE Value=575;
UPDATE ColourChart SET Image=readfile('4.b64') WHERE Value=580;
UPDATE ColourChart SET Image=readfile('5.b64') WHERE Value=585;
UPDATE ColourChart SET Image=readfile('6.b64') WHERE Value=590;
UPDATE ColourChart SET Image=readfile('7.b64') WHERE Value=595;
UPDATE ColourChart SET Image=readfile('8.b64') WHERE Value=600;
UPDATE ColourChart SET Image=readfile('9.b64') WHERE Value=605;
UPDATE ColourChart SET Image=readfile('10.b64') WHERE Value=610;
UPDATE ColourChart SET Image=readfile('11.b64') WHERE Value=615;
UPDATE ColourChart SET Image=readfile('12.b64') WHERE Value=620;
UPDATE ColourChart SET Image=readfile('13.b64') WHERE Value=625;
UPDATE ColourChart SET Image=readfile('14.b64') WHERE Value=630;
UPDATE ColourChart SET Image=readfile('15.b64') WHERE Value=635;
UPDATE ColourChart SET Image=readfile('16.b64') WHERE Value=640;
INSERT INTO Configurations VALUES(1,"urine_records.glade",'T',"");
INSERT INTO Configurations VALUES(2,"urine_records.png",'B',"");
INSERT INTO Configurations VALUES(3,"toilet_action.jpeg",'B',"");
UPDATE Configurations SET Details=readfile('../src/urine_records.glade') WHERE ID=1;
UPDATE Configurations SET Details=readfile('urine_records.b64') WHERE ID=2;
UPDATE Configurations SET Details=readfile('toilet_action.b64') WHERE ID=3;

