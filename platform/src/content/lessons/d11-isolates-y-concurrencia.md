---
id: 'D11-L01'
trackId: 'dart'
moduleId: 'D11'
order: 0
slug: 'concurrencia-isolates-y-mensajes'
title: 'Async espera; un isolate separa trabajo de CPU'
summary: 'Distingue espera asíncrona de cómputo concurrente y comunica workers sin compartir memoria mutable.'
estimatedMinutes: 115
objectives:
  - 'Detectar cuándo una operación async todavía bloquea el isolate que la ejecuta.'
  - 'Mover un cálculo costoso con Isolate.run y recibir un resultado transferible.'
  - 'Elegir entre un isolate corto y uno persistente con puertos y mensajes.'
prerequisites: ['D10-L01']
activities:
  - id: 'predecir-bloqueo'
    kind: 'predict'
    prompt: 'Compara esperar un archivo con recorrer cien millones de enteros dentro de una función async. Predice cuál permite que un temporizador del mismo isolate siga respondiendo y justifica el punto de espera.'
    required: true
    hints:
      - 'async no convierte automáticamente el cuerpo en trabajo paralelo.'
      - 'Un cálculo síncrono largo no contiene un await que ceda el control.'
  - id: 'escribir-isolate-run'
    kind: 'code'
    prompt: 'En un scratch local, calcula una suma de comprobación primero en el isolate principal y luego con Isolate.run. Comprueba el mismo resultado y mide ambas rutas con Stopwatch usando Dart mediante FVM.'
    required: true
    hints:
      - 'La función del worker debe recibir o capturar datos transferibles y devolver otro valor transferible.'
      - 'Mide también el costo de crear el isolate; con trabajo pequeño puede ser más lento.'
  - id: 'diagnosticar-estado'
    kind: 'debug'
    prompt: 'Analiza un diseño que espera incrementar desde un worker la misma lista mutable del isolate principal. Explica por qué no comparte memoria y rediseña el intercambio como mensajes de entrada y resultado.'
    required: true
    hints:
      - 'Cada isolate tiene su propia memoria y su propio ciclo de eventos.'
      - 'Envía datos o resultados, no referencias mutables compartidas.'
  - id: 'rastrear-isolates'
    kind: 'docs'
    prompt: 'En Isolates, localiza Isolate.run, el costo de workers cortos y los puertos para varios mensajes. Registra también la nota de plataforma sobre Flutter web.'
    required: true
    hints:
      - 'Busca ReceivePort y SendPort para workers persistentes.'
      - 'La disponibilidad por plataforma forma parte de la decisión técnica.'
  - id: 'defender-frontera'
    kind: 'explain'
    prompt: 'Elige Future normal o isolate para esperar red, leer un archivo pequeño, decodificar JSON enorme y aplicar un filtro intensivo. Defiende cada decisión por bloqueo medido y costo de comunicación.'
    required: true
    hints:
      - 'I/O asíncrono ya cede el control; el cómputo síncrono intensivo no.'
      - 'No pagues creación y transferencia sin evidencia de bloqueo.'
  - id: 'transferir-importacion'
    kind: 'transfer'
    prompt: 'Diseña una importación que lea texto de forma asíncrona y solo mueva parseo y validación a un isolate cuando el tamaño supere un umbral medido. Define las métricas antes del umbral.'
    required: true
    hints:
      - 'Separa tiempo de I/O, tiempo de CPU y demora observable del proceso principal.'
      - 'El umbral debe salir de medición representativa, no de un número universal.'
docRefs:
  - label: 'Concurrency in Dart'
    url: 'https://dart.dev/language/concurrency'
    kind: 'guide'
    version: 'Dart 3.13'
    lastVerified: '2026-08-23'
  - label: 'Isolates'
    url: 'https://dart.dev/language/isolates'
    kind: 'guide'
    version: 'Dart 3.13'
    lastVerified: '2026-08-23'
  - label: 'Isolate class'
    url: 'https://api.dart.dev/dart-isolate/Isolate-class.html'
    kind: 'api'
    version: 'Dart 3.13 API'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Por qué marcar una función async no evita que un ciclo síncrono largo bloquee su isolate?'
  - '¿Qué memoria comparten dos isolates y cómo intercambian información?'
  - '¿Cuándo elegirías Isolate.run y cuándo un worker persistente con puertos?'
  - '¿Qué debes medir para justificar mover una tarea a otro isolate?'
---

`Future` e `isolate` resuelven problemas distintos. Un Future modela una finalización posterior y permite esperar I/O sin bloquear el ciclo de eventos. Un isolate agrega otra unidad de ejecución con memoria separada, útil cuando el cálculo síncrono impediría atender el resto del trabajo.

## Async no vuelve paralelo el cálculo

Esta función sigue ocupando su isolate hasta terminar el ciclo:

```dart
Future<int> sumarMuchos(int limite) async {
  var total = 0;
  for (var numero = 0; numero < limite; numero += 1) {
    total += numero;
  }
  return total;
}
```

