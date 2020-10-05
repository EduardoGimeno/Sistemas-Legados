	   IDENTIFICATION DIVISION.
       PROGRAM-ID. BANK6.

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

           SELECT F-MOVIMIENTOS ASSIGN TO "movimientos.ubd"
           ORGANIZATION IS INDEXED
           ACCESS MODE IS DYNAMIC
           RECORD KEY IS MOV-NUM
           FILE STATUS IS FSM.


       DATA DIVISION.
       FILE SECTION.
       FD TARJETAS
           LABEL RECORD STANDARD
           VALUE OF FILE-ID IS "tarjetas.ubd".
       01 TAJETAREG.
           02 TNUM-E      PIC 9(16).
           02 TPIN-E      PIC  9(4).
       FD F-MOVIMIENTOS.
       01 MOVIMIENTO-REG.
           02 MOV-NUM              PIC  9(35).
           02 MOV-TARJETA          PIC  9(16).
           02 MOV-ANO              PIC   9(4).
           02 MOV-MES              PIC   9(2).
           02 MOV-DIA              PIC   9(2).
           02 MOV-HOR              PIC   9(2).
           02 MOV-MIN              PIC   9(2).
           02 MOV-SEG              PIC   9(2).
           02 MOV-IMPORTE-ENT      PIC  S9(7).
           02 MOV-IMPORTE-DEC      PIC   9(2).
           02 MOV-CONCEPTO         PIC  X(35).
           02 MOV-SALDOPOS-ENT     PIC  S9(9).
           02 MOV-SALDOPOS-DEC     PIC   9(2).


       WORKING-STORAGE SECTION.
       77 FST                      PIC   X(2).
       77 FSM                      PIC   X(2).

       78 BLACK                  VALUE      0.
       78 BLUE                   VALUE      1.
       78 GREEN                  VALUE      2.
       78 CYAN                   VALUE      3.
       78 RED                    VALUE      4.
       78 MAGENTA                VALUE      5.
       78 YELLOW                 VALUE      6.
       78 WHITE                  VALUE      7.

       01 CAMPOS-FECHA.
           05 FECHA.
               10 ANO              PIC   9(4).
               10 MES              PIC   9(2).
               10 DIA              PIC   9(2).
           05 HORA.
               10 HORAS            PIC   9(2).
               10 MINUTOS          PIC   9(2).
               10 SEGUNDOS         PIC   9(2).
               10 MILISEGUNDOS     PIC   9(2).
           05 DIF-GMT              PIC  S9(4).

       01 KEYBOARD-STATUS          PIC  9(4).
           88 ENTER-PRESSED      VALUE     0.
           88 PGUP-PRESSED       VALUE  2001.
           88 PGDN-PRESSED       VALUE  2002.
           88 UP-ARROW-PRESSED   VALUE  2003.
           88 DOWN-ARROW-PRESSED VALUE  2004.
           88 ESC-PRESSED        VALUE  2005.

       77 PRESSED-KEY              PIC   9(4).

       77 LAST-MOV-NUM             PIC  9(35).
       77 LAST-USER-ORD-MOV-NUM    PIC  9(35).
       77 LAST-USER-DST-MOV-NUM    PIC  9(35).

       77 EURENT-USUARIO           PIC  S9(7).
       77 EURDEC-USUARIO           PIC   9(2).
       77 CUENTA-DESTINO           PIC  9(16).
       77 NOMBRE-DESTINO           PIC  X(35).

       77 CENT-SALDO-ORD-USER      PIC  S9(9).
       77 CENT-SALDO-DST-USER      PIC  S9(9).
       77 CENT-IMPOR-USER          PIC  S9(9).

       77 MSJ-ORD                  PIC  X(35) VALUE "Transferimos".
       77 MSJ-ORD-MENSUAL          PIC  X(35) 
           VALUE "Transferimos mensual".
       77 MSJ-DST                  PIC  X(35) VALUE "Nos transfieren".
       77 MSJ-DST-MENSUAL          PIC  X(35) 
           VALUE "Nos transfieren mensual".

       77 ELECCION                 PIC 9(1).
       77 DIA-TRANSFERENCIA-PUNTUAL PIC 9(2).
       77 MES-TRANSFERENCIA-PUNTUAL PIC 9(2).
       77 ANO-TRANSFERENCIA-PUNTUAL PIC 9(4).
       77 DIA-TRANSFERENCIA-MENSUAL PIC 9(2).
       77 HOY                      PIC 9(1).
       77 DEBUG                    PIC 9(1).

       LINKAGE SECTION.
       77 TNUM                     PIC  9(16).

       SCREEN SECTION.
       01 BLANK-SCREEN.
           05 FILLER LINE 1 BLANK SCREEN BACKGROUND-COLOR BLACK.

       01 FILTRO-CUENTA-PUNTUAL.
           05 FILLER BLANK WHEN ZERO UNDERLINE
               LINE 12 COL 54 PIC 9(16) USING CUENTA-DESTINO.
           05 FILLER AUTO UNDERLINE
               LINE 14 COL 54 PIC X(15) USING NOMBRE-DESTINO.
           05 FILLER BLANK ZERO UNDERLINE
               SIGN IS LEADING SEPARATE
               LINE 16 COL 54 PIC -9(7) USING EURENT-USUARIO.
           05 FILLER BLANK ZERO UNDERLINE
               LINE 16 COL 63 PIC 9(2) USING EURDEC-USUARIO.
           05 FILLER BLANK ZERO AUTO UNDERLINE
               LINE 20 COL 54 PIC 9(2) USING DIA-TRANSFERENCIA-PUNTUAL.
           05 FILLER BLANK ZERO AUTO UNDERLINE
               LINE 21 COL 54 PIC 9(2) USING MES-TRANSFERENCIA-PUNTUAL.
           05 FILLER BLANK ZERO AUTO UNDERLINE
               LINE 22 COL 54 PIC 9(4) USING ANO-TRANSFERENCIA-PUNTUAL.

       01 FILTRO-CUENTA-MENSUAL.
           05 FILLER BLANK WHEN ZERO AUTO UNDERLINE
               LINE 12 COL 54 PIC 9(16) USING CUENTA-DESTINO.
           05 FILLER AUTO UNDERLINE
               LINE 14 COL 54 PIC X(15) USING NOMBRE-DESTINO.
           05 FILLER BLANK ZERO AUTO UNDERLINE
               SIGN IS LEADING SEPARATE
               LINE 16 COL 54 PIC -9(7) USING EURENT-USUARIO.
           05 FILLER BLANK ZERO UNDERLINE
               LINE 16 COL 63 PIC 9(2) USING EURDEC-USUARIO.
           05 FILLER BLANK ZERO AUTO UNDERLINE
               LINE 18 COL 54 PIC 9(2) USING DIA-TRANSFERENCIA-MENSUAL.

       01 FILTRO-CUENTA.
           05 FILLER BLANK WHEN ZERO AUTO UNDERLINE
               LINE 12 COL 54 PIC 9(16) USING CUENTA-DESTINO.
           05 FILLER AUTO UNDERLINE
               LINE 14 COL 54 PIC X(15) USING NOMBRE-DESTINO.
           05 FILLER BLANK ZERO AUTO UNDERLINE
               SIGN IS LEADING SEPARATE
               LINE 16 COL 54 PIC -9(7) USING EURENT-USUARIO.
           05 FILLER BLANK ZERO UNDERLINE
               LINE 16 COL 63 PIC 9(2) USING EURDEC-USUARIO.

       01 TIPO-TRANSFERENCIA.
           05 FILLER BLANK ZERO AUTO UNDERLINE
               LINE 16 COL 19 PIC 9(1) USING ELECCION.

       01 SALDO-DISPLAY.
           05 FILLER SIGN IS LEADING SEPARATE
               LINE 10 COL 33 PIC -9(7) FROM MOV-SALDOPOS-ENT.
           05 FILLER LINE 10 COL 41 VALUE ",".
           05 FILLER LINE 10 COL 42 PIC 99 FROM MOV-SALDOPOS-DEC.
           05 FILLER LINE 10 COL 45 VALUE "EUR".


       PROCEDURE DIVISION USING TNUM.
       INICIO.
           SET ENVIRONMENT 'COB_SCREEN_EXCEPTIONS' TO 'Y'.

           INITIALIZE CUENTA-DESTINO.
           INITIALIZE NOMBRE-DESTINO.
           INITIALIZE EURENT-USUARIO.
           INITIALIZE EURDEC-USUARIO.
           INITIALIZE LAST-MOV-NUM.
           INITIALIZE LAST-USER-ORD-MOV-NUM.
           INITIALIZE LAST-USER-DST-MOV-NUM.
           INITIALIZE ELECCION.
           INITIALIZE DIA-TRANSFERENCIA-PUNTUAL.
           INITIALIZE MES-TRANSFERENCIA-PUNTUAL.
           INITIALIZE ANO-TRANSFERENCIA-PUNTUAL.
           INITIALIZE DIA-TRANSFERENCIA-MENSUAL.
           INITIALIZE HOY.
           INITIALIZE DEBUG.

       IMPRIMIR-CABECERA.
           DISPLAY BLANK-SCREEN.
           DISPLAY "Cajero Automatico UnizarBank" LINE 2 COL 26
               WITH FOREGROUND-COLOR IS 1.

           MOVE FUNCTION CURRENT-DATE TO CAMPOS-FECHA.

           DISPLAY DIA LINE 4 COL 32.
           DISPLAY "-" LINE 4 COL 34.
           DISPLAY MES LINE 4 COL 35.
           DISPLAY "-" LINE 4 COL 37.
           DISPLAY ANO LINE 4 COL 38.
           DISPLAY HORAS LINE 4 COL 44.
           DISPLAY ":" LINE 4 COL 46.
           DISPLAY MINUTOS LINE 4 COL 47.

       MOVIMIENTOS-OPEN.
           OPEN I-O F-MOVIMIENTOS.
           IF FSM = 35
               OPEN OUTPUT F-MOVIMIENTOS
               IF FSM = 0
                   GO TO MOVIMIENTOS-OPEN
               ELSE
                   GO TO MOVIMIENTOS-OPEN
           ELSE
               IF FSM <> 00
                   MOVE 4 TO DEBUG
                   GO TO PSYS-ERR.

       LECTURA-MOVIMIENTOS.
           READ F-MOVIMIENTOS NEXT RECORD AT END GO TO ORDENACION-TRF.
           IF MOV-TARJETA = TNUM THEN
               IF LAST-USER-ORD-MOV-NUM < MOV-NUM THEN
                   MOVE MOV-NUM TO LAST-USER-ORD-MOV-NUM
               END-IF
           END-IF.
           IF LAST-MOV-NUM < MOV-NUM THEN
               MOVE MOV-NUM TO LAST-MOV-NUM
           END-IF.
           GO TO LECTURA-MOVIMIENTOS.

       ORDENACION-TRF.
           CLOSE F-MOVIMIENTOS.

           DISPLAY "Transferencia a realizar:" LINE 10 COL 19.
           DISPLAY "1: Puntual" LINE 12 COL 19.
           DISPLAY "2: Mensual" LINE 14 COL 19.
           DISPLAY "ESC - Cancelar" LINE 24 COL 66.

           ACCEPT TIPO-TRANSFERENCIA ON EXCEPTION
           IF ESC-PRESSED
               EXIT PROGRAM
           ELSE
               GO TO ORDENACION-TRF.

           PERFORM IMPRIMIR-CABECERA THRU IMPRIMIR-CABECERA.    

           DISPLAY "Ordenar Transferencia" LINE 8 COL 30.
           DISPLAY "Saldo Actual:" LINE 10 COL 19.

           DISPLAY "Enter - Confirmar" LINE 24 COL 2.
           DISPLAY "ESC - Cancelar" LINE 24 COL 66.

           IF LAST-USER-ORD-MOV-NUM = 0
               GO TO NO-MOVIMIENTOS.

           MOVE LAST-USER-ORD-MOV-NUM TO MOV-NUM.

           PERFORM MOVIMIENTOS-OPEN THRU MOVIMIENTOS-OPEN.
           READ F-MOVIMIENTOS INVALID KEY GO PSYS-ERR.
           DISPLAY SALDO-DISPLAY.
           CLOSE F-MOVIMIENTOS.
           IF ELECCION = 2
               GO TO INDICAR-CTA-DST-MENSUAL.

       INDICAR-CTA-DST-PUNTUAL.
           DISPLAY "Indique la cuenta destino" LINE 12 COL 19.
           DISPLAY "y nombre del titular" LINE 14 COL 19.
           DISPLAY "Indique la cantidad a transferir" LINE 16 COL 19.
           DISPLAY "," LINE 16 COL 61.
           DISPLAY "EUR" LINE 16 COL 66.
           DISPLAY "Indique la fecha" LINE 18 COL 19.
           DISPLAY "Maximo un año posterior" LINE 19 COL 19.
           DISPLAY "Dia (dd):" LINE 20 COL 19.
           DISPLAY "Mes (mm):" LINE 21 COL 19.
           DISPLAY "Ano (aaaa):" LINE 22 COL 19.

           COMPUTE CENT-SALDO-ORD-USER = (MOV-SALDOPOS-ENT * 100)
                                         + MOV-SALDOPOS-DEC.

           ACCEPT FILTRO-CUENTA-PUNTUAL ON EXCEPTION
           IF ESC-PRESSED
               EXIT PROGRAM
           ELSE
               GO TO INDICAR-CTA-DST-PUNTUAL.

           COMPUTE CENT-IMPOR-USER = (EURENT-USUARIO * 100)
                                     + EURDEC-USUARIO.

           IF CENT-IMPOR-USER > CENT-SALDO-ORD-USER
                   DISPLAY "Indique una cantidad menor!!" LINE 20 COL 19
                   WITH BACKGROUND-COLOR RED
                   GO TO INDICAR-CTA-DST-PUNTUAL.

           IF DIA-TRANSFERENCIA-PUNTUAL < 1 OR DIA-TRANSFERENCIA-PUNTUAL > 31
               DISPLAY "Indique un dia entre 1 y 31!!" LINE 20 COL 19
               WITH BACKGROUND-COLOR RED
               GO TO INDICAR-CTA-DST-PUNTUAL.

           IF MES-TRANSFERENCIA-PUNTUAL < 1 OR MES-TRANSFERENCIA-PUNTUAL > 12
               DISPLAY "Indique un mes entre 1 y 12!!" LINE 20 COL 19
               WITH BACKGROUND-COLOR RED
               GO TO INDICAR-CTA-DST-PUNTUAL.

           MOVE FUNCTION CURRENT-DATE TO CAMPOS-FECHA.

           IF ANO-TRANSFERENCIA-PUNTUAL < ANO
               DISPLAY "Indique un ano valido!!" LINE 20 COL 19
               WITH BACKGROUND-COLOR RED
               GO TO INDICAR-CTA-DST-PUNTUAL.

           GO TO REALIZAR-TRF-VERIFICACION.

       INDICAR-CTA-DST-MENSUAL.
           DISPLAY "Indique la cuenta destino" LINE 12 COL 19.
           DISPLAY "y nombre del titular" LINE 14 COL 19.
           DISPLAY "Indique la cantidad a transferir" LINE 16 COL 19.
           DISPLAY "," LINE 16 COL 61.
           DISPLAY "EUR" LINE 16 COL 66.
           DISPLAY "Indique el dia del mes (dd)" LINE 18 COL 19.

           COMPUTE CENT-SALDO-ORD-USER = (MOV-SALDOPOS-ENT * 100)
                                         + MOV-SALDOPOS-DEC.
           
           ACCEPT FILTRO-CUENTA-MENSUAL ON EXCEPTION
           IF ESC-PRESSED
               EXIT PROGRAM
           ELSE
               GO TO INDICAR-CTA-DST-MENSUAL.

           COMPUTE CENT-IMPOR-USER = (EURENT-USUARIO * 100)
                                     + EURDEC-USUARIO.

           IF CENT-IMPOR-USER > CENT-SALDO-ORD-USER
                   DISPLAY "Indique una cantidad menor!!" LINE 20 COL 19
                   WITH BACKGROUND-COLOR RED
                   GO TO INDICAR-CTA-DST-MENSUAL.

           IF DIA-TRANSFERENCIA-MENSUAL < 1 OR DIA-TRANSFERENCIA-MENSUAL > 28
               DISPLAY "Indique un dia entre 1 y 28!!" LINE 20 COL 19
               WITH BACKGROUND-COLOR RED
               GO TO INDICAR-CTA-DST-MENSUAL.

           GO TO REALIZAR-TRF-VERIFICACION.

       NO-MOVIMIENTOS.
           DISPLAY "0" LINE 10 COL 51.
           DISPLAY " LINE 10 COL 52.".
           DISPLAY "00" LINE 10 COL 53.
           DISPLAY "EUR" LINE 10 COL 54.

           DISPLAY "Indica la cuenta destino " LINE 12 COL 19.
           DISPLAY "y nombre del titular" LINE 14 COL 19.
           DISPLAY "Indique la cantidad a transferir" LINE 16 COL 19.
           DISPLAY "," LINE 16 COL 61.
           DISPLAY "EUR" LINE 16 COL 66.

           ACCEPT FILTRO-CUENTA ON EXCEPTION
           IF ESC-PRESSED THEN
               EXIT PROGRAM
           END-IF.

           DISPLAY "Indique una cantidad menor!!" LINE 20 COL 19
            WITH BACKGROUND-COLOR RED.

           GO TO NO-MOVIMIENTOS.

       REALIZAR-TRF-VERIFICACION.
           PERFORM IMPRIMIR-CABECERA THRU IMPRIMIR-CABECERA.
           DISPLAY "Ordenar Transferencia" LINE 08 COL 30.
           DISPLAY "Va a transferir:" LINE 11 COL 19.
           DISPLAY EURENT-USUARIO LINE 11 COL 38.
           DISPLAY " LINE 11 COL 45.".
           DISPLAY EURDEC-USUARIO LINE 11 COL 46.
           DISPLAY "EUR de su cuenta" LINE 11 COL 49.
           DISPLAY "a la cuenta cuyo titular es" LINE 12 COL 19.
           DISPLAY NOMBRE-DESTINO LINE 12 COL 48.
           IF ELECCION = 2
               DISPLAY "el dia" LINE 13 COL 19
               DISPLAY DIA-TRANSFERENCIA-MENSUAL LINE 13 COL 26
               DISPLAY "de cada mes" LINE 13 COL 29
           ELSE
               DISPLAY "el dia" LINE 13 COL 19
               DISPLAY DIA-TRANSFERENCIA-PUNTUAL LINE 13 COL 26
               DISPLAY "/" LINE 13 COL 28
               DISPLAY MES-TRANSFERENCIA-PUNTUAL LINE 13 COL 29
               DISPLAY "/" LINE 13 COL 31
               DISPLAY ANO-TRANSFERENCIA-PUNTUAL LINE 13 COL 32.

           DISPLAY "Enter - Confirmar" LINE 24 COL 2.
           DISPLAY "ESC - Cancelar" LINE 24 COL 66.

       ENTER-VERIFICACION.
           ACCEPT PRESSED-KEY ON EXCEPTION
           IF ESC-PRESSED THEN
               EXIT PROGRAM
           ELSE
               GO TO ENTER-VERIFICACION
           END-IF.

       VERIFICACION-CTA-CORRECTA.
           OPEN I-O TARJETAS.
           IF FST <> 00
              MOVE 1 TO DEBUG.
              GO TO PSYS-ERR.

           MOVE CUENTA-DESTINO TO TNUM-E.
           READ TARJETAS INVALID KEY GO TO USER-BAD.
           CLOSE TARJETAS.

           PERFORM MOVIMIENTOS-OPEN THRU MOVIMIENTOS-OPEN.
           MOVE 0 TO MOV-NUM.
           MOVE 0 TO LAST-USER-DST-MOV-NUM.

       LECTURA-SALDO-DST.
           READ F-MOVIMIENTOS NEXT RECORD AT END GO TO GUARDAR-TRF.
           IF MOV-TARJETA = CUENTA-DESTINO THEN
               IF LAST-USER-DST-MOV-NUM < MOV-NUM THEN
                   MOVE MOV-NUM TO LAST-USER-DST-MOV-NUM
               END-IF
           END-IF.

           GO TO LECTURA-SALDO-DST.

       GUARDAR-TRF.
           CLOSE F-MOVIMIENTOS.
           MOVE LAST-USER-DST-MOV-NUM TO MOV-NUM.
           PERFORM MOVIMIENTOS-OPEN THRU MOVIMIENTOS-OPEN.
           MOVE 2 TO DEBUG.
           READ F-MOVIMIENTOS INVALID KEY 
               MOVE 0 TO CENT-SALDO-DST-USER
               GO TO CONTINUAR.

           COMPUTE CENT-SALDO-DST-USER = (MOV-SALDOPOS-ENT * 100)
                                         + MOV-SALDOPOS-DEC.
       CONTINUAR.
           ADD 1 TO LAST-MOV-NUM.

           MOVE FUNCTION CURRENT-DATE TO CAMPOS-FECHA.

           MOVE 0 TO HOY.

           IF ELECCION = 2 AND DIA-TRANSFERENCIA-MENSUAL = DIA
               MOVE 1 TO HOY

           IF ELECCION = 1 AND DIA-TRANSFERENCIA-PUNTUAL = DIA AND
               MES-TRANSFERENCIA-PUNTUAL = MES AND
               ANO-TRANSFERENCIA-PUNTUAL = ANO
                   MOVE 1 TO HOY.
           
           IF ELECCION = 2
               MOVE DIA-TRANSFERENCIA-MENSUAL TO DIA
               MOVE 0 TO MES
               MOVE 0 TO ANO
           ELSE
               MOVE DIA-TRANSFERENCIA-PUNTUAL TO DIA
               MOVE MES-TRANSFERENCIA-PUNTUAL TO MES
               MOVE ANO-TRANSFERENCIA-PUNTUAL TO ANO.

           MOVE LAST-MOV-NUM   TO MOV-NUM.
           MOVE TNUM           TO MOV-TARJETA.
           MOVE ANO            TO MOV-ANO.
           MOVE MES            TO MOV-MES.
           MOVE DIA            TO MOV-DIA.
           MOVE HORAS          TO MOV-HOR.
           MOVE MINUTOS        TO MOV-MIN.
           MOVE SEGUNDOS       TO MOV-SEG.

           MULTIPLY -1 BY EURENT-USUARIO.
           MOVE EURENT-USUARIO TO MOV-IMPORTE-ENT.
           MULTIPLY -1 BY EURENT-USUARIO.
           MOVE EURDEC-USUARIO TO MOV-IMPORTE-DEC.

           IF ELECCION = 2
               MOVE MSJ-ORD-MENSUAL TO MOV-CONCEPTO
           ELSE
               MOVE MSJ-ORD TO MOV-CONCEPTO.
           
           IF HOY = 1
               SUBTRACT CENT-IMPOR-USER FROM CENT-SALDO-ORD-USER.

           COMPUTE MOV-SALDOPOS-ENT = (CENT-SALDO-ORD-USER / 100).
           MOVE FUNCTION MOD(CENT-SALDO-ORD-USER, 100)
               TO MOV-SALDOPOS-DEC.
           
           MOVE 3 TO DEBUG.
           WRITE MOVIMIENTO-REG INVALID KEY GO TO PSYS-ERR.

           ADD 1 TO LAST-MOV-NUM.

           MOVE LAST-MOV-NUM   TO MOV-NUM.
           MOVE CUENTA-DESTINO TO MOV-TARJETA.
           MOVE ANO            TO MOV-ANO.
           MOVE MES            TO MOV-MES.
           MOVE DIA            TO MOV-DIA.
           MOVE HORAS          TO MOV-HOR.
           MOVE MINUTOS        TO MOV-MIN.
           MOVE SEGUNDOS       TO MOV-SEG.

           MOVE EURENT-USUARIO TO MOV-IMPORTE-ENT.
           MOVE EURDEC-USUARIO TO MOV-IMPORTE-DEC.

           IF ELECCION = 2
               MOVE MSJ-DST-MENSUAL TO MOV-CONCEPTO
           ELSE
               MOVE MSJ-DST        TO MOV-CONCEPTO.
           
           IF HOY = 1
               ADD CENT-IMPOR-USER TO CENT-SALDO-DST-USER
               COMPUTE MOV-SALDOPOS-ENT = (CENT-SALDO-DST-USER / 100)
               MOVE FUNCTION MOD(CENT-SALDO-DST-USER, 100)
                   TO MOV-SALDOPOS-DEC.

           WRITE MOVIMIENTO-REG INVALID KEY GO TO PSYS-ERR.

           CLOSE F-MOVIMIENTOS.

       P-EXITO.
           PERFORM IMPRIMIR-CABECERA THRU IMPRIMIR-CABECERA.

           DISPLAY "Ordenar transferencia" LINE 8 COL 30.
           DISPLAY "Transf. realizada correctamente" LINE 11 COL 19.
           DISPLAY "Enter - Aceptar" LINE 24 COL 33.

           GO TO EXIT-ENTER.

       PSYS-ERR.
           CLOSE TARJETAS.
           CLOSE F-MOVIMIENTOS.

           PERFORM IMPRIMIR-CABECERA THRU IMPRIMIR-CABECERA.
           DISPLAY DEBUG LINE 7 COL 25.
           DISPLAY "Ha ocurrido un error interno" LINE 09 COL 25
               WITH FOREGROUND-COLOR IS BLACK
                    BACKGROUND-COLOR IS RED.
           DISPLAY "Vuelva mas tarde" LINE 11 COL 32
               WITH FOREGROUND-COLOR IS BLACK
                    BACKGROUND-COLOR IS RED.
           DISPLAY "Enter - Aceptar" LINE 24 COL 33.

       EXIT-ENTER.
           ACCEPT PRESSED-KEY
           IF ENTER-PRESSED
               EXIT PROGRAM
           ELSE
               GO TO EXIT-ENTER.

       USER-BAD.
           CLOSE TARJETAS.
           PERFORM IMPRIMIR-CABECERA THRU IMPRIMIR-CABECERA.
           DISPLAY "La cuenta introducida es incorrecta" LINE 9 COL 22
               WITH FOREGROUND-COLOR IS BLACK
                    BACKGROUND-COLOR IS RED.
           DISPLAY "Enter - Salir" LINE 24 COL 33.
           GO TO EXIT-ENTER.
	   END PROGRAM BANK6.
