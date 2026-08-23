---
id: 'D13-L01'
trackId: 'dart'
moduleId: 'D13'
order: 0
slug: 'paquetes-versiones-y-documentacion-publica'
title: 'Una dependencia amplía tu API y tu responsabilidad'
summary: 'Lee pubspec, restricciones y lockfiles; diseña bibliotecas públicas pequeñas y documentación que explique contratos.'
estimatedMinutes: 110
objectives:
  - 'Distinguir paquete, biblioteca, dependencia directa, transitiva y de desarrollo.'
  - 'Interpretar SemVer, restricciones caret y el papel del pubspec.lock.'
  - 'Evaluar y documentar una API pública antes de depender de ella.'
prerequisites: ['D12-L01']
activities:
  - id: 'predecir-versiones'
    kind: 'predict'
    prompt: 'Para una dependencia ^2.3.5, predice si pub puede elegir 2.3.6, 2.9.0 y 3.0.0. Repite con ^0.3.2 y explica por qué el límite cambia antes de 1.0.0.'
    required: true
    hints:
      - 'Caret incluye versiones compatibles desde el mínimo y excluye el próximo cambio incompatible.'
      - 'La convención Dart desplaza la ruptura a minor cuando la versión es 0.x.'
  - id: 'escribir-biblioteca'
    kind: 'code'
    prompt: 'En un scratch local, extrae una función reusable a una biblioteca pública, deja detalles en una biblioteca interna y exporta solo el contrato. Añade doc comments y genera la API con Dart mediante FVM.'
    required: true
    hints:
      - 'La fachada pública vive directamente bajo lib; los detalles pueden vivir bajo lib/src.'
      - 'Otro paquete no debe importar package:tu_paquete/src/....'
  - id: 'diagnosticar-actualizacion'
    kind: 'debug'
    prompt: 'Analiza una actualización que modifica pubspec.yaml pero no revisa pubspec.lock, changelog ni pruebas. Explica qué versión se resuelve realmente y diseña una secuencia segura.'
    required: true
    hints:
      - 'La restricción declara el rango; el lockfile registra la selección concreta de la aplicación.'
      - 'Usa pub outdated para separar actual, actualizable, resoluble y más reciente.'
  - id: 'rastrear-pub'
    kind: 'docs'
    prompt: 'En How to use packages, Package versioning y Package layout, localiza dependencia directa/transitiva, caret, reglas del lockfile y límites de lib/src. Registra el encabezado de cada decisión.'
    required: true
    hints:
      - 'Aplicaciones y paquetes publicados no tratan igual pubspec.lock.'
      - 'La API pública incluye lo que otros consumidores pueden importar.'
  - id: 'defender-paquete'
    kind: 'explain'
    prompt: 'Evalúa incorporar un cliente HTTP por mantenimiento, plataformas, licencia, documentación, historial de cambios, API y facilidad de prueba. Defiende aceptar o rechazar sin usar popularidad como único criterio.'
    required: true
    hints:
      - 'Una puntuación orienta, pero no reemplaza leer la API y el changelog.'
      - 'El costo incluye actualizaciones y superficie transitiva.'
  - id: 'transferir-contrato'
    kind: 'transfer'
    prompt: 'Documenta una función pública cargar(Uri origen): promesa, retorno, errores, ejemplo mínimo y límites de plataforma. Elimina frases que solo repitan nombre o tipo.'
    required: true
    hints:
      - 'La primera oración debe resumir lo que el consumidor obtiene.'
      - 'Explica decisiones que la firma no puede expresar por sí sola.'
docRefs:
  - label: 'How to use packages'
    url: 'https://dart.dev/tools/pub/packages'
    kind: 'guide'
    version: 'Dart 3.13'
    lastVerified: '2026-08-23'
  - label: 'Package versioning'
    url: 'https://dart.dev/tools/pub/versioning'
    kind: 'guide'
    version: 'Dart 3.13'
    lastVerified: '2026-08-23'
  - label: 'Package layout conventions'
    url: 'https://dart.dev/tools/pub/package-layout'
    kind: 'guide'
    version: 'Dart 3.13'
    lastVerified: '2026-08-23'
  - label: 'Effective Dart: Documentation'
    url: 'https://dart.dev/effective-dart/documentation'
    kind: 'guide'
    version: 'Dart 3.13'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué diferencia hay entre una restricción en pubspec.yaml y una versión en pubspec.lock?'
  - '¿Cómo interpreta caret una versión estable y una versión 0.x en Dart?'
  - '¿Qué código forma parte de la API pública de un paquete y qué propósito tiene lib/src?'
  - '¿Qué debe explicar un doc comment que la firma no comunica por sí sola?'
---

Reutilizar un paquete ahorra trabajo inicial, pero agrega código, versiones y decisiones que tu proyecto deberá mantener. `pub` resuelve el grafo; tú sigues siendo responsable de entender la API, la compatibilidad y el comportamiento que entra a tu producto.

## Paquete y biblioteca no son lo mismo

Un paquete es un directorio con `pubspec.yaml` y puede contener bibliotecas, ejecutables, pruebas, documentación y recursos. Una biblioteca es una unidad importable de código Dart.

Por convención, el contrato público vive bajo `lib/`. Los detalles que no quieres ofrecer a otros paquetes pueden vivir en `lib/src/`. Una biblioteca fachada exporta solo lo estable:

```dart
// lib/lector.dart
export 'src/resultado_lectura.dart';
export 'src/lector.dart' show Lector;
```

