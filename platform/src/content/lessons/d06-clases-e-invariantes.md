---
id: 'D06-L01'
trackId: 'dart'
moduleId: 'D06'
order: 0
slug: 'clases-objetos-e-invariantes'
title: 'Construye objetos que no puedan nacer inválidos'
summary: 'Diseña clases pequeñas, constructores con intención y métodos que preserven las reglas del objeto.'
estimatedMinutes: 105
objectives:
  - 'Distinguir identidad, estado y comportamiento al diseñar una clase.'
  - 'Validar invariantes en constructores o fábricas antes de exponer el objeto.'
  - 'Preferir objetos inmutables y operaciones que devuelvan nuevos valores.'
prerequisites: ['D05-L01']
activities:
  - id: 'predecir-invariantes'
    kind: 'predict'
    prompt: 'Enumera estados inválidos para un porcentaje y predice qué partes del programa tendrían que defenderse si el constructor permitiera valores menores que 0 o mayores que 100.'
    required: true
    hints:
      - 'Una invariante debe cumplirse durante toda la vida del objeto.'
      - 'Cuenta cuántos consumidores necesitarían repetir la validación.'
  - id: 'escribir-porcentaje'
    kind: 'code'
    prompt: 'En un scratch local, implementa un Porcentaje inmutable con fábrica validadora y un método sumar que devuelva otro objeto válido. Ejecuta casos de frontera con el Dart de FVM.'
    required: true
    hints:
      - 'Oculta el constructor generativo con un nombre privado.'
      - 'ArgumentError.value conserva el valor rechazado y el nombre del parámetro.'
  - id: 'diagnosticar-fuga'
    kind: 'debug'
    prompt: 'Crea una clase que reciba una List y la exponga directamente; demuestra cómo el llamador rompe su estado al modificar la lista y corrige la fuga defensivamente.'
    required: true
    hints:
      - 'final impide reasignar el campo, no mutar el objeto apuntado.'
      - 'Considera List.unmodifiable al cruzar el límite.'
  - id: 'rastrear-constructores'
    kind: 'docs'
    prompt: 'En Constructors, compara constructor generativo, nombrado, const y factory. Anota qué problema resuelve cada uno y cuál usarías para validar antes de crear.'
    required: true
    hints:
      - 'Una factory puede devolver una instancia existente o un subtipo.'
      - 'Un constructor const exige estado final compatible con constantes.'
  - id: 'defender-responsabilidad'
    kind: 'explain'
    prompt: 'Decide si formatear un porcentaje para una interfaz concreta pertenece al objeto de dominio o a la capa que presenta el dato. Defiende el límite elegido.'
    required: true
    hints:
      - 'Distingue una representación universal de una decisión visual o regional.'
      - 'Pregunta cuántos motivos distintos tendría la clase para cambiar.'
  - id: 'transferir-rango'
    kind: 'transfer'
    prompt: 'Diseña un RangoFecha que garantice inicio menor o igual que fin. Escribe su contrato, tres casos de frontera y una operación duracion que preserve la invariante.'
    required: true
    hints:
      - 'La igualdad puede representar un rango de duración cero.'
      - 'Decide explícitamente si los extremos están incluidos.'
docRefs:
  - label: 'Classes'
    url: 'https://dart.dev/language/classes'
    kind: 'guide'
    version: 'Dart 3.13'
    lastVerified: '2026-08-23'
  - label: 'Constructors'
    url: 'https://dart.dev/language/constructors'
    kind: 'guide'
    version: 'Dart 3.13'
    lastVerified: '2026-08-23'
  - label: 'Methods'
    url: 'https://dart.dev/language/methods'
    kind: 'guide'
    version: 'Dart 3.13'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué diferencia hay entre validar una invariante al construir y comprobarla en cada consumidor?'
  - '¿Por qué un campo final que contiene una List no vuelve inmutable la lista?'
  - '¿Cuándo elegirías un constructor factory en lugar de uno generativo público?'
  - '¿Cómo detectas que una clase tiene más de una responsabilidad?'
---

Una clase útil no agrupa datos porque aparecen juntos en una pantalla. Representa un concepto con reglas que deben mantenerse siempre. El constructor establece esas reglas; los métodos evitan que el objeto las rompa después.

## De datos sueltos a una invariante

Un porcentaje válido vive entre 0 y 100. Si el programa usa un `int`, cada función debe recordar ese límite. Un tipo propio puede convertir la regla en una puerta de entrada única:

