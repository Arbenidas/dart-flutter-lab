# Guía para contribuir contenido educativo

Esta guía evita que una lección correcta técnicamente sea confusa para alguien que nunca programó.

## Público y lenguaje

- Escribe en español `es-419` y asume cero conocimiento previo.
- Define un término antes de usarlo como explicación.
- Usa frases directas, un ejemplo mínimo y una sola dificultad nueva por experimento.
- Distingue claramente qué archivo viene incluido, cuál debe crear el estudiante y desde qué carpeta se ejecuta cada comando.
- No digas que la plataforma ejecutó o validó código: la persona confirma su trabajo local.

## Progresión

La secuencia general es:

1. observar un programa mínimo;
2. valores, tipos y variables;
3. null safety y control de flujo;
4. funciones y colecciones;
5. modelado, objetos, errores y asincronía;
6. herramientas, pruebas y arquitectura;
7. Flutter: widgets y estado local antes de MVVM y gestores de estado.

Una abstracción avanzada entra cuando el estudiante ya experimentó el problema que resuelve. Clean Architecture, Riverpod o Bloc no son vocabulario inicial.

## Contrato del ciclo de evidencia

Cada lección declara `kind` y ese `kind` decide qué movimientos son obligatorios. El objetivo es que
el ciclo se aplique según la naturaleza del trabajo, no como ritual idéntico en las 23 lecciones.

| `kind`     | Movimientos obligatorios          | ¿Necesita `lab`? |
| ---------- | --------------------------------- | ---------------- |
| `taller`   | `attempt`, `evidence`, `source`, `judgment` | sí     |
| `concepto` | `attempt`, `source`, `judgment`   | no               |
| `proyecto` | `attempt`, `evidence`, `judgment` | sí               |

Los cuatro movimientos y lo que produce cada uno:

1. **Intento** (`attempt`): obliga a escribir o predecir **antes** de leer la teoría de más abajo.
   Debe poder responderse con la lección anterior y los objetivos; si necesita la prosa que viene
   después, está mal ubicado y solo mide lectura.
2. **Evidencia** (`evidence`): el estudiante ejecuta y conserva la salida exacta. Es el único
   movimiento cuya prueba no depende de su opinión.
3. **Fuente** (`source`): una pregunta concreta contra la documentación oficial. Puede declarar
   `sourceLabel`, que debe coincidir con el `label` de un `docRefs` de la misma lección.
4. **Criterio** (`judgment`): una decisión con su alternativa descartada y el costo aceptado.

Cada actividad puede tener como máximo tres pistas socráticas. Las pistas avanzan de pregunta
diagnóstica a concepto y después a documentación o esqueleto mínimo. Una lección tiene entre cuatro
y ocho actividades: menos no cubre el ciclo, más la convierte en un monolito.

**No dupliques.** El frontmatter declara las tareas; la prosa aporta el material para resolverlas.
Los encabezados `## Intento · …`, `## Evidencia · …`, `## Fuente · …` y `## Criterio · …` explican
cómo abordar el movimiento; no repiten el enunciado de la actividad.

## Escalera de repaso

`reviewPrompts` declara exactamente cuatro entradas y su **índice es la etapa**. La antigua etapa de
transferencia vive aquí: reaplicar el mismo día sigue siendo reconocimiento.

| Índice | Vence   | Verbo         | Qué debe pedir el prompt                              |
| ------ | ------- | ------------- | ----------------------------------------------------- |
| 0      | día 1   | recordar      | una pregunta que se responde de memoria               |
| 1      | día 3   | reescribir    | volver a escribir el ejercicio en un archivo vacío    |
| 2      | día 7   | explicar      | explicar en voz alta, sin apuntes                     |
| 3      | día 21  | transferir    | aplicar la idea a un problema que no apareció         |

## Tamaño de una lección

Una lección es **una sesión de estudio**, no un módulo. El presupuesto es 20–90 minutos de
`estimatedMinutes`; el validador avisa por encima de 90. Un módulo `available` de más de dos horas
debe declarar al menos dos lecciones, y la suma de sus lecciones debe acercarse a su
`estimatedHours`.

Reglas para partir un módulo:

- **Módulos con laboratorio Dart:** una lección por ejercicio de `dart_lab/tool/lab.dart`, usando su
  id (`m02-1`) en `lab.exerciseId` y `--name m02-1` en `lab.testCommand`.
- **Módulos sin laboratorio:** partir por unidades conceptuales que quepan en una sesión, con
  `kind: 'concepto'`.
- El slug existente se conserva en la primera lección del módulo, para no romper enlaces publicados.
- Solo la lección que **cierra** el módulo lleva `lab.revealReference: true`. Sin eso, el debrief de
  la primera lección filtraría las respuestas de todas las que apuntan al mismo archivo.

## Archivos de contenido

- Lecciones: `platform/src/content/lessons/*.md`.
- Módulos: `platform/src/content/modules/*.json`.
- Rutas: `platform/src/content/tracks/*.json`.
- Contrato tipado: `platform/src/content.config.ts`.

Los IDs son permanentes y ASCII. No cambies un ID para corregir un título o slug. El progreso local depende de esos IDs.

Una lección debe declarar `kind`, cuatro repasos escalonados, referencias oficiales, objetivos verificables, prerrequisitos existentes y los movimientos que su `kind` exige. Si incluye `lab`, la ruta y los comandos deben existir y usar FVM.

## Documentación oficial

Cada referencia declara:

- tipo: guía, API, cookbook, paquete o changelog;
- URL oficial y específica;
- versión objetivo;
- fecha UTC de última verificación.

Enseña a leer encabezados, firmas, tipos de entrada y retorno, null safety, restricciones y plataforma. La actividad debe formular una pregunta concreta; “lee toda la documentación” no es una instrucción útil.

## Lista de revisión pedagógica

- ¿Una persona que entra por enlace directo encuentra el archivo y la preparación?
- ¿El Intento se puede responder sin leer la prosa que viene después?
- ¿La lección muestra la sintaxis necesaria antes de pedir una predicción?
- ¿Cada comando indica su carpeta de ejecución?
- ¿El ejemplo evita conceptos que todavía no fueron definidos?
- ¿La actividad de Fuente pide un encabezado concreto y no «lee la página»?
- ¿Las pistas ayudan sin revelar la respuesta completa?
- ¿El repaso del día 21 cambia el problema, no solo los nombres?
- ¿La fuente oficial responde realmente la pregunta planteada?
- ¿El cierre dice con claridad qué viene después?

Ejecuta `npm run check:content` y `npm run check` desde `platform/` antes de abrir el pull request.
