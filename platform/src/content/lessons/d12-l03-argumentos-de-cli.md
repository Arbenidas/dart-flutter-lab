---
id: 'D12-L03'
trackId: 'dart'
moduleId: 'D12'
kind: 'taller'
order: 2
slug: 'interpretar-argumentos-de-cli'
title: 'Los argumentos también son entrada no confiable'
summary: 'Interpreta comando, opciones y argumentos libres, y define qué hacer con cada forma malformada.'
estimatedMinutes: 50
objectives:
  - 'Separar comando, opciones con valor y argumentos libres.'
  - 'Definir el comportamiento ante una opción malformada.'
  - 'Manejar el caso de un valor que contiene el separador.'
prerequisites: ['D12-L02']
activities:
  - id: 'predecir-argumentos'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, escribe cómo interpretarías «listar --limite=10 hoy --formato=json» y qué harías con «--limite» sin valor y con «--q=a=b».'
    required: true
    hints:
      - 'Un argumento que no empieza con dos guiones no es una opción.'
      - 'Solo el primer signo igual separa la clave del valor.'
  - id: 'resolver-m13-4'
    kind: 'evidence'
    prompt: 'Implementa interpretarArgumentos con sus tres casos. Ejecuta sus pruebas y pega la salida del caso del valor con signo igual dentro.'
    required: true
    hints:
      - 'indexOf devuelve la primera aparición.'
      - 'Sin argumentos no hay comando: eso es un error, no un caso vacío.'
  - id: 'sustentar-string-api'
    kind: 'source'
    prompt: 'En Built-in types, localiza los métodos de String que necesitas para separar por la primera aparición de un carácter.'
    required: true
    sourceLabel: 'Built-in types'
    hints:
      - 'Busca indexOf y substring.'
      - 'Fíjate en qué devuelve indexOf cuando no encuentra nada.'
  - id: 'defender-estricto'
    kind: 'judgment'
    prompt: 'Decide si «--limite» sin valor debe lanzar o interpretarse como una bandera booleana, y nombra qué ambigüedad introduce cada opción.'
    required: true
    hints:
      - 'Aceptar banderas obliga a distinguir una opción sin valor de un error de tipeo.'
      - 'Lanzar es estricto y rechaza un uso legítimo muy común.'
docRefs:
  - label: 'Built-in types'
    url: 'https://dart.dev/language/built-in-types'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Error handling'
    url: 'https://dart.dev/language/error-handling'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Cómo separas comando, opciones y argumentos libres en una línea de comandos?'
  - 'En un archivo vacío, vuelve a escribir interpretarArgumentos sin mirar tu solución.'
  - 'Explica en voz alta por qué solo el primer signo igual separa la clave del valor.'
  - 'Diseña la interfaz de comandos de una bitácora y define qué acepta cada uno.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m13_io_json_cli.dart'
  testCommand: 'fvm dart test test/m13_io_json_cli_test.dart --name m13-3'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm13-3'
---

Una CLI recibe una lista de textos y no hay ningún tipo que la proteja. Es entrada externa, igual que un cuerpo JSON.

## Tres cosas mezcladas

```text
listar --limite=10 hoy --formato=json
```

- **comando**: `listar`, siempre el primero
- **opciones**: `limite=10`, `formato=json`
- **libres**: `hoy`

```dart
Argumentos interpretarArgumentos(List<String> argumentos) {
  if (argumentos.isEmpty) {
    throw ArgumentError('Falta el comando');
  }
  final opciones = <String, String>{};
  final libres = <String>[];
  for (final argumento in argumentos.skip(1)) {
    if (!argumento.startsWith('--')) {
      libres.add(argumento);
      continue;
    }
    final separador = argumento.indexOf('=');
    if (separador < 0) {
      throw ArgumentError.value(argumento, 'argumento', 'Se esperaba --clave=valor');
    }
    opciones[argumento.substring(2, separador)] = argumento.substring(separador + 1);
  }
  return (comando: argumentos.first, opciones: opciones, libres: libres);
}
```

El tipo de retorno es un record con nombres —D08-L03— y separa las tres cosas sin inventar una clase.

## El detalle de `--q=a=b`

`indexOf('=')` devuelve la **primera** aparición. Con `--q=a=b`, la clave es `q` y el valor es `a=b` completo. Partir por todos los `=` daría `['q', 'a', 'b']` y perdería datos.

Es un caso raro y llega el día que alguien busca una ecuación o pega una cadena en base64.

## Sin argumentos no hay comando

`interpretarArgumentos([])` lanza. Devolver un comando vacío obligaría a cada consumidor a comprobar, y ya sabes cómo termina eso.

## Intento · antes de mirar

Escribe qué produce tu interpretación para:

- `['listar', '--limite=10', 'hoy']`
- `['listar', '--limite']`
- `['x', '--q=a=b']`
- `[]`

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m13_io_json_cli_test.dart --name m13-4
```

Pega la salida del caso del valor con `=` dentro.

## Fuente · lee con una pregunta

Abre **Built-in types** y busca los métodos de `String`. Pregunta concreta: ¿qué devuelve `indexOf` cuando no encuentra nada? Anota el encabezado; ese `-1` es la comprobación que evita un `substring` fuera de rango.

## Criterio · decide y acepta el costo

Defiende que `--limite` sin valor lance. La alternativa —tratarlo como bandera booleana— es un uso legítimo y muy común, y trae una ambigüedad: `--verboso` es una bandera y `--limte` es un error de tipeo, y las dos se ven igual.

Nombra tu postura y cómo distinguirías las dos. Cierra el módulo:

```bash
fvm dart analyze
```

En D13 el código deja de ser tuyo y pasa a ser algo que otros van a **usar**.
