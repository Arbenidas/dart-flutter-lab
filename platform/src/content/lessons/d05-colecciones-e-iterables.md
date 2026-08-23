---
id: 'D05-L01'
trackId: 'dart'
moduleId: 'D05'
order: 0
slug: 'colecciones-e-iterables-con-intencion'
title: 'La colección correcta expresa una regla del dominio'
summary: 'Elige List, Set o Map por sus invariantes y construye transformaciones de Iterable sin efectos laterales ocultos.'
estimatedMinutes: 100
objectives:
  - 'Elegir List, Set o Map a partir de orden, unicidad y forma de acceso.'
  - 'Explicar cuándo un pipeline de Iterable es perezoso y cuándo se materializa.'
  - 'Transformar colecciones sin modificar accidentalmente la entrada.'
prerequisites: ['D04-L01']
activities:
  - id: 'predecir-coleccion'
    kind: 'predict'
    prompt: 'Para una fila de reproducción, un conjunto de etiquetas y un catálogo por identificador, elige List, Set o Map y predice qué información perderías con cada alternativa.'
    required: true
    hints:
      - 'Pregunta si el orden y los duplicados son parte del problema.'
      - 'Pregunta si la operación principal busca por posición, pertenencia o clave.'
  - id: 'escribir-pipeline'
    kind: 'code'
    prompt: 'En un scratch local, transforma una lista de pedidos: conserva los pagados, extrae sus totales y materializa el resultado en una lista no ampliable. Ejecuta el ejemplo con el Dart administrado por FVM.'
    required: true
    hints:
      - 'Encadena where, map y toList en ese orden.'
      - 'Usa growable: false al materializar.'
  - id: 'diagnosticar-pereza'
    kind: 'debug'
    prompt: 'Construye un ejemplo donde el callback de map imprima un mensaje y demuestra por qué iterar dos veces ejecuta dos veces ese efecto. Nombra el problema y elimina el efecto lateral.'
    required: true
    hints:
      - 'map devuelve un Iterable perezoso.'
      - 'Compara guardar el Iterable con guardar el resultado de toList.'
  - id: 'rastrear-iterable'
    kind: 'docs'
    prompt: 'En la referencia oficial de Iterable, encuentra la regla de evaluación de map y where y la advertencia sobre modificar una colección durante la iteración. Registra ambos encabezados.'
    required: true
    hints:
      - 'Busca la palabra lazy en la descripción de Iterable.'
      - 'Busca ConcurrentModificationError.'
  - id: 'defender-estructura'
    kind: 'explain'
    prompt: 'Defiende la estructura para guardar permisos únicos por usuario y explica por qué una List de pares o un Set aislado vuelve más difícil la consulta principal.'
    required: true
    hints:
      - 'Una clave de Map aparece una sola vez.'
      - 'El valor del Map todavía puede ser un Set.'
  - id: 'transferir-indice'
    kind: 'transfer'
    prompt: 'Diseña una función genérica que convierta Iterable<T> en Map<K, T> usando una función que extraiga la clave. Decide y documenta qué ocurre si dos elementos producen la misma clave.'
    required: true
    hints:
      - 'La política de duplicados es parte del contrato.'
      - 'Considera rechazar el duplicado o conservar el último; no lo dejes implícito.'
docRefs:
  - label: 'Collections'
    url: 'https://dart.dev/language/collections'
    kind: 'guide'
    version: 'Dart 3.13'
    lastVerified: '2026-08-23'
  - label: 'Iterable class'
    url: 'https://api.dart.dev/dart-core/Iterable-class.html'
    kind: 'api'
    version: 'Dart 3.13 API'
    lastVerified: '2026-08-23'
  - label: 'Map class'
    url: 'https://api.dart.dev/dart-core/Map-class.html'
    kind: 'api'
    version: 'Dart 3.13 API'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué preguntas del dominio separan List, Set y Map?'
  - '¿Cuándo se ejecuta realmente el callback pasado a map o where?'
  - '¿Por qué modificar el tamaño de una colección mientras se itera es peligroso?'
  - '¿Qué decisión debe documentar una función que indexa elementos con claves repetidas?'
---

Una colección no es solo un recipiente. Su tipo comunica qué considera importante el problema: posición, unicidad o asociación por una clave. Elegir por costumbre puede dejar reglas críticas escondidas en ciclos y condiciones.

## Tres estructuras, tres contratos

Usa una `List<T>` cuando el orden, la posición o los elementos repetidos tengan significado. Una lista de pasos conserva la secuencia; dos pasos iguales pueden ser dos eventos distintos.

Usa un `Set<T>` cuando la pertenencia única sea la regla central. Agregar el mismo permiso dos veces no crea otro permiso. No elijas un set si luego necesitas depender de un índice.

