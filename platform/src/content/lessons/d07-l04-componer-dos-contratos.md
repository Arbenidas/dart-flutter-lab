---
id: 'D07-L04'
trackId: 'dart'
moduleId: 'D07'
kind: 'taller'
order: 3
slug: 'componer-dos-contratos'
title: 'Una clase que solo conoce contratos'
summary: 'Combina dos dependencias sustituibles y comprueba las dos ramas de una decisión sin tocar nada real.'
estimatedMinutes: 55
objectives:
  - 'Componer dos dependencias inyectadas en una sola clase.'
  - 'Comprobar las dos ramas de una decisión con dobles controlados.'
  - 'Explicar por qué una clase que no conoce implementaciones es más fácil de mover.'
prerequisites: ['D07-L03']
activities:
  - id: 'predecir-ramas'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, escribe las dos ramas de avisarSiVencio y qué debería observarse en el enviador en cada una.'
    required: true
    hints:
      - 'Cuando no venció, la rama correcta no envía nada.'
      - 'Comprobar solo el valor devuelto dejaría pasar un envío indebido.'
  - id: 'resolver-m08-4'
    kind: 'evidence'
    prompt: 'Implementa NotificadorVencimiento recibiendo los dos contratos. Ejecuta sus pruebas y pega la salida del caso en que no venció.'
    required: true
    hints:
      - 'La clase no construye ni el servicio ni el enviador.'
      - 'Devuelve si envió, además de enviar.'
  - id: 'sustentar-arquitectura-dart'
    kind: 'source'
    prompt: 'En Classes, localiza qué dice sobre depender de abstracciones y anota el encabezado que lo respalda.'
    required: true
    sourceLabel: 'Classes'
    hints:
      - 'Busca la parte sobre interfaces implícitas o programar contra contratos.'
      - 'Si la página no lo dice literalmente, anota lo más cercano y explica la diferencia.'
  - id: 'defender-dos-comprobaciones'
    kind: 'judgment'
    prompt: 'Decide si la prueba debe comprobar solo el valor devuelto o también el estado del enviador, y nombra el bug que se escapa con cada opción.'
    required: true
    hints:
      - 'Devolver false y enviar igual es un bug posible.'
      - 'Comprobar de más ata la prueba a detalles internos.'
docRefs:
  - label: 'Classes'
    url: 'https://dart.dev/language/classes'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Class modifiers'
    url: 'https://dart.dev/language/class-modifiers'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué gana una clase que solo conoce contratos y ninguna implementación?'
  - 'En un archivo vacío, vuelve a escribir NotificadorVencimiento con sus dos dependencias, sin mirar.'
  - 'Explica en voz alta por qué una prueba debe comprobar el efecto además del valor devuelto.'
  - 'Diseña un servicio que dependa de tres contratos y decide cuáles podrían fusionarse.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m08_contratos.dart'
  testCommand: 'fvm dart test test/m08_contratos_test.dart --name m08-4'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm08-4'
---

Las dos lecciones anteriores construyeron dos piezas sustituibles. Esta las junta, y el resultado es una clase que no conoce **ninguna** implementación concreta.

## Solo contratos

```dart
class NotificadorVencimiento {
  NotificadorVencimiento({
    required ServicioVencimiento servicio,
    required EnviadorMensaje enviador,
  }) : _servicio = servicio,
       _enviador = enviador;

  final ServicioVencimiento _servicio;
  final EnviadorMensaje _enviador;

  bool avisarSiVencio({required String destino, required DateTime limite}) {
    if (!_servicio.vencio(limite)) {
      return false;
    }
    _enviador.enviar(destino: destino, cuerpo: 'La fecha límite ya pasó.');
    return true;
  }
}
```

En producción recibirá un reloj del sistema y un enviador de correo real. En la prueba, un `RelojFijo` y un `EnviadorEnMemoria`. La clase es exactamente la misma.

Fíjate en la sintaxis del constructor: `: _servicio = servicio` es una lista de inicializadores, necesaria porque los campos son privados y los parámetros con nombre no pueden usar la forma corta `this._servicio`.

## Comprobar el efecto, no solo el resultado

La rama que no envía es la que más importa:

```dart
expect(notificador.avisarSiVencio(...), isFalse);
expect(enviador.enviados, isEmpty); // esta línea es la que vale
```

Comprobar solo el valor devuelto dejaría pasar una implementación que devuelve `false` y **envía igual**. Un aviso indebido a un cliente no es un detalle: es el tipo de bug que llega al soporte.

Cada operación con efectos tiene dos cosas que comprobar —lo que devuelve y lo que hizo—, y la segunda solo es observable porque el doble la registra.

## Intento · antes de mirar

Escribe las dos ramas y, para cada una, **qué esperas ver en `enviados`**. Anota también qué pasaría si la implementación enviara antes de comprobar.

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m08_contratos_test.dart --name m08-4
```

Pega la salida del caso en que no venció. Experimento: mueve la línea del envío antes del `if` y observa qué test lo detecta — debería ser el de `enviados` vacío, no el del valor devuelto.

## Fuente · lee con una pregunta

Abre **Classes** y busca lo que dice sobre interfaces implícitas y depender de abstracciones. Si la página no lo enuncia tal cual, anota lo más cercano y escribe en tu cuaderno en qué se diferencia de lo que hicimos aquí — esa distinción también es lectura de documentación.

## Criterio · decide y acepta el costo

Defiende comprobar el estado del enviador además del valor devuelto. Después nombra el límite: si la prueba empezara a comprobar el orden interno de las llamadas o el texto exacto del cuerpo, se ataría a detalles que cambiarán en el primer refactor.

Elige dónde está tu línea. En la última lección del módulo aparece la tercera forma de reutilizar: ni heredar ni componer, sino **mezclar**.
