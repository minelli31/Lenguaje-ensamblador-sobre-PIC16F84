    List P=16F84A ; Procesador PIC16f84A
    #include "p16f84a.inc" ;Incluye las librerias    
    ; CONFIGURACION DEL PIC16F84A
        __CONFIG _FOSC_XT & _WDTE_OFF & _PWRTE_ON & _CP_OFF
    ;Variables
    CBLOCK   0X0C       ;RAM USUARIOS
    ENDC      
    ;CODIGO
        ORG	    0
    INICIO
        bsf	    STATUS,RP0
        clrf    TRISB	;PORTB todo como salida
        movlw   b'00011111'
        movwf   TRISA	; PORTA todo como entrada
        bcf	    STATUS,RP0
    START
        bsf	    PORTB,7
        call    RETARDO_5ms
        goto    START
    CBLOCK 
        Contador
        Contador_2
        Contador_3
    ENDC
     
    RETARDO_5ms	            ; subrutina con el retardo de 5ms	
        movlw   d'32'		; x		
        goto    Retardos_ms	
    Retardos_ms   
        movwf   Contador_2	
        nop
    Regresa_Cuenta_2
        movlw   d'38'		; y		 
        movwf   Contador			
    Regresa_Cuenta
        nop				
        decfsz  Contador,F		
        goto    Regresa_Cuenta		
        decfsz  Contador_2,F		
        goto    Regresa_Cuenta_2		
        return    
    ; 2cm + 2cm + 2cm + (2+ 4x + 4xy) -> x=32 y=38
        
    ;6 + (2 + 4*32 + 4*32*38) = 
    ;6 + (2 + 128 + 4864) =
    ;6 + (4994) =
    ;= 5000 us = 5 ms
    END