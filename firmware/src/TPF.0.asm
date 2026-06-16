    LIST p=16f887
    #INCLUDE "p16f887.inc"

;CONFIGURACIÓN
    __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON
    __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF

;VARIABLES
W_TEMP        EQU 0x70
STATUS_TEMP   EQU 0x71
 
INDEX         EQU 0x20
NUM0          EQU 0x21    ;'n' 
NUM1          EQU 0x22    ;'c'
NUM2          EQU 0x23    ;Unidad en modo distancia
NUM3          EQU 0x24    ;Decena en modo distancia
    
;Variables para el ADC y UART
ADC_H         EQU 0x25
ADC_L         EQU 0x26
RESTO_L       EQU 0x27
DATO_RECIBIDO EQU 0x2A
TEMP_MATH     EQU 0x35
UMBRAL        EQU 0x36
     
;Variables de Estado y Texto
MODO          EQU 0x2B    
TXT_CASA0     EQU 0x2C    ; 'A'
TXT_CASA1     EQU 0x2D    ; 'S'
TXT_CASA2     EQU 0x2E    ; 'A'
TXT_CASA3     EQU 0x2F    ; 'C'

TXT_CALLE0    EQU 0x30    ; 'L'
TXT_CALLE1    EQU 0x31    ; 'L'
TXT_CALLE2    EQU 0x32    ; 'A'
TXT_CALLE3    EQU 0x33    ; 'C'

; Variables para el Límite y Error
FLAG_DIGITO   EQU 0x37    
DIST_NUEVA    EQU 0x38   
CONT_TEMP     EQU 0x39    
TXT_LIM0      EQU 0x3A    ; Unidad 
TXT_LIM1      EQU 0x3B    ; Decena 
TXT_LIM2      EQU 0x3C    ; '-'
TXT_LIM3      EQU 0x3D    ; 'L'
TXT_ERR0      EQU 0x3E    ; '-' 
TXT_ERR1      EQU 0x3F    ; 'r' 
TXT_ERR2      EQU 0x40    ; 'r' 
TXT_ERR3      EQU 0x41    ; 'E' 

    ORG 0x00
    GOTO INICIO
    ORG 0x04
    GOTO ISR

HABILITACION_DISPLAY:
    ADDWF   PCL, F
    RETLW   B'00000001'   ; RD0 
    RETLW   B'00000010'   ; RD1 
    RETLW   B'00000100'   ; RD2 
    RETLW   B'00001000'   ; RD3 

TABLA_DISPLAY:
    ADDWF   PCL, F
    RETLW   B'00111111'   ;0  [0x00]
    RETLW   B'00000110'   ;1  [0x01]
    RETLW   B'01011011'   ;2  [0x02]
    RETLW   B'01001111'   ;3  [0x03]
    RETLW   B'01100110'   ;4  [0x04]
    RETLW   B'01101101'   ;5  [0x05]
    RETLW   B'01111101'   ;6  [0x06]
    RETLW   B'00000111'   ;7  [0x07]  
    RETLW   B'01111111'   ;8  [0x08]
    RETLW   B'01101111'   ;9  [0x09]
    ; Letras de control:
    RETLW   B'01110111'   ;A  [0x0A]
    RETLW   B'01101101'   ;S  [0x0B]
    RETLW   B'00111001'   ;C  [0x0C]
    RETLW   B'00111000'   ;L  [0x0D]
    ; Letras minúsculas fijas
    RETLW   B'01011000'   ;c  [0x0E]
    RETLW   B'01010100'   ;n  [0x0F]
    RETLW   B'01000000'   ;-  [0x10]
    RETLW   B'01111001'   ;E  [0x11]
    RETLW   B'01010000'   ;r  [0x12] 
    
