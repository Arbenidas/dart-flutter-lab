---
id: 'F06-L02'
trackId: 'flutter'
moduleId: 'F06'
kind: 'taller'
order: 1
slug: 'el-flujo-de-cada-operacion'
title: 'Seguir una operación de punta a punta'
summary: 'Traza crear, editar y eliminar desde el gesto hasta el estado nuevo, y predice la tabla de resultados sin ejecutar.'
estimatedMinutes: 60
objectives:
  - 'Trazar una operación desde el gesto del usuario hasta el estado publicado.'
  - 'Predecir el contenido de la lista tras una secuencia de operaciones.'
  - 'Localizar en qué paso se rompería el flujo ante un fallo concreto.'
prerequisites: ['F06-L01']
activities:
  - id: 'predecir-secuencia'
    kind: 'attempt'
    prompt: 'Sin ejecutar la app, construye la tabla de esta secuencia: lista vacía, crear A, crear B, editar A, eliminar B. Predice contador, primer elemento y estado vacío tras cada paso.'
    required: true
    hints:
      - 'Revisa el comparador de getAll para decidir el orden, no lo adivines por inserción.'
      - 'Editar cambia la fecha de actualización.'
  - id: 'recorrer-app'
    kind: 'evidence'
    prompt: 'Ejecuta la app y realiza esa misma secuencia. Pega la lista resultante y márca en qué paso tu predicción falló.'
    required: true
    hints:
      - 'Anota el primer elemento después de editar A: ahí suele fallar la predicción.'
      - 'Si acertaste todo, prueba a editar B en vez de A.'
  - id: 'sustentar-ui-layer'
    kind: 'source'
    prompt: 'En UI layer case study, encuentra cómo describe el recorrido de un evento del usuario hasta el estado.'
    required: true
    sourceLabel: 'UI layer case study'
    hints:
      - 'Busca el diagrama o la enumeración de pasos.'
      - 'Anota el encabezado y el orden de los pasos.'
  - id: 'defender-orden'
    kind: 'judgment'
    prompt: 'Decide si la lista debe ordenarse por fecha de actualización o de creación, y nombra qué comportamiento cambia para el usuario.'
    required: true
    hints:
      - 'Ordenar por actualización mueve una entrada al editarla.'
      - 'Ordenar por creación mantiene la lista estable y esconde lo reciente.'
docRefs:
  - label: 'UI layer case study'
    url: 'https://docs.flutter.dev/app-architecture/case-study/ui-layer'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Common architecture concepts'
    url: 'https://docs.flutter.dev/app-architecture/concepts'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué pasos recorre una operación desde el gesto hasta el estado publicado?'
  - 'En una hoja en blanco, vuelve a construir la tabla de la secuencia crear, crear, editar, eliminar, sin mirar.'
  - 'Explica en voz alta por qué editar una entrada cambia su posición en la lista.'
  - 'Traza la operación de eliminar en otro proyecto y localiza dónde se decide qué se ve después.'
lab:
  workspace: 'flutter_lab'
  targetPath: 'lib/features/journal/presentation/journal_view_model.dart'
  testCommand: 'fvm flutter test'
  analyzeCommand: 'fvm flutter analyze'
---

Saber dónde está cada archivo no es lo mismo que saber qué pasa cuando alguien pulsa un botón. Esta lección sigue el recorrido completo.

## Los cinco pasos de una operación

1. **Gesto** — la View captura `onPressed`.
2. **Comando** — llama a un método del `ViewModel` con `ref.read(...notifier)`.
3. **Regla** — el `ViewModel` valida; si falla, publica el error y se detiene.
4. **Datos** — el `Repository` guarda y devuelve.
5. **Estado nuevo** — el `ViewModel` reasigna `state`, Riverpod notifica y la View se reconstruye.

El paso 3 es el que se salta en los diseños apurados, y es el único que puede **interrumpir** la cadena.

## El detalle que rompe las predicciones

`getAll()` ordena por `updatedAt` descendente, con el `id` como desempate:

```dart
final byDate = b.updatedAt.compareTo(a.updatedAt);
return byDate != 0 ? byDate : b.id.compareTo(a.id);
```

Consecuencia: **editar una entrada la mueve al principio de la lista**. No es un efecto secundario accidental — es una decisión de producto escrita en el comparador, y cambia lo que el usuario ve después de guardar.

Si tu predicción para «editar A» deja a A en su sitio, ya encontraste dónde estaba el hueco.

## Intento · antes de mirar

Completa la tabla antes de ejecutar nada. Empieza con la lista vacía:

| Paso       | Contador | Primer elemento | ¿Se ve el estado vacío? |
| ---------- | -------- | --------------- | ----------------------- |
| inicio     | ?        | ?               | ?                       |
| crear A    | ?        | ?               | ?                       |
| crear B    | ?        | ?               | ?                       |
| editar A   | ?        | ?               | ?                       |
| eliminar B | ?        | ?               | ?                       |

## Evidencia · ejecuta y compara

Ejecuta la app y realiza la misma secuencia. Pega la lista resultante y marca en qué paso falló tu predicción.

Si acertaste todo, sube la apuesta: predice qué pasa al editar B en lugar de A, y qué pasa si creas dos entradas con el mismo título.

## Fuente · lee con una pregunta

Abre **UI layer case study** y busca cómo describe el recorrido de un evento hasta el estado. Pregunta concreta: ¿en qué orden ocurren los pasos? Anota el encabezado y compáralo con los cinco de arriba.

## Criterio · decide y acepta el costo

Defiende el orden por `updatedAt`. Mover una entrada al editarla mantiene lo reciente arriba y hace que la lista **se mueva bajo el dedo** justo después de guardar, que es desconcertante. Ordenar por `createdAt` deja la lista estable y esconde lo que acabas de tocar.

Elige y nombra el costo. En la próxima lección empiezas a convertir estos recorridos en pruebas, empezando por la capa de abajo.
