---
id: 'D02-L02'
trackId: 'dart'
moduleId: 'D02'
kind: 'taller'
order: 1
slug: 'acceso-condicional-en-una-expresion'
title: 'Encadenar sobre algo que quizá no exista'
summary: 'Combina ?. y ?? en una sola expresión y entiende por qué el tipo del resultado cambia a mitad de camino.'
estimatedMinutes: 45
objectives:
  - 'Usar ?. para acceder a un miembro solo cuando el receptor no es null.'
  - 'Explicar por qué el resultado de un acceso condicional es nulable.'
  - 'Componer ?. y ?? para obtener un valor no nulable en una expresión.'
prerequisites: ['D02-L01']
activities:
  - id: 'predecir-longitud'
    kind: 'attempt'
    prompt: 'Sin ejecutar nada, escribe en una sola expresión cómo obtendrías la longitud de un String? o 0 si es null, e indica el tipo de cada paso intermedio.'
    required: true
    hints:
      - 'Pregúntate qué tipo tiene texto?.length antes de aplicar nada más.'
      - 'Si te salen tres líneas con un if, funciona: después reescríbelo en una.'
  - id: 'resolver-m03-2'
    kind: 'evidence'
    prompt: 'Implementa longitudSegura en una sola expresión, ejecuta sus pruebas y pega la salida.'
    required: true
    hints:
      - '?. devuelve null si el receptor es null, sin evaluar el miembro.'
      - '?? convierte ese null en el valor por defecto.'
  - id: 'sustentar-operadores'
    kind: 'source'
    prompt: 'En Operators, localiza los operadores condicionales y encuentra qué devuelve una expresión con ?. cuando el receptor es null.'
    required: true
    sourceLabel: 'Operators'
    hints:
      - 'Busca el encabezado de conditional member access.'
      - 'Fíjate en el tipo del resultado, no solo en el valor.'
  - id: 'defender-una-expresion'
    kind: 'judgment'
    prompt: 'Compara tu versión de una sola expresión con una versión de tres líneas usando if. Decide cuál dejarías en un proyecto real y qué costo aceptas.'
    required: true
    hints:
      - 'Una expresión corta no siempre es la más legible para quien recién llega.'
      - 'Un if explícito da un lugar donde poner un punto de interrupción.'
docRefs:
  - label: 'Operators'
    url: 'https://dart.dev/language/operators'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Understanding null safety'
    url: 'https://dart.dev/null-safety/understanding-null-safety'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué diferencia existe entre ?. y ?? en una expresión?'
  - 'En un archivo vacío, vuelve a escribir longitudSegura en una sola expresión sin mirar tu solución.'
  - 'Explica en voz alta por qué el resultado de texto?.length es int? y no int.'
  - 'Encadena tres accesos condicionales sobre datos anidados y decide dónde conviene cortar con un valor por defecto.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m03_null_safety.dart'
  testCommand: 'fvm dart test test/m03_null_safety_test.dart --name m03-2'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm03-2'
---

Ya sabes proteger un valor ausente. Ahora el problema es llegar **a través** de él: acceder a una propiedad de algo que quizá no exista, sin escribir un `if` por cada nivel.

## El acceso condicional corta la cadena

```dart
String? texto;
print(texto?.length); // null, y no explota
```

`?.` hace dos cosas: si el receptor es `null`, devuelve `null` **sin evaluar el miembro**; si no, accede normalmente. El cortocircuito es la parte importante: `texto.length` habría lanzado una excepción.

## El tipo cambia a mitad de camino

Este es el detalle que cuesta ver. `length` está declarado como `int`. Pero `texto?.length` es de tipo `int?`, porque el acceso condicional **puede** no llegar a ejecutarse.

```dart
String? texto;
int? posible = texto?.length;  // int?, no int
int seguro = texto?.length ?? 0; // ahora sí, int
```

Cada `?.` en una cadena vuelve nulable el resultado. Por eso `??` casi siempre aparece al final: es lo que cierra la expresión devolviendo un tipo con el que se puede trabajar.

## Intento · antes de mirar

Escribe, antes de abrir el archivo, la expresión completa y **anota el tipo de cada paso**:

```text
texto        -> String?
texto?.length -> ?
... ?? 0      -> ?
```

Si te salen tres líneas con un `if`, funciona igual; vuelve a intentarlo hasta que te salga la de una.

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m03_null_safety_test.dart --name m03-2
```

Pega la salida. Después haz un experimento extra: borra el `?? 0` y ejecuta `fvm dart analyze`. Copia el error de tipo que aparece; es la mejor explicación de por qué el `??` no es opcional.

## Fuente · lee con una pregunta

Abre **Operators** y busca el acceso condicional a miembros. Pregunta concreta: ¿qué devuelve la expresión cuando el receptor es `null`, y de qué tipo es? Registra el encabezado.

## Criterio · decide y acepta el costo

Compara tu expresión de una línea con la versión explícita:

```dart
if (texto == null) return 0;
return texto.length;
```

Ambas son correctas. Una es más densa; la otra ofrece un lugar donde poner un punto de interrupción y leer el estado. Elige una para un proyecto real y nombra el costo que aceptas.

En la próxima lección dejas de consumir nulos y empiezas a producirlos: devolver `String?` a propósito.
