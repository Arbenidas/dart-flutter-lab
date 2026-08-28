---
id: 'D07-L03'
trackId: 'dart'
moduleId: 'D07'
kind: 'taller'
order: 2
slug: 'un-doble-que-registra-lo-que-paso'
title: 'Probar un efecto sin producirlo'
summary: 'Escribe un doble que acumula lo enviado, y comprueba una acción con consecuencias sin provocarlas de verdad.'
estimatedMinutes: 45
objectives:
  - 'Escribir un doble que registra las llamadas recibidas.'
  - 'Comprobar un efecto lateral sin ejecutarlo de verdad.'
  - 'Validar los argumentos de una operación dentro de su implementación.'
prerequisites: ['D07-L02']
activities:
  - id: 'predecir-doble'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, escribe cómo comprobarías que un servicio envía un correo sin enviar ninguno, y qué debería guardar tu doble.'
    required: true
    hints:
      - 'Guardar lo recibido convierte un efecto en un dato que se puede comprobar.'
      - 'No basta con contar llamadas: el destino y el cuerpo también importan.'
  - id: 'resolver-m08-3'
    kind: 'evidence'
    prompt: 'Implementa EnviadorEnMemoria con su validación de destino. Ejecuta sus pruebas y pega la salida del caso del destino vacío.'
    required: true
    hints:
      - 'Guarda un record con destino y cuerpo en una lista pública.'
      - 'Un destino en blanco es tan inválido como uno vacío.'
  - id: 'sustentar-interface-class'
    kind: 'source'
    prompt: 'En Class modifiers, encuentra qué obliga implements frente a extends respecto de los miembros de la clase.'
    required: true
    sourceLabel: 'Class modifiers'
    hints:
      - 'Busca qué pasa si no implementas un miembro del contrato.'
      - 'Fíjate en si implements hereda alguna implementación.'
  - id: 'defender-validacion-doble'
    kind: 'judgment'
    prompt: 'Decide si el doble debe validar igual que la implementación real, y nombra qué bug se te escaparía en cada caso.'
    required: true
    hints:
      - 'Un doble más permisivo deja pasar pruebas que fallarían en producción.'
      - 'Duplicar la validación la deja en dos sitios que pueden desincronizarse.'
docRefs:
  - label: 'Class modifiers'
    url: 'https://dart.dev/language/class-modifiers'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Classes'
    url: 'https://dart.dev/language/classes'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Cómo compruebas un efecto lateral sin producirlo de verdad?'
  - 'En un archivo vacío, vuelve a escribir EnviadorEnMemoria sin mirar tu solución.'
  - 'Explica en voz alta qué obliga implements respecto de los miembros del contrato.'
  - 'Escribe el doble de un contrato de pago y decide qué información necesitas guardar de cada llamada.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m08_contratos.dart'
  testCommand: 'fvm dart test test/m08_contratos_test.dart --name m08-3'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm08-3'
---

Un servicio que envía correos no se puede probar enviando correos. Tampoco se prueba «confiando en que funciona». Se prueba sustituyendo el envío por algo que **anote** lo que le pidieron.

## El contrato y su doble

```dart
abstract interface class EnviadorMensaje {
  void enviar({required String destino, required String cuerpo});
}

class EnviadorEnMemoria implements EnviadorMensaje {
  final List<({String destino, String cuerpo})> enviados = <({String destino, String cuerpo})>[];

  @override
  void enviar({required String destino, required String cuerpo}) {
    if (destino.trim().isEmpty) {
      throw ArgumentError.value(destino, 'destino', 'No puede estar vacío');
    }
    enviados.add((destino: destino, cuerpo: cuerpo));
  }
}
```

El doble convierte un **efecto** en un **dato**. Después de ejecutar, `enviados` contiene exactamente lo que se pidió enviar, y eso sí se puede comprobar con un `expect`.

Fíjate en el tipo del registro: un record con campos nombrados. No hizo falta declarar una clase para guardar dos textos juntos — es la misma herramienta de D03-L03.

## Contar no alcanza

Un doble que solo cuente llamadas deja pasar el bug más común: enviar al destinatario equivocado. Guarda lo suficiente para poder comprobar **qué** se pidió, no solo cuántas veces.

## `implements` obliga a todo

Con `implements`, Dart exige que declares **todos** los miembros del contrato. No heredas ninguna implementación: la interfaz no tiene ninguna que dar.

Eso es lo que hace ruidoso agregar un método a un contrato — y es bueno que lo sea. El compilador te lista cada implementación que quedó incompleta, incluidos los dobles de prueba.

## Intento · antes de mirar

Escribe, antes de abrir el archivo, qué guardarías de cada llamada y cómo sería el `expect` que comprueba que se envió al destinatario correcto.

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m08_contratos_test.dart --name m08-3
```

Pega la salida del caso del destino vacío.

## Fuente · lee con una pregunta

Abre **Class modifiers** con una pregunta concreta: ¿qué te obliga `implements` respecto de los miembros, y hereda alguna implementación? Anota el encabezado.

## Criterio · decide y acepta el costo

¿Debe el doble validar igual que la implementación real?

Si es más permisivo, tus pruebas pasan con datos que en producción explotan — el doble te está mintiendo. Si duplica la validación, la regla vive en dos sitios y pueden desincronizarse.

La salida habitual es poner la validación **antes** del contrato, en quien lo llama. Defiende tu elección y nombra el bug que se te escaparía. En la próxima lección los dos contratos se juntan.
