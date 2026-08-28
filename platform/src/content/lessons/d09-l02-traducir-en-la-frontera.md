---
id: 'D09-L02'
trackId: 'dart'
moduleId: 'D09'
kind: 'taller'
order: 1
slug: 'traducir-un-fallo-en-la-frontera'
title: 'Traducir el fallo en la frontera'
summary: 'Atrapa la excepción de una librería y conviértela en un fallo de tu dominio, sin filtrar cómo lo implementaste.'
estimatedMinutes: 55
objectives:
  - 'Atrapar un tipo concreto de excepción con on.'
  - 'Traducir un fallo técnico a uno de dominio con contexto.'
  - 'Explicar por qué filtrar la excepción original acopla al llamador.'
prerequisites: ['D09-L01']
activities:
  - id: 'predecir-traduccion'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, decide qué debería lanzar parsearEdad ante «abc» y ante «500», y si quien la llama debería tener que conocer FormatException.'
    required: true
    hints:
      - 'Las dos entradas son inválidas por motivos distintos.'
      - 'Si la firma no menciona int.parse, el llamador no debería enterarse de que existe.'
  - id: 'resolver-m10-2'
    kind: 'evidence'
    prompt: 'Implementa parsearEdad traduciendo el fallo. Ejecuta sus pruebas y pega la salida del test que comprueba que no escapa la FormatException original.'
    required: true
    hints:
      - 'on FormatException atrapa solo ese tipo.'
      - 'El motivo debe incluir el dato recibido para que el registro sirva.'
  - id: 'sustentar-on-catch'
    kind: 'source'
    prompt: 'En Error handling, encuentra la diferencia entre on, catch y on-catch combinados.'
    required: true
    sourceLabel: 'Error handling'
    hints:
      - 'Busca el ejemplo con los tres formatos.'
      - 'Fíjate en cuándo hace falta el objeto del error.'
  - id: 'defender-traduccion'
    kind: 'judgment'
    prompt: 'Decide si vale la pena traducir o si conviene dejar subir la excepción original, y nombra qué acopla cada opción.'
    required: true
    hints:
      - 'Dejarla subir acopla al llamador con tu implementación interna.'
      - 'Traducir cuesta un tipo más y puede perder detalle técnico si no lo conservas.'
docRefs:
  - label: 'Error handling'
    url: 'https://dart.dev/language/error-handling'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Built-in types'
    url: 'https://dart.dev/language/built-in-types'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Por qué una función no debería dejar escapar la excepción de la librería que usa por dentro?'
  - 'En un archivo vacío, vuelve a escribir parsearEdad con su traducción, sin mirar tu solución.'
  - 'Explica en voz alta la diferencia entre on y catch.'
  - 'Toma una función tuya que use una librería externa y define qué excepción propia debería lanzar.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m10_errores.dart'
  testCommand: 'fvm dart test test/m10_errores_test.dart --name m10-2'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm10-2'
---

Cuando una función usa `int.parse` por dentro y deja escapar su `FormatException`, está contando un detalle de implementación que nadie le pidió.

## El acoplamiento invisible

```dart
int parsearEdad(String entrada) => int.parse(entrada); // lanza FormatException
```

Quien la llame tendrá que escribir `on FormatException`. Y el día que cambies a otra librería de parseo que lance otra cosa, **todos** esos `catch` dejan de funcionar sin que nada avise.

## Traducir

```dart
int parsearEdad(String entrada) {
  final normalizada = entrada.trim();
  final int numero;
  try {
    numero = int.parse(normalizada);
  } on FormatException {
    throw DatoInvalido('edad', 'No es un número entero: "$normalizada"');
  }
  if (numero < 0 || numero > 130) {
    throw DatoInvalido('edad', 'Fuera del rango 0..130: $numero');
  }
  return numero;
}
```

Ahora la función tiene **una sola** forma de fallar, y está en su contrato. Cómo lo implementó por dentro deja de importarle a nadie.

Fíjate también en `final int numero;` declarado antes del `try`: el `late`-como-promesa de D02-L05 en su forma local. El compilador comprueba que se asigne exactamente una vez.

## `on` y `catch`

```dart
on FormatException { }              // solo ese tipo, sin el objeto
on FormatException catch (error) { } // ese tipo, con el objeto
catch (error) { }                    // cualquier cosa
catch (error, stackTrace) { }        // cualquier cosa, con la pila
```

`catch` a secas atrapa **todo**, incluidos los bugs que querías dejar explotar. Úsalo solo en el borde exterior del programa, donde el trabajo es registrar y no morir.

## Dos fallos, un tipo

`'abc'` y `'500'` fallan por motivos distintos —formato y dominio— y las dos lanzan `DatoInvalido`, con motivos diferentes. El `motivo` es lo que los distingue en el registro. Si necesitaras distinguirlos **en código**, harían falta dos tipos, o el `Resultado` sellado de D08.

## Intento · antes de mirar

Escribe qué lanza tu función para `'abc'`, `'500'`, `'-1'` y `' 30 '`, y decide si quien la llama debería conocer `int.parse`.

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m10_errores_test.dart --name m10-2
```

Pega la salida del test que comprueba que **no** escapa la `FormatException` original. Es la prueba de que la traducción ocurrió de verdad.

## Fuente · lee con una pregunta

Abre **Error handling** y busca el ejemplo con `on`, `catch` y la combinación. Pregunta concreta: ¿cuándo hace falta el objeto del error? Anota el encabezado.

## Criterio · decide y acepta el costo

Defiende traducir frente a dejar subir la original. Traducir cuesta un tipo más y puede **perder detalle técnico** si no lo conservas; hay una tercera vía —traducir conservando la causa original en un campo— que cuesta más y da lo mejor de las dos.

Elige y nombra el costo. En la próxima lección el `finally` demuestra que corre siempre.
