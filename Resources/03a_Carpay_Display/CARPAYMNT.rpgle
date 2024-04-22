         DCL-F CARPAYDSP WORKSTN;

         EXSR RESET;
         EXFMT PURCHREC;
         DOW *IN03 = *OFF;
           IF AUTOPRICE <= 0;
             *IN80 = *ON;
             EXFMT PURCHREC;
             *IN80 = *OFF;
             ITER;
           ELSEIF RUSTPROTOP = ' ';
             *IN81 = *ON;
             EXFMT PURCHREC;
             *IN81 = *OFF;
             ITER;
           // ELSE;
           //   ...;
           //   ...;
           ENDIF;
         // Protect first screen record fields
         // Redisplay first screen record and then overlay second record
           EXSR GETPAYMENT;
           *IN55 = *ON;
           WRITE PURCHREC;
           EXFMT LOANREC;
           *IN55 = *OFF;
           IF *IN03 = *OFF;
             EXSR RESET;
             EXFMT PURCHREC;
           ENDIF;
         ENDDO;
         *INLR = *ON;
         RETURN;

         BEGSR RESET;
           AUTOPRICE = 0;
           FREIGHT = 1300;
           ROADREADY = 675.89;
           RUSTPROTOP = ' ';
           RUSTPROT = 999;
           TRADEIN = 0;
           REBATE = 0;
           DPAYMENT = 0;
           TERM = 60;
         ENDSR;

         BEGSR GETPAYMENT;
           SUBTOTAL = 999;
           HST = 999;
           TOTALOWED = 999;
           MONEYOFF = 999;
           PRINCIPAL = 999;
           PAYMENT = 999;
         ENDSR; 