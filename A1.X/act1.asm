    ;Para realizar la comparacion restamos los dos número (A-B).
    ; Si al realizar la resta los dos números son iguales el resultado será cero, activándose el bit Z del registro de
    ; Estado.
    ; Si al realizar la resta (suma del complemento a 2 de B) se produce un bit de acarreo el resultado es positivo
    ; (A> B). Ejemplo: 3-2 = 0011 + 1110 = 1 0001.
    ; Si no se produce acarreo el resultado es negativo (A<B). Ejemplo: 2-3 = 0010 + 1101 = 0 1111.
    list p=16F84A
    include <P16F84A.INC>
    NumA equ 0x0C ;Variable del número A
    NumB equ 0x0D ;Variable del número B
    Mayor equ 0x0E ;Variable que almacenará el mayor de los números
    org 0x00 ;Vector de reset
        goto Inicio ;Salto incondicional al principio del programa
    org 0x05 ;Vector de interrupcion
    Inicio movf NumB,W ;NumB -> W (acumulador)
        subwf NumA,W ;A-W -> W
        btfsc STATUS,Z ;Bit de cero del registro de Estado a 1 0
        goto A_igual_B ;Si
        btfsc STATUS,C ;Bit de acarreo del registro de Estado a 1
        goto A_menor_B ;Si
    A_menor_B movf NumB,W ;No, A es menor que B
        movwf Mayor ;Suma A más B ;movwf Mayor Suma A más B 
        goto Stop
    A_mayor_B movf NumA,W ;No, A es menor que B
        movwf Mayor ;Suma A más B
        goto Stop     ;Fin
    A_igual_B clrf Mayor ;Pone a 0 el resultado
    Stop nop ;Poner breakpoint de parada
    end ;Fin del programa fuente