INICIO:
    CLRF  NUM0
    CLRF  NUM1
    CLRF  NUM2
    CLRF  NUM3
    CLRF  PORTB  
    CLRF  PORTD  
    CLRF  DATO_RECIBIDO
    CLRF  MODO          ; Modo 0 por defecto (Distancia)
    CLRF  FLAG_DIGITO   

    MOVLW .40           ;umbral de arranque = 40cm
    MOVWF UMBRAL
    
    ; Cargar los equivalentes de letras en las variables de texto fijo
    MOVLW 0x0A          ; 'A'
    MOVWF TXT_CASA0
    MOVLW 0x0B          ; 'S'
    MOVWF TXT_CASA1
    MOVLW 0x0A          ; 'A'
    MOVWF TXT_CASA2
    MOVLW 0x0C          ; 'C'
    MOVWF TXT_CASA3

    MOVLW 0x0D          ; 'L'
    MOVWF TXT_CALLE0
    MOVLW 0x0D          ; 'L'
    MOVWF TXT_CALLE1
    MOVLW 0x0A          ; 'A'
    MOVWF TXT_CALLE2
    MOVLW 0x0C          ; 'C'
    MOVWF TXT_CALLE3
    
    ; Pre-configurar el texto fijo para L-XX
    MOVLW 0x0D          ; Letra 'L'
    MOVWF TXT_LIM3
    MOVLW 0x10          ; Guion '-'
    MOVWF TXT_LIM2

    ; Pre-configurar el texto fijo para "Err-"
    MOVLW 0x11          ; 'E'
    MOVWF TXT_ERR3
    MOVLW 0x12          ; 'r'
    MOVWF TXT_ERR2
    MOVLW 0x12          ; 'r'
    MOVWF TXT_ERR1
    MOVLW 0x10          ; '-'
    MOVWF TXT_ERR0
 

; CONFIGURACIÓN
    
    BSF    STATUS, RP0
    BSF    STATUS, RP1   ; Banco 3
    MOVLW  B'00000001'   ;AN0
    MOVWF  ANSEL
    CLRF   ANSELH     

     ; --- CONFIGURACIÓN DEL PWM (TIMER 2) ---
    BANKSEL PR2           
    MOVLW   .255            ; Período del PWM 
    MOVWF   PR2

    BANKSEL T2CON          
    MOVLW   B'00000100'     ; Prescaler 1:1 y encendemos el Timer 2
    MOVWF   T2CON

    MOVLW   B'00001100'     ; Configura el módulo CCP1 en modo PWM básico
    MOVWF   CCP1CON

    ; 2. Configurar TRIS y ADCON1 
    BSF    STATUS, RP0
    BCF    STATUS, RP1  
    CLRF   TRISB         ; PORTB segmentos
    MOVLW  B'11110000'   ; RD0-RD3 multiplexado
    MOVWF  TRISD
    BSF    TRISA, 0      ; AN0 entrada sensor
    MOVLW  B'10000000'   
    MOVWF  TRISC
    
    BCF     TRISC, 2     ; RC2 salida (MOTOR)
        
    MOVLW  B'00000000'  
    MOVWF  ADCON1

    MOVLW  D'25'         ; 9600 baudios
    MOVWF  SPBRG
    MOVLW  B'00100100'   
    MOVWF  TXSTA         
    
    MOVLW  B'00000111'   ; Prescaler Timer0 1:256
    MOVWF  OPTION_REG

    ; 3. Inicializar Periféricos
    BCF    STATUS, RP0  
    
    MOVLW  B'10010000'   ; SPEN=1, CREN=1
    MOVWF  RCSTA         ; Recepcion
 
    MOVLW  D'237'
    MOVWF  TMR0          
    
    MOVLW  B'01000001'   ; Fosc/8, ADON=1, Canal AN0 seleccionado
    MOVWF  ADCON0
 
; HABILITACIÓN DE INTERRUPCIONES
    BSF    INTCON, TMR0IE
    BSF    INTCON, GIE
    CLRF   INDEX
 
BUCLE_PRINCIPAL:
    
    ;TIEMPO DE ADQUISICIÓN DEL ADC
    MOVLW   D'50'
    MOVWF   RESTO_L          
DELAY_ADC:
    DECFSZ  RESTO_L, F       
    GOTO    DELAY_ADC
    
    ;LEER SENSOR
    BSF     ADCON0, GO_DONE     
ESPERA_ADC:
    BTFSC   ADCON0, GO_DONE      
    GOTO    ESPERA_ADC      
    
    MOVF    ADRESH, W            
    CALL    CALCULAR_CM_SHARP    

    ;SECCIÓN DE COMPARACIÓN INTEGRADA EN EL FLUJO
    MOVF    TEMP_MATH, W       ;CM reales
    SUBWF   UMBRAL, W          ;UMBRAL - TEMP_MATH
    BTFSC   STATUS, C       
    GOTO    LLAMAR_PRENDER     
    
LLAMAR_APAGAR:
    CALL    APAGAR_PWM         
    GOTO    SECCION_UART

LLAMAR_PRENDER:
    CALL    PRENDER_PWM
    
    
SECCION_UART:
    BTFSS   PIR1, RCIF      
    GOTO    BUCLE_PRINCIPAL 

    MOVF    RCREG, W        
    MOVWF   DATO_RECIBIDO
    
    ; INGRESAR LETRAS DESDE LA UART
