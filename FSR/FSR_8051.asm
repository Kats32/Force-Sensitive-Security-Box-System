ORG 0000H

;=============================
; Port Definitions
;=============================
ADC_DATA   EQU P1
WR_PIN     EQU P3.6
RD_PIN     EQU P3.7
INTR_PIN   EQU P3.2

LCD_PORT   EQU P0
RS         EQU P2.0
RW         EQU P2.1
EN         EQU P2.2

;=============================
; Main Program
;=============================
START:
    MOV P1, #0FFH       ; ADC input
    MOV P0, #00H

    ACALL LCD_INIT

MAIN_LOOP:
    ACALL READ_ADC
    MOV A, R0

    ACALL LCD_CLEAR
    ACALL DISPLAY_VALUE

    ; Compare with threshold (adjust value)
    CJNE A, #50, CHECK

CHECK:
    JC NO_PRESSURE

PRESSURE:
    ACALL LCD_LINE2
    MOV DPTR, #MSG1
    ACALL LCD_PRINT
    SJMP MAIN_LOOP

NO_PRESSURE:
    ACALL LCD_LINE2
    MOV DPTR, #MSG2
    ACALL LCD_PRINT
    SJMP MAIN_LOOP

;=============================
; ADC Read
;=============================
READ_ADC:
    CLR WR_PIN
    SETB WR_PIN

WAIT_INTR:
    JB INTR_PIN, WAIT_INTR

    CLR RD_PIN
    MOV A, ADC_DATA
    MOV R0, A
    SETB RD_PIN
    RET

;=============================
; LCD Functions
;=============================

LCD_INIT:
    MOV A, #38H
    ACALL LCD_CMD
    MOV A, #0CH
    ACALL LCD_CMD
    MOV A, #06H
    ACALL LCD_CMD
    MOV A, #01H
    ACALL LCD_CMD
    RET

LCD_CMD:
    MOV LCD_PORT, A
    CLR RS
    CLR RW
    SETB EN
    ACALL DELAY
    CLR EN
    RET

LCD_DATA:
    MOV LCD_PORT, A
    SETB RS
    CLR RW
    SETB EN
    ACALL DELAY
    CLR EN
    RET

LCD_PRINT:
    CLR A
PRINT_LOOP:
    MOVC A, @A+DPTR
    JZ END_PRINT
    ACALL LCD_DATA
    INC DPTR
    CLR A
    SJMP PRINT_LOOP
END_PRINT:
    RET

LCD_CLEAR:
    MOV A, #01H
    ACALL LCD_CMD
    RET

LCD_LINE2:
    MOV A, #0C0H
    ACALL LCD_CMD
    RET

;=============================
; Display ADC Value
;=============================
DISPLAY_VALUE:
    MOV B, #10
    DIV AB          ; A/10 ? A=quotient, B=remainder

    ADD A, #30H
    ACALL LCD_DATA

    MOV A, B
    ADD A, #30H
    ACALL LCD_DATA
    RET

;=============================
; Delay
;=============================
DELAY:
    MOV R7, #200
D1: MOV R6, #255
D2: DJNZ R6, D2
    DJNZ R7, D1
    RET

;=============================
; Messages
;=============================
MSG1: DB "PRESSURE",0
MSG2: DB "NO PRESS",0

END