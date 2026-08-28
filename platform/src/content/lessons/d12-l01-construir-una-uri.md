---
id: 'D12-L01'
trackId: 'dart'
moduleId: 'D12'
kind: 'taller'
order: 0
slug: 'io-json-http-y-cli'
title: 'Una URL se construye, no se concatena'
summary: 'Arma una consulta con Uri y comprueba qué codifica sola y qué exige que valides tú.'
estimatedMinutes: 50
objectives:
  - 'Construir una URL con Uri en lugar de concatenar texto.'
  - 'Explicar qué codifica Uri automáticamente y por qué importa.'
  - 'Validar el esquema antes de emitir una petición.'
prerequisites: ['D11-L05']
activities:
  - id: 'predecir-concatenacion'
    kind: 'attempt'
    prompt: 'Sin ejecutar nada, escribe qué URL produce concatenar una base con un parámetro cuyo valor es «dart & flutter», y qué se rompe.'
    required: true
    hints:
      - 'El ampersand separa parámetros en una cadena de consulta.'
      - 'Los espacios tampoco pueden viajar tal cual.'
  - id: 'resolver-m13-1'
    kind: 'evidence'
    prompt: 'Implementa construirConsulta con su validación de esquema. Ejecuta sus pruebas y pega la salida del caso con caracteres especiales.'
    required: true
    hints:
      - 'Uri.parse y replace evitan armar la cadena a mano.'
      - 'Sin parámetros no debe quedar la interrogación colgando.'
  - id: 'sustentar-uri'
    kind: 'source'
    prompt: 'En la referencia de Uri, encuentra qué hace replace y cómo se codifican los parámetros de consulta.'
    required: true
    sourceLabel: 'Uri class'
    hints:
      - 'Busca queryParameters en la lista de miembros.'
      - 'Fíjate en si menciona la codificación automática.'
  - id: 'defender-https'
    kind: 'judgment'
    prompt: 'Decide si la función debe rechazar una base que no sea https o dejarlo a quien la llama, y nombra el riesgo de cada opción.'
    required: true
    hints:
      - 'Permitir http deja pasar peticiones que cualquiera puede leer.'
      - 'Rechazarlo impide usar la función contra un servidor local de pruebas.'
docRefs:
  - label: 'Uri class'
    url: 'https://api.dart.dev/stable/dart-core/Uri-class.html'
    kind: 'api'
    version: 'API estable'
    lastVerified: '2026-08-23'
  - label: 'Using JSON'
    url: 'https://dart.dev/libraries/serialization/json'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Por qué conviene construir una URL con Uri en lugar de concatenar texto?'
  - 'En un archivo vacío, vuelve a escribir construirConsulta sin mirar tu solución.'
  - 'Explica en voz alta qué codifica Uri por ti y qué sigue siendo tu responsabilidad.'
  - 'Construye la URL de una búsqueda con dos filtros y comprueba qué caracteres se codificaron.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m13_io_json_cli.dart'
  testCommand: 'fvm dart test test/m13_io_json_cli_test.dart --name m13-1'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm13-1'
---

Concatenar una URL funciona hasta el primer valor con un espacio, un acento o un ampersand. Y entonces no falla: produce una URL **distinta** de la que querías.

## Lo que rompe la concatenación

```dart
final url = '$base/buscar?q=$termino';
```

Con `termino = 'dart & flutter'`:

```text
https://api.ejemplo.com/buscar?q=dart & flutter
```

El espacio no es válido en una URL y el `&` **separa parámetros**: el servidor recibe `q=dart ` y un parámetro llamado `flutter` que nadie pidió. No es un error de sintaxis; es un dato equivocado que llega bien formado.

## Uri codifica por ti

```dart
Uri construirConsulta({
  required String base,
  required String ruta,
  Map<String, String> parametros = const <String, String>{},
}) {
  final origen = Uri.parse(base);
  if (origen.scheme != 'https') {
    throw ArgumentError.value(base, 'base', 'La base debe usar https');
  }
  return origen.replace(
    path: ruta,
    queryParameters: parametros.isEmpty ? null : parametros,
  );
}
```

`queryParameters` codifica cada valor. El espacio se vuelve `%20`, el `&` se vuelve `%26`, y al leerlos de vuelta con `uri.queryParameters['q']` recuperas el texto original.

Fíjate en el `parametros.isEmpty ? null : parametros`: pasar un mapa vacío dejaría un `?` colgando al final. Es un detalle pequeño que ensucia registros y cachés.

## Lo que Uri no hace por ti

`Uri` no valida el esquema, ni el host, ni que la ruta tenga sentido. Eso sigue siendo tuyo. Aquí la validación es explícita: solo `https`.

## Intento · antes de mirar

Escribe la URL que produce concatenar con `'dart & flutter'`, y después la que debería producir una construcción correcta.

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m13_io_json_cli_test.dart --name m13-1
```

Pega la salida del caso con caracteres especiales. Fíjate en que el test comprueba dos cosas: que `queryParameters['q']` devuelve el texto original **y** que la URL completa no tiene espacios.

## Fuente · lee con una pregunta

Abre **Uri class** con una pregunta concreta: ¿qué hace `replace` y cómo se codifican los parámetros? Anota el encabezado.

## Criterio · decide y acepta el costo

Defiende exigir `https`. El costo es real: la función deja de servir contra un servidor local en `http://localhost`.

Una salida es un parámetro explícito para permitirlo, que obliga a escribirlo en cada uso inseguro. Elige y nombra el costo. En la próxima lección lo que llega ya no es una URL sino un cuerpo que hay que creer o no.