EVALUAR_H:
    XORLW   A'H'         
    BTFSC   STATUS, Z     
    GOTO    ACTIVAR_MODO_CASA
    MOVF    DATO_RECIBIDO, W
    XORLW   A'h'          
    BTFSC   STATUS, Z
    GOTO    ACTIVAR_MODO_CASA

EVALUAR_C:
    MOVF    DATO_RECIBIDO, W
    XORLW   A'C'          
    BTFSC   STATUS, Z
    GOTO    ACTIVAR_MODO_CALLE
    MOVF    DATO_RECIBIDO, W
    XORLW   A'c'         
    BTFSC   STATUS, Z
    GOTO    ACTIVAR_MODO_CALLE

EVALUAR_D:
    MOVF    DATO_RECIBIDO, W
    XORLW   A'D'
    BTFSC   STATUS, Z
    GOTO    ACTIVAR_MOSTRAR_DISTANCIA
    MOVF    DATO_RECIBIDO, W
    XORLW   A'd'
    BTFSC   STATUS, Z
    GOTO    ACTIVAR_MOSTRAR_DISTANCIA


; INGRESAR NÚMEROS DESDE LA UART
EVALUAR_NUMEROS:
    ; Sólo caracteres del 0-9
    MOVF    DATO_RECIBIDO, W
    SUBLW   A'0' - 1
    BTFSC   STATUS, C
    GOTO    ERROR_TECLA
    MOVF    DATO_RECIBIDO, W
    SUBLW   A'9'
    BTFSS   STATUS, C
    GOTO    ERROR_TECLA
    
    BTFSC   FLAG_DIGITO, 0  ;nro válido
    GOTO    ES_UNIDAD

ES_DECENA:
    MOVF    DATO_RECIBIDO, W
    ADDLW   -0x30           
    MOVWF   TXT_LIM1        
    BSF     FLAG_DIGITO, 0  
    GOTO    BUCLE_PRINCIPAL

ES_UNIDAD:
    MOVF    DATO_RECIBIDO, W
    ADDLW   -0x30
    MOVWF   TXT_LIM0        
    BCF     FLAG_DIGITO, 0  

    ;Valor matemático real (Decena * 10 + Unidad)
    CLRF    DIST_NUEVA
    MOVF    TXT_LIM1, W
    MOVWF   CONT_TEMP
    BTFSC   STATUS, Z       
    GOTO    SUMA_UNIDADES

SUMA_DIEZ:
    MOVLW   .10
    ADDWF   DIST_NUEVA, F
    DECFSZ  CONT_TEMP, F
    GOTO    SUMA_DIEZ

SUMA_UNIDADES:
    MOVF    TXT_LIM0, W
    ADDWF   DIST_NUEVA, F   

    ;VALIDACIÓN DE RANGOS (10 a 80 cm)
    MOVLW   .10
    SUBWF   DIST_NUEVA, W
    BTFSS   STATUS, C       
    GOTO    ERROR_RANGO     

    MOVLW   .81
    SUBWF   DIST_NUEVA, W
    BTFSC   STATUS, C       
    GOTO    ERROR_RANGO     


    MOVF    DIST_NUEVA, W   
    MOVWF   UMBRAL          

    ;Nuevo modo "LIMITE" 
    MOVLW   0x03
    MOVWF   MODO
    CALL    MOSTRAR_UART_LIMITE
    GOTO    BUCLE_PRINCIPAL

ERROR_RANGO:                
    CLRF    FLAG_DIGITO     
    MOVLW   0x04            
    MOVWF   MODO
    CALL    MOSTRAR_ERROR   
    GOTO    BUCLE_PRINCIPAL

ERROR_TECLA:
    CLRF    FLAG_DIGITO     
    MOVLW   0x04           
    MOVWF   MODO
    CALL    MOSTRAR_ERROR   
    GOTO    BUCLE_PRINCIPAL


;-------------------------------------------------
;RUTINAS DE CONTROL DEL PWM
PRENDER_PWM:
    MOVF    TEMP_MATH, W    
   SUBWF    UMBRAL, W       
    
    ADDLW   .100            
    MOVWF   CCPR1L          
    RETURN
    
APAGAR_PWM:
    CLRF    CCPR1L          
    RETURN
    
;-------------------------------------------------   
; RUTINAS DE CAMBIO DE MODO Y UART
ACTIVAR_MODO_CALLE:
    MOVLW   0x02
    MOVWF   MODO
    CALL    MODO_CALLE      
    MOVLW   .70
    MOVWF   UMBRAL      
    GOTO    BUCLE_PRINCIPAL 

