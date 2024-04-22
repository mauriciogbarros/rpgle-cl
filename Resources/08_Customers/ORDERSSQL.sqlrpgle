       //******************************************************************
       //* THIS PROGRAM USES A CURSOR TO LOAD A TEMPORARY RESULT TABLE
       //* FROM 3 SEPARATE TABLES: CUSTOMER2, ORDER1 AND ORDERLINE.
       //* A NUMBER IS PASSED TO THE PROGRAM TO DETERMINE WHICH LINE
       //* RECORDS ARE INCLUDED.
       //*****************************************************************

       DCL-F CUSTREPORT      PRINTER OFLIND(*IN01);
       DCL-S ORDERNUMH       PACKED(5:0);
       DCL-S NUMORDERS       PACKED(3:0);

       // Declare an indicator to handle end of result set (file)
       DCL-S ENDOFFILE       IND;

       // All host variables available under a single name
       DCL-DS ORDERSRECORD;
         CUSTNAME            CHAR(31);
         ORDERNUM            PACKED(5:0);
         ORDERDATE           DATE;
         PARTNUM             CHAR(4);
         QUANTITY            PACKED(3:0);
         QTPRICE             PACKED(6:2);
         EXTPRICE            PACKED(7:2);
       END-DS;

       // LIMITIN is passed to the program
       DCL-PI MAIN EXTPGM('ORDERSSQL');
         LIMITIN PACKED(15:5);
       END-PI;

       // Main routine
       SPENDLIMIT = LIMITIN;

       EXSR PREPAREFILES;
       WRITE REPORTITLE;
       WRITE COLHEADING;

       EXSR GETROW;
       IF NOT ENDOFFILE;
         WRITE NEXTCUST;
         ORDERNUMH = ORDERNUM;
       ENDIF;

       DOW NOT ENDOFFILE;
         IF *IN01 = *ON;
           WRITE REPORTITLE;
           WRITE COLHEADING;
           *IN01 = *OFF;
         ENDIF;

         // Handle control breaks on order number
         IF ORDERNUMH = ORDERNUM;
           WRITE ORDDETAIL;
         ELSE;
           ORDERNUMH = ORDERNUM;
           WRITE ORDTOTAL;
           TOTALALL = TOTALALL + TOTALORD;
           TOTALORD = 0;
           WRITE NEXTCUST;
           WRITE ORDDETAIL;
         ENDIF;

         TOTALORD = TOTALORD + EXTPRICE;
         EXSR GETROW;
       ENDDO;
       WRITE ORDTOTAL;

       TOTALALL = TOTALALL + TOTALORD;
       WRITE ALLORDERS;

       EXSR WRAPUP;

       EXEC SQL
         SELECT COUNT(*)
           INTO NUMORDERS
         FROM BCI433LIB/ORDERLINE;
       WRITE NOTINCLUDE;

       *INLR = *ON;
       RETURN;

       //*****************************************************************
       //* PREPARE FILES SUBROUTINE
       //*****************************************************************
       BEGSR PREPAREFILES;
         // Set up the temporary result structure
         EXEC SQL
           DECLARE ORDERSCURSOR CURSOR
           FOR
           SELECT
             TRIM(FIRST_NAME) || ' ' || LAST_NAME AS CUST_NAME,
             O.ORDER_NUMBER,
             ORDER_DATE,
             PART_NUMBER,
             NUMBER_ORDERED,
             QUOTED_PRICE,
             NUMBER_ORDERED * QUOTED_PRICE
           FROM
             BCI433LIB/CUSTOMER2 C,
             BCI433LIB/ORDER1 O,
             BCI433LIB/ORDERLINE OL
           WHERE
             O.ORDER_NUMBER = OL.ORDER_NUMBER AND
             C.CUSTOMER_NUMBER = O.CUSTOMER_NUMBER AND
             NUMBER_ORDERED * QUOTED_PRICE > 0;

         // Create the temporary table
         EXEC SQL
           OPEN ORDERSCURSOR;

         IF SQLCODE <> 0 OR SQLWN0 = 'W';
           ENDOFFILE = *ON;
         ENDIF;

       ENDSR;

       //*****************************************************************
       //* GET ROW SUBROUTINE
       //*****************************************************************
       BEGSR GETROW;
         EXEC SQL
           FETCH NEXT
             INTO ORDERSRECORD;

         IF SQLCODE <> 0 OR SQLWN0 = 'W';
           ENDOFFILE = *ON;
         ENDIF;

       ENDSR;

       //*****************************************************************
       //* WRAPUP SUBROUTINE
       //*****************************************************************
       BEGSR WRAPUP;
         EXEC SQL
           CLOSE ORDERSCURSOR;

         IF SQLCODE <> 0 OR SQLWN0 = 'W';
           DSPLY 'PROBLEM CLOSING CURSOR';
         ENDIF;
       ENDSR; 