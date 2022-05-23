
__CONFIG   _CP_OFF &  _WDT_OFF & _PWRTE_ON & _XT_OSC
list     p=16f84a
include "p16f84a.inc"

ORG	    0x2100		; Direccion 0 de la EEPROM
DE	    0x00		; Telemetria a cero.
Dato1	    equ	    0x0C
Dato2	    equ	    0x0D
DH	    equ     0x0E         ; byte alto
DL	    equ     0x0F         ; byte bajo
NumA        equ	    0x10	;Numero A
NumB        equ	    0x11	;Numero B
ResultAxB	    equ     0x12	; Resultado de NumA x NumB
Conta	    equ	    0x13        ; Contador
RegW        equ	    0x14        ; Registro W
RegS        equ	    0x15        ; Registro STATUS
FlagL	    equ	    0x16        ; Flag Lecturas
n1	    equ	    0x17        ; 1ªLectura
n2	    equ	    0x18        ; 2ªLectura
n3	    equ	    0x19        ; 3ªLectura
n4	    equ	    0x1A        ; 4ªLectura
n5	    equ	    0x1B        ; 5ªLectura
n6	    equ	    0x1C        ; 6ªLectura
n7	    equ	    0x1D        ; 7ªLectura
n8	    equ	    0x1E        ; 8ªLectura
Err	    equ	    0x1F        ; Error
ErrAnt	    equ	    0x20        ; Error Anterior
Integ	    equ	    0x21        ; Integral
Deriv	    equ	    0x22        ; Derivada
Control	    equ	    0x23        ; Control
Referen	    equ	    0x24        ; Referencia
MedFil	    equ	    0x25        ; Medida filtrada
kp	    equ	    0x26        ; Kp
ki	    equ	    0x27        ; Ki
kd	    equ	    0x28        ; Kd
;------------------------------------------------------------------
	org	    0x00
	GOTO	INICIO
	org	    0x04
	GOTO	INT_Timer
INICIO 
	BSF		STATUS,5	; Banco 1 (RP0)
	MOVWF	b'00000000'
	MOVWF	TRISB		; Puerto B como salida
	MOVWF	b'00011111'
	MOVWF	TRISA		; Puerto A como entrada
	CLRW			; Borro W
	MOVLW	0x07		; Cargo W con 00000111 (PSAx,1,1,1)
	MOVWF	OPTION_REG	; Divisor = 256
	BCF		STATUS,5	; Banco 0 (RP0)
	MOVLW	0x88		; Cargo W con 10101000
	MOVWF	INTCON		; Habilitamos GIE y RBIE
	CLRF	PORTB		; Borro PORTB
	CLRF	PORTA		; Borro PORTA
	CLRF	Conta		; Borro Conta
	CLRF	Dato1		; Borramos
	CLRF	Dato2		; Borramos
	CLRF	NumA		; Borramos
	CLRF	NumB		; Borramos
	CLRF	ResultAxB	; Borramos
	MOVLW	0xA		; 10cs = 0,1s
	MOVWF	Conta    
	MOVLW	0xD9		; Cargo W con 0x00-0x27
	MOVWF	TMR0		; Lo paso a TMR0
	MOVLW	0x1		; Cargo W con 1
	MOVWF	FlagL		; Inicializo FlagL
PRINCIPAL
	; Pasamos el cálculo al actuador (PORTA)
	MOVF	Control,W	; W = Control
	MOVWF	PORTA		; Lo pasamos a PORTA
	GOTO	PRINCIPAL
;Interrupcion
;0,01S = 10MS = 1CS --> LEER PORTB 
;0,1S = 100MS = 10CS -> CALC MED.F -> CALC CONTROL -> GUARDAR DATO 

INT_Timer
	BCF		INTCON,GIE	; Deshabilitar interrupciones
	MOVWF	RegW		; Guardamos W
	SWAPF	STATUS,W	; Invertimos nibbles
	MOVWF	RegS		; Guardamos estado
	CALL	LECTURAS	; Leo puerto B
	DECFSZ	Conta,F		; Conta -=1
	GOTO	SIGO		; No hemos acabado
	MOVLW	0xA		; 10cs = 0,1s
	MOVWF	Conta		; Conta = 0xA
	CALL	MEDIDAFILTRADA	; Calculo Medida filtrada
	CALL	CONTROLADOR	; Calculo Control
	MOVF	Control,W	; W = Control
	CALL	GUARDAR		; Guardo telemetrias
SIGO
	MOVLW	0xD9		; Cargo W con 0x00-0x27
	MOVWF	TMR0		; Lo paso a TMR0
	BCF		INTCON,T0IF	; Limpiar bandera de interrupcion
	SWAPF	RegS,W		; Invertimos nibbles de RegS
	MOVWF	STATUS		; Restauramos estado
	SWAPF	RegW,W		; Restauramos W
	BSF		INTCON,GIE	; Habilitar interrupciones
	RETFIE			; Vuelvo de la interrupcion

