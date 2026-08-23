---
id: 'D07-L01'
trackId: 'dart'
moduleId: 'D07'
order: 0
slug: 'contratos-composicion-y-reutilizacion'
title: 'Compón capacidades antes de construir jerarquías'
summary: 'Usa interfaces para intercambiar dependencias y elige herencia, mixins o extensiones solo cuando su relación sea explícita.'
estimatedMinutes: 110
objectives:
  - 'Definir contratos pequeños con abstract interface class e implementaciones intercambiables.'
  - 'Preferir composición cuando una dependencia no sea una relación real de subtipo.'
  - 'Distinguir los usos legítimos de extends, with y extension.'
prerequisites: ['D06-L01']
activities:
  - id: 'predecir-cambio'
    kind: 'predict'
    prompt: 'Compara un servicio que crea DateTime.now dentro de cada método con otro que recibe un Reloj. Predice qué pruebas y cambios de zona horaria resultan difíciles en la primera versión.'
    required: true
    hints:
      - 'Una dependencia oculta no se puede sustituir desde el test.'
      - 'Pregunta quién decide cuál es la hora actual.'
  - id: 'escribir-reloj'
    kind: 'code'
    prompt: 'En un scratch local, define Reloj como contrato, implementa RelojSistema y RelojFijo, e inyecta uno en un servicio que calcule vencimientos. Ejecuta ambos comportamientos con FVM.'
    required: true
    hints:
      - 'El contrato necesita una sola operación: ahora().'
      - 'RelojFijo conserva un DateTime entregado por el test.'
  - id: 'diagnosticar-herencia'
    kind: 'debug'
    prompt: 'Analiza una clase ReporteCsv extends List<String>. Encuentra una operación heredada que permita romper el concepto y rediseña ReporteCsv para contener la lista.'
    required: true
    hints:
      - 'Si cualquier método de List carece de sentido para ReporteCsv, la sustitución es sospechosa.'
      - 'La composición expone solo las operaciones necesarias.'
  - id: 'rastrear-mecanismos'
    kind: 'docs'
    prompt: 'En Class modifiers, Mixins y Extension methods, identifica qué puede construirse, implementarse o mezclarse y cómo el tipo estático afecta una extensión.'
    required: true
    hints:
      - 'Busca abstract interface class en la tabla de capacidades.'
      - 'Las extensiones se resuelven con el tipo estático, no con dynamic.'
  - id: 'defender-eleccion'
    kind: 'explain'
    prompt: 'Para reutilizar registro de auditoría en clases no relacionadas, compara composición, mixin y clase base con criterios de estado, constructor, contrato público y pruebas.'
    required: true
    hints:
      - 'Un mixin reutiliza implementaciones en varias jerarquías, pero no recibe parámetros de un constructor generativo.'
      - 'Composición hace visible el colaborador como dependencia.'
  - id: 'transferir-notificaciones'
    kind: 'transfer'
    prompt: 'Diseña un EnviadorMensaje con implementaciones de correo y consola; crea un servicio que dependa del contrato y explica cómo probarías una entrega sin enviar nada real.'
    required: true
    hints:
      - 'El doble de prueba puede guardar los mensajes recibidos.'
      - 'El servicio no debe preguntar qué implementación recibió.'
docRefs:
  - label: 'Class modifiers'
    url: 'https://dart.dev/language/class-modifiers'
    kind: 'guide'
    version: 'Dart 3.13'
    lastVerified: '2026-08-23'
  - label: 'Mixins'
    url: 'https://dart.dev/language/mixins'
    kind: 'guide'
    version: 'Dart 3.13'
    lastVerified: '2026-08-23'
  - label: 'Extension methods'
    url: 'https://dart.dev/language/extension-methods'
    kind: 'guide'
    version: 'Dart 3.13'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué vuelve sustituible y fácil de probar a una dependencia?'
  - '¿Qué pregunta te ayuda a decidir entre herencia y composición?'
  - '¿Cuándo aporta un mixin y qué limitación tiene respecto a construcción y estado?'
  - '¿Por qué una extension method no funciona igual sobre una variable dynamic?'
---

Una abstracción útil no existe para ocultar archivos. Define una capacidad que varios colaboradores pueden cumplir sin obligar al consumidor a conocer sus detalles. La composición conecta esas capacidades de forma visible.

## Un contrato pequeño crea un punto de sustitución

El tiempo actual es una dependencia. Si un servicio llama `DateTime.now()` internamente, una prueba depende del reloj real. Extraer una capacidad permite decidir desde afuera:

