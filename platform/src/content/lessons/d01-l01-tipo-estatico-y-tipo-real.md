---
id: 'D01-L01'
trackId: 'dart'
moduleId: 'D01'
kind: 'taller'
order: 0
slug: 'tipos-valores-y-variables'
title: 'Un tipo es una promesa verificable'
summary: 'Separa lo que el analizador sabe de lo que el objeto realmente es, y usa is para convertir una sospecha en evidencia.'
estimatedMinutes: 60
objectives:
  - 'Distinguir el tipo estático de una referencia del tipo real del objeto.'
  - 'Usar is para obtener promoción de tipo en lugar de forzar con as.'
  - 'Explicar por qué en Dart un int no es un double.'
prerequisites: ['D00-L02']
activities:
  - id: 'predecir-describir-tipo'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, escribe de memoria cómo implementarías describirTipo(Object valor) y en qué orden preguntarías por cada tipo.'
    required: true
    hints:
      - 'El orden de las comprobaciones puede cambiar el resultado.'
      - '¿Qué pasa si preguntas por num antes que por int?'
  - id: 'resolver-m02-1'
    kind: 'evidence'
    prompt: 'Implementa describirTipo en lib/m02_tipos.dart, ejecuta solo sus pruebas y pega la línea del primer test que falle o el resumen final.'
    required: true
    hints:
      - 'Lee la firma antes que el enunciado: recibe Object y devuelve String.'
      - 'El test «un int no se confunde con decimal» te dice si el orden está mal.'
  - id: 'sustentar-type-system'
    kind: 'source'
    prompt: 'En The Dart type system, encuentra qué dice sobre la relación entre int, double y num, y sobre la promoción de tipo tras un is.'
    required: true
    sourceLabel: 'The Dart type system'
    hints:
      - 'Busca type promotion dentro de la página.'
      - 'Registra el encabezado y una paráfrasis, no el párrafo entero.'
  - id: 'defender-orden'
    kind: 'judgment'
    prompt: 'Decide si tu implementación debería preguntar por num o por int y double por separado. Nombra la alternativa descartada y el caso que la rompe.'
    required: true
    hints:
      - 'Escribe primero los valores de frontera: 7, 7.0, y una lista vacía.'
      - 'Una implementación correcta también debe ser legible para quien la mantenga.'
docRefs:
  - label: 'The Dart type system'
    url: 'https://dart.dev/language/type-system'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Built-in types'
    url: 'https://dart.dev/language/built-in-types'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Cuál es la diferencia entre el tipo estático de una referencia y el tipo real del objeto?'
  - 'En un archivo vacío, vuelve a escribir describirTipo sin mirar lib/m02_tipos.dart ni tu solución.'
  - 'Explica en voz alta por qué comprobar num antes que int cambia el resultado de la función.'
  - 'Escribe una función que reciba Object? y distinga null, texto vacío y texto con contenido, sin usar as.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m02_tipos.dart'
  testCommand: 'fvm dart test test/m02_tipos_test.dart --name m02-1'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm02-1'
---

Un tipo no es una etiqueta decorativa. Es una promesa sobre las operaciones que serán válidas. El analizador usa esa promesa antes de ejecutar el programa y te señala contradicciones mientras todavía son baratas de corregir.

## Dos preguntas distintas

Observa este código:

```dart
Object entrada = '42';

if (entrada is String) {
  print(entrada.length);
}
```

El tipo estático de `entrada` es `Object`: eso es lo que se declaró y lo que puede asumir cualquier línea sin más evidencia. El objeto actual es un `String`. Dentro del `if`, la comprobación `is String` aporta evidencia y Dart **promueve** temporalmente la variable para permitir `length`.

Confundir ambos niveles produce dos errores frecuentes: usar `dynamic` para evitar pensar en el contrato, o forzar conversiones con `as` sin haber comprobado el dato.

## La trampa: int no es double

En muchos lenguajes un entero se acepta donde se espera un decimal. En Dart no: `int` y `double` son dos subtipos hermanos de `num`, y ninguno es subtipo del otro. Por eso este orden está mal:

```dart
if (valor is num) return 'decimal'; // atrapa también los enteros
if (valor is int) return 'entero';  // nunca se alcanza
```

El primer `is` que coincide gana. Ordenar de lo específico a lo general no es estilo: es corrección.

## Intento · antes de mirar

Antes de abrir `lib/m02_tipos.dart`, escribe de memoria tu versión de `describirTipo`. Debe devolver exactamente `'entero'`, `'decimal'`, `'texto'`, `'booleano'`, `'lista'` u `'otro'`. Anota el orden de tus comprobaciones y por qué elegiste ese orden.

## Evidencia · ejecuta y compara

Ahora implementa la función y ejecuta solo sus pruebas:

```bash
cd dart_lab
fvm dart test test/m02_tipos_test.dart --name m02-1
```

Un test rojo acota el contrato que aún no cumples; no juzga tu capacidad. Presta atención especial a `un int no se confunde con decimal`: ese test existe para atrapar el orden equivocado.

Cuando pase, clasifica lo que te costó:

- **tipo:** una operación no es válida para la promesa declarada;
- **orden:** la comprobación general tapó a la específica;
- **cobertura:** un valor cae en `'otro'` cuando no debería.

## Fuente · lee con una pregunta

Abre **The Dart type system** con dos preguntas concretas: ¿qué relación hay entre `int`, `double` y `num`?, y ¿qué gana una variable después de un `is` exitoso? Busca el encabezado que menciona _type promotion_, cópialo en tu cuaderno y explica la regla con tu propio ejemplo.

## Criterio · decide y acepta el costo

Defiende tu orden de comprobaciones. ¿Preguntar por `num` primero y luego afinar es más corto pero incorrecto? ¿Preguntar por `int` y `double` por separado repite código pero hace visible la regla? Nombra la opción descartada y el caso concreto que la rompe.

Cuando el test pase, ejecuta `fvm dart analyze` y déjalo en cero avisos. En la próxima lección la promesa deja de ser sobre categorías y pasa a ser sobre aritmética: dividir no siempre da lo que esperas.
