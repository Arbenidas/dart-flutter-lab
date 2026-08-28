---
id: 'D14-L03'
trackId: 'dart'
moduleId: 'D14'
kind: 'taller'
order: 2
slug: 'operaciones-idempotentes'
title: 'Hacer dos veces lo mismo no debería contar dos veces'
summary: 'Implementa una operación que informa si cambió algo, y descubre por qué esa respuesta importa.'
estimatedMinutes: 45
objectives:
  - 'Implementar una operación idempotente que informa si hubo cambio.'
  - 'Explicar por qué devolver si cambió algo es más útil que si tuvo éxito.'
  - 'Cubrir el caso del identificador inexistente.'
prerequisites: ['D14-L02']
activities:
  - id: 'predecir-idempotencia'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, decide qué debería devolver completar la primera vez, la segunda vez sobre la misma tarea, y sobre un id que no existe.'
    required: true
    hints:
      - 'Completar dos veces deja el mismo estado final.'
      - ' Devolver si cambió algo y si tuvo éxito no es la misma pregunta.'
  - id: 'resolver-m15-3'
    kind: 'evidence'
    prompt: 'Implementa ServicioTareas.completar. Ejecuta sus pruebas y pega la salida del caso de la segunda llamada.'
    required: true
    hints:
      - 'Busca la tarea antes de decidir.'
      - 'Si ya estaba hecha, no hace falta guardar nada.'
  - id: 'sustentar-testing-casos'
    kind: 'source'
    prompt: 'En Testing, encuentra cómo se agrupan casos relacionados y qué aporta un nombre de prueba descriptivo.'
    required: true
    sourceLabel: 'Testing'
    hints:
      - 'Busca group y los nombres de los ejemplos.'
      - 'Fíjate en qué se lee cuando una prueba falla.'
  - id: 'defender-idempotente'
    kind: 'judgment'
    prompt: 'Decide si completar un id inexistente debe devolver falso o lanzar, y compáralo con la decisión que tomó eliminar en el repositorio.'
    required: true
    hints:
      - 'Las dos operaciones parecen iguales y viven en capas distintas.'
      - 'Un Service recibe entrada de usuario; un Repository recibe llamadas de código.'
docRefs:
  - label: 'Testing'
    url: 'https://dart.dev/tools/dart-test'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Error handling'
    url: 'https://dart.dev/language/error-handling'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué significa que una operación sea idempotente?'
  - 'En un archivo vacío, vuelve a escribir completar sin mirar tu solución.'
  - 'Explica en voz alta la diferencia entre devolver si cambió algo y si tuvo éxito.'
  - 'Revisa una operación tuya de marcar o desmarcar y decide si es idempotente.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m15_calidad.dart'
  testCommand: 'fvm dart test test/m15_calidad_test.dart --name m15-3'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm15-3'
---

Una operación **idempotente** deja el mismo estado si la ejecutas una vez o cinco. Marcar una tarea como hecha lo es; incrementar un contador no.

## Informar el cambio, no el éxito

```dart
bool completar(String id) {
  final actual = _repositorio.listar().where((tarea) => tarea.id == id).firstOrNull;
  if (actual == null || actual.hecha) {
    return false;
  }
  _repositorio.guardar(actual.copyWith(hecha: true));
  return true;
}
```

El `bool` no dice «tuvo éxito». Dice **«cambió algo»**. Son dos preguntas distintas:

| Caso            | ¿Éxito? | ¿Cambió? |
| --------------- | ------- | -------- |
| tarea pendiente | sí      | sí       |
| tarea ya hecha  | sí      | **no**   |
| id inexistente  | no      | no       |

La segunda fila es la interesante. Marcar algo que ya estaba marcado no es un error, y tampoco hizo nada. Quien llame puede usar esa información para no refrescar la pantalla, no anotar en el historial y no enviar una notificación.

## Dos ids inexistentes, dos respuestas

Fíjate en la inconsistencia aparente: `Repositorio.eliminar` **lanza** con un id inexistente; `Servicio.completar` devuelve `false`.

No es un descuido. Son capas distintas con orígenes distintos:

- El **Repository** recibe llamadas de código tuyo. Un id que no existe es un bug, y lanzar lo hace visible — D09-L01.
- El **Service** recibe, indirectamente, entrada de usuario. Un id que no existe es un caso esperado.

## Intento · antes de mirar

Completa la tabla antes de tocar el archivo:

| Llamada                               | Devuelve |
| ------------------------------------- | -------- |
| primera vez sobre una tarea pendiente | ?        |
| segunda vez sobre la misma            | ?        |
| sobre un id inexistente               | ?        |

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m15_calidad_test.dart --name m15-3
```

Pega la salida del caso de la segunda llamada.

## Fuente · lee con una pregunta

Abre **Testing** con una pregunta concreta: ¿qué aporta un nombre de prueba descriptivo cuando falla? Anota el encabezado; los nombres de este archivo están escritos como frases por ese motivo.

## Criterio · decide y acepta el costo

Defiende la diferencia entre las dos capas. Es una decisión defendible y también una **inconsistencia aparente** que alguien va a cuestionar en una revisión.

Nombra cómo la documentarías para que no parezca un descuido. En la próxima lección se cuenta en una sola pasada.
