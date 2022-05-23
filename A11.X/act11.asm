 List P=16F84A			    ; Procesador PIC16f84A
    #include "p16f84a.inc"      ;Incluye las librerias 
        
    ; CONFIGURACION DEL PIC16F84A
     __CONFIG _FOSC_XT & _WDTE_OFF & _PWRTE_ON & _CP_OFF
    
    ;Valores de definidos 
    ;Periodo_10ms EQU d'216';  39*256= 9984us ~ 10ms
    CBLOCK 0x0C         ;Bloque de variables asignadas a partir de 0x0C
	test_bucle         ;Variable verificacion del bucle
	Salida
	Periodo_10ms
    ENDC  
    ;CODIGO
        ORG	00h
        GOTO	INICIO
        ORG	04h
        GOTO	INT1CS	
    INICIO
        BSF	STATUS,RP0
        CLRF	Salida
        MOVLW   B'00000111'; 256 PRESCALER TMR0
        MOVWF   OPTION_REG 
        BCF	STATUS,RP0
        MOVLW   B'10100000'
        MOVWF   INTCON	    ;Habiltar timer0 y global respectivamente (T0IE - GIE) 
	MOVLW   d'216'	    ;39*256= 9984us ~ 10ms
        MOVWF   Periodo_10ms
    BUCLE	    
        INCF	test_bucle  ;test
	GOTO	BUCLE	
    ;INTERRUPCION
    INT1CS
        MOVLW   Periodo_10ms    
        MOVWF   TMR0
	INCF	Salida	    ;Contador de salida
        GOTO    FIN_INT   
    FIN_INT
        BCF	INTCON,T0IF
        RETFIE	    ;GIE
        END