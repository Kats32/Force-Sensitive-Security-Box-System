ORG 0000H

; Port definitions
ADC_DATA   EQU P1
WR_PIN     EQU P3.6
RD_PIN     EQU P3.7
INTR_PIN   EQU P3.2
BUZZER     EQU P2.0

START:
    MOV P1, #0FFH        ; Make P1 input
    CLR BUZZER           ; Buzzer OFF

MAIN:
    ACALL READ_ADC       ; Get FSR value
    MOV A, R0            ; Move ADC value to A

    CJNE A, #50, CHECK   ; Compare with threshold (adjust)
    SJMP MAIN

CHECK:
    JC NO_PRESSURE       ; If less than threshold

PRESSURE:
    SETB BUZZER          ; Pressure detected
    SJMP MAIN

NO_PRESSURE:
    CLR BUZZER
    SJMP MAIN

;-----------------------------------
; ADC Reading Subroutine
;-----------------------------------
READ_ADC:
    CLR WR_PIN           ; Start conversion
    SETB WR_PIN

WAIT_INTR:
    JB INTR_PIN, WAIT_INTR  ; Wait until conversion complete

    CLR RD_PIN           ; Enable ADC output
    MOV A, ADC_DATA      ; Read digital value
    MOV R0, A
    SETB RD_PIN          ; Disable read

    RET

END