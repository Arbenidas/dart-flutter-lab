---
id: 'D15-L01'
trackId: 'dart'
moduleId: 'D15'
order: 0
slug: 'proyecto-bitacora-cli-json'
title: 'Capstone: una bitácora CLI que protege sus datos'
summary: 'Construye desde criterios de aceptación una herramienta local con comandos, JSON versionado, arquitectura pequeña y pruebas.'
estimatedMinutes: 1080
objectives:
  - 'Convertir necesidades en comandos, esquema de datos y criterios de aceptación verificables.'
  - 'Integrar tipos, JSON, I/O asíncrono, Repository–Service, errores y pruebas en un proyecto.'
  - 'Defender alcance, decisiones y evidencia de calidad en una demostración reproducible.'
prerequisites: ['D14-L01']
activities:
  - id: 'predecir-especificacion'
    kind: 'predict'
    prompt: 'Antes de crear el proyecto, ejecuta mentalmente add, list, done y stats sobre una bitácora vacía. Escribe stdout, estado JSON y código de salida después de cada orden, incluidos tres fallos.'
    required: true
    hints:
      - 'Una especificación ejecutable incluye estado anterior, entrada, salida y estado posterior.'
      - 'Prueba orden desconocida, id inexistente y archivo corrupto.'
  - id: 'escribir-vertical'
    kind: 'code'
    prompt: 'Crea con FVM el proyecto bitacora_cli y entrega primero una rebanada vertical add → Repository → JSON → list. Después incorpora done y stats sin romper los criterios existentes.'
    required: true
    hints:
      - 'Mantén bin como adaptador: parsea, llama al Repository y presenta.'
      - 'Inyecta archivo, reloj e identificador para que las pruebas no dependan del entorno.'
  - id: 'diagnosticar-corrupcion'
    kind: 'debug'
    prompt: 'Provoca un corte lógico durante escritura y un JSON con schemaVersion desconocida. Demuestra que la herramienta no reemplaza el archivo válido ni interpreta datos incompatibles como bitácora vacía.'
    required: true
    hints:
      - 'Valida por completo antes de mutar y escribe primero un temporal en el mismo directorio.'
      - 'Un error debe conservar el archivo original y terminar con código no cero.'
  - id: 'rastrear-proyecto'
    kind: 'docs'
    prompt: 'En dart create, dart run, Package layout, dart:convert y Dart testing, confirma plantilla CLI, paso de argumentos, ubicación de bin/lib/test, valores JSON y ejecución de suites.'
    required: true
    hints:
      - 'El template cli incluye parsing básico; adapta su API, no copies otra plantilla.'
      - 'La documentación oficial responde una decisión concreta de la especificación.'
  - id: 'defender-arquitectura'
    kind: 'explain'
    prompt: 'Defiende por qué el parser no toca File, el Service no decide reglas de bitácora y el Repository no imprime. Señala también una capa que decidiste no crear y qué evidencia justificaría agregarla.'
    required: true
    hints:
      - 'Cada pieza debe tener entradas, salidas y una razón distinta para cambiar.'
      - 'Un use case solo aporta si existe lógica compleja compartida o una unidad independiente de prueba.'
  - id: 'transferir-entrega'
    kind: 'transfer'
    prompt: 'Prepara una demostración desde clon limpio: crear datos, filtrar, completar, recuperar de un fallo y ejecutar el quality gate. Cierra con una propuesta de migración para schemaVersion 2 sin implementarla.'
    required: true
    hints:
      - 'La demo debe usar comandos y resultados repetibles, no editar JSON a mano salvo para probar corrupción.'
      - 'Una migración define versión origen, destino, transformación y respaldo.'
docRefs:
  - label: 'dart create'
    url: 'https://dart.dev/tools/dart-create'
    kind: 'guide'
    version: 'Dart 3.13'
    lastVerified: '2026-08-23'
  - label: 'dart run'
    url: 'https://dart.dev/tools/dart-run'
    kind: 'guide'
    version: 'Dart 3.13'
    lastVerified: '2026-08-23'
  - label: 'Package layout conventions'
    url: 'https://dart.dev/tools/pub/package-layout'
    kind: 'guide'
    version: 'Dart 3.13'
    lastVerified: '2026-08-23'
  - label: 'dart:convert library'
    url: 'https://api.dart.dev/dart-convert/'
    kind: 'api'
    version: 'Dart 3.13 API'
    lastVerified: '2026-08-23'
  - label: 'Dart testing'
    url: 'https://dart.dev/tools/testing'
    kind: 'guide'
    version: 'Dart 3.13'
    lastVerified: '2026-08-23'
  - label: 'Flutter architecture recommendations'
    url: 'https://docs.flutter.dev/app-architecture/recommendations'
    kind: 'guide'
    version: 'Guía oficial vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué cuatro elementos convierten una necesidad en un criterio de aceptación ejecutable?'
  - '¿Qué responsabilidades separan parser/presentación, Repository y Service de archivo?'
  - '¿Cómo evita el diseño que JSON corrupto sea interpretado o sobrescrito como estado vacío?'
  - '¿Qué evidencia presentarías para afirmar que el capstone está listo y es mantenible?'
