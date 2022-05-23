    ;Subrutina Retcs---
    ;Haremos los calculos para un temporizador de 1ms con un prescaler de 64.
    ;Temporizador = Tcm * Prescaler (256 - Carga_TMR0)
    ;0,01 s = 10ms = 10000us => 1us * 64 (256 - Carga_TMR0)
    ;64 * Carga_TMR0 = 16384 - 10000
    ;Carga_TMR0 = 99.75 = 100
    ;Necesitamos que el valor de Carga_TMR0 sea 100 para un prescaler de 64	
    List P=16F84A			    ; Procesador PIC16f84A
    #include "p16f84a.inc"		    ;Incluye las librerias 
    ; CONFIGURACION DEL PIC16F84A
        __CONFIG _FOSC_XT & _WDTE_OFF & _PWRTE_ON & _CP_OFF
    
    ;Definimos Variables 
    CBLOCK		0x0C
	TMR0_Carga10ms		
	TimerN			;Variable N veces 10ms
	TimerN_temp
	Control			;Variable de control, bit 0
    ENDC
    ;CODIGO
        ORG		0
    INICIO
        bsf	STATUS,RP0
        movlw	b'00000101'
        movwf	OPTION_REG	;Prescaler de 64 asignado al TMR0
        bcf	STATUS,RP0
	movlw	d'100'		;100
	movwf	TMR0_Carga10ms
    START
	movlw	b'00000001'
	movwf	Control
	movlw	d'3'		; N veces que se jecutará el Retcs
        goto	RetNcs		;Llamamos a la funcion de retardo de 10ms (1 centésima de segundo)
    Retcs
        movlw	TMR0_Carga10ms	;Carga el Timer0 con el valor que queremos para 10ms
        movwf	TMR0
        bcf	INTCON,T0IF	;Reseteamos el Flag de desbordamiento del TMR0
    Timer0_Desbordamiento
        btfss	INTCON,T0IF	;Comprobamos el desbordamiento en el TMR0
        goto	Timer0_Desbordamiento	;Si aún no se ha desbordado repite la operacion 
    RetNcs
	btfsc	Control,0	    ;Si el bit de control es uno cargamos W en TimerN.				    
	movwf	TimerN		    ;Esta intruccion solo se ejecuta la primera vez que entra en RetNcs
	bcf	Control,0	    ;Limpiamos el bit de control para que no se ejecute mas
	decfsz	TimerN,F
        call	Retcs 
	END