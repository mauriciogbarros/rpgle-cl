        DCL-F SHIFTWEEK USAGE(*INPUT) KEYED RENAME(SHIFTWEEK:SHIFTWEEKR);
        DCL-F SHIFTRATES DISK RENAME(SHIFTRATES:SHIFTRATER);
        DCL-F PAYSUMMARY WORKSTN;
        DCL-F PAYRPT PRINTER OFLIND(*IN01);
        DCL-S HOURSOVER PACKED(3);

        READ SHIFTRATES;
        *IN01 = *ON;
        READ SHIFTWEEK;
        DOW NOT %EOF;
          EXSR PAYSR;
          IF *IN01 = *ON;
            WRITE TITLE;
            WRITE COLHDG;
            *IN01 = *OFF;
          ENDIF;
          WRITE EMPDETAIL;
          READ SHIFTWEEK;
        ENDDO;

        TOTWKPAY = TOTREGPAY + TOTOVTPAY;
        WRITE TOTALS;
        EXFMT RECORD1;
        *INLR = *ON;

        BEGSR PAYSR;
          SELECT;
            WHEN WORKSHIFT = 'D';
              HOURLYRATE = DAYHRS;
            WHEN WORKSHIFT = 'N';
              HOURLYRATE = NIGHTHRS;
            WHEN WORKSHIFT = 'A';
              HOURLYRATE = AFTHRS;
          ENDSL;
          SELECT;
            WHEN PAYCLASS = 1;
              HOURLYRATE = HOURLYRATE * 1.093;
            WHEN PAYCLASS = 2;
              HOURLYRATE = HOURLYRATE * 1.065;
            WHEN PAYCLASS = 3;
              HOURLYRATE = HOURLYRATE * (1 - 0.047);
          ENDSL;

          IF HRSWORKED > 40;
            HOURSOVER = HRSWORKED - 40;
            REGULARPAY = 40 * HOURLYRATE;
            OVERPAY = HOURSOVER * HOURLYRATE * 1.5;
          ELSE;
            HOURSOVER = 0;
            REGULARPAY = HRSWORKED * HOURLYRATE;
            OVERPAY = 0;
          ENDIF;

          WEEKLYPAY = REGULARPAY + OVERPAY;
          TOTREGPAY = TOTREGPAY + REGULARPAY;
          TOTOVTPAY = TOTOVTPAY + OVERPAY;
        ENDSR; 