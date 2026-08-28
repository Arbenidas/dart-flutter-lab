---
id: 'D07-L01'
trackId: 'dart'
moduleId: 'D07'
kind: 'taller'
order: 0
slug: 'abstraccion-y-composicion'
title: 'Un contrato existe para poder sustituirlo'
summary: 'Declara una interfaz mínima y escribe el doble que la cumple, entendiendo qué problema resuelve realmente.'
estimatedMinutes: 55
objectives:
  - 'Declarar una interfaz con abstract interface class.'
  - 'Implementar un doble que cumpla el contrato para las pruebas.'
  - 'Explicar por qué DateTime.now es una dependencia oculta.'
prerequisites: ['D06-L05']
activities:
  - id: 'predecir-dependencia-oculta'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, escribe qué prueba se vuelve imposible cuando una clase llama a DateTime.now por dentro, y cómo la harías posible.'
    required: true
    hints:
      - 'Una prueba que compara fechas depende de cuándo se ejecuta.'
      - 'Si el tiempo llega por parámetro, deja de ser una sorpresa.'
  - id: 'resolver-m08-1'
    kind: 'evidence'
    prompt: 'Declara el contrato Reloj e implementa RelojFijo. Ejecuta sus pruebas y pega la salida del test que lo usa donde se espera un Reloj.'
    required: true
    hints:
      - 'abstract interface class declara qué se puede hacer, no cómo.'
      - 'RelojFijo guarda un instante y siempre devuelve el mismo.'
  - id: 'sustentar-interfaces'
    kind: 'source'
    prompt: 'En Class modifiers, encuentra qué significa abstract interface class y en qué se diferencia de una clase abstracta corriente.'
    required: true
    sourceLabel: 'Class modifiers'
    hints:
      - 'Busca el modificador interface en la tabla de la página.'
      - 'Fíjate en qué impide: extender frente a implementar.'
  - id: 'defender-contrato-minimo'
    kind: 'judgment'
    prompt: 'Decide si el contrato Reloj debería tener un solo método o varios, y nombra qué le cuesta a cada implementación un método de más.'
    required: true
    hints:
      - 'Cada método del contrato es trabajo obligatorio para todos los que lo implementen.'
      - 'Un contrato pequeño es fácil de sustituir y a veces obliga a componer varios.'
docRefs:
  - label: 'Class modifiers'
    url: 'https://dart.dev/language/class-modifiers'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Classes'
    url: 'https://dart.dev/language/classes'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué vuelve sustituible y fácil de probar a una dependencia?'
  - 'En un archivo vacío, vuelve a escribir el contrato Reloj y su doble fijo, sin mirar tu solución.'
  - 'Explica en voz alta por qué DateTime.now es una dependencia oculta.'
  - 'Toma una clase tuya que use el reloj del sistema y escribe la interfaz que la volvería probable.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m08_contratos.dart'
  testCommand: 'fvm dart test test/m08_contratos_test.dart --name m08-1'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm08-1'
---

«Programa contra interfaces» es de esos consejos que se repiten sin explicar qué compra. Este módulo lo compra con un caso concreto: el tiempo.

## La dependencia oculta

```dart
class ServicioVencimiento {
  bool vencio(DateTime limite) => limite.isBefore(DateTime.now());
}
```

Esta clase parece no tener dependencias. Tiene una, y es la peor clase de dependencia: **invisible en la firma**. `DateTime.now()` hace que el resultado dependa de cuándo se ejecuta el código.

Prueba a escribir un test para esto. Necesitas una fecha «pasada» y una «futura» relativas al momento de ejecución, y cualquier caso de frontera —¿qué pasa exactamente en el instante límite?— es imposible de fijar.

## El contrato

```dart
abstract interface class Reloj {
  DateTime ahora();
}
```

Cuatro líneas que no hacen nada. Lo que hacen es **crear un punto de sustitución**: a partir de aquí, «de dónde sale la hora» es una decisión de quien construye el objeto, no del objeto.

`abstract interface class` dice dos cosas: no se puede instanciar, y solo se puede `implements`, no `extends`. Esa segunda restricción es intencional: un contrato no tiene comportamiento que heredar.

## El doble

```dart
class RelojFijo implements Reloj {
  RelojFijo(this._instante);

  final DateTime _instante;

  @override
  DateTime ahora() => _instante;
}
```

Tres líneas de lógica. Con esto, cualquier prueba puede decir «son las 15 de junio de 2026» y comprobar exactamente el instante límite.

Fíjate en que el doble **no es código de mentira**: es una implementación legítima del contrato que resulta útil en pruebas. No hace falta ninguna librería para esto.

## Intento · antes de mirar

Escribe, antes de abrir el archivo, una prueba que compruebe qué pasa en el instante límite exacto, usando `DateTime.now()`. Cuando veas que no puedes escribirla de forma estable, ya tienes el motivo de la lección.

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m08_contratos_test.dart --name m08-1
```

Pega la salida del test que asigna un `RelojFijo` a una variable de tipo `Reloj`. Ese test comprueba lo único que importa de un doble: que sea **sustituible** donde se espera el contrato.

## Fuente · lee con una pregunta

Abre **Class modifiers** con una pregunta concreta: ¿qué añade `interface` a una clase abstracta? Anota el encabezado y qué te impide hacer.

## Criterio · decide y acepta el costo

Defiende un contrato de un solo método. Cada método que agregues es trabajo obligatorio para **todas** las implementaciones, incluidos los dobles de prueba. Un contrato de siete métodos produce dobles de siete métodos, de los cuales seis lanzan `UnimplementedError`.

A cambio, un contrato mínimo a veces obliga a componer varios en vez de tener uno cómodo. Elige y nombra el costo. En la próxima lección el contrato entra en una clase que lo usa.
