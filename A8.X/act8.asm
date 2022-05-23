    ; Temporizador = Tcm * Prescaler (256 - Carga\_TMR0)
    ; 0,01 s = 10ms = 10000us => 1us * 64 (256 - Carga\_TMR0)
    ; 64 * Carga\_TMR0 = 16384 - 10000
    ; Carga\_TMR0 = 99.75 = 100
    List P=16F84A			    ; Procesador PIC16f84A
    #include "p16f84a.inc"		    ;Incluye las librerias 
    ; CONFIGURACION DEL PIC16F84A
        __CONFIG _FOSC_XT & _WDTE_OFF & _PWRTE_ON & _CP_OFF
    
    ;Definimos Variables 
    CBLOCK		0x0C
	TMR0_Carga10ms		
	FLAG			;Variable de control y debug
    ENDC
    ;CODIGO
        ORG		0
    INICIO
        bsf	STATUS,RP0
        movlw	b'00000101'
        movwf	OPTION_REG	;Prescaler de 64 asignado al TMR0
        bcf	STATUS,RP0
	movlw	d'100'
	movwf	TMR0_Carga10ms
    START
	clrf	FLAG		;Limpiamos el Flag 	
        call	Retcs		;Llamamos a la funcion de retardo de 10ms (1 centesima de segundo)
    Retcs
	incf	FLAG		;Incrementamos el Flag
        movlw	TMR0_Carga10ms	;Carga el Timer0 con el valor que queremos para 10ms
        movwf	TMR0
        bcf	INTCON,T0IF	;Reseteamos el Flag de desbordamiento del TMR0
    Timer0_Desbordamiento
        btfss	INTCON,T0IF	;Comprobamos el desbordamiento en el TMR0
        goto	Timer0_Desbordamiento	;Si aun no se ha desbordado repite la operacion
        return
    END