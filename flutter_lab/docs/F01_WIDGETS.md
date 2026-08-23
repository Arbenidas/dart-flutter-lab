# F01 — Widgets y composición

## Objetivo

Leer una UI como un árbol de objetos inmutables.

## Práctica

1. Dibuja el árbol que devuelve `FlutterLabApp.build`.
2. En `JournalEntryCard`, predice qué parte cambia al editar una entrada.
3. Extrae temporalmente la etiqueta de fecha a un widget propio y compara la
   legibilidad antes y después.
4. Lee [`StatelessWidget`](https://api.flutter.dev/flutter/widgets/StatelessWidget-class.html) y explica el contrato de `build`.

## Pista socrática

Si un widget es inmutable, ¿dónde puede vivir algo que cambia?