```dart
final class Porcentaje {
  final int valor;

  const Porcentaje._(this.valor);

  factory Porcentaje(int valor) {
    if (valor < 0 || valor > 100) {
      throw ArgumentError.value(valor, 'valor', 'Debe estar entre 0 y 100');
    }
    return Porcentaje._(valor);
  }

  Porcentaje sumar(int puntos) => Porcentaje(valor + puntos);
}
```

El constructor privado impide saltarse la validación desde otra biblioteca. La fábrica decide si puede producir una instancia. `sumar` no modifica el objeto: vuelve a pasar por la misma regla y entrega uno nuevo.

No uses una clase para esconder cualquier entero. El tipo merece existir cuando el nombre y la invariante eliminan decisiones repetidas o ambiguas.

## Final no significa profundamente inmutable

Este diseño todavía filtra mutabilidad:

```dart
final class Equipo {
  final List<String> miembros;
  Equipo(this.miembros);
}
```

El campo no puede apuntar a otra lista, pero el llamador conserva una referencia y puede usar `add`. Una frontera defensiva crea una vista no modificable:

```dart
final class Equipo {
  final List<String> miembros;
  Equipo(Iterable<String> miembros)
      : miembros = List.unmodifiable(miembros);
}
```

La decisión tiene costo de copia. Debes aceptarlo conscientemente cuando proteger el estado vale más que compartir una colección mutable.

## P — Predice

Enumera valores de frontera para `Porcentaje`: `-1`, `0`, `1`, `99`, `100` y `101`. Predice qué ocurre al construir y qué ocurre al sumar. Después imagina que `valor` fuera público y mutable. Lista todos los lugares que tendrían que comprobar la regla otra vez.

Haz la misma predicción con `Equipo`: crea una lista, pásala al constructor y modifícala desde afuera. ¿Cambian los miembros del objeto? La respuesta revela si el límite es real o decorativo.

## E — Escribe

Implementa ambos tipos en un scratch local. Prueba construcción válida, fronteras inválidas y la fuga de la lista. Ejecuta tus ejemplos con el SDK administrado por FVM y confirma que el laboratorio existente sigue sano:

```bash
cd dart_lab
fvm dart --version
fvm dart analyze
fvm dart test
```

No atrapes el `ArgumentError` dentro de `Porcentaje`: la fábrica debe rechazar; quien traduce una entrada externa decide cómo informar al usuario.

## N — Nombra el fallo

Separa estas causas:

- **invariante ausente:** el tipo permite representar un estado que el dominio prohíbe;
- **validación tardía:** la regla se comprueba después de que el objeto inválido ya circuló;
- **fuga mutable:** una referencia externa puede cambiar estado interno;
- **responsabilidad mezclada:** el objeto combina reglas del dominio con formato, red o almacenamiento;
- **constructor ambiguo:** dos maneras de crear el objeto no explican su intención.

Cuando un test falla, identifica qué regla dejó de ser cierta. “El objeto acepta 101” permite revisar el límite; “la clase está mal” no.

## S — Sustenta

En **Constructors**, compara generativos, nombrados, constantes y fábricas. No memorices la lista: anota la decisión que habilita cada forma. Busca también el orden de inicialización y recuerda que el cuerpo se ejecuta después de los inicializadores.

En **Methods**, verifica qué miembros acceden al estado de instancia y cómo se declara un método abstracto. Regresa a tu clase y marca qué parte es dato, qué parte es regla de construcción y qué parte es comportamiento.

## A — Argumenta

¿Debe `Porcentaje` devolver `'75 %'`? Puede tener una representación técnica general, pero formato regional, color y texto para pantalla pertenecen a la presentación. Defiende el límite según los consumidores reales.

Compara también copiar una lista con conservar la referencia. Compartir ahorra una asignación; copiar reduce acoplamiento. No conviertas toda colección en no modificable por reflejo: explica qué invariante proteges y quién posee el dato.

## R — Reaplica

Diseña `RangoFecha`. Decide si permite inicio igual a fin y si los extremos cuentan dentro del rango. Antes del código, escribe tres frases: qué acepta, qué rechaza y qué devuelve `duracion`.

Luego prueba la transferencia a `Dinero`, `NombreUsuario` o `Coordenada`. Si el nuevo tipo no puede explicar una regla propia, quizá una función y un valor sean suficientes. La orientación a objetos no consiste en crear más clases, sino en colocar cada regla donde sea difícil violarla.
