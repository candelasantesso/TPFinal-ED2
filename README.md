# Bastón inteligente para personas no videntes.
> **Asignatura:** Electrónica Digital II - Universidad Nacional de Córdoba
> * **Integrantes:**
> - GLADES, LUCILA JAZMIN
> - LOSSANI BUFE, GRECIA AZUL
> - SANTESSO, CANDELA
> * **Profesor:** Blasco, Marcos Javier

---

## 1. Descripción General del Proyecto.
El sistema consiste en un bastón inteligente para personas no videntes que detecta la distancia a los obstáculos mediante un sensor infrarrojo Sharp y procesa la información con un microcontrolador PIC. A través de la comunicación UART, el usuario puede seleccionar una distancia de alerta mediante el modo Casa o Calle y visualizar la distancia medida. Los displays muestran el modo seleccionado o el valor medido en cada momento.

El objetivo del sistema es brindar una advertencia temprana ante la presencia de obstáculos, mejorando la seguridad durante el desplazamiento de la persona. Cuando la distancia medida es mayor a la configurada, el microcontrolador activa una señal de aviso mediante un motor vibrador (o un buzzer, según la implementación final), proporcionando al usuario una alerta que facilita una movilidad más segura y autónoma.

### Alcances del Proyecto.
* **El sistema es capaz de:**
 - Medir la distancia a los obstáculos mediante un sensor infrarrojo.
 - Mostrar en displays la distancia medida y el modo de funcionamiento seleccionado.
  - Permitir seleccionar modo Casa o Calle.
  - Activar una señal de advertencia cuando la distancia al obstáculo es mayor que la configurada.
  - Enviar información del estado del sistema y de la distancia medida por UART.
* **El sistema NO incluye (Fuera de alcance):**
  - Configurar manualmente la distancia de alerta.
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
 * **Diagrama de Bloques:** Muestra cómo están conectados los distintos módulos electrónicos del sistema y cómo circula la información entre ellos. Es una vista general, sin entrar en detalles de conexiones pin a pin. ¿Qué componentes tiene el sistema y cómo se comunican entre sí? [Insertar imagen o link al diagrama de bloques del hardware]
* **Esquemático del Circuito:** PROTEUS CAPTURA *[Inserte aquí la captura de imagen/render del esquemático completo desarrollado en KiCad/Altium]*
  `![Esquemático Completo](hardware/esquematico.png)`
* **Descripción del Circuito y Consideraciones de Diseño:**
* Circuito compuesto por un microcontrolador PIC que recibe la señal analógica del sensor infrarrojo Sharp a través del conversor ADC, procesa la distancia medida y controla las salidas del sistema. Mediante la comunicación UART se reciben los comandos de configuración enviados desde la computadora, mientras que los displays de siete segmentos muestran el modo de funcionamiento o la distancia configurada.

Como consideraciones de diseño, se utilizaron etapas de adaptación entre los distintos módulos y una etapa de potencia para accionar el motor vibrador (o buzzer) mediante PWM. Además, se contempla el uso de un diodo de protección para absorber los picos de tensión generados por la carga inductiva del motor y garantizar un funcionamiento seguro del circuito.

### Arquitectura de Software (Firmware)
* **Diagrama de Flujo o Máquina de Estados:** DIAGRAMA DE FLUJOS Q HAY EN CANVA *[Inserte aquí la imagen del diagrama que explique el lazo principal o el comportamiento del sistema]*
  `![Diagrama de Flujo / Máquina de Estados](docs/diagrama_software.png)`

---

## 3. Especificaciones Eléctricas, Alimentación y Entorno (Específico por Asignatura)

### Parámetros de Alimentación y Consumo (Común a ambas materias)
* **Tensión de operación del sistema:** 5 V para PIC; 3 V para motor vibrador.
* **Método de alimentación:** Alimentación por USB (5 V).
* **Consumo estimado o medido:** * En modo activo (motor/buzzer encendido y displays en funcionamiento): aproximadamente 150–250 mA, (dependiendo del consumo del motor y de los displays).
Modo de espera (sin activación del motor): aproximadamente 50–80 mA.
* **Herramientas de Software:** MPLAB X IDE v5.35 y compilador XC8 [vX.XX].
* **Hardware de Programación/Depuración:** PICkit 3.
* **Configuración de Bits (Fuses Críticos):**
  * *Oscilador:* HS (Cristal interno de 4MHz)
  * *Watchdog Timer (WDT):* OFF
  * *Master Clear (MCLRE):* [Ej: ON (Pin externo) / OFF (Digital IO)]
* **Periféricos Internos Utilizados:** ADC, EUSART (UART), módulo PWM y temporizadores (Tmr0 y TMR2??).
* **Gestión de Interrupciones:** Se prioriza la recepción por UART para asegurar que los comandos enviados por el usuario no se pierdan, y posteriormente se atienden las interrupciones asociadas al temporizador y a las demás tareas periódicas del sistema.

---

## 4. Proceso de Integración y Desarrollo.

* **Etapa 1 (Validación inicial):**   Configuración del oscilador del PIC e inicializacion de variables.
* **Etapa 2 (Adquisición/Comunicación):** Implementación del módulo ADC y validación de las mediciones mediante el encendido de LEDs según el valor detectado. 
* **Etapa 3 (Integración lógica):** Desarrollo de la comunicación UART y multiplexación de displays.
* **Etapa 4 (Sistema Completo):** Integración del sensor, acople del motor, UART y displays para calibración y pruebas finales de funcionamiento. 

---

## 5. Ensayos, Pruebas y Resultados (Común)
Demuestren con datos empíricos que el sistema funciona correctamente. **Es obligatorio incluir registro visual**.

* **Pruebas Funcionales Realizadas:** Detallen los ensayos (Ej: "Se inyectó una señal controlada para medir la precisión del ADC...").
* **Evidencia Fotográfica y Gráficos:** * *Capturas de instrumental:* [Insertar capturas de Osciloscopio, Analizador Lógico o Terminal Serie]
  * *Foto del Prototipo Real:* [Insertar foto del hardware final cableado/armado en funcionamiento]

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
