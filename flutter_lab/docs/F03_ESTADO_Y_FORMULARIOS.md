# F03 — Estado local y formularios

## Objetivo

Distinguir estado efímero de UI y estado de la feature.

## Práctica

1. Explica por qué los `TextEditingController` viven en el diálogo y las entradas
   viven en el ViewModel/Repository.
2. Agrega una validación de cuerpo máximo de 500 caracteres en el ViewModel.
3. Escribe un test para el caso borde.
4. Lee [`State`](https://api.flutter.dev/flutter/widgets/State-class.html) y busca
   cuándo debe ejecutarse `dispose`.

## Pista socrática

¿Necesita otra pantalla conocer el cursor actual del campo de título?
