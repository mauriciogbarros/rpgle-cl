       // ********************************************************************
       //  CUSTOMER23 READ BY NATIVE LANGUAGE (ILE RPG)
       //  CONTACTS23 ROW RETRIEVED WITH EMBEDDED SQL
       //  DETAIL REPORT LINE INCLUDES INFORMATION FROM CUSTOMER23 AND
       //  CONTACTS23
       //  SUMMARY REPORT INFORMATION RETRIEVED WITH EMBEDDED SQL STATEMENTS

           DCL-F PHNREPORT  PRINTER OFLIND(*IN01) ;
           DCL-F CUSTOMER23 DISK(*EXT) KEYED USAGE(*INPUT)
                 RENAME(CUSTOMER23:CUSTR);
       // data structure for host variables from CONTACTS23
           DCL-DS CONTACTS23 EXT END-DS;

       // Standalone fields for indicator variables
           DCL-S INDLDCALLED BINDEC(4:0);
           DCL-S INDNEXTCDATE BINDEC(4:0);

           DCL-S Dummy  Zoned(1);                                         // ***********************
       //  CUSTOMER23 READ BY NATIVE LANGUAGE (ILE RPG)
       //  CONTACTS23 ROW RETRIEVED WITH EMBEDDED SQL
       //  DETAIL REPORT LINE INCLUDES INFORMATION FROM CUSTOMER23 AND
       //  CONTACTS23
       //  SUMMARY REPORT INFORMATION RETRIEVED WITH EMBEDDED SQL STATEMENTS

           DCL-F PHNREPORT  PRINTER OFLIND(*IN01) ;
           DCL-F CUSTOMER23 DISK(*EXT) KEYED USAGE(*INPUT)
                 RENAME(CUSTOMER23:CUSTR);
       //  data structure for host variables from CONTACTS23
           DCL-DS CONTACTS23 EXT END-DS;

       // Standalone fields for indicator variables
           DCL-S INDLDCALLED BINDEC(4:0);
           DCL-S INDNEXTCDATE BINDEC(4:0);

           DCL-S Dummy  Zoned(1);
        //**********************************************************************
        //*                        ***   M A I N   R O U T I N E   ***
        //**********************************************************************
           EXSR SummaryInfo;
           WRITE NEWPAGE;
           READ CUSTOMER23;
           DOW NOT %EOF;
               EXSR SQLSelect;
               IF *IN01 = *ON;
                  Write NEWPAGE;
                  *IN01 = *OFF;
               ENDIF;
               Write RPTLINE;
              READ CUSTOMER23;
           ENDDO;
           Write SUMMARY;
           *INLR = *ON;
           RETURN;
       //**********************************************************************
        //   S Q L S E L E C T   S U B R O U T I N E
        //********************************************************************
                       BEGSR    SQLSelect ;
         // A row from the Contacts table that has the same customer number as t
         // record read from the CUSTOMER23 file is retrieved to find out the la
         // called, phone number, comments and the salesperson number.

         //  The call back interval is added to the last date called to determin
         //  next date to call.  Since null values may be stored in the last dat
         // called indicator variables are used.
           ErrorMsg = ' ';




           ENDSR ;
        //**********************************************************************
        // S U M M A R Y I N F O   S U B R O U T I N E
        //**********************************************************************
           BEGSR  SummaryInfo;

        //  D E T E R M I N E   T O T A L S   F O R   CONTACTS23 & CUSTOMER23
           EXEC SQL
             SELECT COUNT(*) INTO :CONTACTT
               FROM BCI433LIB/CONTACTS23;
           IF(SQLCODE <> 0) OR (SQLWN0 = 'W');
             CONTACTT = -99999;
           ENDIF;

           EXEC SQL
             SELECT COUNT(*) INTO :CUSTOMERT
               FROM BCI433LIB/CUSTOMER23;
           IF(SQLCODE <> 0) OR (SQLWN0 = 'W');
             CUSTOMERT = -99999;
           ENDIF;

        // D E T E R M I N E   N U M B E R   O F   U N K N O W N   LAST DATE CAL
         EXEC SQL
           SELECT COUNT(*) INTO :UNKNOWNT
           FROM CONTACTS23
           WHERE LDCALLED IS NULL;
         IF (SQLCODE <> 0) OR (SQLWN0 = 'W');
           UNKNOWNT = -99999;
         ENDIF;


        //  D E T E R M I N E   O L D E S T   &  M O S T   R E C E N T  LAST DAT
        // Use Max, Min



       // D E T E R M I N E   T H E   U S E R   S E R V E R   &   T I M E S T A
       // SYSIBM/SYSDUMMY1 from System registers,Don't need check SQLCODE
          EXEC SQL
            SELECT USER, CURRENT TIMESTAMP, CURRENT SERVER
              INTO :USER, :TIMESTAMP, :SERVER
            FROMSYSIBM/SYSDUMMY1;



       ENDSR;
        //**********************************************************************
        //*                        ***   M A I N   R O U T I N E   ***
        //**********************************************************************

           EXSR SummaryInfo;
           WRITE NEWPAGE;
           READ CUSTOMER23;
           DOW NOT %EOF;
               EXSR SQLSelect;
               IF *IN01 = *ON;
                  Write NEWPAGE;
                  *IN01 = *OFF;
               ENDIF;
               Write RPTLINE;
              READ CUSTOMER23;
           ENDDO;
           Write SUMMARY;
           *INLR = *ON;
           RETURN;
       //**********************************************************************
        //   S Q L S E L E C T   S U B R O U T I N E
        //********************************************************************
                       BEGSR    SQLSelect ;
         // A row from the Contacts table that has the same customer number as t
         // record read from the CUSTOMER23 file is retrieved to find out the la
         // called, phone number, comments and the salesperson number.

         //  The call back interval is added to the last date called to determin
         //  next date to call.  Since null values may be stored in the last dat
         // called indicator variables are used.
           ErrorMsg = ' ';
           EXEC SQL
             SELECT LDCALLED + CALLBINT DAYS,
               LDCALLED,
               PHONE,
               SLSNUMBER
             INTO :NEXTCDATE :INDNEXTCDATE,
               :LDCALLED :INDLDCALLED,
               :PHONE,
               :SLSNUMBER
             FROM BCI433LIB/CONTACTS23
             WHERE CUSTNUMBER = :CSTNUM;

           SELECT;
             WHEN SQLSTATE = '00000';
               DUMMY = 0;
             WHEN SQLSTATE = '02000';
               ERRORMSG = 'MATCH NOT FOUND';
               PHONE = 9999999999;
               NEXTCDATE = D'9999-09-09';
               LDCALLED = D'9999-09-09';
               SLSNUMBER = -999;
             WHEN %SUBST(SQLSTATE:1:2) = '01';
               ERRORMSG = 'WARNING OCCURED';
               PHONE = 9999999999;
               NEXTCDATE = D'9999-09-09';
               LDCALLED = D'9999-09-09';
               SLSNUMBER = -999;
             OTHER;
               ERRORMSG = 'ERROR OCCURED';
               PHONE = 9999999999;
               NEXTCDATE = D'9999-09-09';
               LDCALLED = D'9999-09-09';
               SLSNUMBER = -999;
           ENDSL;

           IF INDLDCALLED = -1;
             ERRORMSG = 'UKNOWN DATE';
             NEXTCDATE = D'9999-09-09';
             LDCALLED = D'9999-09-09';
           ENDIF;


           ENDSR ;
        //**********************************************************************
        // S U M M A R Y I N F O   S U B R O U T I N E
        //**********************************************************************
           BEGSR  SummaryInfo;

        //  D E T E R M I N E   T O T A L S   F O R   CONTACTS23 & CUSTOMER23










        // D E T E R M I N E   N U M B E R   O F   U N K N O W N   LAST DATE CAL










        //  D E T E R M I N E   O L D E S T   &  M O S T   R E C E N T  LAST DAT












       // D E T E R M I N E   T H E   U S E R   S E R V E R   &   T I M E S T A
       // SYSIBM/SYSDUMMY1 from System registers,Don't need check SQLCODE






       ENDSR; 