No hay un punto de espera antes del cálculo. `async` envuelve la finalización en un Future, pero no mueve el cuerpo a otro hilo ni introduce pausas mágicas. Si un temporizador o una interfaz comparte ese isolate, debe esperar.

En cambio, una lectura asíncrona de archivo o red entrega el control mientras el sistema operativo espera. Mover I/O pequeño a otro isolate suele añadir costo sin resolver un bloqueo real.

## Isolate.run para un trabajo acotado

`Isolate.run` crea un worker, ejecuta una función y devuelve su resultado como `Future`:

```dart
import 'dart:isolate';

int checksum(List<int> bytes) {
  var resultado = 0;
  for (final byte in bytes) {
    resultado = (resultado + byte) & 0x7fffffff;
  }
  return resultado;
}

Future<int> checksumConcurrente(List<int> bytes) {
  return Isolate.run(() => checksum(bytes));
}
```

El isolate principal y el worker no comparten una lista mutable. El runtime comprueba y transfiere mensajes permitidos. Piensa en la función como un contrato: datos de entrada, cálculo aislado y un resultado que cruza de regreso.

Crear y comunicar tiene costo. Para cien números, el worker puede ser más lento. La pregunta correcta no es “¿puedo usar isolate?”, sino “¿esta tarea bloquea de forma perceptible con datos reales?”.

## Workers persistentes para conversaciones

`Isolate.run` encaja con una solicitud y un resultado. Si necesitas enviar muchos trabajos a lo largo del tiempo, crear un isolate por operación repite el costo. Un worker persistente usa `Isolate.spawn`, `ReceivePort` y `SendPort` para intercambiar mensajes.

Ese diseño necesita protocolo: tipos de mensaje, identificador de solicitud, respuesta, errores, cierre y recursos. No empieces con puertos si una llamada acotada demuestra el concepto.

## P — Predice

Programa mentalmente un temporizador que imprime cada 100 ms. Después inicia un ciclo de CPU que tarda un segundo dentro de una función `async`. Predice el espacio entre impresiones. Repite el razonamiento cuando el ciclo corre con `Isolate.run`.

Separa la predicción de tiempo total y capacidad de respuesta. El worker puede añadir tiempo de creación y aun así mantener libre el isolate principal.

## E — Escribe

Construye un scratch local con `checksum`, `Stopwatch` y dos rutas: directa y `Isolate.run`. Prueba primero pocos elementos y luego una entrada lo bastante grande para observar diferencia. Verifica siempre que ambos resultados coincidan.

Ejecuta con el SDK fijado por FVM y conserva la base en verde:

```bash
cd dart_lab
fvm dart --version
fvm dart analyze
fvm dart test
```

No concluyas desde una sola medición. Haz varias ejecuciones, descarta calentamiento y registra tamaño de entrada y plataforma.

## N — Nombra el fallo

Clasifica el problema antes de agregar concurrencia:

- **I/O en espera:** la operación ya es asíncrona y no consume CPU continuamente;
- **bloqueo de CPU:** un trabajo síncrono largo monopoliza el isolate;
- **mensaje no transferible:** la entrada o salida contiene una capacidad que no puede cruzar;
- **estado compartido supuesto:** el diseño espera observar mutaciones hechas en otra memoria;
- **granularidad demasiado pequeña:** crear workers cuesta más que el trabajo;
- **protocolo incompleto:** un isolate persistente no define error, correlación o cierre.

“La interfaz se congela” es un síntoma. “El parseo usa 140 ms continuos en el isolate principal” ya es evidencia accionable.

## S — Sustenta

En **Concurrency in Dart**, conecta ciclo de eventos, Future e isolates. En **Isolates**, localiza `Isolate.run`, el paso de mensajes y el ejemplo con puertos. Busca además la nota para Flutter web: la plataforma de destino limita la técnica disponible.

Usa la referencia API de `Isolate` cuando necesites una firma o comportamiento exacto. La guía construye el modelo mental; la API confirma el contrato puntual.

## A — Argumenta

Esperar una respuesta HTTP y leer un archivo pequeño ya encajan con Futures asíncronos. Decodificar un JSON enorme o filtrar millones de elementos puede justificar un worker si la medición muestra bloqueo. Incluso allí, evalúa el costo de transferir la entrada y resultado.

Defiende también la duración del worker. Una importación ocasional favorece `Isolate.run`. Un procesador que recibe cientos de trabajos puede justificar puertos persistentes, siempre que el protocolo y el cierre estén probados.

## R — Reaplica

Diseña una importación en dos tiempos: lee el archivo de forma asíncrona y mide el parseo/validación. Define una métrica de capacidad de respuesta y un conjunto de tamaños representativos. Solo después propone un umbral para usar isolate.

Transfiere el criterio a compresión, búsqueda y procesamiento de imágenes. La concurrencia madura empieza con una causa medida, usa mensajes explícitos y conserva una ruta simple para el caso pequeño.