```dart
abstract interface class Reloj {
  DateTime ahora();
}

final class RelojSistema implements Reloj {
  @override
  DateTime ahora() => DateTime.now();
}

final class RelojFijo implements Reloj {
  final DateTime instante;
  const RelojFijo(this.instante);

  @override
  DateTime ahora() => instante;
}

final class CalculadorVencimiento {
  final Reloj reloj;
  const CalculadorVencimiento(this.reloj);

  DateTime enDias(int dias) => reloj.ahora().add(Duration(days: dias));
}
```

`CalculadorVencimiento` compone un `Reloj`; no hereda de él. El servicio **usa** la capacidad, no **es** un reloj. El constructor vuelve visible la dependencia y una prueba puede entregar `RelojFijo`.

## Cuatro mecanismos que no son sinónimos

- `implements` acepta un contrato y obliga a implementar sus miembros. Úsalo para sustituibilidad.
- `extends` declara una relación de subtipo y hereda implementación. Úsalo cuando el descendiente pueda cumplir todo lo prometido por la base.
- `with` incorpora implementaciones de un mixin en varias jerarquías. Es útil para una capacidad transversal bien acotada.
- `extension` agrega miembros que se resuelven estáticamente sin modificar ni subtipar la clase original.

La composición no usa una palabra especial: una clase recibe o contiene otra. Esa sencillez mantiene responsabilidades separadas y facilita reemplazar colaboradores.

## P — Predice

Imagina una prueba que comprueba un vencimiento a medianoche. Predice qué ocurre si usa el reloj real y se ejecuta un segundo después del cambio de día. Luego reemplaza mentalmente la fuente por `RelojFijo` y describe qué parte deja de variar.

Después revisa `ReporteCsv extends List<String>`. Enumera tres operaciones heredadas que no expresan el dominio. Si el subtipo permite estados que un reporte debería prohibir, la herencia amplió demasiado el contrato.

## E — Escribe

Implementa el reloj y el calculador en un scratch local. Ejecuta una prueba manual con una fecha fija y otra con el sistema. Después compón un `EnviadorMensaje` falso que guarde mensajes en memoria.

Usa la versión del SDK fijada por el repositorio y conserva la verificación existente:

```bash
cd dart_lab
fvm dart --version
fvm dart analyze
fvm dart test
```

No agregues una fábrica global ni un singleton. Pasa la dependencia por constructor para que cada instancia declare qué necesita.

## N — Nombra el fallo

Clasifica los problemas antes de cambiar la jerarquía:

- **dependencia oculta:** el colaborador se crea dentro y no puede sustituirse;
- **contrato ancho:** una interfaz obliga a implementar operaciones que el consumidor no usa;
- **herencia por reutilización:** el subtipo no puede cumplir todas las expectativas de la base;
- **comprobación de tipo:** el consumidor pregunta `if (x is ...)` para decidir cómo usar una implementación;
- **extensión invisible:** el receptor es `dynamic` o existe un conflicto entre extensiones.

Si el servicio debe saber qué implementación recibió, el contrato todavía no contiene la diferencia importante.

## S — Sustenta

En **Class modifiers**, lee la tabla que separa construir, extender, implementar y mezclar. Conecta `abstract interface class` con el objetivo del reloj: nadie crea el contrato y las implementaciones externas aceptan cumplirlo.

En **Mixins**, identifica sus restricciones de construcción y el uso de `on`. En **Extension methods**, busca la sección sobre tipos estáticos y `dynamic`. Cada documento responde una pregunta distinta; evita elegir el mecanismo por tener menos líneas.

## A — Argumenta

Para auditoría transversal, compara tres diseños. Una clase base comparte implementación, pero fija una jerarquía. Un mixin agrega la capacidad a tipos no relacionados, aunque acopla esa implementación a cada clase. Un objeto `Auditor` compuesto hace la dependencia explícita, puede conservar estado propio e intercambiarse en pruebas.

Elige con cuatro criterios: relación semántica, estado compartido, construcción y necesidad de sustitución. “Reutiliza código” no es suficiente porque los cuatro mecanismos pueden hacerlo con costos diferentes.

## R — Reaplica

Diseña `EnviadorMensaje` con una sola operación. Implementa correo, consola y un doble de prueba que recopile entregas. El servicio consumidor no debe importar SDKs externos ni ramificarse por implementación.

Transfiere luego la idea a almacenamiento, generación de identificadores o lectura de configuración. Si el contrato nace con diez métodos, vuelve al consumidor y conserva solo la capacidad que realmente necesita. Las mejores abstracciones suelen aparecer desde un límite concreto, no desde el deseo de anticipar todo el futuro.
