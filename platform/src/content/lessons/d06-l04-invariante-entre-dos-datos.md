---
id: 'D06-L04'
trackId: 'dart'
moduleId: 'D06'
kind: 'taller'
order: 3
slug: 'una-invariante-entre-dos-campos'
title: 'Cuando la regla relaciona dos campos'
summary: 'Garantiza que un inicio nunca sea posterior a un fin, y construye operaciones que dependen de esa garantía.'
estimatedMinutes: 55
objectives:
  - 'Validar una invariante que relaciona dos campos al construir.'
  - 'Escribir operaciones que se apoyan en la invariante sin volver a comprobarla.'
  - 'Decidir si los extremos de un rango se incluyen o se excluyen.'
prerequisites: ['D06-L03']
activities:
  - id: 'predecir-rango'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, decide qué debería ocurrir con un RangoFecha cuyo inicio es posterior al fin, y si un rango con inicio igual a fin es válido.'
    required: true
    hints:
      - 'Un rango invertido no es un caso raro: es un dato imposible.'
      - 'Un rango de duración cero puede ser perfectamente válido según el dominio.'
  - id: 'resolver-m07-4'
    kind: 'evidence'
    prompt: 'Implementa RangoFecha con su validación, duracionEnDias y contiene. Ejecuta sus pruebas y pega la salida del caso de los extremos.'
    required: true
    hints:
      - 'difference entre dos DateTime devuelve una Duration con inDays.'
      - 'Para incluir los extremos conviene negar isBefore e isAfter en vez de usar comparaciones estrictas.'
  - id: 'sustentar-datetime'
    kind: 'source'
    prompt: 'En Built-in types, localiza qué ofrece DateTime para comparar dos instantes y cómo se obtiene la diferencia entre ellos.'
    required: true
    sourceLabel: 'Built-in types'
    hints:
      - 'Busca isBefore, isAfter y difference.'
      - 'Anota el encabezado y qué devuelve difference.'
  - id: 'defender-extremos'
    kind: 'judgment'
    prompt: 'Decide si contiene debe incluir los extremos del rango y nombra un dominio concreto donde tu decisión sería la equivocada.'
    required: true
    hints:
      - 'Una reserva de hotel y un turno médico tratan el instante final de forma distinta.'
      - 'Excluir el fin evita que dos rangos consecutivos se solapen en un punto.'
docRefs:
  - label: 'Classes'
    url: 'https://dart.dev/language/classes'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Built-in types'
    url: 'https://dart.dev/language/built-in-types'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué gana una clase cuando la invariante relaciona dos de sus campos?'
  - 'En un archivo vacío, vuelve a escribir RangoFecha con su validación y sus dos operaciones, sin mirar.'
  - 'Explica en voz alta por qué duracionEnDias no necesita comprobar el orden de las fechas.'
  - 'Diseña un rango de horas laborables con su invariante y decide qué ocurre con un turno de medianoche a medianoche.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m07_clases.dart'
  testCommand: 'fvm dart test test/m07_clases_test.dart --name m07-4'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm07-4'
---

Hasta aquí la invariante afectaba a un solo campo. Ahora relaciona dos, y eso cambia dónde se puede comprobar.

## La regla no cabe en un campo

```dart
class RangoFecha {
  RangoFecha({required this.inicio, required this.fin}) {
    if (inicio.isAfter(fin)) {
      throw ArgumentError('inicio no puede ser posterior a fin');
    }
  }

  final DateTime inicio;
  final DateTime fin;
}
```

Ningún tipo de `DateTime` puede expresar «esta fecha es anterior a esa otra». La regla solo existe cuando ambos datos están juntos, y el único momento en que están juntos por primera vez es el constructor.

## Lo que se gana abajo

```dart
int get duracionEnDias => fin.difference(inicio).inDays;
```

Sin comprobaciones. No hace falta preguntarse qué pasa si el rango está invertido, porque **un rango invertido no existe**. Con campos públicos y mutables, esta línea tendría que empezar con un `if` defensivo, y todas las demás también.

Esa es la ganancia concreta de una invariante: las operaciones se escriben suponiendo lo que la clase garantiza.

## `RangeError` o `ArgumentError`

`RangeError` es para un valor fuera de un rango numérico —lo usaste con `Porcentaje`—. Aquí el problema no es que una fecha sea demasiado grande: es que la **relación** entre dos argumentos no se cumple. Para eso está `ArgumentError`. La distinción parece menor y ayuda a quien lee el error a saber qué buscar.

## Los extremos son una decisión

```dart
bool contiene(DateTime momento) =>
    !momento.isBefore(inicio) && !momento.isAfter(fin);
```

Este contrato **incluye** ambos extremos. Fíjate en la forma: negar `isBefore` e `isAfter` es lo que produce «mayor o igual» y «menor o igual» sobre `DateTime`.

Y no es la única opción defendible. Dos turnos consecutivos que terminan e inician a las 10:00 se solapan en un punto si ambos incluyen sus extremos. Muchos dominios excluyen el fin justo por eso.

## Intento · antes de mirar

Decide, por escrito:

- qué ocurre con `RangoFecha(inicio: hoy, fin: ayer)`
- si `inicio == fin` es válido y cuánto dura
- si `contiene(inicio)` debería ser verdadero

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m07_clases_test.dart --name m07-4
```

Pega la salida del caso de los extremos. Si usaste comparaciones estrictas, ese es el test que te lo dice.

## Fuente · lee con una pregunta

Abre **Built-in types** y busca `DateTime`. Dos preguntas: ¿cómo se comparan dos instantes?, ¿qué devuelve `difference`? Anota el encabezado.

## Criterio · decide y acepta el costo

Defiende incluir ambos extremos. Después nombra un dominio concreto donde tu decisión sería la equivocada —turnos consecutivos, reservas por noche— y explica cómo lo dejarías escrito para que nadie tenga que deducirlo del código.

En la última lección del módulo la invariante ya no protege un número: protege una **colección**.
