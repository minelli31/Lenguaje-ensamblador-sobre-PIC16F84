    List P=16F84A			    ; Procesador PIC16f84A
    #include "p16f84a.inc"      ;Incluye las librerias 
        
    ; CONFIGURACION DEL PIC16F84A
     __CONFIG _FOSC_XT & _WDTE_OFF & _PWRTE_ON & _CP_OFF

    ;Definimos Variables 
    CBLOCK  0x0C
	FlagNcs	    ; Bandera
	Contador
	Periodo_10ms
    ENDC   
    ;CODIGO
        ORG	00h
        GOTO	INICIO
        ORG	04h
        GOTO	RTINCS  
    INICIO
        BSF	STATUS,RP0
        MOVLW   B'00000111'; 256 PRESCALER TMR0
        MOVWF   OPTION_REG 
        BCF	STATUS,RP0
        MOVLW   B'10100000'
        MOVWF   INTCON	    ;	Habiltar timer0 y global respectivamente (T0IE - GIE) 
	MOVLW	d'216'
	MOVWF	Periodo_10ms ;	39*256= 9984us ~ 10ms
	MOVLW	d'100'
	MOVWF	Contador    ;	100*10ms= 1000ms ~ 1s
    BUCLE
        MOVLW	d'0'
        MOVWF	FlagNcs
        GOTO    BUCLE		    
    ;INTERRUPCION
    RTINCS
    	CALL    INT1CS
    	DECFSZ	Contador,F 
    	GOTO	RTINCS
    	MOVLW	d'1'
    	MOVWF	FlagNcs
    	GOTO    FIN_INT
    INT1CS
        MOVLW   Periodo_10ms    
        MOVWF   TMR0
	RETURN     
    FIN_INT
        BCF	INTCON,T0IF
        RETFIE	    ;GIE
	END