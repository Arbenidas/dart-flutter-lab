---
id: 'D12-L01'
trackId: 'dart'
moduleId: 'D12'
order: 0
slug: 'fronteras-io-json-http-y-cli'
title: 'Todo dato externo entra sin garantías'
summary: 'Lee archivos, valida JSON, construye URI, observa HTTP y diseña una CLI con salidas y errores explícitos.'
estimatedMinutes: 135
objectives:
  - 'Validar la forma de JSON dinámico antes de construir objetos del dominio.'
  - 'Usar File, Uri y HTTP como fronteras asíncronas con cierre y errores visibles.'
  - 'Diseñar argumentos, stdout, stderr y códigos de salida como contrato de una CLI.'
prerequisites: ['D11-L01']
activities:
  - id: 'predecir-fronteras'
    kind: 'predict'
    prompt: 'Sigue un valor desde argumentos o HTTP hasta el dominio. Predice en qué puntos puede fallar sintaxis, transporte, estado HTTP, forma JSON y validación semántica sin agruparlos como “error de red”.'
    required: true
    hints:
      - 'Una respuesta 404 puede contener JSON perfectamente válido.'
      - 'JSON válido todavía puede tener tipos o campos incompatibles.'
  - id: 'escribir-roundtrip'
    kind: 'code'
    prompt: 'En un scratch local, convierte una entrada tipada a Map<String, Object?>, codifícala a JSON, escríbela y vuelve a leerla de forma asíncrona. Valida cada campo antes de reconstruir el objeto.'
    required: true
    hints:
      - 'jsonDecode devuelve dynamic; verifica Map y tipos de campos.'
      - 'Mantén toJson y fromJson cerca del límite de serialización.'
  - id: 'diagnosticar-url'
    kind: 'debug'
    prompt: 'Corrige una URL construida por concatenación que rompe espacios, &, ? y valores Unicode. Reemplázala por Uri con queryParameters y explica qué responsabilidad absorbe.'
    required: true
    hints:
      - 'Uri.https recibe autoridad, ruta sin codificar y parámetros.'
      - 'No apliques escape manual a toda la URL.'
  - id: 'rastrear-io'
    kind: 'docs'
    prompt: 'En File, dart:convert, Uri y HttpClient, encuentra la preferencia por I/O asíncrono, tipos JSON admitidos, construcción por componentes y obligaciones de leer/cerrar respuestas.'
    required: true
    hints:
      - 'File ofrece pares síncronos y asíncronos; la referencia recomienda async salvo una razón concreta.'
      - 'HttpClient debe cerrarse y el body debe consumirse o drenarse.'
  - id: 'defender-cli'
    kind: 'explain'
    prompt: 'Diseña el contrato de una orden importar <archivo>: éxito por stdout y código 0; uso inválido y datos inválidos por stderr con códigos distintos. Defiende qué información pertenece a cada canal.'
    required: true
    hints:
      - 'stdout puede alimentar otra herramienta; stderr explica fallos.'
      - 'El código de salida permite automatizar sin analizar frases.'
  - id: 'transferir-http'
    kind: 'transfer'
    prompt: 'Modela una consulta GET que valide esquema https, estado 2xx, cuerpo UTF-8 y forma JSON antes de devolver dominio. Documenta timeout, cierre del cliente y mensaje seguro para cada fallo.'
    required: true
    hints:
      - 'Transporte, protocolo y contenido son capas distintas.'
      - 'La API oficial de HttpClient recomienda un cliente de mayor nivel para producto; conserva esa decisión para evaluar paquetes.'
docRefs:
  - label: 'dart:io library'
    url: 'https://api.dart.dev/dart-io/'
    kind: 'api'
    version: 'Dart 3.13 API'
    lastVerified: '2026-08-23'
  - label: 'File class'
    url: 'https://api.dart.dev/dart-io/File-class.html'
    kind: 'api'
    version: 'Dart 3.13 API'
    lastVerified: '2026-08-23'
  - label: 'dart:convert library'
    url: 'https://api.dart.dev/dart-convert/'
    kind: 'api'
    version: 'Dart 3.13 API'
    lastVerified: '2026-08-23'
  - label: 'Uri class'
    url: 'https://api.dart.dev/dart-core/Uri-class.html'
    kind: 'api'
    version: 'Dart 3.13 API'
    lastVerified: '2026-08-23'
  - label: 'HttpClient class'
    url: 'https://api.dart.dev/dart-io/HttpClient-class.html'
    kind: 'api'
    version: 'Dart 3.13 API'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué validaciones separan JSON sintácticamente válido de un objeto de dominio válido?'
  - '¿Por qué conviene construir una URL con Uri en lugar de concatenar texto?'
  - '¿Qué recursos y estados debes observar al usar un cliente HTTP?'
  - '¿Cómo cooperan stdout, stderr y el código de salida en una CLI automatizable?'
---

Archivos, argumentos y respuestas HTTP no obedecen el sistema de tipos de tu programa. Al cruzar la frontera llegan texto, bytes y estructuras dinámicas. La responsabilidad de esa frontera es comprobar forma y contexto antes de entregar un objeto confiable al dominio.

## JSON es sintaxis, no tu modelo

`jsonDecode` devuelve una estructura dinámica formada por valores JSON: números, booleanos, strings, `null`, listas y mapas con claves string. Que la sintaxis sea válida no garantiza campos ni invariantes:

