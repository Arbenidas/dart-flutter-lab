---
id: 'D14-L05'
trackId: 'dart'
moduleId: 'D14'
kind: 'taller'
order: 4
slug: 'probar-el-camino-de-error'
title: 'Un doble que falla prueba lo que nadie prueba'
summary: 'Sustituye el repositorio por uno que siempre falla y comprueba qué hace tu servicio cuando el almacenamiento no responde.'
estimatedMinutes: 50
objectives:
  - 'Escribir un doble que falla para probar el camino de error.'
  - 'Decidir si una capa debe traducir o dejar subir el fallo de su dependencia.'
  - 'Definir qué demuestra cada herramienta de la puerta de calidad.'
prerequisites: ['D14-L04']
activities:
  - id: 'predecir-fallo-almacen'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, decide qué debería hacer el servicio cuando el almacenamiento no responde: traducir el fallo, dejarlo subir o devolver un motivo.'
    required: true
    hints:
      - 'Un almacenamiento caído no es un dato inválido del usuario.'
      - 'Recuerda la distinción entre fallo esperado y bug de D09.'
  - id: 'resolver-m15-5'
    kind: 'evidence'
    prompt: 'Implementa RepositorioQueFalla y ejecuta sus pruebas. Pega la salida del test que comprueba que el servicio propaga el fallo.'
    required: true
    hints:
      - 'Las tres operaciones deben lanzar StateError.'
      - 'El doble tiene que ser sustituible donde se espera el contrato.'
  - id: 'sustentar-quality-gate'
    kind: 'source'
    prompt: 'En Customizing static analysis y en Testing, encuentra qué demuestra cada herramienta y qué no puede demostrar ninguna.'
    required: true
    sourceLabel: 'Testing'
    hints:
      - 'Formato, análisis y pruebas responden preguntas distintas.'
      - 'Anota un encabezado de cada página.'
  - id: 'defender-propagar'
    kind: 'judgment'
    prompt: 'Decide si el servicio debe traducir el fallo del almacenamiento a un motivo de rechazo o dejarlo subir, y nombra qué confunde cada opción.'
    required: true
    hints:
      - 'Traducirlo lo mezcla con los rechazos por datos inválidos.'
      - 'Dejarlo subir obliga a quien llama a manejar dos clases de fallo.'
docRefs:
  - label: 'Testing'
    url: 'https://dart.dev/tools/dart-test'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Customizing static analysis'
    url: 'https://dart.dev/tools/analysis'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué garantía aporta el formateador, el analizador y las pruebas, y qué no puede demostrar cada uno?'
  - 'En un archivo vacío, vuelve a escribir RepositorioQueFalla y una prueba que lo use, sin mirar.'
  - 'Explica en voz alta por qué el camino de error necesita su propio doble.'
  - 'Define la puerta de calidad local y de CI de un proyecto tuyo: orden, salida esperada y evidencia ante un fallo.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m15_calidad.dart'
  testCommand: 'fvm dart test test/m15_calidad_test.dart --name m15-5'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm15-5'
  revealReference: true
---

El camino feliz se prueba solo: lo recorres cada vez que usas la app. El camino de error hay que provocarlo.

## El doble que rompe

```dart
class RepositorioQueFalla implements RepositorioTareas {
  @override
  List<Tarea> listar() => throw StateError('almacenamiento no disponible');

  @override
  void guardar(Tarea tarea) => throw StateError('almacenamiento no disponible');

  @override
  void eliminar(String id) => throw StateError('almacenamiento no disponible');
}
```

Nueve líneas que te permiten responder una pregunta que de otro modo exige desconectar un cable: **¿qué hace mi servicio cuando el almacenamiento no responde?**

Sin este doble, la respuesta se descubre en producción.

## Propagar o traducir

Aquí el servicio **propaga**: el `StateError` sube tal cual. Es una decisión, y la razón es la de D09-L01.

`crear` devuelve `String?` para los rechazos por **datos inválidos** —el usuario escribió mal—. Un almacenamiento caído no es eso. Mezclarlos haría que quien llama trate «el disco no responde» igual que «el título está vacío», y esas dos situaciones piden acciones distintas: una se reintenta, la otra se corrige.

## Tres herramientas, tres preguntas

| Herramienta | Qué demuestra                                   | Qué **no**                   |
| ----------- | ----------------------------------------------- | ---------------------------- |
| formateador | el estilo es uniforme                           | nada sobre el comportamiento |
| analizador  | no hay contradicciones de tipo ni código muerto | que la lógica sea correcta   |
| pruebas     | los casos escritos se cumplen                   | los casos que no escribiste  |

Ninguna reemplaza a las otras, y ninguna demuestra que el programa esté bien. Demuestran que **ciertas cosas concretas** están bien.

La puerta de calidad local es la secuencia de las tres:

```bash
cd dart_lab
fvm dart format --output=none --set-exit-if-changed .
fvm dart analyze
fvm dart test
```

En ese orden: lo barato primero, y cada paso corta si falla.

## Intento · antes de mirar

Decide qué debería hacer el servicio ante un almacenamiento caído, entre las tres opciones —traducir, propagar, devolver motivo— y justifica.

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m15_calidad_test.dart --name m15-5
```

Pega la salida del test que comprueba la propagación.

## Fuente · lee con una pregunta

Abre **Testing** y **Customizing static analysis** con una pregunta que las cruza: ¿qué demuestra cada una y qué queda fuera de las dos? Anota un encabezado de cada página.

## Criterio · decide y acepta el costo

Defiende propagar. El costo es real: quien llame tiene que manejar dos clases de fallo —el `String?` y la excepción—, y es fácil olvidarse de la segunda.

Nombra cómo lo harías visible. Cierra el módulo:

```bash
fvm dart analyze
```

En D15 se junta todo en un proyecto que puedes demostrar de principio a fin.