ACTIVAR_MODO_CASA:
    MOVLW   0x01
    MOVWF   MODO
    CALL    MODO_CASA       
    MOVLW   .25
    MOVWF   UMBRAL      
    GOTO    BUCLE_PRINCIPAL

ACTIVAR_MOSTRAR_DISTANCIA:
    MOVLW   0x00
    MOVWF   MODO
    CALL    MOSTRAR_DISTANCIA 
    GOTO    BUCLE_PRINCIPAL

; RESPUESTAS DE LA UART
MODO_CALLE:
    MOVLW   A'M'     
    CALL    ENVIA    
    MOVLW   A'O'
    CALL    ENVIA
    MOVLW   A'D'
    CALL    ENVIA
    MOVLW   A'O'
    CALL    ENVIA
    MOVLW   A' '
    CALL    ENVIA
    MOVLW   A'C'
    CALL    ENVIA
    MOVLW   A'A'
    CALL    ENVIA
    MOVLW   A'L'
    CALL    ENVIA
    MOVLW   A'L'
    CALL    ENVIA
    MOVLW   A'E'
    CALL    ENVIA
    GOTO    SALTO_LINEA     

MODO_CASA:
    MOVLW   A'M'
    CALL    ENVIA
    MOVLW   A'O'
    CALL    ENVIA
    MOVLW   A'D'
    CALL    ENVIA
    MOVLW   A'O'
    CALL    ENVIA
    MOVLW   A' '
    CALL    ENVIA
    MOVLW   A'C'
    CALL    ENVIA
    MOVLW   A'A'
    CALL    ENVIA
    MOVLW   A'S'
    CALL    ENVIA
    MOVLW   A'A'
    CALL    ENVIA
    GOTO    SALTO_LINEA     

MOSTRAR_DISTANCIA:
    MOVLW   A'D'
    CALL    ENVIA
    MOVLW   A'I'
    CALL    ENVIA
    MOVLW   A'S'
    CALL    ENVIA
    MOVLW   A'T'
    CALL    ENVIA
    MOVLW   A'A'
    CALL    ENVIA
    MOVLW   A'N'
    CALL    ENVIA
    MOVLW   A'C'
    CALL    ENVIA
    MOVLW   A'I'
    CALL    ENVIA
    MOVLW   A'A'
    CALL    ENVIA
    MOVLW   A':'
    CALL    ENVIA
    MOVLW   A' '
    CALL    ENVIA

    MOVF    NUM3, W
    ADDLW   0x30     
    CALL    ENVIA
    MOVF    NUM2, W
    ADDLW   0x30
    CALL    ENVIA
    MOVLW   A'c'
    CALL    ENVIA
    MOVLW   A'm'
    CALL    ENVIA
    GOTO    SALTO_LINEA     

MOSTRAR_UART_LIMITE:    
    MOVLW   A'L'
    CALL    ENVIA
    MOVLW   A'I'
    CALL    ENVIA
    MOVLW   A'M'
    CALL    ENVIA
    MOVLW   A'I'
    CALL    ENVIA
    MOVLW   A'T'
    CALL    ENVIA
    MOVLW   A'E'
    CALL    ENVIA
    MOVLW   A':'
    CALL    ENVIA
    MOVLW   A' '
    CALL    ENVIA

    MOVF    TXT_LIM1, W
    ADDLW   0x30
    CALL    ENVIA
    MOVF    TXT_LIM0, W
    ADDLW   0x30
    CALL    ENVIA

    MOVLW   A'c'
    CALL    ENVIA
    MOVLW   A'm'
    CALL    ENVIA

    GOTO    SALTO_LINEA

MOSTRAR_ERROR:              
    MOVLW   A'E'
    CALL    ENVIA
    MOVLW   A'R'
    CALL    ENVIA
    MOVLW   A'R'
    CALL    ENVIA
    MOVLW   A'O'
    CALL    ENVIA
    MOVLW   A'R'
    CALL    ENVIA
    GOTO    SALTO_LINEA

SALTO_LINEA:
    MOVLW   0x0D
    CALL    ENVIA
    MOVLW   0x0A
    CALL    ENVIA
    RETURN                  

ENVIA:
    BTFSS   PIR1, TXIF    
    GOTO    ENVIA         
    MOVWF   TXREG         
    RETURN

    
;---------------------------------------------- INTERRUPCION 

