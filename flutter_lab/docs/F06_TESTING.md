# F06 — Tests de unidad y widget

## Objetivo

Probar comportamiento en la capa más barata que dé confianza suficiente.

## Práctica

1. Ejecuta por separado los tests de Repository, ViewModel y View.
2. Rompe deliberadamente el trim del título y observa qué test localiza el fallo.
3. Agrega un test de widget para título mayor de 80 caracteres.
4. Agrega un test unitario que confirme el orden por `updatedAt`.
5. Lee el [resumen oficial de testing](https://docs.flutter.dev/testing/overview).

## Criterio de terminado

Sabes justificar por qué el CRUD del ViewModel es unit test y el flujo del diálogo
es widget test; `fvm flutter analyze` y `fvm flutter test` quedan en verde.
