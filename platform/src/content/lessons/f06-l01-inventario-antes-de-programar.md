---
id: 'F06-L01'
trackId: 'flutter'
moduleId: 'F06'
kind: 'proyecto'
order: 0
slug: 'proyecto-bitacora-crud-verificable'
title: 'Proyecto final: inventario antes de programar'
summary: 'Recorre la app completa y escribe qué archivo protege cada responsabilidad antes de tocar una línea.'
estimatedMinutes: 50
objectives:
  - 'Mapear cada responsabilidad del CRUD al archivo que la contiene.'
  - 'Escribir criterios de aceptación observables para las cuatro operaciones.'
  - 'Detectar una responsabilidad que no tenga dueño claro.'
prerequisites: ['F05-L05']
activities:
  - id: 'mapear-responsabilidades'
    kind: 'attempt'
    prompt: 'Sin abrir el proyecto, escribe qué archivo esperarías que contenga: la validación del título, el orden de la lista, el diálogo de confirmación y la creación del identificador.'
    required: true
    hints:
      - 'Recuerda el reparto de capas de F05-L01.'
      - 'Si dudas de dónde va algo, esa duda es información sobre el diseño.'
  - id: 'verificar-inventario'
    kind: 'evidence'
    prompt: 'Recorre lib/features/journal y corrige tu mapa. Ejecuta la suite completa y pega el resumen de pruebas.'
    required: true
    hints:
      - 'Comparar tu mapa con la realidad vale más que acertar a la primera.'
      - 'La suite completa se ejecuta sin argumentos.'
  - id: 'sustentar-caso'
    kind: 'source'
    prompt: 'En UI layer case study, encuentra cómo reparte el ejemplo oficial las responsabilidades y compáralo con la bitácora.'
    required: true
    sourceLabel: 'UI layer case study'
    hints:
      - 'Busca los nombres de las clases del ejemplo y su papel.'
      - 'Anota una diferencia concreta con esta app.'
  - id: 'defender-criterios'
    kind: 'judgment'
    prompt: 'Escribe un criterio de aceptación observable para crear una entrada y defiende por qué es verificable; nombra qué queda fuera del criterio.'
    required: true
    hints:
      - 'Un criterio observable dice qué se ve, no qué se siente.'
      - 'Incluye el estado antes y el estado después.'
docRefs:
  - label: 'UI layer case study'
    url: 'https://docs.flutter.dev/app-architecture/case-study/ui-layer'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Guide to app architecture'
    url: 'https://docs.flutter.dev/app-architecture/guide'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué archivo protege cada responsabilidad del CRUD y por qué?'
  - 'En una hoja en blanco, vuelve a dibujar el mapa de la feature journal sin mirar el proyecto.'
  - 'Explica en voz alta qué hace que un criterio de aceptación sea verificable.'
  - 'Escribe los criterios de aceptación de una feature nueva antes de escribir su primera línea de código.'
lab:
  workspace: 'flutter_lab'
  targetPath: 'lib/features/journal'
  testCommand: 'fvm flutter test'
  analyzeCommand: 'fvm flutter analyze'
---

El proyecto final no empieza escribiendo código. Empieza sabiendo qué hay.

## Escribe el mapa antes de abrirlo

Antes de recorrer el proyecto, escribe de memoria en qué archivo esperas encontrar cada cosa:

| Responsabilidad                         | ¿Qué archivo? |
| --------------------------------------- | ------------- |
| validar que el título no esté vacío     | ?             |
| ordenar la lista por fecha              | ?             |
| mostrar el diálogo de confirmación      | ?             |
| generar el identificador de una entrada | ?             |
| decidir el texto del mensaje de error   | ?             |

Las que no puedas responder son exactamente las que vale la pena mirar primero.

## Criterios de aceptación observables

Un criterio útil dice **qué se ve**, no qué se siente. Compara:

```text
mal:  "crear una entrada funciona bien"
bien: "dado que la lista está vacía, cuando escribo el título «Primera»
       y guardo, entonces la lista muestra 1 entrada con ese título
       y el contador del encabezado dice 1"
```

El segundo se puede convertir en una prueba sin discutir. El primero no.

Escribe uno así para cada una de las cuatro operaciones —crear, leer, editar, eliminar— y para al menos dos casos no felices: título vacío y título de más de 80 caracteres.

## Las tres capas de evidencia

El proyecto se verifica en tres niveles, y cada uno responde algo distinto:

| Nivel       | Archivo                                  | Qué demuestra                            |
| ----------- | ---------------------------------------- | ---------------------------------------- |
| repositorio | `in_memory_journal_repository_test.dart` | los datos se guardan y se devuelven bien |
| ViewModel   | `journal_view_model_test.dart`           | las reglas y el estado son correctos     |
| widget      | `journal_view_test.dart`                 | la persona puede completar el recorrido  |

Ninguno reemplaza a los otros. Una prueba de widget verde con un repositorio roto es posible; una de repositorio verde con la pantalla rota, también.

## Intento · antes de mirar

Completa la tabla de responsabilidades de arriba **antes** de abrir el proyecto. Anota tu nivel de confianza en cada fila.

## Evidencia · ejecuta y compara

Recorre `lib/features/journal` y corrige tu mapa. Después ejecuta la suite completa:

```bash
cd flutter_lab
fvm flutter test
```

Pega el resumen. Ese número de pruebas verdes es tu línea de base: cualquier cosa que hagas de aquí en adelante tiene que mantenerlo.

## Fuente · lee con una pregunta

Abre **UI layer case study** con una pregunta concreta: ¿cómo reparte el ejemplo oficial las responsabilidades? Anota una diferencia real con esta app; las diferencias son más informativas que los parecidos.

## Criterio · decide y acepta el costo

Escribe un criterio de aceptación observable para crear una entrada y defiende por qué es verificable. Después nombra qué queda **fuera**: tu criterio probablemente no dice nada sobre el foco después de guardar, ni sobre qué pasa si alguien pulsa dos veces rápido.

Esos huecos no son un fallo del criterio; son la lista de lo que todavía no decidiste.

En la próxima lección sigues cada operación de punta a punta.
