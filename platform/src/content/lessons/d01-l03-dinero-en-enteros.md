---
id: 'D01-L03'
trackId: 'dart'
moduleId: 'D01'
kind: 'taller'
order: 2
slug: 'dinero-en-enteros'
title: 'El dinero no cabe en un double'
summary: 'Representa importes en centavos, formatea con división entera y módulo, y decide qué hacer con una entrada imposible.'
estimatedMinutes: 60
objectives:
  - 'Explicar por qué un importe decimal en double pierde exactitud.'
  - 'Componer ~/, % y padLeft para formatear un importe guardado en centavos.'
  - 'Elegir entre devolver un valor por defecto y lanzar ante una entrada inválida.'
prerequisites: ['D01-L02']
activities:
  - id: 'predecir-formato'
    kind: 'attempt'
    prompt: 'Sin ejecutar nada, escribe cómo obtendrías «$12.05» a partir del entero 1205 usando solo aritmética y texto, y qué harías con 7 y con 0.'
    required: true
    hints:
      - '1205 centavos son 12 pesos y 5 centavos: dos operaciones distintas sobre el mismo número.'
      - 'El caso 7 revela si tu formato rellena con ceros.'
  - id: 'resolver-m02-3'
    kind: 'evidence'
    prompt: 'Implementa formatearPrecio y ejecuta sus pruebas. Pega la salida del caso que te haya costado más: 7, 0 o el negativo.'
    required: true
    hints:
      - '~/ te da los pesos y % te da los centavos.'
      - 'padLeft rellena por la izquierda: convierte 7 en 07.'
  - id: 'sustentar-builtin'
    kind: 'source'
    prompt: 'En Built-in types, encuentra qué garantiza int frente a double para valores exactos, y localiza cómo se interpolan valores dentro de un String.'
    required: true
    sourceLabel: 'Built-in types'
    hints:
      - 'Busca la sección de numbers y la de strings.'
      - 'La interpolación usa el símbolo del dólar dentro de las comillas.'
  - id: 'defender-negativo'
    kind: 'judgment'
    prompt: 'El contrato exige lanzar RangeError con centavos negativos en vez de devolver «$0.00». Defiende esa decisión y nombra qué se pierde con la alternativa.'
    required: true
    hints:
      - 'Un importe negativo silenciado se propaga hasta el reporte contable.'
      - 'Preguntar de quién es la responsabilidad de validar: ¿de esta función o de quien la llama?'
docRefs:
  - label: 'Built-in types'
    url: 'https://dart.dev/language/built-in-types'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Operators'
    url: 'https://dart.dev/language/operators'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Por qué conviene representar centavos con int en lugar de double?'
  - 'En un archivo vacío, vuelve a escribir formatearPrecio sin mirar lib/m02_tipos.dart ni tu solución.'
  - 'Explica en voz alta cómo colaboran ~/, % y padLeft para producir «$0.07».'
  - 'Diseña la representación de un precio con descuento y moneda; elige tipo y mutabilidad de cada dato y defiende cada decisión.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m02_tipos.dart'
  testCommand: 'fvm dart test test/m02_tipos_test.dart --name m02-3'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm02-3'
---

Este ejercicio parece de formato de texto y en realidad es de **representación**: qué tipo elegiste para guardar el dato antes de mostrarlo.

## Por qué el dinero no va en double

Un `double` usa coma flotante binaria. Muchos decimales que en base diez son exactos no lo son en base dos:

```dart
print(0.1 + 0.2);        // 0.30000000000000004
print(0.1 + 0.2 == 0.3); // false
```

En un carrito de compras eso se acumula. La solución estándar no es redondear al final: es **no usar decimales**. Se guarda el importe en la unidad mínima —centavos— como `int`, y solo se convierte a texto en el momento de mostrarlo.

`int` en Dart es exacto. `1205` es `1205`, siempre.

## Descomponer un entero

Con el importe en centavos, el formato sale de dos operaciones sobre el mismo número:

```dart
final pesos = centavos ~/ 100;   // 1205 ~/ 100 == 12
final resto = centavos % 100;    // 1205 % 100  == 5
```

Falta un detalle: `5` debe mostrarse como `05`. Para eso existe `padLeft`, que rellena por la izquierda hasta alcanzar un ancho:

```dart
'5'.padLeft(2, '0'); // '05'
```

Y para armar el texto final, la interpolación de strings evita concatenar a mano.

## Intento · antes de mirar

Escribe tu versión antes de abrir el archivo. Cubre explícitamente tres casos: `1205`, `7` y `0`. Anota qué hace tu función con cada uno. Si tu predicción para `7` no incluye un cero de relleno, ya encontraste algo.

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m02_tipos_test.dart --name m02-3
```

Pega la salida del caso que más te costó. Los seis tests están ordenados de lo obvio a lo incómodo: caso normal, menos de un peso, cero, centenas exactas, número grande y centavos negativos.

## Fuente · lee con una pregunta

Abre **Built-in types** con dos preguntas: ¿qué garantiza `int` sobre exactitud?, y ¿cómo se inserta un valor dentro de un `String` sin concatenar? Registra los dos encabezados. Vas a volver a esta página muchas veces; conviene saber dónde está cada cosa.

## Criterio · decide y acepta el costo

El contrato exige que `formatearPrecio(-1)` **lance** `RangeError` en lugar de devolver `'$0.00'`. Defiende esa decisión: un importe negativo silenciado no desaparece, viaja hasta el reporte contable disfrazado de cero. Ahora nombra el costo: quien llame a la función tiene que estar preparado para el error.

Cuando pase, ejecuta `fvm dart analyze`. En la próxima lección la promesa deja de ser sobre el valor y pasa a ser sobre **cuándo se conoce**: `const` frente a `final`.
