       DCL-F SQLDSP WORKSTN;

       DCL-S  ShipCityNull BinDec (4:0);
       DCL-S  DiscountNull BinDec (4:0);

       EXFMT RECORD1;
       DOW NOT (*IN03);

        EXEC SQL
         SELECT  CUSTID,
                 NAME,
                 SHIPCITY,
                 DISCOUNT
         INTO    :CUSTID,
                 :NAME,
                 :SHIPCITY :SHIPCITYNULL,
                 :DISCOUNT :DISCOUNTNULL
         FROM    BCI433LIB/CUSTOMER
         WHERE   CUSTID = :CustIDin;

         If ShipCityNull = -1;
           ShipCity = 'Unknown';
         EndIf;

        If DiscountNull = -1;
           *in99 = *on;
         Else;
           *in99 = *off;
         EndIf;
         Write Record1;
         EXFMT Record2;
         If *IN03 = *OFF;
           EXFMT Record1;
         ENDIF;
        ENDDO;
        *INLR = *ON;
        Return; 