	   IDENTIFICATION DIVISION.
       PROGRAM-ID. BANK5.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SPECIAL-NAMES.
           CRT STATUS IS KEYBOARD-STATUS.

       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT F-MOVIMIENTOS ASSIGN TO DISK
           ORGANIZATION IS INDEXED
           ACCESS MODE IS DYNAMIC
           RECORD KEY IS MOV-NUM
           FILE STATUS IS FSM.

       DATA DIVISION.
       FILE SECTION.
       FD F-MOVIMIENTOS
           LABEL RECORD STANDARD
           VALUE OF FILE-ID IS "movimientos.ubd".
       01 MOVIMIENTO-REG.
           02 MOV-NUM               PIC  9(35).
           02 MOV-TARJETA           PIC  9(16).
           02 MOV-ANO               PIC   9(4).
           02 MOV-MES               PIC   9(2).
           02 MOV-DIA               PIC   9(2).
           02 MOV-HOR               PIC   9(2).
           02 MOV-MIN               PIC   9(2).
           02 MOV-SEG               PIC   9(2).
           02 MOV-IMPORTE-ENT       PIC  S9(7).
           02 MOV-IMPORTE-DEC       PIC   9(2).
           02 MOV-CONCEPTO          PIC  X(35).
           02 MOV-SALDOPOS-ENT      PIC  S9(9).
           02 MOV-SALDOPOS-DEC      PIC   9(2).

       WORKING-STORAGE SECTION.
       77 FSM                       PIC   X(2).

       78 BLACK                   VALUE      0.
       78 BLUE                    VALUE      1.
       78 GREEN                   VALUE      2.
       78 CYAN                    VALUE      3.
       78 RED                     VALUE      4.
       78 MAGENTA                 VALUE      5.
       78 YELLOW                  VALUE      6.
       78 WHITE                   VALUE      7.

       01 CAMPOS-FECHA.
           05 FECHA.
               10 ANO               PIC   9(4).
               10 MES               PIC   9(2).
               10 DIA               PIC   9(2).
           05 HORA.
               10 HORAS             PIC   9(2).
               10 MINUTOS           PIC   9(2).
               10 SEGUNDOS          PIC   9(2).
               10 MILISEGUNDOS      PIC   9(2).
           05 DIF-GMT               PIC  S9(4).

       01 KEYBOARD-STATUS           PIC   9(4).
           88 ENTER-PRESSED       VALUE      0.
           88 PGUP-PRESSED        VALUE   2001.
           88 PGDN-PRESSED        VALUE   2002.
           88 UP-ARROW-PRESSED    VALUE   2003.
           88 DOWN-ARROW-PRESSED  VALUE   2004.
           88 ESC-PRESSED         VALUE   2005.

       77 LAST-USER-MOV-NUM        PIC   9(35).
       77 LAST-MOV-NUM             PIC   9(35).

	   77 BILLETE10-USUARIO        PIC    9(2).
       77 BILLETE20-USUARIO        PIC    9(2).
       77 BILLETE50-USUARIO        PIC    9(2).									   
       77 EURENT-USUARIO           PIC    9(7).
       77 EURDEC-USUARIO           PIC    9(2).
       77 SALDO-USUARIO-ENT        PIC   S9(9).
       77 SALDO-USUARIO-DEC        PIC    9(2).
       77 CENT-SALDO-USER          PIC  S9(11).
       77 CENT-IMPOR-USER          PIC    9(9).
       77 CENT-ACUMULADOR          PIC   9(11).

       77 CON                      PIC   X(35) VALUE "Ingreso".
       77 PRESSED-KEY BLANK ZERO   PIC    9(1).

       LINKAGE SECTION.
       77 TNUM                     PIC  9(16).

       SCREEN SECTION.
       01 BLANK-SCREEN.
           05 FILLER LINE 1 BLANK SCREEN BACKGROUND-COLOR BLACK.

       01 ENTRADA-USUARIO.
           05 FILLER BLANK ZERO AUTO UNDERLINE
               LINE 13 COL 50 PIC 9(2) USING BILLETE10-USUARIO.
           05 FILLER BLANK ZERO AUTO UNDERLINE
               LINE 14 COL 50 PIC 9(2) USING BILLETE20-USUARIO.
           05 FILLER BLANK ZERO AUTO UNDERLINE
               LINE 15 COL 50 PIC 9(2) USING BILLETE50-USUARIO.

       01 SALDO-DISPLAY.
           05 FILLER SIGN IS LEADING SEPARATE
               LINE 10 COL 33 PIC -9(7) FROM SALDO-USUARIO-ENT.
           05 FILLER LINE 10 COL 41 VALUE ".".
           05 FILLER LINE 10 COL 42 PIC 99 FROM SALDO-USUARIO-DEC.
           05 FILLER LINE 10 COL 45 VALUE "EUR".

       01 SALDO-DISPLAY-FINAL.
           05 FILLER SIGN IS LEADING SEPARATE
               LINE 11 COL 44 PIC -9(7) FROM SALDO-USUARIO-ENT.
           05 FILLER LINE 11 COL 52 VALUE ".".
           05 FILLER LINE 11 COL 53 PIC 99 FROM SALDO-USUARIO-DEC.
           05 FILLER LINE 11 COL 56 VALUE "EUR".

       PROCEDURE DIVISION USING TNUM.
       IMPRIMIR-CABECERA.
           SET ENVIRONMENT 'COB_SCREEN_EXCEPTIONS' TO 'Y'.

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

       CONSULTA-ULTIMO-MOVIMIENTO.
           OPEN INPUT F-MOVIMIENTOS.
           IF FSM = 35
               OPEN OUTPUT F-MOVIMIENTOS
               IF FSM = 0
                   GO TO CONSULTA-ULTIMO-MOVIMIENTO
               ELSE
                   GO TO CONSULTA-ULTIMO-MOVIMIENTO
           ELSE
               IF FSM <> 00
                   GO TO PSYS-ERR.

           INITIALIZE CENT-ACUMULADOR.

           MOVE 0 TO LAST-MOV-NUM.

       LEER-ULTIMO-MOV-READ.
           READ F-MOVIMIENTOS NEXT RECORD AT END GO TO LAST-MOV-FOUND.

           IF MOV-NUM > LAST-MOV-NUM
               MOVE MOV-NUM TO LAST-MOV-NUM.

           GO TO LEER-ULTIMO-MOV-READ.

       LAST-MOV-FOUND.
           CLOSE F-MOVIMIENTOS.

       CONSULTA-SALDO-USUARIO SECTION.
           OPEN INPUT F-MOVIMIENTOS.
           IF FSM <> 00
               GO TO PSYS-ERR.

           MOVE 0 TO LAST-USER-MOV-NUM.
           MOVE 0 TO MOV-NUM.

       LECTURA-MOV-USER.
           READ F-MOVIMIENTOS NEXT RECORD
              AT END GO LAST-USER-MOV-FOUND.

              IF MOV-TARJETA = TNUM
                  IF LAST-USER-MOV-NUM < MOV-NUM
                      MOVE MOV-NUM TO LAST-USER-MOV-NUM.
              GO LECTURA-MOV-USER.

       LAST-USER-MOV-FOUND.
           CLOSE F-MOVIMIENTOS.

           IF LAST-USER-MOV-NUM = 0 THEN
               MOVE 0 TO SALDO-USUARIO-ENT
               MOVE 0 TO SALDO-USUARIO-DEC
               MOVE 0 TO CENT-SALDO-USER
               GO TO PANTALLA-INGRESO
           END-IF.

           MOVE LAST-USER-MOV-NUM TO MOV-NUM.

           OPEN INPUT F-MOVIMIENTOS.
           IF FSM <> 00
               GO TO PSYS-ERR.

           READ F-MOVIMIENTOS INVALID KEY GO TO PSYS-ERR.

           MOVE MOV-SALDOPOS-ENT TO SALDO-USUARIO-ENT.
           MOVE MOV-SALDOPOS-DEC TO SALDO-USUARIO-DEC.
           COMPUTE CENT-SALDO-USER = (SALDO-USUARIO-ENT * 100)
                                     + SALDO-USUARIO-DEC.

           CLOSE F-MOVIMIENTOS.

       PANTALLA-INGRESO SECTION.
           INITIALIZE EURENT-USUARIO.
           INITIALIZE EURDEC-USUARIO.
		   INITIALIZE BILLETE10-USUARIO.
           INITIALIZE BILLETE20-USUARIO.
           INITIALIZE BILLETE50-USUARIO

           DISPLAY "ESC - Finalizar ingreso efectivo" LINE 24 COL 23.
           DISPLAY "Ingresar efectivo" LINE 8 COL 30.
           DISPLAY "Saldo Actual: " LINE 10 COL 24.

           DISPLAY SALDO-DISPLAY.

           DISPLAY "Por favor,introduzca billetes" AT LINE 11 COL 24.
           DISPLAY "Numero de billetes de 10:" AT LINE 13 COL 24.
           DISPLAY "Numero de billetes de 20:" AT LINE 14 COL 24.
           DISPLAY "Numero de billetes de 50:" AT LINE 15 COL 24.

       CONF2.
           ACCEPT ENTRADA-USUARIO ON EXCEPTION
               IF ESC-PRESSED THEN
                   GO TO PANT
               ELSE
                   GO TO CONF2
               END-IF.

           COMPUTE CENT-IMPOR-USER = (BILLETE10-USUARIO * 10 * 100)
                                     + (BILLETE20-USUARIO * 20 * 100)
                                     + (BILLETE50-USUARIO * 50 * 100).	   
           ADD CENT-IMPOR-USER TO CENT-ACUMULADOR.

       INSERTAR-MOVIMIENTO SECTION.
           OPEN I-O F-MOVIMIENTOS.
           IF FSM <> 00
              GO TO PSYS-ERR.

           ADD CENT-IMPOR-USER TO CENT-SALDO-USER
               ON SIZE ERROR GO TO PSYS-ERR.
           COMPUTE SALDO-USUARIO-ENT = (CENT-SALDO-USER / 100).
           MOVE FUNCTION MOD(CENT-SALDO-USER, 100)
               TO SALDO-USUARIO-DEC.
           COMPUTE EURENT-USUARIO = (BILLETE10-USUARIO * 10)
                                     + (BILLETE20-USUARIO * 20)
                                     + (BILLETE50-USUARIO * 50).
           MOVE 0 TO EURDEC-USUARIO.

       ESCRITURA.
           ADD 1 TO LAST-MOV-NUM.

           MOVE LAST-MOV-NUM            TO MOV-NUM.
           MOVE TNUM                    TO MOV-TARJETA.
           MOVE ANO                     TO MOV-ANO.
           MOVE MES                     TO MOV-MES.
           MOVE DIA                     TO MOV-DIA.
           MOVE HORAS                   TO MOV-HOR.
           MOVE MINUTOS                 TO MOV-MIN.
           MOVE SEGUNDOS                TO MOV-SEG.

           MOVE EURENT-USUARIO          TO MOV-IMPORTE-ENT.
           MOVE EURDEC-USUARIO          TO MOV-IMPORTE-DEC.

           MOVE CON                     TO MOV-CONCEPTO.

           MOVE SALDO-USUARIO-ENT       TO MOV-SALDOPOS-ENT.
           MOVE SALDO-USUARIO-DEC       TO MOV-SALDOPOS-DEC.

           WRITE MOVIMIENTO-REG INVALID KEY GO TO PSYS-ERR.
           CLOSE F-MOVIMIENTOS.

           GO TO PANTALLA-INGRESO.

       PANT SECTION.

           COMPUTE EURENT-USUARIO = (CENT-ACUMULADOR / 100).
           MOVE FUNCTION MOD(CENT-ACUMULADOR, 100)
               TO EURDEC-USUARIO.

           PERFORM IMPRIMIR-CABECERA THRU IMPRIMIR-CABECERA.
           DISPLAY "Ingresar efectivo" LINE 8 COL 30.
           DISPLAY "Se han recibido correctamente:" LINE 10 COL 19.
           DISPLAY EURENT-USUARIO LINE 10 COL 50.
           DISPLAY EURDEC-USUARIO LINE 10 COL 58.
           DISPLAY "." LINE 10 COL 57.
           DISPLAY "EUR" LINE 10 COL 61.
           DISPLAY "El saldo resultante es de:" LINE 11 COL 19.

           DISPLAY SALDO-DISPLAY-FINAL.

           DISPLAY "Enter - Aceptar" LINE 24 COL 33.

           GO TO EXIT-ENTER.

       PSYS-ERR.
           CLOSE F-MOVIMIENTOS.

           PERFORM IMPRIMIR-CABECERA THRU IMPRIMIR-CABECERA.
           DISPLAY "Ha ocurrido un error interno" LINE 9 COL 25
               WITH FOREGROUND-COLOR IS WHITE
                    BACKGROUND-COLOR IS RED.
           DISPLAY "Vuelva mas tarde" LINE 11 COL 32
               WITH FOREGROUND-COLOR IS WHITE
                    BACKGROUND-COLOR IS RED.
           DISPLAY "Enter - Aceptar" LINE 24 COL 33.

       EXIT-ENTER.
           ACCEPT PRESSED-KEY
           IF ENTER-PRESSED
               EXIT PROGRAM
           ELSE
               GO TO EXIT-ENTER.

	   END PROGRAM BANK5.

