    List P=16F84A ; Procesador PIC16f84A
    #include "p16f84a.inc" ;Incluye las librerias    
        __CONFIG _FOSC_XT & _WDTE_OFF & _PWRTE_ON & _CP_OFF
    NumA     equ     0x0C		;dato a sumar
    NumB     equ     0x0D		;veces a sumar
    
    DH        equ     0x0E		;byte alto
    DL        equ     0x0F		;byte bajo
    	
    NumT     equ     0x10		;test
    k	     equ     0x0F		;test
        org     00h                     ;Vector de Reset
        goto     INICIO         
        org     0x05                    ;Vector de interrupcion
    INICIO    
        bsf	    STATUS,RP0
        clrf    TRISB		    ;PORTB todo como salida
        movlw   b'00011111'
        movwf   TRISA		    ;PORTA todo como entrada
        bcf	    STATUS,RP0
        call leerNumeros
    numeroA
        andlw   k
        movwf   NumA		    ;multiplicando
        return
    numeroB   
        andlw   k
        movwf   NumB		    ;multiplicador
        return
    leerNumeros
        movf    PORTA,W  
        ;movlw   b'00010011'	    
        movwf   NumT    
        btfsc   NumT,4		    ;Si tenemos un 1 en el bit 4 la siguiente instruccion se ejecuta y es el numero A
        call	numeroA
	btfss   NumT,4		    ;Si tenemos un 0 en el bit 4 la siguiente instruccion se ejecuta y es el numero B
	call	numeroB
        movf    PORTA,W  
	;movlw   b'00000111'
        movwf   NumT    
        btfsc   NumT,4		    ;Si tenemos un 1 en el bit 4 la siguiente instruccion se ejecuta y es el numero A
        call	numeroA
	btfss   NumT,4		    ;Si tenemos un 0 en el bit 4 la siguiente instruccion se ejecuta y es el numero B
	call	numeroB
        call    multiplica	    ;subrutina
        movf    DL,W
        movwf   PORTB		    ;mostramos el resultado en el puerto B
        goto    dormir		    ;hemos acabado
    multiplica
        clrf    DH
        clrf    DL
        movf    NumB,W		    ;W = multiplicador
        btfsc   STATUS,Z	    ;Salta si Z=1
        goto    dormir		    ;Z=0 multiplicador=0
    bucle
        movf    DL,W		    ;W=DL
        addwf   NumA,W		    ;W += multiplicando
        movwf   DL		    ;DL=W
        btfsc   STATUS,C	    ;Salta si C=0
        rrf	DH,F		    ;incf    DH,F
    resto
        decfsz  NumB,F		    ;multiplicador-1
        goto    bucle		    ;no hemos acabado
        return			    ;fin subrutina
    dormir        
        sleep
        end			    ;Fin del programa