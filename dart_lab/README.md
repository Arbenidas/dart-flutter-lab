# Dart Lab

Un taller deliberadamente incompleto: el codigo de `lib/` conserva los
`TODO` y las firmas que debes implementar. El starter descargable no incluye
`soluciones/`: la referencia correspondiente se revela en la plataforma solo
despues de registrar tu intento.

## Preparacion reproducible

El repositorio fija Flutter `3.47.1` en `.fvmrc`; esa version incluye la linea
de Dart `3.13` que exige este paquete. Desde la raiz del repositorio:

```sh
fvm install
./tool/preflight.sh
cd dart_lab
fvm dart pub get --enforce-lockfile
```

El preflight se detiene si FVM no encuentra exactamente Flutter `3.47.1` y
Dart `3.13.x`; el laboratorio nunca cambia silenciosamente al SDK global.

## Recorrido

Empieza por el banco de observacion del modulo 1:

```sh
fvm dart run bin/m01_hola.dart
```

Ese primer archivo no tiene tests: sirve para aprender el ciclo
predecir–ejecutar–explicar de D00. Cuando comiences D01, trabaja una sola
unidad por vez:

```sh
./lab next
./lab check m03-2
./lab module m04
./lab status
```

`next` ejecuta solamente las pruebas del siguiente `TODO` y se detiene en el
primer fallo. Asi recibes una pista accionable, no una pared con decenas de
errores que todavia no te corresponde resolver. El progreso local se guarda
en `.dart_tool/lab_progress.json`.

Cuando termines, verifica comportamiento, estructura, contratos publicos y
analisis estatico:

```sh
./lab verify
```

La verificacion tambien avanza en orden y se detiene en el primer problema.
`fvm dart test` queda disponible para quien quiera ejecutar la suite completa.

## Como leer documentacion oficial

Para cada concepto, sigue esta secuencia corta:

1. Lee primero el ejemplo minimo y predice su salida antes de ejecutarlo.
2. Identifica la firma: entradas, tipo de retorno y nulabilidad.
3. Busca las restricciones y errores documentados, no solo el caso feliz.
4. Cambia una sola cosa del ejemplo y explica por que cambia el resultado.
5. Vuelve al `TODO` sin copiar el ejemplo literalmente.

Referencias de partida: [guia del lenguaje](https://dart.dev/language),
[bibliotecas del SDK](https://api.dart.dev/) y
[busqueda de paquetes](https://pub.dev/).
