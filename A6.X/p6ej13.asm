    list p=16F84A
    #include P16F84A.inc
    ;#include <RETARDOS.inc>
    __CONFIG   _CP_OFF & _WDT_OFF & _PWRTE_ON & _XT_OSC
    ;**** Definicion de variables ****
    ;FlagNcs	    EQU	    7       ; Definimos FlagNcs como el bit cero de un registro, en este caso PORTB.
    Contador	    EQU     0x0C    ; Contador para detectar 14 desbordes de TMR0.
    W_Temp	    EQU     0x0D    ; Registro para guardar temporalmente W.
    STATUS_Temp	    EQU     0x0E    ; Registro para guardar temporalmente STATUS
    DH		    EQU     0x0F    ;byte alto
    DL		    EQU     0x10    ;byte bajo
    NumT	    EQU	    0x11    ;variable temporal
    FlagNcs	    EQU	    0x12    ; Definimos FlagNcs como el bit cero del registro.
    Segundos	    EQU	    0x13    ;variable segundos
; Contadores para los retardos.
    R_ContA	    EQU	    0x14    
    R_ContB	    EQU	    0x15
    R_ContC	    EQU	    0x16
    Periodo_50ms    EQU	    d'195'  ; 195*256= 49920us = 50ms 
    Periodo_1000ms  EQU	    d'20'   ; 50ms*20=1000ms

  ;**** Inicio del Micro ****
    RESET           
    ORG     0x00		; Aquí comienza el micro.
    GOTO    Inicio		; Salto a inicio de mi programa.
    ;**** Vector de Interrupcion ****
    ORG     0x04		; Atiendo Interrupcion.
    GOTO    Inicio_RtiNcs 
    ; **** Programa Principal ****
    ;**** Configuracion de puertos ***
    ORG     0x05		; Origen del código de programa.
    Retardo_1s				; La llamada "call" aporta 2 ciclos máquina.
	MOVLW	d'10'			; Aporta 1 ciclo máquina. Este es el valor de "N". d'10'
	GOTO	Retardo_1Decima		; Aporta 2 ciclos máquina.
    Retardo_1Decima
	MOVWF	R_ContC			; Aporta 1 ciclo máquina.
    R1Decima_BucleExterno2
	MOVLW	d'100'			; Aporta Nx1 ciclos máquina. Este es el valor de "M".d'100'	
	MOVWF	R_ContB			; Aporta Nx1 ciclos máquina.
    R1Decima_BucleExterno
	MOVLW	d'249'			; Aporta MxNx1 ciclos máquina. Este es el valor de "K".d'249'
	MOVWF	R_ContA			; Aporta MxNx1 ciclos máquina.
    R1Decima_BucleInterno          
	NOP				; Aporta KxMxNx1 ciclos máquina.
	DECFSZ	R_ContA,F		; (K-1)xMxNx1 cm (si no salta) + MxNx2 cm (al saltar).
	GOTO	R1Decima_BucleInterno	; Aporta (K-1)xMxNx2 ciclos máquina.
	DECFSZ	R_ContB,F		; (M-1)xNx1 cm (cuando no salta) + Nx2 cm (al saltar).
	GOTO	R1Decima_BucleExterno	; Aporta (M-1)xNx2 ciclos máquina.
	DECFSZ	R_ContC,F		; (N-1)x1 cm (cuando no salta) + 2 cm (al saltar).
	GOTO	R1Decima_BucleExterno2	; Aporta (N-1)x2 ciclos máquina.
	RETURN	
    Cambio_FlagNcs_0
	BCF	FlagNcs,0	; FlagNcs a 0.
	CALL	Retardo_1s	;llamamos el retaraso de 1s.	
	INCF	PORTB		; PortB := PortB+1.
	RETURN
    Multiplica
	CLRF    DH
	CLRF    DL
	MOVF    PORTB,W		;W = multiplicador
	MOVWF	NumT
	BTFSC   STATUS,Z	;Salta si Z=1
	GOTO    Bucle		;Z=0 multiplicador=0
    Bucle_Multiplica
	MOVF    DL,W		;W=DL
	ADDWF   PORTA,W		;W += multiplicando
	MOVWF   DL		;DL=W
	BTFSC   STATUS,C	;Salta si C=0
	RRF	DH,F		;incf    DH,F
    Resto
	DECFSZ  NumT,F		;multiplicador-1
	GOTO    Bucle_Multiplica;no hemos acabado
	RETURN
    Inicio          
	BSF     STATUS,RP0      ; Pasamos de Banco 0 a Banco 1.
	CLRF    TRISB
	MOVLW   B'00011111'
	CLRF    TRISA		
	MOVLW   b'00000111'     ; Se selecciona TMR0 modo temporizador y preescaler de 1/256.
	MOVWF   OPTION_REG
	BCF     STATUS,RP0      ; Paso del Banco 1 al Banco 0
	BCF     FlagNcs,0       ; El FlagNcs comienza a 0.
	MOVLW   Periodo_50ms	; Cargamos variable en TMR0 para lograr aprox. 50ms.
	MOVWF   TMR0
	CLRF    Contador        ; Iniciamos contador.
	MOVLW   b'10100000'     ; Habilitamos GIE y T0IE (interrupción del TMR0)
	MOVWF   INTCON
	MOVLW   b'00000111'	; Ponemos un valor en PORTA
	MOVWF	PORTA 
	MOVLW   b'00000011'	; Ponemos un valor en PORTB
	MOVWF	PORTB 
    ;**** Bucle ****
    Bucle
	BTFSC   FlagNcs,0	; Si esta a 1, ponemos a 0.
	CALL    Cambio_FlagNcs_0
	CALL	Multiplica
	GOTO    Bucle           ; sin necesidad de utilizar tiempo en un bucle de demora.   
    ;**** Rutina de servicio de Interrupcion ****
    ;  Guardado de registro W y STATUS.
    Inicio_RtiNcs
	MOVWF   W_Temp  ; Copiamos W a un registro Temporario.
	SWAPF   STATUS, W       ;Invertimos los nibles del registro STATUS.
	MOVWF   STATUS_Temp     ; Guardamos STATUS en un registro temporal.
	BSF     FlagNcs,0       ; Ponemos el FlagNcs a 1.
    ;**** Interrupcion por TMR0 ****
    RtiNcs
	BTFSS   INTCON,T0IF     ; Consultamos si es por TMR0.
	GOTO    Fin_RtiNcs	; No, entonces restauramos valores.
	INCF	Segundos
	GOTO    Actualizo_TMR0  ; No, cargo TMR0 si salgo.
	BTFSS   FlagNcs,0
	GOTO    Cambio_FlagNcs
    Actualizo_TMR0		; Actualizo TMR0 para obtener una temporizacion de 50 ms.
	MOVLW   Periodo_50ms	; 50 ms
	MOVWF   TMR0
	BCF     INTCON,T0IF     ; Borro bandera de control de Interrupcion.
	GOTO    Fin_RtiNcs	; Restauro valores.
    Cambio_FlagNcs
	BSF     FlagNcs,0       ; FlagNcs a 1.
	GOTO    Actualizo_TMR0
    ; Restauramos los valores de W y STATUS.
    Fin_RtiNcs
	SWAPF   STATUS_Temp,W   ; Invertimos lo nibles de STATUS_Temp.
	MOVWF   STATUS
	SWAPF   W_Temp,f	; Invertimos los nibles y lo guardamos en el mismo registro.
	SWAPF	W_Temp,W	; Invertimos los nibles nuevamente y lo guardamos en W.
	RETFIE                  ; Salimos de interrupción.
    END