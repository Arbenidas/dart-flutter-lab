---
id: 'D07-L02'
trackId: 'dart'
moduleId: 'D07'
kind: 'taller'
order: 1
slug: 'inyectar-en-vez-de-construir'
title: 'Pedir en vez de construir'
summary: 'Recibe la dependencia por constructor y comprueba fronteras que antes eran imposibles de probar.'
estimatedMinutes: 50
objectives:
  - 'Recibir una dependencia por constructor en lugar de construirla dentro.'
  - 'Probar una frontera exacta gracias a una dependencia controlada.'
  - 'Distinguir una decisión de negocio de un detalle de infraestructura.'
prerequisites: ['D07-L01']
activities:
  - id: 'predecir-frontera'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, decide si una fecha límite igual al instante actual debe considerarse vencida, y qué comparación produce cada respuesta.'
    required: true
    hints:
      - 'isBefore es estricto; negar isAfter incluye el instante exacto.'
      - 'La respuesta correcta depende del dominio, no del lenguaje.'
  - id: 'resolver-m08-2'
    kind: 'evidence'
    prompt: 'Implementa ServicioVencimiento recibiendo un Reloj y ejecuta sus pruebas. Pega la salida del test del instante exacto.'
    required: true
    hints:
      - 'La clase no debe construir el reloj: lo recibe.'
      - 'diasRestantes usa difference y devuelve negativo si ya venció.'
  - id: 'sustentar-composicion'
    kind: 'source'
    prompt: 'En Classes, encuentra qué dice sobre la composición frente a la herencia y cuándo conviene cada una.'
    required: true
    sourceLabel: 'Classes'
    hints:
      - 'Busca la parte sobre reutilizar comportamiento.'
      - 'Anota el encabezado y una frase.'
  - id: 'defender-inyeccion'
    kind: 'judgment'
    prompt: 'Decide si el reloj debe ser un parámetro obligatorio o tener DateTime.now como valor por defecto, y nombra el costo de cada opción.'
    required: true
    hints:
      - 'Un valor por defecto vuelve cómoda la construcción en producción.'
      - 'Un parámetro obligatorio hace visible la dependencia en cada punto de uso.'
docRefs:
  - label: 'Classes'
    url: 'https://dart.dev/language/classes'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Constructors'
    url: 'https://dart.dev/language/constructors'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué pregunta te ayuda a decidir entre herencia y composición?'
  - 'En un archivo vacío, vuelve a escribir ServicioVencimiento con su reloj inyectado, sin mirar tu solución.'
  - 'Explica en voz alta qué prueba se vuelve posible al controlar el reloj.'
  - 'Toma un servicio tuyo que dependa de una fuente externa y reescribe su constructor para recibirla.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m08_contratos.dart'
  testCommand: 'fvm dart test test/m08_contratos_test.dart --name m08-2'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm08-2'
---

El contrato de la lección anterior no sirve de nada si la clase que lo necesita se construye su propia implementación por dentro.

## Pedir, no construir

```dart
class ServicioVencimiento {
  ServicioVencimiento(this._reloj);

  final Reloj _reloj;

  bool vencio(DateTime limite) => limite.isBefore(_reloj.ahora());
}
```

La clase declara qué necesita y espera que se lo den. Esa es toda la idea de la inyección de dependencias: no hace falta ninguna librería ni ningún contenedor. Un parámetro de constructor alcanza.

Lo que cambió no es la lógica —la comparación es idéntica— sino **quién decide** de dónde sale la hora. En producción sale del sistema; en una prueba, de un `RelojFijo`.

## La frontera que ahora se puede probar

```dart
final servicio = ServicioVencimiento(RelojFijo(DateTime.utc(2026, 6, 15)));

servicio.vencio(DateTime.utc(2026, 6, 15)); // ¿true o false?
```

Con `DateTime.now()` esta pregunta no tenía respuesta estable. Ahora sí, y hay que **decidirla**: `isBefore` es estricto, así que el instante exacto todavía no venció. Negar `isAfter` daría la respuesta contraria.

Ninguna de las dos es más correcta que la otra en abstracto. Lo que sí es un error es no haberlo decidido y descubrirlo cuando un cliente reclama.

## Composición, no herencia

`ServicioVencimiento` no _es_ un reloj: _tiene_ un reloj. Esa es la pregunta que suele resolver la duda entre herencia y composición: **¿es un…?** o **¿tiene un…?**

La composición además se puede cambiar en tiempo de ejecución y no ata la clase a una jerarquía. La herencia trae comportamiento gratis y, con él, todo lo demás de la clase padre.

## Intento · antes de mirar

Decide, por escrito:

- si una fecha límite igual al instante actual está vencida
- qué comparación produce cada respuesta
- qué devuelve `diasRestantes` para una fecha ya pasada

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m08_contratos_test.dart --name m08-2
```

Pega la salida del test del instante exacto. Ese test solo existe porque el reloj es controlable; escríbelo en tu cuaderno como ejemplo de qué compra una dependencia inyectada.

## Fuente · lee con una pregunta

Abre **Classes** y busca lo que dice sobre reutilizar comportamiento. Pregunta concreta: ¿cuándo conviene componer y cuándo heredar? Anota el encabezado.

## Criterio · decide y acepta el costo

Defiende si el reloj debe ser obligatorio o tener `DateTime.now` por defecto:

```dart
ServicioVencimiento({Reloj? reloj}) : _reloj = reloj ?? RelojDelSistema();
```

El valor por defecto vuelve cómoda la construcción en producción y esconde otra vez la dependencia — nadie que lea la llamada sabe que hay un reloj. El parámetro obligatorio la hace visible en cada punto de uso y alarga todas las construcciones.

Elige y nombra el costo. En la próxima lección el contrato deja de leer y empieza a **producir efectos**.
