         DCL-F CARPAYDSP WORKSTN;
         DCL-S MRATE PACKED(7:7);

         EXSR RESET;
         EXFMT PURCHREC;
         DOW *IN03 = *OFF;
           // Check if AUTOPRICE is missing
           IF AUTOPRICE <= 0;
             *IN80 = *ON;
             EXFMT PURCHREC;
             *IN80 = *OFF;
             ITER;
           // Check if RUSTPROTOP is missing
           ELSEIF RUSTPROTOP = ' ';
             *IN81 = *ON;
             EXFMT PURCHREC;
             *IN81 = *OFF;
             ITER;
           // Else, do the calculations
           ELSE;
             EXSR ADJUSTRATE;
             EXSR GETPAYMENT;
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
           RUSTPROT = 0;
           TRADEIN = 0;
           REBATE = 0;
           DPAYMENT = 0;
           RATE = 4.5;
           TERM = 60;
           SUBTOTAL = 0;
           HST = 0;
           TOTALOWED = 0;
           MONEYOFF = 0;
           PRINCIPAL = 0;
           PAYMENT = 0;
           TOTALINT = 0;
           TOTALWLOAN = 0;
         ENDSR;

         BEGSR GETPAYMENT;
           IF RUSTPROTOP = 'Y';
             EVAL RUSTPROT = AUTOPRICE * 0.018;
           ELSE;
             RUSTPROT = 0;
           ENDIF;
           EVAL SUBTOTAL = AUTOPRICE + FREIGHT + ROADREADY + RUSTPROT;
           EVAL HST = SUBTOTAL * 0.13;
           EVAL TOTALOWED = SUBTOTAL + HST;
           EVAL MONEYOFF = TRADEIN + REBATE + DPAYMENT;
           EVAL PRINCIPAL = TOTALOWED - MONEYOFF;
           IF TERM >= 1;
             EVAL MRATE = RATE/(100 * 12);
             EVAL(H) PAYMENT = (PRINCIPAL * MRATE)/(1 - (1 + MRATE)**-TERM);
           ELSE;
             PAYMENT = 0;
           ENDIF;
           EVAL TOTALINT = TERM * PAYMENT - PRINCIPAL;
           EVAL TOTALWLOAN = PRINCIPAL + TOTALINT;
         ENDSR;

         BEGSR ADJUSTRATE;
           SELECT;
             WHEN TERM >= 81;
               RATE = 99.99;
             WHEN TERM >= 73;
               EVAL RATE += 1.3;
              WHEN TERM >= 61;
                EVAL RATE += 0.65;
               WHEN TERM >= 49;
                EVAL RATE += 0;
               WHEN TERM >= 37;
                 EVAL RATE -= 0.6;
               WHEN TERM >= 1;
                 EVAL RATE -= 0.77;
           ENDSL;
           // Refressh PURCHREC screen
           EXFMT PURCHREC;
         ENDSR; 