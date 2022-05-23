   __CONFIG _CP_OFF & _WDT_OFF & _PWRTE_ON & _XT_OSC   ;Config

   LIST   P=16F84A   ;Procesador
   INCLUDE   <P16F84A.INC>   ;Fichero con las etiquetas
   
CBLOCK 0x0C         ;Bloque de variables asignadas a partir de 0x0C
    Segundos         ;Variable de segundos
    Periodo_10ms
ENDC         
;--------------------------------------Zona de codigos----------------------------------------
    RESET           
    ORG     0x00		; Aquí comienza el micro.
    GOTO    Inicio		; Salto a inicio de mi programa.
;**** Vector de Interrupcion ****
    ORG     0x04		; Atiendo Interrupcion.
    GOTO    RetNcs 
Inicio
    MOVLW   0x00   ;Carga 0 en W
    BSF	    STATUS,RP0   ;Acceso al banco 1
    MOVLW   b'00000000'	;Valor para configurar los puertos (todos como salida) copiado al W
    MOVWF   TRISB	    ;Fija PORTB<0:7> como salidas
    MOVLW   b'00011111'
    MOVWF   TRISA   
    MOVLW   b'00000111'     ; Se selecciona TMR0 modo temporizador y preescaler de 1/256.
    MOVWF   OPTION_REG
    BCF	    STATUS,RP0   ;Vuelve al banco 0 
Bucle  
    CALL   RetNcs	    ; Retardo de 1 segundo
    CALL   Contador   ; Incrementar contador
    GOTO   Bucle
;-------------------------Contador de segundos---------------------------- 
RetNcs
    MOVLW   0x00   ;Carga 0 en W
    MOVWF   TMR0   ;Carga el TMR0 con 0x00
    BCF	    INTCON,T0IF   ;Resetea el flag de desbordamiento del TMR0 
Timer0_Desborde
    BTFSS   INTCON,T0IF   ;Salta si se desborda el TMR0
    GOTO    Timer0_Desborde   ;Repite la subrutina porque no hubo overflow
    RETURN      ;Return para volver
;------------------------Actualizador de segundos--------------------------  
Contador  
    INCF    Segundos   ;Incrementa en 1 el contador de segundos
    MOVF    Segundos,W
    MOVWF   PORTB
    MOVLW   d'60'   ;Pone d60 en W
    SUBWF   Segundos,W   ;Resta Segundos - W y lo guarda en W
    BTFSC   STATUS,Z   ;Salta si Z=0, porque el segundero no llego a 60
    RETURN      ;Vuelve

    END      ;Fin del programa