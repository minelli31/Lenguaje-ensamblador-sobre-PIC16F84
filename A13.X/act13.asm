 List P=16F84A			    ; Procesador PIC16f84A
    #include "p16f84a.inc"      ;Incluye las librerias 
        
    ; CONFIGURACION DEL PIC16F84A
     __CONFIG _FOSC_XT & _WDTE_OFF & _PWRTE_ON & _CP_OFF

    ;Definimos Variables 
    CBLOCK  0x0C
	FlagNcs	    ; Bandera
	Contador
	Periodo_10ms
	NumT
	DL
	DH
	W_Temp
	STATUS_Temp
	Cont_Temp
	Resultado
    ENDC  
    ;CODIGO
        ORG	00h
        GOTO	INICIO
        ORG	04h
        GOTO	RTINCS		
    FLAGNCS_PORTB
	CLRF	FlagNcs	
	INCF	PORTB		; PortB := PortB+1.
	RETURN
    FLAGNCS_1
	MOVLW	d'1'
	MOVWF	FlagNcs	
	RETURN
    MULTIPLICA
	CLRF    DH
	CLRF    DL
	MOVF    PORTB,W		;W = multiplicador
	MOVWF	NumT
	BTFSC   STATUS,Z	;Salta si Z=1
	GOTO    BUCLE		;Z=0 multiplicador=0
    BUCLE_MULTIPLICA
	MOVF    DL,W		;W=DL
	ADDWF   PORTA,W		;W += multiplicando
	MOVWF   DL		;DL=W
	BTFSC   STATUS,C	;Salta si C=0
	RRF	DH,F		;incf    DH,F
    RESTO
	DECFSZ  NumT,F		;multiplicador-1
	GOTO    BUCLE_MULTIPLICA;no hemos acabado
	RETURN
    INICIO
        BSF	STATUS,RP0
        MOVLW   B'00000111'; 256 PRESCALER TMR0
	CLRF    TRISB
	MOVLW   B'00011111'
	CLRF    TRISA		
	MOVLW   b'00000111'     ; Se selecciona TMR0 modo temporizador y preescaler de 1/256.
        MOVWF   OPTION_REG 
        BCF	STATUS,RP0
        MOVLW   B'10100000'
        MOVWF   INTCON		; Habiltar timer0 y global respectivamente (T0IE - GIE) 
	MOVLW   b'00000010'	; Ponemos un valor en PORTA
	MOVWF	PORTA 
	MOVLW   b'00000000'	; Ponemos un valor en PORTB
	MOVWF	PORTB 
	MOVLW	d'216'
	MOVWF	Periodo_10ms	; 39*256= 9984us ~ 10ms
	MOVLW	d'100'
	MOVWF	Contador	; 100*10ms= 1000ms ~ 1s
        ;**** Bucle ****
    BUCLE
    	BTFSC	FlagNcs,0 
	CALL	FLAGNCS_PORTB
	CALL	MULTIPLICA	; Hacemos la multiplicacion
	MOVWF	Resultado	; Guardamos el resultado de la multiplicacion
	GOTO    BUCLE		
    INT1CS
        MOVLW   Periodo_10ms    
        MOVWF   TMR0
	RETURN
    ;INTERRUPCION desactivar flag interrupcion
    RTINCS
    	MOVWF   W_Temp		; Copiamos W a un registro Temporario.
	SWAPF   STATUS, W       ;Invertimos los nibles del registro STATUS.
	MOVWF   STATUS_Temp     ; Guardamos STATUS en un registro temporal.
	CALL    INT1CS		; Llamo al retardo de 10ms
	DECFSZ	Contador,F	; 100 * 10ms = 1s
	GOTO	RTINCS
	CALL	FLAGNCS_1	; Pongo la bandera a 1
	MOVLW	d'100'	
	MOVWF	Contador	; Restauro el contador
	BCF     INTCON,T0IF     ; Borro bandera de control de Interrupcion.
	GOTO    FIN_RTINCS	; Restauro valores.
    FIN_RTINCS
	SWAPF   STATUS_Temp,W   ; Invertimos lo nibles de STATUS_Temp.
	MOVWF   STATUS
	SWAPF   W_Temp,f	; Invertimos los nibles y lo guardamos en el mismo registro.
	SWAPF	W_Temp,W	; Invertimos los nibles nuevamente y lo guardamos en W.
	RETFIE                  ; Salimos de interrupción.
	END