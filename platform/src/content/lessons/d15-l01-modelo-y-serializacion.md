---
id: 'D15-L01'
trackId: 'dart'
moduleId: 'D15'
kind: 'proyecto'
order: 0
slug: 'proyecto-bitacora-cli'
title: 'Proyecto final: el modelo y su ida y vuelta'
summary: 'Serializa una nota a JSON y reconstrúyela validando cada campo, sin aceptar nunca una forma inesperada.'
estimatedMinutes: 60
objectives:
  - 'Serializar y deserializar un modelo conservando todos sus campos.'
  - 'Rechazar una forma inesperada en vez de rellenar con valores por defecto.'
  - 'Comprobar la ida y vuelta con una sola prueba.'
prerequisites: ['D14-L05']
activities:
  - id: 'predecir-ida-y-vuelta'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, escribe qué debería ocurrir al reconstruir una nota cuyo id es un número, y qué prueba demostraría que la serialización no pierde nada.'
    required: true
    hints:
      - 'Una ida y vuelta que devuelve algo distinto es una pérdida silenciosa.'
      - 'Un tipo equivocado no es un valor por defecto: es un archivo corrupto.'
  - id: 'resolver-m16-1'
    kind: 'evidence'
    prompt: 'Implementa aJson y desdeJson con su validación. Ejecuta sus pruebas y pega la salida del test de la ida y vuelta.'
    required: true
    hints:
      - 'Comprueba el tipo de cada campo antes de construir.'
      - 'Las etiquetas deben ser todas textos.'
  - id: 'sustentar-json-modelo'
    kind: 'source'
    prompt: 'En Using JSON, encuentra qué recomienda sobre convertir mapas en modelos y dónde ubicar esa conversión.'
    required: true
    sourceLabel: 'Using JSON'
    hints:
      - 'Busca los ejemplos de fromJson y toJson.'
      - 'Fíjate en si menciona la validación.'
  - id: 'defender-rechazo'
    kind: 'judgment'
    prompt: 'Decide entre rechazar una nota con forma inesperada y rellenar los campos faltantes con valores por defecto, y nombra qué se pierde con cada opción.'
    required: true
    hints:
      - 'Rellenar convierte un archivo corrupto en datos plausibles.'
      - 'Rechazar puede tirar un archivo entero por una nota rota.'
docRefs:
  - label: 'Using JSON'
    url: 'https://dart.dev/libraries/serialization/json'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Classes'
    url: 'https://dart.dev/language/classes'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué demuestra una prueba de ida y vuelta sobre una serialización?'
  - 'En un archivo vacío, vuelve a escribir Nota.aJson y Nota.desdeJson, sin mirar tu solución.'
  - 'Explica en voz alta por qué rellenar un campo faltante puede ser peor que fallar.'
  - 'Agrega un campo a Nota y decide qué pasa con los archivos escritos antes del cambio.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m16_bitacora.dart'
  testCommand: 'fvm dart test test/m16_bitacora_test.dart --name m16-1'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm16-1'
---

El proyecto final junta todo el recorrido en algo que puedes demostrar desde un clon limpio. Empieza por el dato.

## La ida y vuelta

```dart
Map<String, Object?> aJson() => <String, Object?>{
  'id': id,
  'texto': texto,
  'etiquetas': etiquetas,
  'completada': completada,
};
```

Y la vuelta, que es donde está el trabajo:

```dart
static Nota desdeJson(Object? valor) {
  if (valor is! Map<String, Object?>) {
    throw const BitacoraCorrupta('Cada nota debe ser un objeto');
  }
  final id = valor['id'];
  // ...
  if (id is! String || texto is! String || completada is! bool || etiquetas is! List<Object?>) {
    throw const BitacoraCorrupta('Una nota no tiene la forma esperada');
  }
  // ...
}
```

Cada campo se comprueba antes de construir. Es la validación de forma de D12-L02, ahora con una excepción propia del proyecto.

## Una prueba lo cubre todo

```dart
expect(Nota.desdeJson(jsonDecode(jsonEncode(nota.aJson()))), nota);
```

Serializar, pasar por texto real, deserializar y comparar. Si `aJson` se olvida de un campo o `desdeJson` lo lee mal, esto falla.

Y funciona porque `Nota` implementa `==` —D06-L01—. Sin eso, la comparación sería por identidad y pasaría siempre… o nunca.

## Rechazar, no rellenar

La tentación es `valor['texto'] as String? ?? ''`. Es más corto y convierte un archivo corrupto en una nota con texto vacío que se ve como un dato legítimo.

`BitacoraCorrupta` dice otra cosa: **este archivo no se puede interpretar**. Es información, y quien la reciba puede decidir qué hacer — que es el tema de la última lección del módulo.

## Intento · antes de mirar

Escribe qué debería ocurrir con cada uno de estos, y por qué:

```json
{"id": 1, "texto": "x", "etiquetas": [], "completada": false}
{"id": "n1", "texto": "x", "etiquetas": [1], "completada": false}
{"id": "n1", "texto": "x", "completada": false}
```

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m16_bitacora_test.dart --name m16-1
```

Pega la salida del test de la ida y vuelta.

## Fuente · lee con una pregunta

Abre **Using JSON** con una pregunta concreta: ¿dónde recomienda ubicar la conversión entre mapas y modelos? Anota el encabezado.

## Criterio · decide y acepta el costo

Defiende rechazar. El costo es real: una nota rota tira la lectura del archivo entero, y quizá había noventa y nueve buenas.

Nombra la alternativa —leer nota por nota y separar las válidas de las rechazadas, como el lote de D09-L04— y por qué este proyecto eligió lo estricto. En la próxima lección esa decisión se vuelve el eje del diseño.
