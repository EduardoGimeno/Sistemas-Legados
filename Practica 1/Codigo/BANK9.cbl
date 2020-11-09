       IDENTIFICATION DIVISION.
       PROGRAM-ID. BANK9.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SPECIAL-NAMES.
           CRT STATUS IS KEYBOARD-STATUS.

       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT TARJETAS ASSIGN TO DISK
           ORGANIZATION IS INDEXED
           ACCESS MODE IS DYNAMIC
           RECORD KEY IS TNUM-E
           FILE STATUS IS FST.

           SELECT INTENTOS ASSIGN TO DISK
           ORGANIZATION IS INDEXED
           ACCESS MODE IS DYNAMIC
           RECORD KEY IS INUM
           FILE STATUS IS FSI.

       DATA DIVISION.
       FILE SECTION.
       FD TARJETAS
           LABEL RECORD STANDARD
           VALUE OF FILE-ID IS "tarjetas.ubd".
       01 TARJETAREG.
           02 TNUM-E    PIC 9(16).
           02 TPIN-E    PIC  9(4).

       FD INTENTOS
           LABEL RECORD STANDARD
           VALUE OF FILE-ID IS "intentos.ubd".
       01 INTENTOSREG.
           02 INUM      PIC 9(16).
           02 IINTENTOS PIC 9(1).

       WORKING-STORAGE SECTION.
       77 FST                      PIC  X(2).
       77 FSI                      PIC  X(2).

       78 BLACK   VALUE 0.
       78 BLUE    VALUE 1.
       78 GREEN   VALUE 2.
       78 CYAN    VALUE 3.
       78 RED     VALUE 4.
       78 MAGENTA VALUE 5.
       78 YELLOW  VALUE 6.
       78 WHITE   VALUE 7.

       01 CAMPOS-FECHA.
           05 FECHA.
               10 ANO              PIC  9(4).
               10 MES              PIC  9(2).
               10 DIA              PIC  9(2).
           05 HORA.
               10 HORAS            PIC  9(2).
               10 MINUTOS          PIC  9(2).
               10 SEGUNDOS         PIC  9(2).
               10 MILISEGUNDOS     PIC  9(2).
           05 DIF-GMT              PIC S9(4).

       01 KEYBOARD-STATUS           PIC 9(4).
           88 ENTER-PRESSED          VALUE 0.
           88 PGUP-PRESSED        VALUE 2001.
           88 PGDN-PRESSED        VALUE 2002.
           88 UP-ARROW-PRESSED    VALUE 2003.
           88 DOWN-ARROW-PRESSED  VALUE 2004.
           88 ESC-PRESSED         VALUE 2005.

       77 PRESSED-KEY BLANK ZERO   PIC  9(4).

       77 PIN-ACTUAL               PIC  9(4).
       77 PIN-NUEVO                PIC  9(4).
       77 PIN-NUEVO-II             PIC  9(4).
       77 INTENTOS-CUENTA          PIC  9(1).

       LINKAGE SECTION.
       77 TNUM                     PIC  9(16).

       SCREEN SECTION.
       01 BLANK-SCREEN.
           05 FILLER LINE 1 BLANK SCREEN BACKGROUND-COLOR BLACK.
           05 FILLER LINE 9 BLANK SCREEN BACKGROUND-COLOR BLACK.
           05 FILLER LINE 11 BLANK SCREEN BACKGROUND-COLOR BLACK.
           05 FILLER LINE 13 BLANK SCREEN BACKGROUND-COLOR BLACK.

       01 DATA-ACCEPT.
           05 FILLER BLANK WHEN ZERO AUTO UNDERLINE
               LINE 12 COL 56 PIC 9(4) USING PIN-ACTUAL.
           05 FILLER BLANK WHEN ZERO AUTO UNDERLINE 
               LINE 14 COL 56 PIC 9(4) USING PIN-NUEVO.
           05 FILLER BLANK WHEN ZERO AUTO UNDERLINE 
               LINE 16 COL 56 PIC 9(4) USING PIN-NUEVO-II.

       PROCEDURE DIVISION USING TNUM.
       INICIO.
           SET ENVIRONMENT 'COB_SCREEN_EXCEPTIONS' TO 'Y'.

           INITIALIZE PIN-ACTUAL.
           INITIALIZE PIN-NUEVO.
           INITIALIZE PIN-NUEVO-II.
           INITIALIZE INTENTOS-CUENTA.

           MOVE 3 TO INTENTOS-CUENTA.

       IMPRIMIR-CABECERA.
           DISPLAY BLANK-SCREEN.
           DISPLAY "Cajero Automatico UnizarBank" LINE 2 COL 26
               WITH FOREGROUND-COLOR IS 3.

           MOVE FUNCTION CURRENT-DATE TO CAMPOS-FECHA.

           DISPLAY DIA LINE 4 COL 32.
           DISPLAY "-" LINE 4 COL 34.
           DISPLAY MES LINE 4 COL 35.
           DISPLAY "-" LINE 4 COL 37.
           DISPLAY ANO LINE 4 COL 38.
           DISPLAY HORAS LINE 4 COL 44.
           DISPLAY ":" LINE 4 COL 46.
           DISPLAY MINUTOS LINE 4 COL 47.

       CAMBIO-PIN.
           DISPLAY "Cambio de clave de acceso" LINE 10 COL 19.
           DISPLAY "Introduzca su clave actual:" LINE 12 COL 19.
           DISPLAY "Introduzca su nueva clave:" LINE 14 COL 19.
           DISPLAY "Introduzca de nuevo su nueva clave:" LINE 16 COL 19.

           DISPLAY "Enter - Confirmar" LINE 24 COL 2.
           DISPLAY "ESC - Cancelar" LINE 24 COL 66.

           ACCEPT DATA-ACCEPT ON EXCEPTION
           IF ESC-PRESSED
               EXIT PROGRAM
           ELSE
               GO TO CAMBIO-PIN.

           IF INTENTOS-CUENTA = 0
               GO TO INTENTOS-ERR.
               
           OPEN I-O TARJETAS.
           IF FST <> 00
               GO TO PSYS-ERR.
           
           MOVE TNUM TO TNUM-E.
           READ TARJETAS INVALID KEY GO TO PSYS-ERR.

           IF PIN-ACTUAL <> TPIN-E
               GO TO PIN-ERR.
           
           IF INTENTOS-CUENTA <> 3
               MOVE 3 TO INTENTOS-CUENTA.

           IF PIN-NUEVO <> PIN-NUEVO-II
               GO TO CLAVES-DISTINTAS-ERR.

           MOVE PIN-NUEVO TO TPIN-E.
           REWRITE TARJETAREG INVALID KEY GO TO PSYS-ERR.
           CLOSE TARJETAS.

       EXITO-CAMBIO.
           PERFORM IMPRIMIR-CABECERA THRU IMPRIMIR-CABECERA.

           DISPLAY "Cambio de clave de acceso" LINE 10 COL 19.
           DISPLAY "La clave ha sido cambiada correctamente" 
               LINE 12 COL 19.
           DISPLAY "Enter - Aceptar" LINE 24 COL 2.

           GO TO EXIT-ENTER.

       PSYS-ERR.
           CLOSE TARJETAS.

           PERFORM IMPRIMIR-CABECERA THRU IMPRIMIR-CABECERA.
           DISPLAY "Ha ocurrido un error interno" LINE 09 COL 25
               WITH FOREGROUND-COLOR IS WHITE
                    BACKGROUND-COLOR IS RED.
           DISPLAY "Vuelva mas tarde" LINE 11 COL 32
               WITH FOREGROUND-COLOR IS WHITE
                    BACKGROUND-COLOR IS RED.
           DISPLAY "Enter - Aceptar" LINE 24 COL 2.

       EXIT-ENTER.
           ACCEPT PRESSED-KEY
           IF ENTER-PRESSED
               EXIT PROGRAM
           ELSE
               GO TO EXIT-ENTER.

       CLAVES-DISTINTAS-ERR.
           CLOSE TARJETAS.

           PERFORM IMPRIMIR-CABECERA THRU IMPRIMIR-CABECERA.
           DISPLAY "La clave nueva no coincide con la repetida" 
               LINE 10 COL 25
               WITH FOREGROUND-COLOR IS WHITE
                    BACKGROUND-COLOR IS RED.
           DISPLAY "Por favor, intentelo de nuevo" LINE 12 COL 25
               WITH FOREGROUND-COLOR IS WHITE
                    BACKGROUND-COLOR IS RED.
           DISPLAY "Enter - Aceptar" LINE 24 COL 2.

       CLAVES-DISTINTAS-ERR-ENTER.
           ACCEPT PRESSED-KEY
           IF ENTER-PRESSED
               GO TO IMPRIMIR-CABECERA
           ELSE
               GO TO CLAVES-DISTINTAS-ERR-ENTER.

       INTENTOS-ERR.
           PERFORM IMPRIMIR-CABECERA THRU IMPRIMIR-CABECERA.

           DISPLAY "Se ha sobrepasado el numero de intentos" 
               LINE 09 COL 25
               WITH FOREGROUND-COLOR IS WHITE
                    BACKGROUND-COLOR IS RED.
           DISPLAY "Se ha bloqueado la tarjeta por su seguridad" 
               LINE 11 COL 25
               WITH FOREGROUND-COLOR IS WHITE
                    BACKGROUND-COLOR IS RED.
           DISPLAY "Acuda a una sucursal" LINE 13 COL 25
               WITH FOREGROUND-COLOR IS WHITE
                    BACKGROUND-COLOR IS RED.
           DISPLAY "Enter - Aceptar" LINE 24 COL 2.

           OPEN I-O INTENTOS.
           IF FSI <> 00
              GO TO PSYS-ERR.

           MOVE TNUM-E TO INUM.

           READ INTENTOS INVALID KEY GO TO PSYS-ERR.

           MOVE INTENTOS-CUENTA TO IINTENTOS.

           REWRITE INTENTOSREG INVALID KEY GO TO PSYS-ERR.

           CLOSE INTENTOS.
           
           GO TO EXIT-ENTER.

       PIN-ERR.
           CLOSE TARJETAS.

           PERFORM IMPRIMIR-CABECERA THRU IMPRIMIR-CABECERA.

           SUBTRACT 1 FROM INTENTOS-CUENTA.
           DISPLAY "El pin introducido es incorrecto" LINE 10 COL 25
               WITH FOREGROUND-COLOR IS WHITE
                    BACKGROUND-COLOR IS RED.
           DISPLAY "Le quedan " LINE 12 COL 25
               WITH FOREGROUND-COLOR IS WHITE
                    BACKGROUND-COLOR IS RED.
           DISPLAY INTENTOS-CUENTA LINE 12 COL 35
               WITH FOREGROUND-COLOR IS WHITE
                    BACKGROUND-COLOR IS RED.
           DISPLAY " intentos" LINE 12 COL 36
               WITH FOREGROUND-COLOR IS WHITE
                    BACKGROUND-COLOR IS RED.
           DISPLAY "Enter - Aceptar" LINE 24 COL 2.

       PIN-ERR-ENTER.
           ACCEPT PRESSED-KEY
           IF ENTER-PRESSED
               GO TO IMPRIMIR-CABECERA
           ELSE
               GO TO PIN-ERR-ENTER.

       END PROGRAM BANK9.

