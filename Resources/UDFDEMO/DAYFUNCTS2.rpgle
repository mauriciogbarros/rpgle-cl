


       Ctl-Opt NoMain DatFmt(*USA) ;

        /COPY UDFDEMO,DAYPROTO

       Dcl-Proc DayNumName  EXPORT;

         Dcl-Pi *n  Char(9);
           Number Packed(1:0);
         End-Pi;

         Dcl-DS DayData;
           *n Char(9) Inz('Monday');
           *n Char(9) Inz('Tuesday');
           *n Char(9) Inz('Wednesday');
           *n Char(9) Inz('Thursday');
           *n Char(9) Inz('Friday');
           *n Char(9) Inz('Saturday');
           *n Char(9) Inz('Sunday');

           DayArray Char(9) Dim(7) POS(1);
         End-DS;

         Return DayArray(Number);

       End-Proc;
 