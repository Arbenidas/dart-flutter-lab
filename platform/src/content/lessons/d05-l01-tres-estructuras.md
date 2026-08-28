---
id: 'D05-L01'
trackId: 'dart'
moduleId: 'D05'
kind: 'taller'
order: 0
slug: 'colecciones-e-iterables'
title: 'Tres estructuras, tres contratos'
summary: 'Elige List, Set o Map por la pregunta que hace tu dominio, y encadena where, map y toList sin perder el control del resultado.'
estimatedMinutes: 60
objectives:
  - 'Elegir entre List, Set y Map a partir de orden, unicidad y acceso por clave.'
  - 'Encadenar where, map y toList conservando el orden de entrada.'
  - 'Justificar por qué devolver una lista no ampliable es parte del contrato.'
prerequisites: ['D04-L06']
activities:
  - id: 'predecir-estructura'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, elige List, Set o Map para una fila de reproducción, un conjunto de etiquetas y un catálogo por identificador, y anota qué información perderías con cada alternativa.'
    required: true
    hints:
      - 'Pregunta si el orden y los duplicados son parte del problema.'
      - 'Pregunta si la operación principal busca por posición, pertenencia o clave.'
  - id: 'resolver-m06-1'
    kind: 'evidence'
    prompt: 'Implementa totalesPagados en lib/m06_colecciones.dart y ejecuta sus pruebas. Pega la salida del test que comprueba que la lista no es ampliable.'
    required: true
    hints:
      - 'Encadena where, map y toList en ese orden.'
      - 'toList acepta growable: false.'
  - id: 'sustentar-collections'
    kind: 'source'
    prompt: 'En Collections, encuentra qué garantiza cada estructura y localiza cómo se declara una lista no ampliable.'
    required: true
    sourceLabel: 'Collections'
    hints:
      - 'Busca los encabezados de lists, sets y maps.'
      - 'Anota una frase por estructura, no el párrafo entero.'
  - id: 'defender-no-ampliable'
    kind: 'judgment'
    prompt: 'Decide si la función debe devolver una lista ampliable o una fija, y nombra qué puede hacer quien la llame en cada caso.'
    required: true
    hints:
      - 'Una lista ampliable invita a que quien la recibe la use como acumulador.'
      - 'Una lista fija comunica que el resultado ya está completo.'
docRefs:
  - label: 'Collections'
    url: 'https://dart.dev/language/collections'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Built-in types'
    url: 'https://dart.dev/language/built-in-types'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué preguntas del dominio separan List, Set y Map?'
  - 'En un archivo vacío, vuelve a escribir totalesPagados sin mirar tu solución.'
  - 'Explica en voz alta por qué devolver una lista no ampliable forma parte del contrato.'
  - 'Modela una agenda con reuniones ordenadas y participantes únicos por reunión; compón los tipos que expresen las dos invariantes.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m06_colecciones.dart'
  testCommand: 'fvm dart test test/m06_colecciones_test.dart --name m06-1'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm06-1'
---

Una colección no es solo un recipiente. Su tipo comunica qué considera importante el problema: posición, unicidad o asociación por una clave. Elegir por costumbre esconde reglas críticas dentro de ciclos y condiciones.

## Tres estructuras, tres contratos

Usa una `List<T>` cuando el orden, la posición o los elementos repetidos tengan significado. Una lista de pasos conserva la secuencia; dos pasos iguales pueden ser dos eventos distintos.

Usa un `Set<T>` cuando la pertenencia única sea la regla central. Agregar el mismo permiso dos veces no crea otro permiso. No elijas un set si luego vas a depender de un índice.

Usa un `Map<K, V>` cuando la operación principal sea obtener un valor mediante una clave única:

```dart
final permisosPorUsuario = <String, Set<String>>{
  'ana': {'leer', 'editar'},
  'leo': {'leer'},
};

final puedeEditar = permisosPorUsuario['ana']?.contains('editar') ?? false;
```

El mapa expresa la asociación; el set anidado expresa que los permisos no se duplican. Componer estructuras es válido cuando cada nivel sostiene una regla distinta.

## El pipeline y su materialización

```dart
final totales = pedidos
    .where((pedido) => pedido.pagado)
    .map((pedido) => pedido.total)
    .toList(growable: false);
```

`where` y `map` describen una transformación por etapas. `toList` la materializa. Y `growable: false` no es un detalle de rendimiento: es una promesa. Dice **este resultado ya está completo**, en lugar de entregar un acumulador a medio llenar que cualquiera puede seguir modificando.

## Intento · antes de mirar

Modela tres casos y anota, para cada uno, si importan el orden, los duplicados y el acceso por clave: una fila de reproducción, un conjunto de etiquetas y un catálogo consultado por código. Después predice qué dato se perdería al cambiar la estructura elegida.

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m06_colecciones_test.dart --name m06-1
```

Pega la salida del test que comprueba que la lista devuelta no es ampliable. Si tus otros tests pasan y ese falla, ya sabes que el problema no es el filtrado: es el contrato.

## Fuente · lee con una pregunta

Abre **Collections** con dos preguntas: ¿qué garantiza cada estructura?, ¿cómo se declara una lista no ampliable? Anota un encabezado por respuesta.

## Criterio · decide y acepta el costo

Defiende `growable: false`. Devolver una lista ampliable es más flexible y también invita a que quien la recibe la trate como propia y la modifique. Devolver una fija comunica que terminaste, y obliga a copiar si alguien necesita agregar.

Elige y nombra el costo. En la próxima lección la estructura cambia de lista a conjunto, y con ella la regla que expresa.
