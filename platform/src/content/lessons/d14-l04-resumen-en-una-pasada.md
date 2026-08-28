---
id: 'D14-L04'
trackId: 'dart'
moduleId: 'D14'
kind: 'taller'
order: 3
slug: 'un-resumen-en-una-sola-pasada'
title: 'Contar dos cosas recorriendo una vez'
summary: 'Devuelve un resumen coherente con un solo recorrido y entiende qué garantiza esa coherencia.'
estimatedMinutes: 45
objectives:
  - 'Acumular dos cuentas en un solo recorrido.'
  - 'Explicar por qué dos recorridos pueden producir un resumen incoherente.'
  - 'Devolver varias cuentas con un record nombrado.'
prerequisites: ['D14-L03']
activities:
  - id: 'predecir-resumen'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, escribe cómo contarías pendientes y hechas, y qué podría salir mal si recorres la lista dos veces.'
    required: true
    hints:
      - 'Dos recorridos sobre una fuente que cambia pueden no coincidir.'
      - 'Un record con nombres evita confundir las dos cuentas.'
  - id: 'resolver-m15-4'
    kind: 'evidence'
    prompt: 'Implementa resumen en una sola pasada. Ejecuta sus pruebas y pega la salida del caso con tres tareas y una completada.'
    required: true
    hints:
      - 'Un ciclo con dos acumuladores basta.'
      - 'Sin tareas, las dos cuentas son cero, no un error.'
  - id: 'sustentar-records-testing'
    kind: 'source'
    prompt: 'En Records, encuentra cómo se comparan dos records y si se pueden usar directamente en una comprobación de igualdad.'
    required: true
    sourceLabel: 'Records'
    hints:
      - 'Busca la parte sobre igualdad de records.'
      - 'Fíjate en si compara campo por campo.'
  - id: 'defender-una-pasada'
    kind: 'judgment'
    prompt: 'Decide si vale la pena una sola pasada frente a dos where legibles, y nombra qué garantiza la pasada única además del tiempo.'
    required: true
    hints:
      - 'Con una fuente estable, dos recorridos dan el mismo resultado.'
      - 'Con una fuente que cambia, dos recorridos pueden contradecirse.'
docRefs:
  - label: 'Records'
    url: 'https://dart.dev/language/records'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Collections'
    url: 'https://dart.dev/language/collections'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué garantiza contar dos cosas en un solo recorrido?'
  - 'En un archivo vacío, vuelve a escribir resumen sin mirar tu solución.'
  - 'Explica en voz alta cómo se comparan dos records por igualdad.'
  - 'Escribe un resumen que cuente tres categorías y decide si sigue cabiendo en un record.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m15_calidad.dart'
  testCommand: 'fvm dart test test/m15_calidad_test.dart --name m15-4'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm15-4'
---

Contar pendientes y hechas parece trivial. La versión obvia tiene un problema que solo se ve cuando la fuente cambia.

## Dos recorridos

```dart
final pendientes = _repositorio.listar().where((t) => !t.hecha).length;
final hechas = _repositorio.listar().where((t) => t.hecha).length;
```

Se lee muy bien y llama a `listar()` **dos veces**. Si algo modificó las tareas entre las dos llamadas, las cuentas no describen el mismo momento: pueden sumar más o menos que el total real.

Con un repositorio en memoria y un solo hilo, esto no ocurre. Con uno que consulte una base de datos, o en presencia de asincronía, sí.

## Una pasada

```dart
({int pendientes, int hechas}) resumen() {
  var pendientes = 0;
  var hechas = 0;
  for (final tarea in _repositorio.listar()) {
    tarea.hecha ? hechas++ : pendientes++;
  }
  return (pendientes: pendientes, hechas: hechas);
}
```

Una llamada, una fotografía, dos cuentas **coherentes entre sí**. La ganancia principal no es el tiempo: es que las dos cifras describen el mismo instante.

## El record se compara solo

```dart
expect(servicio.resumen(), (pendientes: 2, hechas: 1));
```

Dos records son iguales si tienen la misma forma y sus campos son iguales. No hace falta implementar `==` — a diferencia de las clases de D06-L01. Eso los vuelve cómodos como valores de retorno en pruebas.

## Intento · antes de mirar

Escribe qué devuelve `resumen` con tres tareas de las que una está completada, y qué devuelve sin ninguna tarea.

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m15_calidad_test.dart --name m15-4
```

Pega la salida del caso con tres tareas.

## Fuente · lee con una pregunta

Abre **Records** con una pregunta concreta: ¿cómo se comparan dos records por igualdad? Anota el encabezado.

## Criterio · decide y acepta el costo

Defiende la pasada única. El argumento débil es el rendimiento —con veinte tareas no se nota—. El fuerte es la **coherencia**: las dos cifras vienen de la misma lectura.

Nombra a partir de qué punto la versión con dos `where` sería aceptable. En la última lección del módulo aparece el doble que rompe cosas a propósito.