;Tomar lecturas
LECTURAS
	MOVF	1,W		;
	SUBWF	FlagL,W		;
	BTFSC	STATUS,Z	;
	GOTO	FLAG1		; 1ªLectura
	MOVF	2,W		;
	SUBWF	FlagL,W		;
	BTFSC	STATUS,Z	;
	GOTO	FLAG2		; 2ªLectura
	MOVF	3,W		;
	SUBWF	FlagL,W		;
	BTFSC	STATUS,Z	;
	GOTO	FLAG3		; 3ªLectura
	MOVF	4,W		;
	SUBWF	FlagL,W		;
	BTFSC	STATUS,Z	;
	GOTO	FLAG4		; 4ªLectura
	MOVF	5,W		;
	SUBWF	FlagL,W		;
	BTFSC	STATUS,Z	;
	GOTO	FLAG5		; 5ªLectura
	MOVF	6,W		;
	SUBWF	FlagL,W		;
	BTFSC	STATUS,Z	;
	GOTO	FLAG6		; 6ªLectura
	MOVF	7,W		;
	SUBWF	FlagL,W		;
	BTFSC	STATUS,Z	;
	GOTO	FLAG7		; 7ªLectura
	GOTO	FLAG8		; 8ªLectura
FLAG1
	MOVF	PORTB,W		;
	SUBLW	0x00000000	; Complemento a 2
	MOVWF	n1		; 1ª lectuta
	INCF	FlagL,1		; FlagL +=1
	GOTO	FIN		;
FLAG2
	MOVF	PORTB,W		;
	SUBLW	0x00000000	; Complemento a 2
	MOVWF	n2		; 2ª lectuta
	INCF	FlagL,1		; FlagL +=1
	GOTO	FIN		;
FLAG3
	MOVF	PORTB,W		;
	SUBLW	0x00000000	; Complemento a 2
	MOVWF	n3		; 3ª lectuta
	INCF	FlagL,1		; FlagL +=1
	GOTO	FIN		;
FLAG4
	MOVF	PORTB,W		;
	SUBLW	0x00000000	; Complemento a 2
	MOVWF	n4		; 4ª lectuta
	INCF	FlagL,1		; FlagL +=1
	GOTO	FIN		;            
FLAG5
	MOVF	PORTB,W		;
	SUBLW	0x00000000	; Complemento a 2
	MOVWF	n5		; 5ª lectuta
	INCF	FlagL,1		; FlagL +=1
	GOTO	FIN		;
FLAG6
	MOVF	PORTB,W		;
	SUBLW	0x00000000	; Complemento a 2
	MOVWF	n6		; 6ª lectuta
	INCF	FlagL,1		; FlagL +=1
	GOTO	FIN		;
FLAG7
	MOVF	PORTB,W		;
	SUBLW	0x00000000	; Complemento a 2
	MOVWF	n7		; 7ª lectuta
	INCF	FlagL,1		; FlagL +=1
	GOTO	FIN		;
FLAG8
	MOVF	PORTB,W		;
	SUBLW	0x00000000	; Complemento a 2
	MOVWF	n8		; 8ª lectuta
	MOVF	1,W		; Reinicio flag
	MOVWF	FlagL		;
FIN
	RETURN			; fin subrutina

;Calcular el dato MedidaFiltrada

MEDIDAFILTRADA
	;(n1+n2)/2
	MOVF	n1,W		; W = n1
	ADDWF	n2,1		; n1+n2 y guardo en n2
	RRF		n2,1		; roto a dcha y guardo en n2
	;(n3+n4)/2
	MOVF	n3,W		; W = n3
	ADDWF	n4,1		; n3+n4 y guardo en n4
	RRF		n4,1		; roto a dcha y guardo en n4
	;(n5+n6)/2
	MOVF	n5,W		; W = n5
	ADDWF	n6,1		; n5+n6 y guardo en n6
	RRF		n6,1		; roto a dcha y guardo en n6
	;(n7+n8)/2
	MOVF	n7,W		; W = n7
	ADDWF	n8,1		; n7+n8 y guardo en n8
	RRF		n8,1		; roto a dcha y guardo en n8
	;(n2+n4)/2
	MOVF	n2,W		; W = n2
	ADDWF	n4,1		; n2+n4 y guardo en n4
	RRF		n4,1		; roto a dcha y guardo en n4
	;(n6+n8)/2
	MOVF	n6,W		; W = n6
	ADDWF	n8,1		; n6+n8 y guardo en n8
	RRF		n8,1		; roto a dcha y guardo en n8
	;(n4+n8)/2
	MOVF	n4,W		; W = n4
	ADDWF	n8,1		; n4+n8 y guardo en n8
	RRF		n8,0		; roto a dcha y guardo en W
	MOVWF	MedFil		; Guardo la Medida Filtrada
	RETURN			; fin subrutina

