         DCL-F UPDREPORT  PRINTER OflInd(*IN01);

         DCL-F SALESTRANS DISK(*EXT) KEYED USAGE(*INPUT)
               RENAME(SALESTRANS:SALESTRANR);

         DCL-F SALESSTAF2 DISK(*EXT) KEYED
               USAGE(*UPDATE : *OUTPUT : *DELETE);

         DCL-DS FullKey ;
               ADept    CHAR(3);
               ASalesId CHAR(4);
         END-DS FullKey;

         DCL-DS SalesTransDS;
               TDept;
               TSalesId;
               TFName;
               TLName;
               TCity;
               TAddress;
               TPCode;
         End-Ds SalesTransDs;

         DCL-DS SalesStaf2DS;
               Dept;
               SalesId;
               FName;
               LName;
               City;
               Address;
               PCode;
         End-Ds SalesStaf2Ds;

         WRITE HEADING;
         READ SALESTRANS;

         DOW NOT %EOF;
           FULLKEY = TDEPT + TSALESID;
           CHAIN %KDS(FULLKEY) SALESSTAF2;

           SELECT;
             WHEN %FOUND(SALESSTAF2);
               SELECT;
                 WHEN TCODE = 'C';
                   EXSR CHGREC;
                 WHEN TCODE = 'D';
                   EXSR DELREC;
                 OTHER;
                   EXSR ERROR;
               ENDSL;
             WHEN NOT %FOUND(SALESSTAF2);
               IF TCODE = 'A';
                 EXSR ADDREC;
               ELSE;
                 EXSR ERROR;
               ENDIF;
             WHEN %ERROR;
               EXSR ERROR;
           ENDSL;

           IF *IN01 = *ON;
             WRITE HEADING;
             *IN01 = *OFF;
           ENDIF;

           WRITE DETAIL;
           READ SALESTRANS;
         ENDDO;
         *INLR = *ON;

         RETURN;

         BEGSR ADDREC;
           SALESSTAF2DS = SALESTRANSDS;
           PHONE = %DEC(TPHONE:10:0);
           WRITE SALESTFR;
         ENDSR;

         BEGSR CHGREC;
           SALESSTAF2DS = SALESTRANSDS;
           PHONE = %DEC(TPHONE:10:0);
           UPDATE SALESTFR;
         ENDSR;

         BEGSR DELREC;
           DELETE SALESTFR;
         ENDSR;

         BEGSR ERROR;
           TFNAME = 'UPDATE/DELETE/CHANGE';
           TLNAME = 'E R R O R';
         ENDSR; 