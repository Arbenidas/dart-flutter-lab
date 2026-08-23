---
id: 'D02-L01'
trackId: 'dart'
moduleId: 'D02'
order: 0
slug: 'null-safety-como-contrato'
title: 'Ausencia no significa incertidumbre'
summary: 'Usa tipos anulables para modelar ausencia esperada y evita convertir el operador ! en una apuesta.'
estimatedMinutes: 80
objectives:
  - 'Distinguir String de String? al leer una firma.'
  - 'Elegir entre chequeo explícito, acceso condicional y valor alternativo.'
  - 'Explicar por qué late y ! trasladan una obligación hacia la ejecución.'
prerequisites: ['D01-L01']
activities:
  - id: 'predecir-nulos'
    kind: 'predict'
    prompt: 'Predice qué expresiones compilan y cuáles pueden fallar en ejecución al combinar String?, ?., ?? y !.'
    required: true
    hints:
      - 'Anota por separado el tipo de cada expresión y su posible valor.'
      - 'El operador ! no comprueba antes de compilar que tengas razón.'
  - id: 'resolver-m03'
    kind: 'code'
    prompt: 'Implementa lib/m03_null_safety.dart por funciones y ejecuta sus tests después de cada cambio.'
    required: true
    hints:
      - 'Empieza por saludar y longitudSegura antes de trabajar con late.'
      - 'Conserva la nulabilidad que declara cada firma.'
  - id: 'diagnosticar-asercion'
    kind: 'debug'
    prompt: 'Explica un escenario real en el que nombre!.length compile pero produzca un fallo en ejecución.'
    required: true
    hints:
      - 'Describe de dónde viene el valor y quién garantiza que no sea null.'
      - 'Busca una alternativa que deje esa garantía en el tipo.'
  - id: 'leer-null-safety'
    kind: 'docs'
    prompt: 'Encuentra en Understanding null safety la diferencia entre nullable y non-nullable y registra el encabezado que la explica.'
    required: true
    hints:
      - 'Usa la búsqueda del navegador con nullable.'
      - 'Resume la regla con un ejemplo propio.'
  - id: 'defender-firma'
    kind: 'explain'
    prompt: 'Defiende si una función buscarUsuario debería devolver Usuario?, lanzar una excepción o devolver un resultado explícito.'
    required: true
    hints:
      - 'Pregunta si no encontrar al usuario es esperado o excepcional.'
      - 'Piensa qué obliga a hacer cada opción a quien llama.'
  - id: 'transferir-api'
    kind: 'transfer'
    prompt: 'Modela la lectura de edad desde un formulario: entrada vacía, texto inválido y edad válida deben quedar distinguibles.'
    required: true
    hints:
      - 'int.tryParse ya representa un fallo esperado con null.'
      - 'No confundas campo vacío con edad cero.'
docRefs:
  - label: 'Understanding null safety'
    url: 'https://dart.dev/null-safety/understanding-null-safety'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Operators'
    url: 'https://dart.dev/language/operators'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué garantía ofrece String que String? no puede ofrecer?'
  - '¿Qué diferencia existe entre ?. y ?? en una expresión?'
  - '¿Por qué ! no elimina el riesgo, sino que cambia cuándo se comprueba?'
  - '¿Cuándo late final expresa un contrato válido y qué ocurre si lo incumples?'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m03_null_safety.dart'
  testCommand: 'fvm dart test test/m03_null_safety_test.dart'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm03_null_safety'
---

Null safety convierte una pregunta ambigua —«¿tal vez exista un valor?»— en una parte visible de la firma. Si una función devuelve `String`, quien la llama puede usar el texto. Si devuelve `String?`, quien la llama debe resolver la ausencia.

## El signo `?` pertenece al tipo

```dart
String nombreSeguro = 'Ada';
String? nombreOpcional;
```

`String?` no significa «String con un error». Significa «el dominio permite un String o ausencia». Ese contrato es útil para una búsqueda que puede no encontrar resultados, pero sería sospechoso en una función que promete crear un usuario y silenciosamente devuelve nada.

Tres herramientas resuelven necesidades distintas:

```dart
final longitud = nombreOpcional?.length;
final visible = nombreOpcional ?? 'Sin nombre';
final forzada = nombreOpcional!.length;
```

- `?.` conserva la ausencia: `longitud` es `int?`.
- `??` proporciona una alternativa: `visible` es `String`.
- `!` afirma que el valor existe y lanza si la afirmación era falsa.

Usar `!` para apagar al analizador elimina información. Úsalo solo cuando exista una garantía externa clara que el tipo no puede expresar, y documenta cuál es.

## P — Predice

Para cada expresión anterior, escribe primero su tipo y luego los valores posibles. Repite el análisis con un string vacío: `''` no es `null`, así que `??` no lo reemplaza.

## E — Escribe

Resuelve `m03_null_safety.dart` en este orden: valores alternativos, acceso condicional, búsqueda anulable, parseo seguro y finalmente `late`. Ejecuta el archivo de tests después de cada función:

```bash
cd dart_lab
fvm dart test test/m03_null_safety_test.dart
```

No cambies una firma anulable a no anulable para facilitar la implementación. La firma es el problema que debes resolver.

## N — Nombra el fallo

Clasifica cada problema:

- **ausencia esperada:** el dominio acepta que no haya valor;
- **entrada inválida:** existe un valor, pero no cumple el formato;
- **inicialización tardía:** el valor llegará antes de cierto uso;
- **supuesto sin prueba:** el código usa `!` sin una garantía real.

Esta clasificación decide si conviene `null`, un resultado explícito, una excepción o un valor alternativo.

## S — Sustenta

En Understanding null safety busca los apartados sobre nullable types y definite assignment. Después abre Operators para localizar `?.`, `??` y `!`. No memorices la tabla completa: aprende a reconocer qué símbolo necesitas y cómo volver a su definición.

## A — Argumenta

Compara estas dos APIs:

```dart
Usuario? buscarUsuario(String id)
Usuario obtenerUsuario(String id)
```

La primera dice que no encontrar es una posibilidad normal. La segunda promete un usuario; si no existe, debe tener otra política explícita, como lanzar un error de dominio. Explica cuál elegirías para una búsqueda y cuál para cargar la sesión autenticada.

## R — Reaplica

Diseña el flujo de un campo de edad. Distingue campo vacío, texto no numérico, número fuera de rango y edad válida. `int.tryParse` resuelve solo una de esas fronteras; tu modelo debe resolver las demás.

Al terminar, corre `fvm dart analyze`. Si necesitas `!`, escribe antes una oración que empiece con «este valor no puede ser null porque…». Si no puedes completarla con una garantía verificable, el operador no es la solución.
