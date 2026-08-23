---
id: 'D08-L01'
trackId: 'dart'
moduleId: 'D08'
order: 0
slug: 'modelado-genericos-records-y-estados-sellados'
title: 'Haz que los estados imposibles también sean imposibles en el tipo'
summary: 'Combina genéricos, records, enums, sealed classes y patterns para modelar datos completos y exhaustivos.'
estimatedMinutes: 120
objectives:
  - 'Usar parámetros genéricos para conservar información de tipo sin duplicar implementaciones.'
  - 'Elegir entre record, enum y sealed class según los datos de cada variante.'
  - 'Cerrar una jerarquía y procesarla con un switch exhaustivo.'
prerequisites: ['D07-L01']
activities:
  - id: 'predecir-estados'
    kind: 'predict'
    prompt: 'Compara dos booleanos isLoading y hasError con un tipo sellado Carga<T>. Enumera combinaciones inválidas de los booleanos y predice qué variantes necesita el tipo.'
    required: true
    hints:
      - 'Dos booleanos producen cuatro combinaciones, aunque el dominio quizá acepte tres.'
      - 'Pregunta qué dato exclusivo acompaña al éxito y al fallo.'
  - id: 'escribir-carga'
    kind: 'code'
    prompt: 'En un scratch local, implementa Carga<T> con estados inicial, enCurso, exitosa y fallida; usa un switch expression exhaustivo para describir cada variante.'
    required: true
    hints:
      - 'Declara la raíz sealed y los subtipos final en la misma biblioteca.'
      - 'Exitosa<T> conserva T; Fallida<T> conserva un error.'
  - id: 'diagnosticar-dynamic'
    kind: 'debug'
    prompt: 'Sustituye temporalmente T por dynamic en una función que extrae el dato. Localiza qué error deja de detectar el analizador y restaura la información genérica.'
    required: true
    hints:
      - 'Prueba a tratar una carga de int como si contuviera String.'
      - 'El parámetro T debe viajar desde la entrada hasta la salida.'
  - id: 'rastrear-modelos'
    kind: 'docs'
    prompt: 'En Generics, Records y Class modifiers, encuentra type bounds, shape de un record y la propiedad exhaustiva de sealed. Escribe una frase de contrato para cada concepto.'
    required: true
    hints:
      - 'La forma de un record incluye tipos, posiciones y nombres de campos nombrados.'
      - 'Los subtipos directos de sealed viven en la misma biblioteca.'
  - id: 'defender-tipo'
    kind: 'explain'
    prompt: 'Decide si coordenadas, nivel de acceso y resultado de una carga deben ser record, enum o sealed class. Defiende cada elección por identidad, variantes y datos asociados.'
    required: true
    hints:
      - 'Un record es un agregado anónimo; un enum enumera constantes; una jerarquía sellada permite datos distintos por variante.'
      - 'No uses cantidad de líneas como criterio principal.'
  - id: 'transferir-validacion'
    kind: 'transfer'
    prompt: 'Modela Resultado<T> para una validación que pueda ser valida con T o invalida con una lista no vacía de mensajes. Escribe un switch sin rama comodín.'
    required: true
    hints:
      - 'Una lista vacía en el estado inválido rompería otra invariante; decide dónde impedirla.'
      - 'Sin _, el analizador puede avisar cuando aparezca una variante nueva.'
docRefs:
  - label: 'Generics'
    url: 'https://dart.dev/language/generics'
    kind: 'guide'
    version: 'Dart 3.13'
    lastVerified: '2026-08-23'
  - label: 'Records'
    url: 'https://dart.dev/language/records'
    kind: 'guide'
    version: 'Dart 3.13'
    lastVerified: '2026-08-23'
  - label: 'Enumerated types'
    url: 'https://dart.dev/language/enums'
    kind: 'guide'
    version: 'Dart 3.13'
    lastVerified: '2026-08-23'
  - label: 'Class modifiers'
    url: 'https://dart.dev/language/class-modifiers'
    kind: 'guide'
    version: 'Dart 3.13'
    lastVerified: '2026-08-23'
  - label: 'Patterns'
    url: 'https://dart.dev/language/patterns'
    kind: 'guide'
    version: 'Dart 3.13'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué información conserva T en un tipo o una función genérica?'
  - '¿Qué forma parte de la shape y por tanto del tipo de un record?'
  - '¿Cuándo basta un enum y cuándo cada variante necesita una clase propia?'
  - '¿Por qué un switch sobre una jerarquía sealed puede detectar variantes faltantes?'
---

Muchos bugs aparecen porque el programa puede representar combinaciones que el problema prohíbe. Dos booleanos como `isLoading` y `hasError` permiten afirmar que una operación carga y falla al mismo tiempo. Un tipo con variantes hace que cada estado válido tenga una forma propia.

## Genéricos: una relación entre tipos

Un parámetro `T` no significa “cualquier cosa sin comprobar”. Conserva una relación. Si una carga contiene `Usuario`, el éxito entrega `Usuario`, no `dynamic`:

