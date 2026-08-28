---
id: 'F03-L02'
trackId: 'flutter'
moduleId: 'F03'
kind: 'taller'
order: 1
slug: 'validar-es-ensenar-el-siguiente-paso'
title: 'Un mensaje de validación enseña el siguiente paso'
summary: 'Valida en el límite correcto y escribe mensajes que digan cómo corregir, no solo que algo está mal.'
estimatedMinutes: 55
objectives:
  - 'Elegir en qué capa vive cada validación de un formulario.'
  - 'Escribir un mensaje de error que indique la acción correctiva.'
  - 'Distinguir validar al escribir de validar al enviar.'
prerequisites: ['F03-L01']
activities:
  - id: 'reescribir-mensajes'
    kind: 'attempt'
    prompt: 'Sin mirar el código, reescribe estos mensajes para que enseñen el siguiente paso: «Campo inválido», «Error», «El título no cumple las reglas».'
    required: true
    hints:
      - 'Un buen mensaje nombra el dato, el problema y la acción.'
      - 'Evita el vocabulario del programa: el usuario no sabe qué es un campo.'
  - id: 'probar-validacion'
    kind: 'evidence'
    prompt: 'Intenta guardar una entrada con el título vacío y otra con más de 80 caracteres. Pega los dos mensajes exactos que muestra la app.'
    required: true
    hints:
      - 'La validación del título vive en el ViewModel, no en el widget.'
      - 'Los dos mensajes son distintos a propósito.'
  - id: 'sustentar-validacion'
    kind: 'source'
    prompt: 'En Build a form with validation, encuentra dónde recomienda ubicar la lógica de validación y cómo se muestra el mensaje.'
    required: true
    sourceLabel: 'Build a form with validation'
    hints:
      - 'Busca el validator dentro del ejemplo.'
      - 'Fíjate en qué devuelve cuando el dato es válido.'
  - id: 'defender-limite-validacion'
    kind: 'judgment'
    prompt: 'Decide si la regla de 80 caracteres debe vivir en el widget del formulario o en el ViewModel, y nombra qué se rompe si la pones en el otro lado.'
    required: true
    hints:
      - 'Una regla en el widget no protege a quien llame al ViewModel desde otro lugar.'
      - 'Una regla solo en el ViewModel llega después de que el usuario ya escribió de más.'
docRefs:
  - label: 'Build a form with validation'
    url: 'https://docs.flutter.dev/cookbook/forms/validation'
    kind: 'cookbook'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Common architecture concepts'
    url: 'https://docs.flutter.dev/app-architecture/concepts'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué debe contener un mensaje de validación útil?'
  - 'En un archivo vacío, vuelve a escribir la validación del título con sus dos reglas y sus dos mensajes, sin mirar.'
  - 'Explica en voz alta la diferencia entre validar al escribir y validar al enviar.'
  - 'Toma tres mensajes de error de una app que uses y reescríbelos para que enseñen el siguiente paso.'
lab:
  workspace: 'flutter_lab'
  targetPath: 'lib/features/journal/presentation/widgets/journal_editor_dialog.dart'
  testCommand: 'fvm flutter test test/features/journal/presentation/journal_view_test.dart'
  analyzeCommand: 'fvm flutter analyze'
---

Una validación tiene dos trabajos: impedir que entre un dato imposible y **decirle a la persona cómo arreglarlo**. El segundo se olvida casi siempre.

## Tres partes de un mensaje útil

| Parte       | Ejemplo pobre    | Ejemplo útil                          |
| ----------- | ---------------- | ------------------------------------- |
| el dato     | «Campo inválido» | «El título…»                          |
| el problema | «Error»          | «…está vacío»                         |
| la acción   | —                | «Ponle un título antes de guardarla.» |

Fíjate en los mensajes de la bitácora:

```text
Ponle un título antes de guardarla.
El título debe tener 80 caracteres o menos.
```

Ninguno usa vocabulario del programa. Ninguno dice «inválido». Los dos dicen qué hacer a continuación.

## Dónde vive cada regla

En la bitácora, la validación del título vive en el `ViewModel`, no en el widget. La razón es concreta: el `ViewModel` es la puerta por la que pasan **todas** las formas de crear una entrada. Una regla en el widget solo protege a ese widget; si mañana llega otra pantalla, o una importación, la regla no se aplica.

El widget puede ayudar antes —limitar el largo del campo, deshabilitar el botón— pero eso es comodidad, no garantía. La garantía vive donde no se pueda esquivar.

## Al escribir o al enviar

- **Al escribir** avisa temprano y molesta si la persona todavía está a mitad del dato.
- **Al enviar** no interrumpe y llega tarde.

El patrón que suele funcionar: no valides el primer intento mientras escribe, valida al enviar, y a partir de ahí sí valida en cada cambio para que vea desaparecer el error cuando lo corrige.

## Intento · antes de mirar

Reescribe estos tres mensajes para que enseñen el siguiente paso:

- «Campo inválido»
- «Error»
- «El título no cumple las reglas»

## Evidencia · ejecuta y compara

Ejecuta la app, intenta guardar una entrada con el título vacío y después una con más de 80 caracteres. Pega los dos mensajes exactos.

Experimento: llama a `createEntry` con un título vacío desde una prueba, saltándote el widget. ¿La regla sigue aplicando? Esa respuesta es la sección «dónde vive cada regla», comprobada.

## Fuente · lee con una pregunta

Abre **Build a form with validation** con una pregunta concreta: ¿qué devuelve un `validator` cuando el dato es válido? Anota el encabezado; ese detalle —devolver `null` cuando todo está bien— confunde a mucha gente la primera vez.

## Criterio · decide y acepta el costo

Defiende dónde poner la regla de los 80 caracteres. En el widget llega antes y solo protege esa pantalla. En el `ViewModel` protege todas las entradas y llega después de que la persona ya escribió de más.

La respuesta madura suele ser «en los dos, con propósitos distintos». Si eliges esa, nombra el costo: la regla queda escrita en dos lugares y pueden desincronizarse.

En la próxima lección el formulario tiene que funcionar también para quien no ve la pantalla.
