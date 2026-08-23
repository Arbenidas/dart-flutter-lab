---
id: 'D09-L01'
trackId: 'dart'
moduleId: 'D09'
order: 0
slug: 'errores-excepciones-y-depuracion-sistematica'
title: 'Un error útil conserva la causa y el camino'
summary: 'Separa fallos esperados, excepciones y bugs; lee el stack trace y reduce cada problema a un caso mínimo.'
estimatedMinutes: 105
objectives:
  - 'Distinguir un resultado esperado de una excepción y de un defecto de programación.'
  - 'Leer un stack trace desde el primer marco que pertenece al proyecto.'
  - 'Capturar, enriquecer o propagar un fallo sin perder causa ni contexto.'
prerequisites: ['D08-L01']
activities:
  - id: 'predecir-propagacion'
    kind: 'predict'
    prompt: 'Dibuja la cadena main → importar → parsear para una entrada inválida. Predice qué marcos aparecerán y dónde tendría sentido traducir el FormatException a un resultado de dominio.'
    required: true
    hints:
      - 'La primera línea propia cercana al lanzamiento señala el origen; los marcos siguientes muestran llamadas.'
      - 'Traduce donde exista suficiente contexto para decidir una recuperación.'
  - id: 'escribir-frontera'
    kind: 'code'
    prompt: 'En un scratch local, parsea una edad desde texto, lanza FormatException con contexto y captura error más stack trace en la frontera del programa. Ejecuta caso válido e inválido con FVM.'
    required: true
    hints:
      - 'int.tryParse permite reconocer la entrada inválida antes de lanzar.'
      - 'Usa catch (error, stackTrace) para observar ambos valores.'
  - id: 'diagnosticar-captura'
    kind: 'debug'
    prompt: 'Analiza un catch (_) que devuelve una lista vacía para cualquier fallo. Demuestra cómo confunde “sin datos” con un bug y rediseña la recuperación.'
    required: true
    hints:
      - 'Captura solo el tipo que sabes manejar.'
      - 'Si agregas contexto y el nivel superior aún debe decidir, conserva la causa o usa rethrow.'
  - id: 'rastrear-errores'
    kind: 'docs'
    prompt: 'En Error handling, encuentra las diferencias prácticas entre on, catch, finally y rethrow. Registra cuándo se recibe también StackTrace.'
    required: true
    hints:
      - 'on filtra por tipo; catch da acceso al objeto lanzado.'
      - 'finally corre aunque exista o no una excepción.'
  - id: 'defender-frontera'
    kind: 'explain'
    prompt: 'Decide dónde convertir una entrada de usuario inválida en mensaje y dónde dejar propagar un StateError causado por una invariante rota. Defiende ambas decisiones.'
    required: true
    hints:
      - 'Una situación esperable necesita una ruta de recuperación explícita.'
      - 'Ocultar un bug con un valor por defecto destruye evidencia.'
  - id: 'transferir-importacion'
    kind: 'transfer'
    prompt: 'Diseña el flujo de importar JSON: lectura, decodificación, validación y presentación. Define un fallo mínimo por etapa y qué contexto debe conservar al subir de nivel.'
    required: true
    hints:
      - 'No mezcles “archivo no legible” con “JSON válido pero esquema incorrecto”.'
      - 'La UI necesita un mensaje; el diagnóstico necesita causa y stack trace.'
docRefs:
  - label: 'Error handling'
    url: 'https://dart.dev/language/error-handling'
    kind: 'guide'
    version: 'Dart 3.13'
    lastVerified: '2026-08-23'
  - label: 'StackTrace class'
    url: 'https://api.dart.dev/dart-core/StackTrace-class.html'
    kind: 'api'
    version: 'Dart 3.13 API'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué diferencia hay entre un fallo esperado, una excepción en una frontera y un bug?'
  - '¿Desde qué marco propio conviene empezar a leer un stack trace y por qué?'
  - '¿Cuándo usarías on, catch, finally y rethrow?'
  - '¿Por qué devolver un valor vacío desde catch puede destruir información importante?'
---

Manejar errores no significa envolver cada función en `try/catch`. Significa decidir qué puede fallar, dónde existe contexto para responder y qué evidencia necesita quien depura. Una captura demasiado amplia puede convertir un defecto real en datos aparentemente válidos.

## Tres categorías para tres respuestas

Un **fallo esperado** forma parte del dominio: una contraseña no cumple la política o un archivo tiene un esquema incompatible. Conviene modelarlo como resultado explícito cuando el llamador debe decidir qué mostrar o corregir.

Una **excepción** interrumpe el flujo normal de una operación: el texto no tiene el formato prometido o una fuente externa no responde. Captúrala donde puedas recuperarte, traducirla o agregar contexto.

