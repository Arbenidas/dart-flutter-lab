---
id: 'D03-L02'
trackId: 'dart'
moduleId: 'D03'
kind: 'taller'
order: 1
slug: 'casos-agrupados-y-exhaustividad'
title: 'Cuando el compilador no puede probar que cubriste todo'
summary: 'Agrupa casos con el operador de alternativa y descubre por qué un switch sobre String necesita un caso por defecto.'
estimatedMinutes: 45
objectives:
  - 'Agrupar varios valores en una sola rama con el operador de alternativa.'
  - 'Explicar por qué una switch expression sobre String exige un caso por defecto.'
  - 'Distinguir un tipo con valores enumerables de uno con valores abiertos.'
prerequisites: ['D03-L01']
activities:
  - id: 'predecir-exhaustividad'
    kind: 'attempt'
    prompt: 'Sin ejecutar nada, predice si una switch expression sobre String que cubre los siete días compila sin caso por defecto, y por qué.'
    required: true
    hints:
      - 'Piensa cuántos valores distintos puede tomar un String.'
      - 'El compilador necesita poder demostrar que no queda ninguno fuera.'
  - id: 'resolver-m04-2'
    kind: 'evidence'
    prompt: 'Implementa tipoDeDia con una switch expression y casos agrupados, ejecuta sus pruebas y pega la salida.'
    required: true
    hints:
      - 'El operador de alternativa se escribe con dos barras verticales entre los valores.'
      - 'Necesitas un caso por defecto, escrito con guion bajo.'
  - id: 'sustentar-exhaustive'
    kind: 'source'
    prompt: 'En Branches, localiza qué dice sobre exhaustividad en switch expressions y qué tipos permiten omitir el caso por defecto.'
    required: true
    sourceLabel: 'Branches'
    hints:
      - 'Busca la palabra exhaustive dentro de la página.'
      - 'Fíjate si menciona enums o sealed classes.'
  - id: 'defender-tipo-entrada'
    kind: 'judgment'
    prompt: 'Decide si el día de la semana debería llegar como String o como enum, y nombra qué gana y qué cuesta cada opción.'
    required: true
    hints:
      - 'Con un enum el compilador puede probar que cubriste todos los casos.'
      - 'Con String, cualquier dedazo entra sin avisar hasta la ejecución.'
docRefs:
  - label: 'Branches'
    url: 'https://dart.dev/language/branches'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Patterns'
    url: 'https://dart.dev/language/patterns'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Por qué una switch expression sobre String necesita un caso por defecto?'
  - 'En un archivo vacío, vuelve a escribir tipoDeDia con casos agrupados sin mirar tu solución.'
  - 'Explica en voz alta qué significa que un switch sea exhaustivo.'
  - 'Convierte tipoDeDia para que reciba un enum y observa qué rama deja de hacer falta.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m04_control.dart'
  testCommand: 'fvm dart test test/m04_control_test.dart --name m04-2'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm04-2'
---

Repetir la misma rama para cinco valores distintos no es solo verboso: esconde que esos cinco valores significan lo mismo para tu lógica. El operador de alternativa lo hace visible.

## Agrupar casos

```dart
final tipo = switch (dia) {
  'sabado' || 'domingo' => 'fin de semana',
  'lunes' || 'martes' || 'miercoles' || 'jueves' || 'viernes' => 'habil',
  _ => 'dia invalido',
};
```

Las dos barras separan alternativas dentro de una misma rama. La agrupación comunica una regla del dominio: _estos días se tratan igual_.

## Exhaustividad: qué puede probar el compilador

La última rama, `_`, es el caso por defecto. Sobre un `String` **no es opcional**, y el motivo es interesante: un `String` puede tomar infinitos valores. `'Lunes'`, `'lunes '`, `'lunse'`. El compilador no tiene forma de demostrar que los cubriste todos, así que exige que digas qué pasa con el resto.

Con otros tipos sí puede. Un `enum` tiene un número finito y conocido de valores; si los cubres todos, el caso por defecto sobra —y además, si mañana agregas un valor nuevo al enum, el compilador te señala cada `switch` incompleto. Eso es un cambio incompleto convertido en error temprano, y es una de las mejores propiedades de Dart 3.

Esa es la diferencia entre un tipo **cerrado** y uno **abierto**, y vas a volver a ella en D08.

## Intento · antes de mirar

Predice: una switch expression sobre `String` que cubre los siete días de la semana y no tiene `_`, ¿compila? Escribe tu respuesta y el motivo antes de probar.

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m04_control_test.dart --name m04-2
```

Después haz el experimento: borra la rama `_` y ejecuta `fvm dart analyze`. Pega el mensaje. Ese error es la respuesta a tu predicción, dicha por la herramienta.

## Fuente · lee con una pregunta

Abre **Branches** y busca la palabra _exhaustive_. Pregunta concreta: ¿qué tipos permiten omitir el caso por defecto y por qué? Anota el encabezado.

## Criterio · decide y acepta el costo

El contrato recibe el día como `String`. Defiende si eso está bien o si debería ser un `enum`. Con `enum`, un dedazo no compila y el caso por defecto desaparece; a cambio, hay que convertir el texto que llega de afuera en un valor del enum, y ahí vuelve el problema de la entrada inválida que ya trabajaste en D02.

En la próxima lección los patterns dejan de comparar valores sueltos y empiezan a **desarmar** objetos.
