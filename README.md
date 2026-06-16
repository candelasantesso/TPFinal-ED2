# Bastón inteligente para personas no videntes.
> **Asignatura:** Electrónica Digital II - Universidad Nacional de Córdoba
> * **Integrantes:**
> - GLADES, LUCILA JAZMIN
> - LOSSANI BUFE, GRECIA AZUL
> - SANTESSO, CANDELA
> * **Profesor:** Blasco, Marcos Javier

---

## 1. Descripción General del Proyecto.
El sistema consiste en un bastón inteligente para personas no videntes que detecta la distancia a los obstáculos mediante un sensor infrarrojo Sharp y procesa la información con un microcontrolador PIC. A través de la comunicación UART, el usuario puede seleccionar una distancia de alerta mediante el modo Casa o Calle, configurar una distancia manual y visualizar la distancia medida. Los displays muestran el modo seleccionado o el valor medido en cada momento.

El objetivo del sistema es brindar una advertencia temprana ante la presencia de obstáculos, mejorando la seguridad durante el desplazamiento de la persona. Cuando la distancia medida es mayor a la configurada, el microcontrolador activa una señal de aviso mediante un motor vibrador, proporcionando al usuario una alerta que facilita una movilidad más segura y autónoma.

### Alcances del Proyecto.
* **El sistema es capaz de:**
 - Medir la distancia a los obstáculos mediante un sensor infrarrojo.
 - Mostrar en displays la distancia medida y el modo de funcionamiento seleccionado.
 - Configurar manualmente la distancia de alerta.
 - Mostrar cuando el usuario seleccione una distancia incorrecta.
  - Permitir seleccionar modo Casa o Calle.
  - Activar una señal de advertencia cuando la distancia al obstáculo es mayor que la configurada.
  - Enviar información del estado del sistema y de la distancia medida por UART.
* **El sistema NO incluye (Fuera de alcance):**
  - Detección del tipo de obstáculo.
  - Reconocimiento de desniveles del terreno.
  - Almacenamiento de datos o historial de mediciones.
  - Brindar conectividad inalámbrica (mediante Wi-Fi o Bluetooth).

### Posibles Etapas Siguientes (Líneas Futuras)

* Reducir el tamaño del circuito integrando los componentes en una única placa, facilitando su incorporación dentro del bastón y mejorando la portabilidad.
* Incorporar una batería recargable y un sistema de bajo consumo para aumentar la autonomía del dispositivo.
* Agregar conectividad Bluetooth o una aplicación móvil para configurar el sistema y monitorear su funcionamiento de forma inalámbrica.
* Incorporar sensores adicionales para mejorar la detección de obstáculos y reducir errores de medición del sensor infrarrojo.
--

## 2. Arquitectura del Sistema: Hardware y Software (Común)

### Hardware & Interconexión
 * **Diagrama de Bloques:** Muestra cómo están conectados los distintos módulos electrónicos del sistema y cómo circula la información entre ellos. Es una vista general, sin entrar en detalles de conexiones pin a pin. ¿Qué componentes tiene el sistema y cómo se comunican entre sí? ![Diagrama de Bloques del Hardware](hardware/DIAGRAMA%20DE%20BLOQUES.png)