;Calcular la accion de control (controlador PID)
;ErrAnterior=Err
;Err= Referencia - MedidaFiltrada
;Integral= Integral + Err
;Derivativa= Err- ErrAnterior
;Control= Kp*Err+Ki*Integral+Kd*Derivativa
CONTROLADOR
	; Valores regulacion PID
	MOVLW	0x1		; w=1
	MOVWF	kp		; Kp=1
	MOVLW	0x1		; w=1
	MOVWF	ki		; Ki=1
	MOVLW	0x1		; w=1
	MOVWF	kd		; Kd=1
	; Err = Referencia - MedidaFiltrada
	MOVF	Err,W	        ; W = Err
	MOVWF	ErrAnt		; ErrAnt = Err
	MOVF	MedFil,W	; W = MedFil
	SUBWF	Referen,0	; f - w ? Referen - MedFil
	MOVWF	Err		; Err = Referen - MedFil
	; Integral = Integral + Err
	ADDWF	Integ,1		; Integ += Err
	; Derivativa = Err - ErrAnterior
	MOVF	ErrAnt,W	; W = ErrAnt
	SUBWF	Err,0		; f - w ? Err - ErrAnt
	MOVWF	Deriv		; Deriv = Err - ErrAnt
	; Control = Kp*Err+Ki*Integral+Kd*Derivativa
	MOVF	kp,W		; W=Kp
	MOVWF	Dato1		; Dato1 = Kp
	MOVF	Err,W		; W=Err
	MOVWF	Dato2		; Dato2 = Err
	CALL	MULTIPLICA	; Multiplico
	ADDWF	Control,1	; Control = Kp*Err
	MOVF	ki,W		; W=Ki
	MOVWF	Dato1		; Dato1 = Ki
	MOVF	Integ,W		; W=Integ
	MOVWF	Dato2		; Dato2 = Integ
	CALL	MULTIPLICA	; Multiplico
	ADDWF	Control,1	; Control = Kp*Err+Ki*Integral
	MOVF	kd,W		; W=Kd
	MOVWF	Dato1		; Dato1 = Kd
	MOVF	Deriv,W		; W=Deriv
	MOVWF	Dato2		; Dato2 = Deriv
	CALL	MULTIPLICA	; Multiplico
	ADDWF	Control,1	; Control = Kp*Err+Ki*Inte+Kd*Deriv
	RETURN			; fin subrutina

;Guardar telemetrias
GUARDAR
	CBLOCK
	GuardaINTCON
	ENDC
	BCF		STATUS,5	; Banco 0
	MOVWF	EEDATA		; El byte a escribir
	MOVF	INTCON,W        ; Valor anterior de INTCON
	MOVWF	GuardaINTCON
	BSF		STATUS,5        ; Banco 1
	BCF		INTCON,GIE	; Deshabilita interrupciones
	BSF		EECON1,WREN	; Habilita escritura
	MOVLW	0x55
	MOVWF	EECON2
	MOVLW	0xAA
	MOVWF	EECON2
	BSF		EECON1,WR	; Inicia la escritura.
TERMINA
	BTFSC	EECON1,WR	; ¿Fin de la escritura?
	GOTO	TERMINA		; No
	BCF		EECON1,WREN	; No escritura en EEPROM
	BCF		EECON1,EEIF	; Limpia flag
	BCF		STATUS,5        ; Banco 0
	MOVF	GuardaINTCON,W	; Restaura INTCON
	MOVWF	INTCON
	RETURN			; fin subrutina
;Multiplicacion
MULTIPLICA
	CLRF	DH
	CLRF	DL
	MOVF	Dato1,W		; W = multiplicador
	BTFSC	STATUS,Z	; Salta si Z=1
	RETURN			; Z=0 hemos terminado
	MOVF	Dato2,W		; W = multiplicador
	BTFSC	STATUS,Z	; Salta si Z=1
	RETURN			; Z=0 hemos terminado
BUCLE
	MOVF	DL,W		; W=DL
	ADDWF	Dato1,W		; W += multiplicando
	MOVWF	DL		; DL=W
	BTFSC	STATUS,C	; Salta si C=0
	INCF	DH,F		;
	DECFSZ	Dato2,F		; multiplicador-1
	GOTO	BUCLE		; no hemos acabado
	MOVWF	DL		; DL=W
	MOVWF	ResultAxB	; MULTIPLICA=W
	;MOVWF     PORTB		; Puerto B=W
	CLRF	Dato2
	RETURN			; fin subrutina

	END            ; fin