El prefijo `src` comunica implementación interna, pero no es seguridad. El diseño público depende de lo que documentas, exportas y prometes conservar.

Las dependencias normales son necesarias al ejecutar la biblioteca. Las `dev_dependencies` sostienen herramientas de desarrollo como pruebas o lints. Una dependencia transitiva llega porque otra dependencia la usa; no deberías importar su API sin declararla directamente.

## Restricción, resolución y lockfile

SemVer usa `major.minor.patch`: una versión major nueva señala ruptura incompatible; minor agrega funcionalidad compatible; patch corrige sin romper el contrato. En el ecosistema Dart, las versiones `0.x` también se tratan semánticamente: `0.3.0` puede romper frente a `0.2.0`.

Una restricción caret declara un rango:

```yaml
dependencies:
  ejemplo: ^2.3.5
```

Acepta desde `2.3.5` hasta antes de `3.0.0`. Pub intersecta las restricciones de todo el grafo y elige una combinación resoluble.

`pubspec.yaml` dice qué puedes aceptar. `pubspec.lock` registra qué seleccionó la aplicación. Las aplicaciones suelen versionar el lockfile para instalaciones reproducibles; los paquetes que se publican normalmente dejan que la aplicación consumidora resuelva el suyo.

## Evalúa antes de agregar

Antes de incorporar un cliente HTTP o parser, revisa:

1. problema exacto que resuelve y alternativa del SDK;
2. plataformas compatibles y restricción del SDK;
3. API pública y capacidad de inyectar o sustituir clientes;
4. mantenimiento reciente, changelog y política de versiones;
5. documentación, ejemplo mínimo y pruebas;
6. licencia, dependencias transitivas y riesgos conocidos.

Popularidad y puntuación ayudan a descubrir opciones; no prueban que encajen con tu contrato.

## Documenta la promesa, no el cuerpo

```dart
/// Lee el recurso de [origen] y devuelve entradas validadas.
///
/// Lanza [FormatException] cuando el contenido no cumple el esquema esperado.
Future<List<Entrada>> cargar(Uri origen) async {
  // Implementación.
}
```

El comentario explica resultado, excepción y concepto. “Carga las entradas” no aportaría más que el nombre. `dart doc` convierte comentarios `///` en referencia navegable; mantenerlos correctos forma parte del cambio de API.

## P — Predice

Traza en una recta `2.3.5`, `2.3.6`, `2.9.0` y `3.0.0`. Marca qué versiones satisface `^2.3.5`. Repite con `0.3.2`, `0.3.9` y `0.4.0`. Después predice qué sucede si otra dependencia exige `<2.5.0`.

No busques todavía qué versión instalará pub: primero expresa la intersección. La selección concreta depende de las versiones publicadas y del grafo completo.

## E — Escribe

Crea en un scratch local una biblioteca pública con una clase y una función; mueve un helper a una biblioteca interna y expórtalo solo si el consumidor lo necesita. Agrega `///` con promesa, error y ejemplo breve. Genera documentación y revisa qué superficie aparece.

Inspecciona el laboratorio existente con el SDK de FVM:

```bash
cd dart_lab
fvm dart pub deps
fvm dart pub outdated
fvm dart analyze
fvm dart test
```

`pub outdated` informa; no actualiza por sí mismo. Antes de cambiar una restricción, anota la versión actual, la resoluble y el motivo.

## N — Nombra el fallo

Separa estos problemas:

- **dependencia no declarada:** importas una transitiva directamente;
- **restricción incompatible:** los rangos del grafo no se intersectan;
- **lockfile desactualizado:** la aplicación no reproduce la versión revisada;
- **API interna filtrada:** consumidores importan `lib/src` de otro paquete;
- **ruptura semántica:** una actualización cambia contrato fuera de lo prometido;
- **documentación redundante o obsoleta:** el comentario repite la firma o contradice el comportamiento.

“Pub falla” no distingue resolución, red, caché o API incompatible.

## S — Sustenta

En **How to use packages**, sigue pubspec → `pub get` → `package_config` → import. En **Package versioning**, verifica SemVer, caret y resolución global. En **Package layout**, localiza `lib`, `lib/src`, `bin`, `test`, `example` y el tratamiento del lockfile.

En **Effective Dart: Documentation**, busca la primera oración, referencias con corchetes y explicación en prosa de parámetros, retornos y excepciones. Aplica una regla a tu API, no todas de memoria.

## A — Argumenta

Evalúa un cliente HTTP de mayor nivel para reemplazar uso directo de `HttpClient`. Explica qué abstracción ofrece, qué plataformas cubre, cómo permite fake, qué dependencias agrega y qué política de versiones aceptarías. Una decisión válida puede ser no agregarlo si el experimento no necesita esa capacidad.

Defiende también tu superficie pública. Cada símbolo exportado limita refactors futuros. Ocultar un helper no es capricho: conserva libertad para cambiar la implementación sin romper consumidores.

## R — Reaplica

Documenta `cargar(Uri origen)` para que alguien pueda usarla sin abrir el cuerpo. Incluye promesa, finalización, errores, esquema esperado, plataformas y ejemplo mínimo. Genera la referencia y léela como consumidor.

Transfiere el proceso a cualquier paquete futuro: formula necesidad, compara SDK y alternativas, revisa mantenimiento, fija rango consciente, ejecuta pruebas y documenta la decisión. Una dependencia dominada es una parte comprendida del sistema, no una caja que “simplemente funciona”.
