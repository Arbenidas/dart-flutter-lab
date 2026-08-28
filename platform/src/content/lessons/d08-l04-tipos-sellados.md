---
id: 'D08-L04'
trackId: 'dart'
moduleId: 'D08'
kind: 'taller'
order: 3
slug: 'tipos-sellados-y-exhaustividad'
title: 'Un tipo sellado convierte un olvido en un error'
summary: 'Modela un resultado con dos variantes y escribe un switch sin comodín que deje de compilar si agregas una tercera.'
estimatedMinutes: 60
objectives:
  - 'Declarar una jerarquía sellada con sus variantes.'
  - 'Escribir una switch expression exhaustiva sin rama comodín.'
  - 'Explicar por qué una rama comodín anula la garantía del compilador.'
prerequisites: ['D08-L03']
activities:
  - id: 'predecir-variante-nueva'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, predice qué ocurre al agregar una tercera variante a un tipo sellado si el switch que lo consume no la contempla, con y sin rama comodín.'
    required: true
    hints:
      - 'Sin comodín, el compilador puede probar que falta un caso.'
      - 'Con comodín, el caso nuevo cae ahí en silencio.'
  - id: 'resolver-m09-4'
    kind: 'evidence'
    prompt: 'Implementa la validación de Invalido y la función describir con un switch exhaustivo. Ejecuta sus pruebas y pega la salida del caso de la lista de mensajes vacía.'
    required: true
    hints:
      - 'Un invalido sin motivos es el estado imposible que la clase debe rechazar.'
      - 'El switch puede desestructurar cada variante para leer sus campos.'
  - id: 'sustentar-sealed'
    kind: 'source'
    prompt: 'En Class modifiers, encuentra qué garantiza sealed y cómo se relaciona con la exhaustividad de un switch.'
    required: true
    sourceLabel: 'Class modifiers'
    hints:
      - 'Busca el modificador sealed en la tabla.'
      - 'Fíjate en la restricción sobre dónde pueden vivir las subclases.'
  - id: 'defender-comodin'
    kind: 'judgment'
    prompt: 'Decide si conviene agregar una rama comodín por seguridad, y nombra qué garantía pierdes al hacerlo.'
    required: true
    hints:
      - 'Una rama comodín evita el error de compilación y también el aviso.'
      - 'El error de compilación es la lista de tareas de tu cambio incompleto.'
docRefs:
  - label: 'Class modifiers'
    url: 'https://dart.dev/language/class-modifiers'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Patterns'
    url: 'https://dart.dev/language/patterns'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué garantiza sealed sobre el conjunto de variantes de un tipo?'
  - 'En un archivo vacío, vuelve a escribir Resultado con sus dos variantes y describir, sin mirar.'
  - 'Explica en voz alta por qué una rama comodín anula la garantía del compilador.'
  - 'Modela un estado de conexión con tres variantes y escribe su switch exhaustivo antes que las clases.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m09_modelado.dart'
  testCommand: 'fvm dart test test/m09_modelado_test.dart --name m09-4'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm09-4'
---

Un `enum` sirve cuando las variantes no llevan datos propios. Cuando cada una necesita cargar información distinta, hace falta otra cosa.

## Dos variantes con datos distintos

```dart
sealed class Resultado<T> {
  const Resultado();
}

final class Valido<T> extends Resultado<T> {
  const Valido(this.valor);
  final T valor;
}

final class Invalido<T> extends Resultado<T> {
  Invalido(this.mensajes) {
    if (mensajes.isEmpty) {
      throw ArgumentError.value(mensajes, 'mensajes', 'No puede estar vacía');
    }
  }
  final List<String> mensajes;
}
```

Un `Valido` lleva un valor; un `Invalido` lleva motivos. No hay forma de escribir un resultado que sea las dos cosas, ni uno que no sea ninguna.

Y fíjate en la validación de `Invalido`: un «inválido sin motivos» sería otro estado imposible, así que la invariante lo rechaza — la técnica de D06-L01 aplicada aquí.

## Qué compra `sealed`

`sealed` le dice al compilador: **todas** las subclases están en este archivo. Nadie puede agregar una tercera desde fuera.

Con esa garantía, el compilador puede comprobar que un `switch` las cubre todas:

```dart
String describir<T>(Resultado<T> resultado) => switch (resultado) {
  Valido<T>(valor: final valor) => 'ok: $valor',
  Invalido<T>(mensajes: final mensajes) => 'error: ${mensajes.join(', ')}',
};
```

Sin rama comodín. Cada caso además **desestructura** la variante para leer su campo, que es el pattern matching de D03-L03 aplicado a clases.

## El error es la funcionalidad

Agrega `Cancelada<T>` a la jerarquía y `describir` deja de compilar. Eso no es un estorbo: es el compilador dándote la **lista de sitios** que tu cambio dejó incompletos.

Un `_ => 'otro'` al final haría que compile. Y también haría que `Cancelada` se describa como «otro» en producción sin que nadie se entere. La rama comodín cambia un error de compilación por un bug silencioso.

## Intento · antes de mirar

Predice, por escrito, qué ocurre al agregar una tercera variante en los dos escenarios: con `switch` exhaustivo y con rama comodín. Anota en cuál te enteras y cuándo.

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m09_modelado_test.dart --name m09-4
```

Pega la salida del caso de la lista vacía. Después haz el experimento completo: agrega una variante `Cancelada<T>` a la jerarquía, ejecuta `fvm dart analyze` y pega el error. Bórrala al terminar.

## Fuente · lee con una pregunta

Abre **Class modifiers** y busca `sealed`. Dos preguntas: ¿qué garantiza?, ¿dónde deben vivir las subclases? Anota el encabezado.

## Criterio · decide y acepta el costo

Defiende no poner rama comodín. El argumento en contra es real: sin comodín, cada variante nueva rompe la compilación de todos los consumidores, y en una base grande eso son muchos archivos.

Pero esos archivos **había que tocarlos**. La pregunta no es si el cambio es grande, sino si te enteras. Nombra tu postura y el costo que aceptas.

En la última lección del módulo el tipo sellado se pone a trabajar.
