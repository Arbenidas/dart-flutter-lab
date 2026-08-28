---
id: 'D09-L04'
trackId: 'dart'
moduleId: 'D09'
kind: 'taller'
order: 3
slug: 'un-dato-malo-no-detiene-el-proceso'
title: 'Un dato malo no puede detener el lote entero'
summary: 'Procesa una colección tolerando fallos individuales y devuelve el resultado junto con los rechazos.'
estimatedMinutes: 50
objectives:
  - 'Atrapar un tipo concreto dentro de un ciclo sin tragar los demás.'
  - 'Devolver el resultado parcial junto con los motivos de rechazo.'
  - 'Decidir cuándo tolerar un fallo y cuándo abortar el lote.'
prerequisites: ['D09-L03']
activities:
  - id: 'predecir-lote'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, decide qué debería devolver una suma de edades sobre 30, abc, 20 y 500, y qué pasaría si atraparas cualquier excepción en vez de una concreta.'
    required: true
    hints:
      - 'El resultado parcial y los rechazos son dos datos distintos.'
      - 'Atrapar todo dentro del ciclo se tragaría también los bugs.'
  - id: 'resolver-m10-4'
    kind: 'evidence'
    prompt: 'Implementa sumarEdades tolerando los datos inválidos. Ejecuta sus pruebas y pega la salida del caso mixto.'
    required: true
    hints:
      - 'on DatoInvalido atrapa solo tu fallo de dominio.'
      - 'Devuelve un record con el total y la lista de motivos.'
  - id: 'sustentar-catch-tipado'
    kind: 'source'
    prompt: 'En Error handling, encuentra por qué conviene atrapar un tipo concreto en vez de usar catch a secas.'
    required: true
    sourceLabel: 'Error handling'
    hints:
      - 'Busca la parte que habla de catch sin tipo.'
      - 'Anota el riesgo que menciona.'
  - id: 'defender-tolerancia'
    kind: 'judgment'
    prompt: 'Decide si este proceso debe tolerar los datos inválidos o abortar al primero, y nombra un dominio donde tu elección sería peligrosa.'
    required: true
    hints:
      - 'Importar contactos y aplicar transferencias bancarias no toleran igual.'
      - 'Un resultado parcial silencioso puede parecerse demasiado a un éxito.'
docRefs:
  - label: 'Error handling'
    url: 'https://dart.dev/language/error-handling'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Collections'
    url: 'https://dart.dev/language/collections'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Por qué conviene atrapar un tipo concreto dentro de un ciclo?'
  - 'En un archivo vacío, vuelve a escribir sumarEdades sin mirar tu solución.'
  - 'Explica en voz alta por qué el resultado parcial y los rechazos deben viajar juntos.'
  - 'Diseña un flujo de importación por lotes y define qué se hace con las filas rechazadas.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m10_errores.dart'
  testCommand: 'fvm dart test test/m10_errores_test.dart --name m10-4'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm10-4'
---

Importar cien contactos y abortar porque uno tenía el teléfono mal es una decisión de producto, no un accidente. Este ejercicio es sobre tomarla a propósito.

## Tolerar sin tragar

```dart
({int total, List<String> rechazos}) sumarEdades(Iterable<String> entradas) {
  var total = 0;
  final rechazos = <String>[];
  for (final entrada in entradas) {
    try {
      total += parsearEdad(entrada);
    } on DatoInvalido catch (error) {
      rechazos.add(error.motivo);
    }
  }
  return (total: total, rechazos: rechazos);
}
```

`on DatoInvalido` es la parte que importa. Un `catch` a secas también atraparía un `RangeError` provocado por un bug tuyo, lo convertiría en «una fila rechazada» y seguiría adelante como si nada.

**Solo se tolera lo que se anticipó.** Todo lo demás debe seguir subiendo.

## El resultado parcial no viaja solo

```dart
return (total: total, rechazos: rechazos);
```

Devolver únicamente el total sería mentir: 50 sobre cuatro entradas se ve idéntico a 50 sobre dos. Los rechazos son parte del resultado, no un efecto lateral que va al log.

Y el tipo lo dice: quien llame a esta función **no puede ignorar** que hay rechazos, porque están ahí, en el record que recibió. Es el mismo argumento que el `Resultado` sellado de D08, con menos ceremonia.

## Intento · antes de mirar

Predice qué devuelve la función para `['30', 'abc', '20', '500']`, y qué pasaría con `[]` y con `['a', 'b']`.

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m10_errores_test.dart --name m10-4
```

Pega la salida del caso mixto. Experimento: cambia `on DatoInvalido` por `catch (_)` y lanza a propósito un `StateError` desde dentro; observa cómo un bug se disfraza de fila rechazada.

## Fuente · lee con una pregunta

Abre **Error handling** y busca lo que dice sobre `catch` sin tipo. Pregunta concreta: ¿qué riesgo menciona? Anota el encabezado.

## Criterio · decide y acepta el costo

Defiende tolerar. Después nombra un dominio donde sería peligroso: aplicar transferencias bancarias por lotes y «rechazar» tres en silencio no es lo mismo que importar contactos.

El costo real de tolerar: un resultado parcial se parece demasiado a un éxito si quien lo recibe no mira los rechazos. Nombra cómo lo evitarías. En la última lección del módulo el error llega a la pantalla.