```dart
T primero<T>(List<T> elementos) => elementos.first;

final numero = primero<int>([10, 20]);
final nombre = primero<String>(['Ada', 'Lin']);
```

La implementación se reutiliza y el retorno sigue conectado con la entrada. Un bound como `T extends Comparable<T>` agrega una capacidad necesaria; no lo añadas si el algoritmo no la usa.

## Record, enum o jerarquía sellada

Un record agrupa pocos valores sin crear identidad nominal:

```dart
({double latitud, double longitud}) centro() =>
    (latitud: 13.6929, longitud: -89.2182);
```

Su tipo depende de la forma: tipos, posiciones y nombres de campos nombrados. Es útil para un retorno local pequeño. Si el concepto necesita invariantes, muchos métodos o un nombre compartido en toda la aplicación, una clase comunica mejor la intención.

Un enum representa un conjunto fijo de constantes del mismo tipo, como `NivelAcceso.lectura` y `NivelAcceso.edicion`. Si cada variante lleva datos diferentes, una jerarquía sellada evita campos opcionales desconectados:

```dart
sealed class Carga<T> {
  const Carga();
}

final class Inicial<T> extends Carga<T> {
  const Inicial();
}

final class EnCurso<T> extends Carga<T> {
  const EnCurso();
}

final class Exitosa<T> extends Carga<T> {
  final T dato;
  const Exitosa(this.dato);
}

final class Fallida<T> extends Carga<T> {
  final Object error;
  const Fallida(this.error);
}
```

Los subtipos directos de una clase `sealed` deben vivir en la misma biblioteca. Así el analizador conoce el catálogo y puede exigir un switch exhaustivo:

```dart
String describir<T>(Carga<T> estado) => switch (estado) {
  Inicial<T>() => 'Sin iniciar',
  EnCurso<T>() => 'Cargando',
  Exitosa<T>(dato: final dato) => 'Dato: $dato',
  Fallida<T>(error: final error) => 'Falló: $error',
};
```

No hay `_`: si agregas una variante, el análisis señala el lugar que aún no decidió qué hacer.

## P — Predice

Escribe la tabla de verdad de `isLoading` y `hasError`. Marca qué filas son legítimas y qué dato necesitaría cada una. Después transforma esa tabla en nombres de variantes. Si `éxito` requiere un dato y `fallo` un error, comprueba que ninguna otra variante pueda acceder a esos campos.

Predice qué ocurre al agregar `Cancelada<T>` sin modificar `describir`. El error de análisis es parte del diseño: convierte un cambio incompleto en una señal temprana.

## E — Escribe

Implementa `Carga<T>` en un scratch local. Crea cargas de `int` y `String`, desestructúralas con patterns y agrega una función que solo transforme el dato exitoso. Ejecuta con el SDK fijado por FVM y verifica el resto del laboratorio:

```bash
cd dart_lab
fvm dart --version
fvm dart analyze
fvm dart test
```

Elimina temporalmente una rama del switch para observar el diagnóstico. Luego agrega `Cancelada<T>`, deja que el analizador enumere los sitios incompletos y actualízalos.

## N — Nombra el fallo

Busca una de estas causas:

- **estado imposible representable:** booleanos o campos opcionales admiten combinaciones contradictorias;
- **tipo borrado:** `dynamic` rompe la relación entre entrada y salida;
- **switch silenciado:** una rama `_` absorbe una variante nueva sin obligar a decidir;
- **record sobredimensionado:** un concepto importante circula como una forma anónima difícil de reconocer;
- **jerarquía abierta por accidente:** el código necesita exhaustividad, pero permite subtipos desconocidos.

Nombra qué garantía perdió el tipo. La sintaxis se corrige después.

## S — Sustenta

En **Generics**, localiza por qué mejoran seguridad y reutilización y cuándo usar bounds. En **Records**, identifica qué significa shape y cómo influyen los nombres de campos. En **Class modifiers**, busca las restricciones de `sealed` y su relación con exhaustividad.

Conecta cada fuente con una línea propia. La documentación no decide tu modelo: confirma qué herramientas ofrece el lenguaje para expresar una decisión.

## A — Argumenta

Defiende estas elecciones:

- coordenadas como record si son un retorno local sin identidad;
- nivel de acceso como enum si todas las variantes son constantes del mismo tipo;
- carga como jerarquía sellada porque cada estado tiene datos y comportamiento de procesamiento distintos.

Después busca el punto donde cada elección dejaría de servir. Si las coordenadas adquieren validación y operaciones, una clase nominal puede ser más clara. Si los niveles llevan políticas diferentes, quizá necesiten datos o estrategia. Un diseño crítico incluye su condición de cambio.

## R — Reaplica

Modela `Resultado<T>` con `Valido<T>` e `Invalido<T>`. El estado inválido debe conservar al menos un mensaje, así que protege esa invariante en construcción. Escribe un switch exhaustivo que transforme el valor o presente los mensajes.

Reutiliza el modelo con formulario, importación de archivo y análisis de configuración. Si terminas preguntando por banderas antes de acceder al dato, revisa el tipo: probablemente todavía representa demasiadas combinaciones.
