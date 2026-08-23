---
id: 'D04-L01'
trackId: 'dart'
moduleId: 'D04'
order: 0
slug: 'funciones-parametros-y-closures'
title: 'La firma cuenta la historia antes que el cuerpo'
summary: 'Diseña funciones legibles, pásalas como valores y entiende qué estado conserva una closure.'
estimatedMinutes: 90
objectives:
  - 'Leer una firma como contrato de entradas y salida.'
  - 'Elegir parámetros posicionales, nombrados y valores por defecto.'
  - 'Explicar funciones de orden superior y closures sin depender de una analogía.'
prerequisites: ['D03-L01']
activities:
  - id: 'leer-firmas'
    kind: 'predict'
    prompt: 'Sin mirar los cuerpos, escribe en lenguaje natural qué recibe y qué devuelve cada función de lib/m05_funciones.dart.'
    required: true
    hints:
      - 'Lee int Function(int) desde el paréntesis interior hacia afuera.'
      - 'Distingue devolver una función de ejecutarla.'
  - id: 'resolver-m05'
    kind: 'code'
    prompt: 'Implementa las funciones del módulo y ejecuta los tests después de cada contrato completado.'
    required: true
    hints:
      - 'Empieza por aplicar y etiqueta.'
      - 'En transformarTodos, crea primero una lista nueva con un for.'
  - id: 'diagnosticar-estado'
    kind: 'debug'
    prompt: 'Explica por qué dos contadores creados por crearContador no deben compartir su valor y localiza dónde viviría un estado compartido accidental.'
    required: true
    hints:
      - 'Pregunta cuántas veces se crea la variable capturada.'
      - 'Compara una variable local con una variable global.'
  - id: 'rastrear-funciones'
    kind: 'docs'
    prompt: 'En la documentación de Functions, encuentra la sección sobre funciones como objetos de primera clase y una regla para parámetros nombrados.'
    required: true
    hints:
      - 'Busca first-class objects y named parameters.'
      - 'Guarda el encabezado y escribe un ejemplo distinto al oficial.'
  - id: 'defender-api'
    kind: 'explain'
    prompt: 'Defiende la firma etiqueta(texto, {mayusculas, prefijo}) frente a una versión con tres argumentos posicionales.'
    required: true
    hints:
      - "Imagina la lectura de etiqueta('hola', true, '>> ')."
      - 'Considera valores por defecto y evolución de la API.'
  - id: 'transferir-validacion'
    kind: 'transfer'
    prompt: 'Diseña una función filtrar que reciba una lista y un predicado; escribe su firma antes de pensar en el cuerpo.'
    required: true
    hints:
      - 'El predicado recibe un elemento y devuelve bool.'
      - 'La función principal devuelve una lista nueva del mismo tipo.'
docRefs:
  - label: 'Functions'
    url: 'https://dart.dev/language/functions'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Cómo se lee el tipo int Function(int)?'
  - '¿Por qué un parámetro bool suele ser más claro cuando es nombrado?'
  - '¿Qué conserva una closure después de que termina la función exterior?'
  - '¿Qué diferencia hay entre map y mutar la lista original dentro de un ciclo?'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m05_funciones.dart'
  testCommand: 'fvm dart test test/m05_funciones_test.dart'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm05_funciones'
---

Una función bien diseñada permite anticipar su uso sin abrir el cuerpo. El nombre expresa intención, los parámetros muestran qué información necesita y el retorno declara qué evidencia produce.

## Lee de afuera hacia adentro

```dart
int aplicar(int valor, int Function(int) transformacion)
```

La función principal recibe un entero y otra función. Esa segunda función recibe un entero y devuelve un entero. El resultado final también es un entero. Todavía no conoces la operación concreta: el contrato permite inyectarla.

En Dart, una función es un objeto. Puedes guardarla, pasarla y devolverla:

```dart
bool esPar(int numero) => numero.isEven;

final condicion = esPar;
final resultado = condicion(8);
```

## Parámetros que se entienden al leer la llamada

Compara:

```dart
crearEtiqueta('dart', true, '>> ');
crearEtiqueta('dart', mayusculas: true, prefijo: '>> ');
```

La segunda llamada explica qué significa `true`. Los parámetros nombrados son especialmente útiles para booleanos, opciones y funciones con varias entradas del mismo tipo. Los valores requeridos que forman la identidad principal de la operación pueden seguir siendo posicionales.

## Closures y estado capturado

```dart
int Function() nuevoContador() {
  var valor = 0;

  return () {
    valor += 1;
    return valor;
  };
}
```

La función interna captura la variable `valor`. Cada llamada a `nuevoContador` crea otra variable y devuelve una closure conectada a ella. El estado sobrevive porque la función devuelta todavía lo referencia, no porque se haya vuelto global.

## P — Predice

Lee solo las firmas de `m05_funciones.dart` y tradúcelas a frases. Luego predice la secuencia de dos contadores independientes. Si ambos empiezan en uno, explica dónde se creó cada variable capturada.

## E — Escribe

Implementa primero la versión explícita de cada idea. Para `transformarTodos`, usa un ciclo y una lista nueva antes de refactorizar a `map`. Así podrás explicar qué oculta la abstracción:

```bash
cd dart_lab
fvm dart test test/m05_funciones_test.dart
```

No comprimas una función a una expresión si el resultado se vuelve menos legible. Brevedad y claridad coinciden a veces, no siempre.

## N — Nombra el fallo

Si un contador comparte estado, pregunta dónde declaraste la variable. Si una transformación modifica la entrada, busca llamadas como `add`, asignaciones por índice o reutilización de la misma lista. Si una llamada es difícil de leer, inspecciona la firma, no solo el cuerpo.

Clasifica el problema como contrato, efecto lateral, estado compartido o retorno incorrecto.

## S — Sustenta

En **Functions**, localiza funciones como objetos de primera clase, parámetros nombrados, funciones anónimas y alcance léxico. Escribe un ejemplo propio para cada encabezado usado. La documentación funciona mejor cuando llegas con una pregunta de firma, no con «quiero aprender todas las funciones».

## A — Argumenta

Compara la versión con ciclo y la versión con `map` de `transformarTodos`. Evalúa:

- si modifican la entrada;
- qué intención se ve primero;
- dónde sería más claro manejar una condición adicional;
- qué versión explicaría mejor alguien nuevo en el equipo.

## R — Reaplica

Diseña la firma genérica de una función `filtrar` antes de implementarla. Debe recibir una lista de `T` y una función que decida si cada `T` permanece. Después prueba mentalmente la misma firma con enteros, nombres y objetos de dominio.

Termina con `fvm dart analyze` y explica una función en voz alta sin mencionar su implementación línea por línea. Si puedes describir el contrato, los efectos y los casos borde, ya estás leyendo APIs como desarrollador.
