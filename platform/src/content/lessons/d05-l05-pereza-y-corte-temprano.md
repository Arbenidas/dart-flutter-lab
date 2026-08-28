---
id: 'D05-L05'
trackId: 'dart'
moduleId: 'D05'
kind: 'taller'
order: 4
slug: 'pereza-y-corte-temprano'
title: 'La pereza se puede medir'
summary: 'Comprueba con un contador que una búsqueda deja de evaluar apenas encuentra, y entiende qué recalcula un Iterable.'
estimatedMinutes: 50
objectives:
  - 'Explicar cuándo se ejecuta el callback de un Iterable perezoso.'
  - 'Implementar una búsqueda que corte al primer acierto.'
  - 'Reconocer cuándo la pereza produce efectos laterales repetidos.'
prerequisites: ['D05-L04']
activities:
  - id: 'predecir-evaluaciones'
    kind: 'attempt'
    prompt: 'Sin ejecutar nada, predice cuántas veces se llama a la condición al buscar el primer par en la lista 1, 2, 3, 4, 5, y cuántas si primero materializas con toList.'
    required: true
    hints:
      - 'Un for con retorno temprano deja de evaluar en cuanto encuentra.'
      - 'Filtrar toda la colección antes de tomar el primero evalúa todo.'
  - id: 'resolver-m06-5'
    kind: 'evidence'
    prompt: 'Implementa primeroQueCumple y ejecuta sus pruebas. Pega la salida del test que cuenta cuántas veces se evaluó la condición.'
    required: true
    hints:
      - 'Un for con return basta: no hace falta construir nada intermedio.'
      - 'Si el test de evaluaciones falla, estás recorriendo de más.'
  - id: 'sustentar-iterable'
    kind: 'source'
    prompt: 'En la referencia de Iterable, encuentra qué dice sobre la evaluación de map y where, y la advertencia sobre modificar la colección mientras se recorre.'
    required: true
    sourceLabel: 'Iterable class'
    hints:
      - 'Busca la palabra lazy en la descripción de la clase.'
      - 'Busca también ConcurrentModificationError.'
  - id: 'defender-materializar'
    kind: 'judgment'
    prompt: 'Decide si una función que devuelve una secuencia debería entregar un Iterable perezoso o una List materializada, y nombra qué le trasladas a quien la llama.'
    required: true
    hints:
      - 'Un Iterable puede recalcularse en cada recorrido, incluidos sus efectos.'
      - 'Una List cuesta memoria y entrega una fotografía estable.'
docRefs:
  - label: 'Iterable class'
    url: 'https://api.dart.dev/stable/dart-core/Iterable-class.html'
    kind: 'api'
    version: 'API estable'
    lastVerified: '2026-08-23'
  - label: 'Collections'
    url: 'https://dart.dev/language/collections'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Cuándo se ejecuta realmente el callback pasado a map o where?'
  - 'En un archivo vacío, vuelve a escribir primeroQueCumple con corte temprano, sin mirar tu solución.'
  - 'Explica en voz alta por qué modificar el tamaño de una colección mientras se itera es peligroso.'
  - 'Diseña una función que convierta Iterable<T> en Map<K, T> y decide si devuelve una vista o una fotografía.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m06_colecciones.dart'
  testCommand: 'fvm dart test test/m06_colecciones_test.dart --name m06-5'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm06-5'
  revealReference: true
---

La evaluación perezosa suele explicarse en abstracto. Este ejercicio la vuelve un número que puedes contar.

## `where` y `map` no calculan nada

```dart
final vista = numeros.map((n) {
  print('transformo $n');
  return n * 2;
});
```

Hasta aquí no se imprimió nada. `map` devolvió un `Iterable` que **describe** una transformación. El trabajo ocurre cuando alguien lo recorre:

```dart
print(vista.first); // imprime "transformo 1", después 2
print(vista.first); // imprime "transformo 1" OTRA VEZ
```

Cada recorrido vuelve a ejecutar el callback. Si ese callback tiene un efecto —imprimir, escribir, contar— el efecto se repite.

## La pereza como ventaja

Esa misma propiedad es lo que hace barata una búsqueda:

```dart
for (final elemento in elementos) {
  if (condicion(elemento)) return elemento;
}
return null;
```

Sobre una lista de un millón de elementos donde el segundo cumple, esto evalúa la condición **dos veces**. La versión que parece equivalente no:

```dart
return elementos.where(condicion).firstOrNull; // esta también corta
return elementos.toList().where(condicion).toList().firstOrNull; // esta no
```

La diferencia está en dónde materializas. Cada `toList` intermedio obliga a recorrer todo.

## Callbacks puros

De lo anterior sale una regla práctica: **prefiere callbacks puros**. Para la misma entrada producen la misma salida y no tocan nada externo. Un callback puro se puede ejecutar una vez o cien sin que cambie el resultado; uno con efectos convierte la pereza en un bug intermitente.

## Intento · antes de mirar

Predice el número exacto de evaluaciones al buscar el primer par en `[1, 2, 3, 4, 5]`:

- con un `for` y retorno temprano
- con `toList()` antes de filtrar
- con `where(...).firstOrNull`

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m06_colecciones_test.dart --name m06-5
```

El test cuenta las evaluaciones y espera exactamente dos. Pega su salida. Si tu implementación materializa antes de buscar, ese test te lo dice con un número, no con una opinión.

## Fuente · lee con una pregunta

Abre **Iterable class** con dos preguntas: ¿cuándo se ejecuta el callback?, ¿qué pasa si modificas la colección mientras la recorres? Anota los dos encabezados; el segundo es la causa del `ConcurrentModificationError` que vas a encontrarte tarde o temprano.

## Criterio · decide y acepta el costo

¿Tu función debería devolver el `Iterable` perezoso o una `List` materializada?

Devolver la vista ahorra trabajo si quien la recibe solo consume una parte, y le traslada un contrato sutil: cada recorrido recalcula. Devolver la lista cuesta memoria y entrega algo estable que nadie tiene que entender.

Elige y nombra el costo. Cierra el módulo:

```bash
fvm dart analyze
```

En D06 las colecciones dejan de ser el modelo y pasan a estar **dentro** de uno: clases que protegen sus propias reglas.