```dart
import 'dart:convert';

final class Entrada {
  final String id;
  final String texto;

  const Entrada({required this.id, required this.texto});

  Map<String, Object?> toJson() => {'id': id, 'texto': texto};

  factory Entrada.fromJson(Object? raw) {
    if (raw case {'id': final String id, 'texto': final String texto}) {
      if (id.isEmpty || texto.trim().isEmpty) {
        throw const FormatException('id y texto no pueden estar vacíos');
      }
      return Entrada(id: id, texto: texto);
    }
    throw const FormatException('La entrada no cumple el esquema');
  }
}

final encoded = jsonEncode(const Entrada(id: 'e-1', texto: 'Aprendí Dart').toJson());
final entry = Entrada.fromJson(jsonDecode(encoded));
```

La conversión se divide en dos: el codec valida sintaxis JSON; `fromJson` valida shape y dominio. Evita repartir casts `as` por toda la aplicación.

## Archivos y rutas son fronteras asíncronas

`File` representa una ruta y ofrece operaciones síncronas y asíncronas. Prefiere `readAsString` y `writeAsString` asíncronos salvo que puedas justificar bloquear el proceso. Decide antes qué significa un archivo ausente: estado inicial vacío, error de configuración o entrada requerida.

Una `Uri` expresa componentes y aplica codificación correcta:

```dart
final uri = Uri.https(
  'api.example.com',
  '/entries',
  {'tag': 'Dart básico', 'limit': '20'},
);
```

Concatenar `'?tag=$tag&limit=$limit'` mezcla datos con sintaxis y falla con espacios, símbolos o Unicode.

## HTTP tiene transporte, protocolo y contenido

Una petición puede fallar antes de conectar, completar con estado no exitoso, entregar bytes no válidos como UTF-8 o contener JSON con otra forma. Verifica cada capa por separado.

`HttpClient` enseña el contrato de bajo nivel: crea petición, cierra para enviarla, observa `statusCode`, consume o drena el body y cierra el cliente. Su propia referencia recomienda usar en producto un cliente de mayor nivel, como `package:http`, para cambiar implementaciones con menos acoplamiento. En D13 aprenderás a evaluar esa dependencia antes de incorporarla.

## Una CLI también es una API

```dart
import 'dart:io';

void main(List<String> arguments) {
  if (arguments.length != 2 || arguments.first != 'importar') {
    stderr.writeln('Uso: programa importar <archivo>');
    exitCode = 2;
    return;
  }

  stdout.writeln('Importando ${arguments[1]}');
}
```

`stdout` contiene el resultado consumible; `stderr`, diagnósticos. El código `0` significa éxito y uno distinto de cero identifica fallo. Documenta tus códigos: otra herramienta no debería analizar el idioma del mensaje para saber si la orden funcionó.

## P — Predice

Dibuja la ruta de una respuesta: DNS/conexión, estado HTTP, bytes, UTF-8, sintaxis JSON, shape y regla de dominio. Para cada etapa inventa una entrada mínima que pase la anterior y falle allí.

Después predice cómo construiría otra herramienta una automatización con tu CLI. ¿Qué lee de stdout? ¿Qué conserva como diagnóstico? ¿Qué condición evalúa sin depender del texto?

## E — Escribe

Crea un scratch local que haga roundtrip de `Entrada`: objeto → mapa → JSON → archivo → JSON → objeto. Prueba archivo ausente, JSON roto, campo faltante y texto vacío. Ninguno debe convertirse silenciosamente en lista vacía.

Ejecuta con el SDK de FVM y verifica el laboratorio:

```bash
cd dart_lab
fvm dart --version
fvm dart analyze
fvm dart test
```

No escribas sobre el archivo original después de una lectura inválida. Conserva la evidencia hasta que el usuario decida reparar o reemplazar.

## N — Nombra el fallo

Usa categorías que preserven la frontera:

- **uso CLI inválido:** faltan argumentos o la orden no existe;
- **I/O:** no se puede leer, escribir o cerrar el recurso;
- **URI inválida:** esquema, host o componentes no cumplen el contrato;
- **transporte:** la conexión no completó;
- **protocolo:** el servidor respondió con un estado inesperado;
- **codificación o sintaxis:** bytes o JSON no pueden decodificarse;
- **esquema o dominio:** la estructura existe, pero sus campos no son válidos.

“No funciona HTTP” mezcla al menos cuatro diagnósticos distintos.

## S — Sustenta

En **File**, localiza la recomendación sobre métodos asíncronos y el uso de streams para archivos grandes. En **dart:convert**, enumera los valores directamente serializables. En **Uri**, compara `Uri.https`, `Uri.file` y `Uri.parse`.

En **HttpClient**, identifica el ciclo de petición/respuesta, consumo del body y cierre. Lee también su nota de nivel de abstracción: una referencia API puede recomendar no usar directamente la clase que documenta.

## A — Argumenta

Diseña `importar <archivo>` como contrato. Uso incorrecto sale por `stderr` y código `2`; datos inválidos usan otro código; éxito escribe un resumen estable por `stdout` y código `0`. El mensaje humano puede cambiar sin romper la automatización si los canales y códigos permanecen.

Para HTTP, defiende cuándo el SDK de bajo nivel basta en un experimento y cuándo un cliente inyectable de mayor nivel reduce acoplamiento, pruebas y diferencias de plataforma. La respuesta debe considerar consumidores, no solo cantidad de código.

## R — Reaplica

Especifica una consulta GET segura: construye `Uri` por componentes, acepta solo `https`, configura límite temporal, valida estado, decodifica UTF-8, comprueba JSON y cierra recursos. Da a cada fallo un mensaje seguro y conserva la causa técnica para diagnóstico.

Transfiere la misma secuencia a variables de entorno, stdin o una base local. Cada frontera convierte información no confiable en un tipo confiable; si ese paso queda implícito, el resto del programa paga la ambigüedad.