ISR:
    MOVWF   W_TEMP
    SWAPF   STATUS, W
    MOVWF   STATUS_TEMP
 
    BCF     INTCON, TMR0IF
    MOVLW   D'237'          
    MOVWF   TMR0
 
    CLRF    PORTD         
 
    BCF     STATUS, RP0   
    BCF     STATUS, RP1
 
    MOVF    MODO, W
    XORLW   0x01          
    BTFSC   STATUS, Z
    GOTO    ASIGNAR_CASA

    MOVF    MODO, W
    XORLW   0x02          
    BTFSC   STATUS, Z
    GOTO    ASIGNAR_CALLE

    MOVF    MODO, W       
    XORLW   0x03          
    BTFSC   STATUS, Z
    GOTO    ASIGNAR_LIMITE

    MOVF    MODO, W 
    XORLW   0x04          
    BTFSC   STATUS, Z
    GOTO    ASIGNAR_ERROR

ASIGNAR_NUM:              
    MOVLW   NUM0
    GOTO    FIN_ISR

ASIGNAR_CASA:             
    MOVLW   TXT_CASA0
    GOTO    FIN_ISR

ASIGNAR_CALLE:            
    MOVLW   TXT_CALLE0
    GOTO    FIN_ISR

ASIGNAR_LIMITE:           
    MOVLW   TXT_LIM0
    GOTO    FIN_ISR

ASIGNAR_ERROR:        
    MOVLW   TXT_ERR0

FIN_ISR:
    ADDWF   INDEX, W      
    MOVWF   FSR           
    MOVF    INDF, W       
    
    ANDLW   0x1F          
    CALL    TABLA_DISPLAY
    MOVWF   PORTB
 
    MOVF    INDEX, W
    ANDLW   0x03          
    CALL    HABILITACION_DISPLAY
    MOVWF   PORTD
 
    INCF    INDEX, F   
    MOVF    INDEX, W   
    XORLW   0x04       
    BTFSC   STATUS, Z  
    CLRF    INDEX      
 
    SWAPF   STATUS_TEMP, W  
    MOVWF   STATUS        
    SWAPF   W_TEMP, F
    SWAPF   W_TEMP, W
    RETFIE
    
;-------------------------------------------------------    
;CONVERSION DE ANALOGICO A CM

CALCULAR_CM_SHARP:
    MOVLW   0x0E        
    MOVWF   NUM1        
    MOVLW   0x0F        
    MOVWF   NUM0        

    MOVF    ADRESH, W   
    MOVWF   RESTO_L

    MOVLW   D'10'       
    MOVWF   TEMP_MATH    

BUCLE_ESCALA:
    MOVLW   D'4'
    SUBWF   RESTO_L, F
    BTFSS   STATUS, C   
    GOTO    ORGANIZAR_DIGITOS
    INCF    TEMP_MATH, F 

    MOVLW   D'80'
    XORWF   TEMP_MATH, W
    BTFSC   STATUS, Z
    GOTO    ORGANIZAR_DIGITOS

    MOVLW   D'3'
    SUBWF   RESTO_L, F
    BTFSS   STATUS, C
    GOTO    ORGANIZAR_DIGITOS
    INCF    TEMP_MATH, F 

    MOVLW   D'80'
    XORWF   TEMP_MATH, W
    BTFSC   STATUS, Z
    GOTO    ORGANIZAR_DIGITOS

    MOVLW   D'4'
    SUBWF   RESTO_L, F
    BTFSS   STATUS, C
    GOTO    ORGANIZAR_DIGITOS
    INCF    TEMP_MATH, F 

    MOVLW   D'80'
    XORWF   TEMP_MATH, W
    BTFSC   STATUS, Z
    GOTO    ORGANIZAR_DIGITOS

    MOVLW   D'3'
    SUBWF   RESTO_L, F
    BTFSS   STATUS, C
    GOTO    ORGANIZAR_DIGITOS
    INCF    TEMP_MATH, F 

    MOVLW   D'80'
    XORWF   TEMP_MATH, W
    BTFSC   STATUS, Z
    GOTO    ORGANIZAR_DIGITOS

    GOTO    BUCLE_ESCALA 

ORGANIZAR_DIGITOS:
    MOVF    TEMP_MATH, W
    MOVWF   RESTO_L     
    
    CLRF    NUM3        

RESTA_10:
    MOVLW   D'10'
    SUBWF   RESTO_L, W
    BTFSS   STATUS, C
    GOTO    FIN_SHARP
    MOVWF   RESTO_L     
    INCF    NUM3, F     
    GOTO    RESTA_10

FIN_SHARP:
    MOVF    RESTO_L, W
    MOVWF   NUM2        
    RETURN

    END
