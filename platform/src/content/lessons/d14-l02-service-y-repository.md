---
id: 'D14-L02'
trackId: 'dart'
moduleId: 'D14'
kind: 'taller'
order: 1
slug: 'separar-reglas-de-almacenamiento'
title: 'El Service decide; el Repository guarda'
summary: 'Pon las reglas de negocio donde no se puedan esquivar y compruébalas sin tocar disco.'
estimatedMinutes: 55
objectives:
  - 'Separar reglas de negocio del acceso a datos.'
  - 'Devolver el motivo de un rechazo en vez de un booleano opaco.'
  - 'Comprobar que un rechazo no deja efectos a medias.'
prerequisites: ['D14-L01']
activities:
  - id: 'repartir-responsabilidades'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, decide en qué capa vive cada cosa: recortar el título, rechazar un id repetido, ordenar la lista y decidir el texto del rechazo.'
    required: true
    hints:
      - 'Pregúntate qué capa cambiaría si el almacenamiento pasara a una base de datos.'
      - 'Una regla que puede esquivarse no es una regla.'
  - id: 'resolver-m15-2'
    kind: 'evidence'
    prompt: 'Implementa ServicioTareas.crear con sus tres reglas. Ejecuta sus pruebas y pega la salida del caso del id repetido.'
    required: true
    hints:
      - 'Devuelve el motivo del rechazo, o null si fue bien.'
      - 'Si rechaza, el repositorio no debe quedar tocado.'
  - id: 'sustentar-analisis'
    kind: 'source'
    prompt: 'En Customizing static analysis, encuentra qué puede detectar el analizador y qué queda fuera de su alcance.'
    required: true
    sourceLabel: 'Customizing static analysis'
    hints:
      - 'Busca qué tipos de problema cubre.'
      - 'Anota el encabezado y un ejemplo de lo que no puede comprobar.'
  - id: 'defender-motivo'
    kind: 'judgment'
    prompt: 'Decide entre devolver el motivo como texto, devolver un booleano o lanzar, y nombra qué pierde cada opción.'
    required: true
    hints:
      - 'Un booleano no dice cuál de las tres reglas falló.'
      - 'Lanzar convierte un caso esperado en una excepción.'
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
  - '¿Cómo separas la responsabilidad de un Service de la de un Repository?'
  - 'En un archivo vacío, vuelve a escribir ServicioTareas.crear con sus tres reglas, sin mirar.'
  - 'Explica en voz alta por qué una regla debe vivir donde no se pueda esquivar.'
  - 'Toma una validación de otro proyecto y decide si está en la capa correcta.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m15_calidad.dart'
  testCommand: 'fvm dart test test/m15_calidad_test.dart --name m15-2'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm15-2'
---

Con la costura en su sitio, la pregunta pasa a ser qué va de cada lado.

## El reparto

| Responsabilidad              | Capa       | Por qué                                        |
| ---------------------------- | ---------- | ---------------------------------------------- |
| recortar el título           | Service    | es una regla del dominio                       |
| rechazar un id repetido      | Service    | depende de la regla, no del almacén            |
| ordenar la lista             | Repository | es una propiedad de cómo se entregan los datos |
| decidir el texto del rechazo | Service    | discutible, y hoy vive aquí                    |

La prueba para saber si algo está en su sitio: **¿qué capa reescribirías si el almacenamiento pasara a una base de datos?** El Repository entero. El Service, nada.

## Rechazar sin efectos

```dart
String? crear({required String id, required String titulo}) {
  final normalizado = titulo.trim();
  if (normalizado.isEmpty) {
    return 'El titulo no puede estar vacio.';
  }
  if (normalizado.length > 60) {
    return 'El titulo debe tener 60 caracteres o menos.';
  }
  if (_repositorio.listar().any((tarea) => tarea.id == id)) {
    return 'Ya existe una tarea con ese identificador.';
  }
  _repositorio.guardar(Tarea(id: id, titulo: normalizado, hecha: false));
  return null;
}
```

Todas las validaciones **antes** de tocar el repositorio. Si rechaza, no queda nada a medias.

Suena obvio y es exactamente el bug que aparece cuando alguien agrega una cuarta regla después del `guardar`.

## Devolver el motivo

`String?` es una elección deliberada: `null` significa éxito. Un `bool` no diría cuál de las tres reglas falló, y quien llame tendría que adivinar o repetir las comprobaciones.

Lanzar sería la tercera opción, y convertiría un caso esperado —un usuario escribe mal— en una excepción, justo lo que D09-L01 dice que no hay que hacer.

Un `Resultado` sellado —D08-L04— sería más expresivo y más ceremonioso. `String?` es el punto intermedio para este tamaño.

## Intento · antes de mirar

Reparte las cuatro responsabilidades de la tabla y justifica cada una. Después decide qué debe devolver `crear` y por qué.

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m15_calidad_test.dart --name m15-2
```

Pega la salida del caso del id repetido. Fíjate en que los tests comprueban **dos** cosas por rechazo: el motivo devuelto y que el repositorio quedó vacío.

## Fuente · lee con una pregunta

Abre **Customizing static analysis** con una pregunta concreta: ¿qué tipo de problemas detecta el analizador y cuáles no? Anota un ejemplo de lo que se le escapa — esa lista es la razón por la que existen las pruebas.

## Criterio · decide y acepta el costo

Defiende `String?` frente a `bool` y frente a lanzar. Nombra el punto donde cambiarías a un `Resultado` sellado: probablemente cuando quien llama necesite **distinguir** las reglas en código y no solo mostrar el texto.

En la próxima lección aparece una propiedad que cambia cómo se escriben las operaciones.