* **Esquemático del Circuito:** Esquematico desarrollado en el software Proteus 8 Professional del circuito a desarrollar.
* **ACLARACIÓN:** El sensor Sharp fue reemplazado por un potenciómetro que simule su señal ya que el mismo no se encuentra como parte de la librería de Proteus.
  `![Esquemático Completo](hardware/esquematico.png)

* **Descripción del Circuito y Consideraciones de Diseño:**
Circuito compuesto por un microcontrolador PIC que recibe la señal analógica del sensor infrarrojo Sharp a través del conversor ADC, procesa la distancia medida y controla las salidas del sistema. Mediante la comunicación UART se reciben los comandos de configuración enviados desde la computadora, mientras que los displays de siete segmentos muestran el modo de funcionamiento o la distancia configurada.

Como consideraciones de diseño, se utilizaron etapas de adaptación entre los distintos módulos y una etapa de potencia para accionar el motor vibrador mediante PWM. Además, se contempla el uso de un diodo de protección para absorber los picos de tensión generados por la carga inductiva del motor y garantizar un funcionamiento seguro del circuito.

### Arquitectura de Software (Firmware)
* **Diagrama de Flujo o Máquina de Estados:** *[Inserte aquí la imagen del diagrama que explique el lazo principal o el comportamiento del sistema]*
  Diagrama que explica el lazo principal y el comportamiento del sistema.
![Diagrama de Flujo / Máquina de Estados](docs/diagrama_software.png)

---

## 3. Especificaciones Eléctricas, Alimentación y Entorno (Específico por Asignatura)

### Parámetros de Alimentación y Consumo (Común a ambas materias)
* **Tensión de operación del sistema:** 5 V para PIC; 3,3 V para motor vibrador.
* **Método de alimentación:** Alimentación por USB (5V) para PIC y alimentación por pilas para Motor Vibrador.
* **Consumo estimado o medido:** * En modo activo (motor encendido y displays en funcionamiento): aproximadamente 150–250 mA, (dependiendo del consumo del motor y de los displays).
Modo de espera (sin activación del motor): aproximadamente 50–80 mA.
* **Herramientas de Software:** MPLAB X IDE v5.35 y compilador XC8 [vX.XX].
* **Hardware de Programación/Depuración:** PICkit 3.
* **Configuración de Bits (Fuses Críticos):**
  * *Oscilador:* HS (Cristal interno de 4MHz)
  * *Watchdog Timer (WDT):* OFF
  * *Master Clear (MCLRE):* OFF 
* **Periféricos Internos Utilizados:** ADC, EUSART (UART), módulo PWM y temporizadores (TMR0 y TMR2).
* **Gestión de Interrupciones:** Se utilizan interrupciones mediante T0IF, para priorizar la multiplexación de los displays mediante desbordamientos del TIMER 0.

---

## 4. Proceso de Integración y Desarrollo.

* **Etapa 1 (Validación inicial):**   Configuración del oscilador del PIC e inicializacion de variables.
* **Etapa 2 (Adquisición/Comunicación):** Implementación del módulo ADC y validación de las mediciones mediante el encendido de LEDs según el valor detectado. 
* **Etapa 3 (Integración lógica):** Desarrollo de la comunicación UART y multiplexación de displays.
* **Etapa 4 (Sistema Completo):** Integración del sensor, acople del motor con PWM, UART y displays para calibración y pruebas finales de funcionamiento. 

---

## 5. Ensayos, Pruebas y Resultados (Común)
Demuestren con datos empíricos que el sistema funciona correctamente. **Es obligatorio incluir registro visual**.

* **Pruebas Funcionales Realizadas:**
* Validacion del ADC y conversión a cm: Se varió el voltaje de entrada en el pin AN0 mediante un potenciómetro, para simular la señal analógica del sensor SHARP. Se corroboró que el programa convierte exitosamente la lectura a cm y se muostraban correctamente en los displays multiplexados.
* Test de Límites y Seguridad (UART): Se enviaron múltiples tramas de datos desde la terminal serial de la PC a 9600 baudios.
Comportamiento esperado: Al ingresar valores dentro del rango seguro (ej: "45"), el sistema actualiza el umbral y muestra L-45 en los displays.

Manejo de errores: Al ingresar caracteres inválidos, letras, o números fuera de rango (menores a 10 o mayores a 80), el sistema rechaza el dato, mantiene el umbral anterior y alerta mostrando Err- en el display, demostrando un software robusto.

* Prueba del Actuador (PWM): Se evaluó la respuesta del módulo CCP1. Al simular que la distancia medida caía por debajo del umbral configurado (situación de colisión), el microcontrolador apagó inmediatamente el motor (Duty Cycle = 0%). Al recuperar una distancia segura, el motor reanudó su giro.
* **Evidencia Fotográfica y Gráficos:** * *Capturas de instrumental:* [Insertar capturas de Osciloscopio, Analizador Lógico o Terminal Serie]
  * *Foto del Prototipo Real:* [Insertar foto del hardware final cableado/armado en funcionamiento]
- Capturas de la Terminal Serie (UART): En la siguiente imagen se observa la recepción de datos y los mensajes de respuesta del PIC (LIMITE: XX y ERROR).

- Foto del Prototipo Real: Circuito final montado en protoboard, mostrando el PIC16F887, los displays de 7 segmentos multiplexados y el sistema de comunicaciones.

---

## 6. Estructura del Repositorio (Común)
El repositorio debe mantener obligatoriamente la siguiente estructura limpia (¡Recuerden configurar correctamente el `.gitignore` para no subir carpetas temporales como `Debug/`, `Release/` o archivos `.p1` / `.d`!).

```text
├── firmware/          # Código fuente del proyecto (MPLABX / MCUXpresso / STM32Cube)
│   ├── src/           # Archivos de código (.c)
│   └── inc/           # Archivos de cabecera (.h)
├── hardware/          # Archivos de diseño (KiCad/Altium), esquemáticos en PDF/Imagen y BOM
├── docs/              # Datasheets clave, imágenes del README, notas de aplicación
└── README.md          # Este archivo de presentación
