    list p=16F84A
    include P16F84A.INC
    
        org     00h		    ;VectordeReset
        goto    START         
        org     0x05	    ;Vector de interrupcion
    START             
        clrf    PORTB	    ;Inicializa los bits de salida
        bsf	    STATUS,RP0	;Selecciona la página 1
        movlw   b'00000000'	;Valor para configurar los puertos (todos como salida) copiado al W
        movwf   TRISB	    ;Fija PORTB<0:7> como salidas
        movlw   b'00011111' ;Valor para configurar los puertos (como entrada) copiado al W
        movwf   TRISA	    ;Fija PORTA<0:4> como entrada
        bcf	    STATUS,RP0	;Selecciona la página 0
    BUCLE
        movf    PORTA,W	    ;Leo las entradas
        movwf   PORTB	    ;Las paso a las salidas
        movlw   0x1F	    ;w=1F
        subwf   PORTA,W	    ;Porta-1F
        btfsc   STATUS,Z	;Z=1 -> PORTA=1F
        goto    DORMIR	    ;Z=1
        goto    BUCLE	    ;Z=0 -> analizamos las entradas
    DORMIR        
        sleep
        end			        ;Fin del programa fuente