---

El proyecto final no pide inventar una aplicación enorme. Pide integrar decisiones pequeñas en un sistema cuyo comportamiento otra persona pueda comprender, ejecutar y verificar. Construirás una bitácora local: registra aprendizajes, los filtra, los marca como practicados y resume evidencia.

## La especificación antes de las carpetas

La aplicación se llama `bitacora_cli` y trabaja sobre un archivo JSON local. No tiene cuenta, nube ni editor embebido. Acepta una opción global `--file <ruta>`; si se omite, usa `bitacora.json` en el directorio actual.

Comandos de la versión 1:

```text
bitacora_cli add <texto> [--tag <etiqueta> ...]
bitacora_cli list [--tag <etiqueta>] [--status pending|done] [--json]
bitacora_cli done <id>
bitacora_cli stats [--json]
```

Contratos:

- `add` normaliza espacios, rechaza texto vacío, elimina etiquetas duplicadas y devuelve `AGREGADA <id>`.
- `list` ordena por `createdAtUtc` ascendente; los filtros se combinan. Sin resultados termina con éxito y encabezado estable.
- `done` es idempotente: una entrada ya completada sigue completada. Un id inexistente es fallo, no éxito silencioso.
- `stats` muestra total, pendientes, completadas y conteo por etiqueta.
- `--json` escribe una representación apta para otra herramienta; sin la opción, la salida es legible por una persona.

Canales y códigos:

| Código | Significado                  | Canal principal |
| ------ | ---------------------------- | --------------- |
| `0`    | Operación completada         | `stdout`        |
| `2`    | Uso u opción inválida        | `stderr`        |
| `3`    | Archivo o JSON inválido      | `stderr`        |
| `4`    | Recurso solicitado no existe | `stderr`        |

No dependas de frases para automatización. El código y el formato JSON son el contrato estable.

## Esquema JSON versionado

```json
{
  "schemaVersion": 1,
  "entries": [
    {
      "id": "e-1724400000000000",
      "text": "Puedo explicar un Future",
      "tags": ["dart", "async"],
      "createdAtUtc": "2026-08-23T15:00:00.000Z",
      "completedAtUtc": null
    }
  ]
}
```

Reglas:

- `schemaVersion` debe ser exactamente `1`; una versión desconocida no se abre ni se sobrescribe.
- `id`, `text` y etiquetas no están vacíos; ids son únicos.
- fechas usan ISO 8601 en UTC; `completedAtUtc` es `null` o no anterior a creación.
- etiquetas se normalizan a minúsculas, sin duplicados, conservando orden determinista.
- campos desconocidos pueden ignorarse al leer, pero nunca sustituyen los obligatorios.

El Repository valida el documento completo antes de publicar estado. Archivo ausente significa primera ejecución vacía; archivo presente pero corrupto es error explícito.

## Arquitectura mínima, no ceremonial

```text
bin/
  bitacora_cli.dart              # argumentos, stdout, stderr, exitCode
lib/
  bitacora_cli.dart              # API pública mínima
  src/bitacora/
    entry.dart                   # modelo e invariantes
    entry_repository.dart        # contrato de fuente de verdad
    json_entry_repository.dart   # reglas y transformación
    json_file_service.dart       # bytes/texto/JSON en disco
    commands.dart                # parsing tipado y presentación CLI
test/
  bitacora/
```

`JsonFileService` lee y escribe representaciones JSON y no sabe qué significa completar una entrada. `JsonEntryRepository` valida modelos, ids, filtros y actualización; usa el Service. El adaptador CLI convierte argumentos en una orden, llama al Repository y presenta resultado.

Inyecta `Clock` e `IdGenerator`. El generador por defecto puede derivar un candidato de microsegundos UTC y avanzar mientras ya exista. Los tests entregan valores fijos. No agregues casos de uso, contenedor de inyección o framework: aún no existe una responsabilidad que los justifique.