Un **bug** viola una suposición interna: un estado que el programa afirmaba imposible sí apareció. Devolver un valor vacío para ocultarlo permite continuar con datos falsos. En desarrollo, conserva la señal y corrige la causa.

Estas categorías dependen del límite. `FormatException` puede ser correcto dentro de un parser, mientras la capa que recibe texto del usuario lo convierte en un resultado validado y comprensible.

## El stack trace es un recorrido, no un veredicto

```dart
int parsearEdad(String texto) {
  final valor = int.tryParse(texto);
  if (valor == null) {
    throw FormatException('Edad no numérica', texto);
  }
  if (valor < 0) {
    throw FormatException('Edad negativa', texto);
  }
  return valor;
}

void main() {
  try {
    print(parsearEdad('doce'));
  } on FormatException catch (error, stackTrace) {
    print(error.message);
    print(stackTrace);
  }
}
```

Empieza en el primer marco que pertenece a tu código cerca del lanzamiento. Esa línea muestra dónde se observó el fallo. Los marcos siguientes reconstruyen quién llamó a quién. Las dependencias importan cuando explican la causa; no empieces leyendo toda la infraestructura.

## Captura solo lo que puedes manejar

`on FormatException` filtra por tipo. `catch (error, stackTrace)` entrega el objeto y el recorrido. `finally` ejecuta limpieza aunque la operación termine o falle. `rethrow` permite hacer trabajo parcial y conservar la excepción y su stack original.

Evita este patrón:

```dart
List<Usuario> cargarUsuarios() {
  try {
    return leerYDecodificar();
  } catch (_) {
    return [];
  }
}
```

Una lista vacía puede significar “el archivo estaba vacío”, “no existe”, “el JSON está roto” o “hay un bug”. La función borró todas esas diferencias.

## P — Predice

Dibuja `main → importar → validar → parsearCampo`. Coloca un `FormatException` en la última función y predice el orden del stack. Marca el primer nivel que sabe el nombre del archivo y el primero que sabe cómo comunicar un problema al usuario.

Después predice qué resultado produce el `catch (_) => []` ante un `RangeError` que revela un bug. Si parece éxito vacío, ya encontraste el costo de capturar sin criterio.

## E — Escribe

Implementa el parser de edad en un scratch local. Ejecuta entradas válidas, texto no numérico y número negativo. Imprime el error y stack trace; después traduce solo `FormatException` a un resultado esperado, dejando que otros fallos conserven su señal.

Usa el SDK fijado y comprueba que no introdujiste regresiones:

```bash
cd dart_lab
fvm dart --version
fvm dart analyze
fvm dart test
```

El mensaje para la persona y el diagnóstico técnico pueden ser distintos. No muestres un stack trace como interfaz, pero tampoco lo descartes donde se registran fallos.

## N — Nombra el fallo

Reduce el problema antes de corregirlo:

1. copia la entrada mínima que reproduce;
2. identifica la primera línea propia del stack;
3. declara la expectativa y el valor observado;
4. clasifica formato, estado, rango, I/O o contrato roto;
5. cambia una sola hipótesis y vuelve a ejecutar.

“El índice 3 falla porque la lista tiene longitud 3” orienta una prueba. “A veces no carga” todavía no es un diagnóstico.

## S — Sustenta

En **Error handling**, localiza `throw`, las formas de `on` y `catch`, `finally` y `rethrow`. Confirma cómo obtener el `StackTrace`. Después abre su referencia API solo para reconocer qué representa, no para memorizar cada miembro.

Construye una tabla de dos columnas: mecanismo y decisión que permite. Si no puedes conectar una palabra clave con una necesidad, todavía estás coleccionando sintaxis.

## A — Argumenta

Una edad inválida es esperable en el límite de entrada; devuelve o traduce un resultado que la presentación pueda explicar. Un `StateError` por una variante imposible señala una suposición rota; capturarlo como “sin resultados” dificulta descubrir el bug.

Defiende dónde cambias de excepción técnica a fallo de dominio. El nivel debe conocer suficiente contexto para nombrar la operación, pero no mezclar todavía decisiones visuales. Conserva causa y stack para diagnóstico aunque entregues un mensaje seguro hacia arriba.

## R — Reaplica

Diseña una importación por etapas: leer bytes, decodificar JSON, validar esquema y presentar resumen. Da un tipo o resultado distinto a archivo inaccesible, sintaxis JSON inválida y versión incompatible. Añade contexto al subir: ruta, versión esperada y campo rechazado.

Prueba el mismo método con una llamada HTTP o una base local: reproduce, reduce, nombra, sustenta y recién entonces corrige. La depuración sistemática convierte un fallo grande en una afirmación pequeña que puedes comprobar.
