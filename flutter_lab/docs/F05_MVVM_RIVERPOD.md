# F05 — MVVM feature-first + Riverpod

## Objetivo

Seguir el flujo de una acción sin mezclar responsabilidades.

```text
tap -> JournalView -> JournalViewModel -> JournalRepository
                                      <- JournalState <-
```

## Práctica

1. Traza `createEntry` desde el botón hasta la reconstrucción de la lista.
2. Explica por qué `JournalView` no importa `InMemoryJournalRepository`.
3. Sustituye el repositorio con un fake mediante `overrideWithValue`.
4. Intenta poner validación dentro del card y explica qué test se vuelve más difícil.
5. Lee la [arquitectura recomendada por Flutter](https://docs.flutter.dev/app-architecture/guide)
   y [`NotifierProvider`](https://riverpod.dev/docs/providers/notifier_provider).

## Criterio de terminado

Puedes cambiar la fuente de datos sin cambiar la View y probar el ViewModel sin
levantar widgets.