## Escritura defensiva

Antes de guardar:

1. lee y valida el estado actual;
2. calcula un estado nuevo en memoria;
3. serializa y vuelve a validar la representación;
4. escribe un archivo temporal en el mismo directorio;
5. reemplaza el destino solo cuando la escritura termina;
6. conserva el original y reporta fallo si cualquier paso no completa.

El reemplazo exacto depende del sistema operativo, pero el temporal reduce la ventana de corrupción. Prueba las garantías que sí controlas: no sobrescribir después de una lectura inválida y limpiar o informar temporales fallidos.

## Criterios de aceptación obligatorios

1. Primera ejecución de `list` con archivo ausente termina `0` y muestra bitácora vacía.
2. `add` persiste texto normalizado, etiquetas únicas, id y fecha UTC; otro proceso puede leerlo.
3. Dos altas con el mismo reloj nunca repiten id.
4. `list --tag dart --status pending` combina filtros y mantiene orden determinista.
5. `done` persiste una fecha; repetirlo no cambia la fecha inicial de finalización.
6. Id inexistente termina `4` y no modifica bytes del archivo.
7. JSON roto, versión desconocida o esquema inválido termina `3` y no se reemplaza.
8. Orden desconocida termina `2`, escribe uso por `stderr` y no contamina `stdout`.
9. `--json` produce JSON decodificable sin texto decorativo.
10. Formatter, analyzer y suite pasan con el SDK fijado.

## P — Predice

Escribe escenarios Given–When–Then para los diez criterios. Incluye contenido exacto antes y después. Predice especialmente los no felices: texto vacío, etiqueta repetida, id inexistente, archivo truncado y versión `2`.

Ordena el backlog por riesgo, no por comodidad. Persistir y recuperar una entrada valida la rebanada central; colores o tablas bonitas no reducen el riesgo de datos.

## E — Escribe

Crea el proyecto con la plantilla CLI oficial y FVM:

```bash
fvm dart create -t cli bitacora_cli
cd bitacora_cli
fvm dart analyze
fvm dart test
fvm dart run -- --help
```

Entrega iteraciones verticales:

1. `add` y `list` en memoria con tests;
2. Service JSON y roundtrip en directorio temporal;
3. Repository con validación y escritura defensiva;
4. `done`, filtros y `stats`;
5. salidas JSON, errores y documentación.

Después de cada iteración ejecuta formatter, analyzer y tests. No pospongas integración de archivo hasta el final.

## N — Nombra el fallo

Mantén una tabla de diagnóstico:

- parser: orden u opción desconocida;
- modelo: invariante de entrada rota;
- Repository: id, filtro o transición inválida;
- Service: lectura, escritura o reemplazo;
- codec: sintaxis JSON;
- esquema: versión, campos o tipos;
- presentación: canal, formato o código equivocado.

Cuando un criterio falla, reduce a la capa más pequeña que puede reproducirlo. Un test de Repository no necesita lanzar el proceso completo; una prueba CLI sí comprueba canales y código.

## S — Sustenta

Usa **dart create** para confirmar plantilla `cli`; **dart run** para argumentos; **Package layout** para `bin`, `lib`, `lib/src` y `test`; **dart:convert** para valores serializables; **Dart testing** para organizar la suite.

La guía oficial de arquitectura sustenta Repository–Service e inyección, pero adáptala: aquí no existe UI ni ViewModel. Documenta en tu README cada decisión y enlaza el encabezado oficial que la respalda.

## A — Argumenta

Presenta un diagrama de dependencias y defiende cada flecha. El CLI conoce Repository; Repository conoce Service; Service no importa dominio ni presentación. Explica por qué una clase que imprime y escribe archivo sería difícil de probar.

Defiende también lo que no construiste: sincronización en nube, login, base SQL, plugins de estado y capa de casos de uso. Para cada exclusión señala la evidencia que permitiría reabrirla, como múltiples fuentes, lógica compartida o volumen que JSON ya no maneja bien.

## R — Reaplica

Haz una demostración desde proyecto limpio: crea dos entradas, filtra, completa una, obtiene estadísticas, provoca un archivo corrupto, verifica que sobrevive y ejecuta el gate. Otra persona debe repetirla desde el README.

Cierra proponiendo `schemaVersion: 2` con una nueva prioridad. No la implementes: diseña respaldo, reconocimiento de versión, transformación `1 → 2`, validación posterior y comportamiento si falla. El capstone termina cuando puedes evolucionar el contrato sin improvisar y defender cada decisión con evidencia.
