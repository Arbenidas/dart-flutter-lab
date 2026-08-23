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

## Contrato PENSAR

Toda lección contiene al menos seis actividades:

1. **Predice:** obliga a formular una hipótesis antes de ejecutar.
2. **Escribe:** produce o modifica código local.
3. **Nombra:** identifica el supuesto, error o regla que cambió.
4. **Sustenta:** busca evidencia en documentación oficial.
5. **Argumenta:** explica por qué funciona y qué alternativa descartó.
6. **Reaplica:** usa la idea en un contexto diferente.

Cada actividad puede tener como máximo tres pistas socráticas. Las pistas avanzan de pregunta diagnóstica a concepto y después a documentación o esqueleto mínimo.

## Archivos de contenido

- Lecciones: `platform/src/content/lessons/*.md`.
- Módulos: `platform/src/content/modules/*.json`.
- Rutas: `platform/src/content/tracks/*.json`.
- Contrato tipado: `platform/src/content.config.ts`.

Los IDs son permanentes y ASCII. No cambies un ID para corregir un título o slug. El progreso local depende de esos IDs.

Una lección debe declarar cuatro repasos, referencias oficiales, objetivos verificables, prerrequisitos existentes y actividades PENSAR. Si incluye `lab`, la ruta y los comandos deben existir y usar FVM.

## Documentación oficial

Cada referencia declara:

- tipo: guía, API, cookbook, paquete o changelog;
- URL oficial y específica;
- versión objetivo;
- fecha UTC de última verificación.

Enseña a leer encabezados, firmas, tipos de entrada y retorno, null safety, restricciones y plataforma. La actividad debe formular una pregunta concreta; “lee toda la documentación” no es una instrucción útil.

## Lista de revisión pedagógica

- ¿Una persona que entra por enlace directo encuentra el archivo y la preparación?
- ¿La lección muestra la sintaxis necesaria antes de pedir una predicción?
- ¿Cada comando indica su carpeta de ejecución?
- ¿El ejemplo evita conceptos que todavía no fueron definidos?
- ¿Las pistas ayudan sin revelar la respuesta completa?
- ¿La transferencia cambia el problema, no solo los nombres?
- ¿La fuente oficial responde realmente la pregunta planteada?
- ¿El cierre dice con claridad qué viene después?

Ejecuta `npm run check:content` y `npm run check` desde `platform/` antes de abrir el pull request.
