---
id: 'D13-L01'
trackId: 'dart'
moduleId: 'D13'
kind: 'taller'
order: 0
slug: 'paquetes-versiones-y-documentacion'
title: 'Una versión es un dato, no un texto'
summary: 'Modela una versión semántica con validación estricta y descubre por qué compararla como texto falla.'
estimatedMinutes: 50
objectives:
  - 'Parsear una versión semántica rechazando formatos inválidos.'
  - 'Explicar por qué comparar versiones como texto produce el orden equivocado.'
  - 'Implementar Comparable para poder ordenar.'
prerequisites: ['D12-L03']
activities:
  - id: 'predecir-orden-texto'
    kind: 'attempt'
    prompt: 'Sin ejecutar nada, ordena como texto las versiones 1.2.0, 1.10.0 y 0.9.9, y compara ese orden con el correcto.'
    required: true
    hints:
      - 'Como texto, el carácter 1 va antes que el 9.'
      - 'Como número, 10 va después de 2.'
  - id: 'resolver-m14-1'
    kind: 'evidence'
    prompt: 'Implementa Version.parsear con su validación y ejecuta sus pruebas. Pega la salida del caso con una parte que no es entero.'
    required: true
    hints:
      - 'Tres partes separadas por punto, todas enteros no negativos.'
      - 'FormatException acepta el texto de origen como segundo argumento.'
  - id: 'sustentar-pubspec'
    kind: 'source'
    prompt: 'En The pubspec file, encuentra qué formato exige Dart para el campo version de un paquete.'
    required: true
    sourceLabel: 'The pubspec file'
    hints:
      - 'Busca la sección de version.'
      - 'Fíjate en si menciona el estándar que sigue.'
  - id: 'defender-tipo-version'
    kind: 'judgment'
    prompt: 'Decide si vale la pena tener un tipo Version en vez de manejar cadenas, y nombra el costo de introducirlo.'
    required: true
    hints:
      - 'Un tipo concentra la validación y el orden en un solo lugar.'
      - 'Una cadena viaja gratis por cualquier API y se compara mal.'
docRefs:
  - label: 'The pubspec file'
    url: 'https://dart.dev/tools/pub/pubspec'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Creating packages'
    url: 'https://dart.dev/tools/pub/create-packages'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Por qué comparar versiones como texto produce el orden equivocado?'
  - 'En un archivo vacío, vuelve a escribir Version.parsear sin mirar tu solución.'
  - 'Explica en voz alta qué formato exige el campo version de un pubspec.'
  - 'Parsea tres versiones de un paquete que uses y ordénalas a mano antes de comprobarlo.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m14_paquetes.dart'
  testCommand: 'fvm dart test test/m14_paquetes_test.dart --name m14-1'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm14-1'
---

`'1.10.0'` es menor que `'1.2.0'` si las comparas como texto. Ese solo hecho justifica tener un tipo.

## El orden textual está mal

```dart
<String>['1.2.0', '1.10.0', '0.9.9']..sort();
// ['0.9.9', '1.10.0', '1.2.0']  <- incorrecto
```

Carácter por carácter, `'1'` va antes que `'2'`, así que `1.10.0` queda antes que `1.2.0`. Es exactamente el orden contrario al correcto, y no falla: produce un resultado plausible y equivocado.

## Tres números, validados

```dart
factory Version.parsear(String texto) {
  final partes = texto.trim().split('.');
  if (partes.length != 3) {
    throw FormatException('Se esperaba mayor.menor.parche', texto);
  }
  final numeros = <int>[];
  for (final parte in partes) {
    final numero = int.tryParse(parte);
    if (numero == null || numero < 0) {
      throw FormatException('Cada parte debe ser un entero no negativo', texto);
    }
    numeros.add(numero);
  }
  return Version(numeros[0], numeros[1], numeros[2]);
}
```

Un `factory` que valida antes de construir —D06-L03— y `tryParse` porque el texto viene de afuera —D02-L04. Las herramientas ya las tienes; lo nuevo es el dominio.

Fíjate en `FormatException(mensaje, texto)`: el segundo argumento es la fuente, y aparece en el mensaje. Quien lea el error ve **qué** texto falló.

## Comparable

```dart
@override
int compareTo(Version other) {
  if (mayor != other.mayor) return mayor.compareTo(other.mayor);
  if (menor != other.menor) return menor.compareTo(other.menor);
  return parche.compareTo(other.parche);
}
```

Implementar `Comparable` es lo que permite `sort()` sin pasarle un comparador. Y el orden es por precedencia: mayor manda sobre menor, menor sobre parche.

## Intento · antes de mirar

Ordena a mano `1.2.0`, `1.10.0` y `0.9.9` como texto y como versiones, y anota en qué posiciones difieren.

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m14_paquetes_test.dart --name m14-1
fvm dart test test/m14_paquetes_test.dart --name m14-2
```

Pega la salida del test de ordenamiento. Es el que demuestra el problema del principio.

## Fuente · lee con una pregunta

Abre **The pubspec file** y busca el campo `version`. Pregunta concreta: ¿qué formato exige? Anota el encabezado y el nombre del estándar.

## Criterio · decide y acepta el costo

Defiende tener un tipo `Version`. El costo: una cadena viaja gratis por cualquier API, JSON incluido, y el tipo obliga a convertir en cada frontera.

Nombra dónde pondrías esa conversión — la respuesta es la misma que en D08-L01 y D12-L02, y esa repetición es el patrón. En la próxima lección la versión se convierte en una restricción.