Usa un `Map<K, V>` cuando la operación principal sea obtener un valor mediante una clave única:

```dart
final permisosPorUsuario = <String, Set<String>>{
  'ana': {'leer', 'editar'},
  'leo': {'leer'},
};

final puedeEditar = permisosPorUsuario['ana']?.contains('editar') ?? false;
```

El mapa expresa una asociación; el set anidado expresa que los permisos no se duplican. Componer estructuras es válido cuando cada nivel sostiene una regla distinta.

## Iterable describe una secuencia posible

`List` y `Set` implementan `Iterable`. Métodos como `where` y `map` permiten describir una transformación por etapas:

```dart
final totalesVisibles = pedidos
    .where((pedido) => pedido.pagado)
    .map((pedido) => pedido.total)
    .toList(growable: false);
```

`where` y `map` devuelven iterables perezosos: sus callbacks se ejecutan cuando alguien recorre el resultado, no necesariamente al construir el pipeline. Cada nueva iteración puede volver a ejecutar el trabajo. `toList` materializa una fotografía concreta en ese momento.

La pereza evita trabajo si solo consumes parte de la secuencia, pero exige disciplina. Un callback con `print`, una escritura externa o una mutación puede repetirse de forma inesperada. Prefiere callbacks puros: para la misma entrada producen la misma salida y no cambian el exterior.

## P — Predice

Antes de escribir, modela tres casos: una fila de reproducción, etiquetas únicas y productos consultados por código. Para cada uno anota si importan orden, duplicados y acceso por clave. Luego predice qué dato se perdería al cambiar la estructura elegida.

Predice también la salida de este fragmento antes de ejecutarlo:

```dart
final numeros = [1, 2, 3];
final dobles = numeros.map((numero) {
  print('transformo $numero');
  return numero * 2;
});

print(dobles.first);
print(dobles.first);
```

No respondas solo los valores. Cuenta cuántas veces se imprime el efecto y conecta la respuesta con la evaluación perezosa.

## E — Escribe

Crea un scratch local dentro de tu copia del laboratorio. Modela pedidos mínimos con `pagado` y `total`; filtra, transforma y materializa. Ejecuta el archivo desde tu editor usando el Dart fijado por FVM. Después verifica que no dañaste el proyecto base:

```bash
cd dart_lab
fvm dart --version
fvm dart analyze
fvm dart test
```

Escribe primero una versión con `for` y una lista nueva. Luego refactoriza a `where`, `map` y `toList`. Ambas deben conservar la entrada y producir el mismo orden.

## N — Nombra el fallo

Clasifica los fallos de colección con precisión:

- **estructura equivocada:** el tipo permite duplicados o pierde una clave necesaria;
- **mutación durante iteración:** cambia el tamaño de la colección mientras un iterador la recorre;
- **efecto perezoso:** un callback produce cambios externos cada vez que se itera;
- **materialización ausente:** el consumidor esperaba una fotografía, pero conserva una vista que se recalcula;
- **duplicado silencioso:** dos valores compiten por la misma clave sin una política declarada.

Una descripción concreta —“el segundo recorrido vuelve a ejecutar `map` porque guardé un `Iterable`, no una `List`”— orienta mejor que “la colección falla”.

## S — Sustenta

Abre **Collections** para comprobar cómo Dart representa listas, sets y mapas. Después usa la referencia de **Iterable**: localiza la descripción de los métodos perezosos y la advertencia sobre modificar la colección mientras se recorre.

No leas todo. Llega con dos preguntas: “¿cuándo se ejecuta este callback?” y “¿qué garantiza esta estructura?”. Copia el encabezado que contiene la respuesta, ciérralo y explica la regla con tu propio ejemplo.

## A — Argumenta

Compara un ciclo explícito con el pipeline. Evalúa intención, puntos de depuración, materialización y costo de recorrer. Un pipeline corto suele hacer visible la transformación; una cadena con muchas ramas puede ocultarla. La decisión no depende de cuántos caracteres ahorra.

Defiende también la política de claves repetidas de tu función de índice. Rechazar un duplicado protege unicidad fuerte; conservar el último puede representar una actualización. Cualquiera sirve si el contrato lo dice y tiene una prueba.

## R — Reaplica

Generaliza el índice a `Map<K, T> indexarPor<T, K>(Iterable<T> elementos, K Function(T) clave)`. Pruébalo mentalmente con usuarios por identificador, productos por código y eventos por fecha. Busca un caso donde la clave no sea realmente única y ajusta el contrato antes del cuerpo.

Termina explicando, sin código, qué estructura usarías para una agenda ordenada con participantes únicos por reunión. Si puedes separar las dos invariantes y componer tipos para expresarlas, ya no eliges colecciones por apariencia.
