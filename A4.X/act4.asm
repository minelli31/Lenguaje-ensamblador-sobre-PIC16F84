    list p=16F84A
    include <P16F84A.INC>
    NumA equ 0x0C ;Variable del número A
    NumB equ 0x0D ;Variable del número B
    Mayor equ 0x0E ;Variable que almacenará el mayor de los números
    Mayor1 equ 0x0F ;Variable 1 que almacenará el mayor de los números
    Mayor2 equ 0x10 ;Variable 2 que almacenará el mayor de los números
    org 0x00 ;Vector de reset
        goto Inicio ;Salto incondicional al principio del programa
    org 0x05 ;Vector de interrupcion
    Inicio 
        ;------------------Primera comparacion
        movlw 0xC
        movwf NumA
        movlw 0x03
        movwf NumB
        call Comparar
        movf Mayor,W
        movwf Mayor1 ;Guardamos el valor en una variable
        ;------------------Segunda comparacion
        movlw 0x07
        movwf NumA
        movlw 0xA
        movwf NumB
        call Comparar
        movf Mayor,W
        movwf Mayor2 ;Guardamos el valor en una variable
    Comparar
        movf NumB,W ;NumB -> W (acumulador)
        subwf NumA,W ;A-W -> W
        btfsc STATUS,Z ;Bit de cero del registro de Estado a 1 
        goto A_igual_B ;Si
        btfss STATUS,C ;Bit de acarreo del registro de Estado a 0 
        ;Si el bit de acarreo es 0 la siguiente instruccion es ejecutada y el resultado es negativo 
        ; y si es 1 la siguiente instruccion es descartada.
        goto A_menor_B ;Si 
        btfsc STATUS,C ;Bit de acarreo del registro de Estado a 1
        ;Si el bit de acarreo es 1 la siguiente instruccion es ejecutada y el resultado es positivo
        ; y si es 0 la siguiente instruccion es descartada.
        goto A_mayor_B ;Si
    return
    A_menor_B movf NumB,W ;No, A es menor que B
        movwf Mayor ;Suma A más B ;
    return
    A_mayor_B movf NumA,W ;No, A es mayor que B
        movwf Mayor ;Suma A más B
    return
    A_igual_B clrf Mayor ;Pone a 0 el resultado
        Stop nop ;Poner breakpoint de parada
    return
    end ;Fin del programa fuente
   