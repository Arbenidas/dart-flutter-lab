// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

const String _progressPath = '.dart_tool/lab_progress.json';

const List<_Exercise> _exercises = <_Exercise>[
  _Exercise('m02-1', 'Tipos: reconocer valores', 'test/m02_tipos_test.dart'),
  _Exercise(
    'm02-2',
    'Numeros: Fahrenheit a Celsius',
    'test/m02_tipos_test.dart',
  ),
  _Exercise('m02-3', 'Enteros: formatear precios', 'test/m02_tipos_test.dart'),
  _Exercise(
    'm02-4',
    'Constantes y canonicalizacion',
    'test/m02_tipos_test.dart',
    checksStructure: true,
  ),
  _Exercise(
    'm02-5',
    'Colecciones: copiar una lista',
    'test/m02_tipos_test.dart',
  ),
  _Exercise(
    'm03-1',
    'Null safety: valores alternativos',
    'test/m03_null_safety_test.dart',
  ),
  _Exercise(
    'm03-2',
    'Null safety: acceso condicional',
    'test/m03_null_safety_test.dart',
  ),
  _Exercise(
    'm03-3',
    'Null safety: retorno nullable',
    'test/m03_null_safety_test.dart',
  ),
  _Exercise(
    'm03-4',
    'Null safety: parseo seguro',
    'test/m03_null_safety_test.dart',
  ),
  _Exercise(
    'm03-5',
    'Inicializacion tardia con late final',
    'test/m03_null_safety_test.dart',
    checksStructure: true,
  ),
  _Exercise(
    'm04-1',
    'Patterns relacionales',
    'test/m04_control_test.dart',
    checksStructure: true,
  ),
  _Exercise(
    'm04-2',
    'Switch expression y casos agrupados',
    'test/m04_control_test.dart',
    checksStructure: true,
  ),
  _Exercise(
    'm04-3',
    'Records y destructuring',
    'test/m04_control_test.dart',
    checksStructure: true,
  ),
  _Exercise(
    'm04-4',
    'Iterar texto',
    'test/m04_control_test.dart',
    checksStructure: true,
  ),
  _Exercise(
    'm04-5',
    'Construir Fibonacci',
    'test/m04_control_test.dart',
    checksStructure: true,
  ),
  _Exercise(
    'm05-1',
    'Funciones como argumentos',
    'test/m05_funciones_test.dart',
  ),
  _Exercise('m05-2', 'Parametros con nombre', 'test/m05_funciones_test.dart'),
  _Exercise(
    'm05-3',
    'Closures con estado',
    'test/m05_funciones_test.dart',
    checksStructure: true,
  ),
  _Exercise(
    'm05-4',
    'Aplicacion parcial',
    'test/m05_funciones_test.dart',
    checksStructure: true,
  ),
  _Exercise(
    'm05-5',
    'Transformaciones con map',
    'test/m05_funciones_test.dart',
    checksStructure: true,
  ),
  _Exercise(
    'm05-6',
    'Medir una accion',
    'test/m05_funciones_test.dart',
    checksStructure: true,
  ),
];

Future<void> main(List<String> arguments) async {
  if (!File('pubspec.yaml').existsSync()) {
    stderr.writeln(
      'Ejecuta este comando desde dart_lab/: '
      './lab next',
    );
    exitCode = 64;
    return;
  }

  final command = arguments.isEmpty ? 'next' : arguments.first;
  final result = switch (command) {
    'next' => await _runNext(),
    'check' => await _checkById(arguments.skip(1).toList()),
    'module' => await _checkModule(arguments.skip(1).toList()),
    'status' => _showStatus(),
    'verify' => await _verifyAll(),
    'help' || '--help' || '-h' => _showHelp(),
    _ => _unknownCommand(command),
  };
  exitCode = result;
}

Future<int> _checkById(List<String> arguments) async {
  if (arguments.length != 1) {
    stderr.writeln('Uso: lab check <id>. Ejemplo: lab check m03-2');
    return 64;
  }

  final id = arguments.single.toLowerCase();
  final exercise = _exerciseById(id);
  if (exercise == null) {
    stderr.writeln('No existe el ejercicio $id. Ejecuta `lab status`.');
    return 64;
  }

  _printHeading(exercise, _exercises.indexOf(exercise));
  if (!await _checkExercise(exercise, showFailure: true)) {
    return 1;
  }

  final completed = _loadProgress()..add(exercise.id);
  _saveProgress(completed);
  print('\n[OK] ${exercise.id} completado.');
  return 0;
}

Future<int> _checkModule(List<String> arguments) async {
  if (arguments.length != 1) {
    stderr.writeln('Uso: lab module <id>. Ejemplo: lab module m04');
    return 64;
  }

  final moduleId = arguments.single.toLowerCase();
  final exercises = _exercises
      .where((exercise) => exercise.id.startsWith('$moduleId-'))
      .toList();
  if (exercises.isEmpty) {
    stderr.writeln('No existe el modulo $moduleId. Usa m02, m03, m04 o m05.');
    return 64;
  }

  final completed = _loadProgress();
  print('Modulo $moduleId: ${exercises.length} contratos, con fail-fast.\n');
  for (final exercise in exercises) {
    stdout.write('${exercise.id} ... ');
    if (!await _checkExercise(exercise, showFailure: true)) {
      print('\nDetenido en ${exercise.id}. Corrige ese contrato y repite.');
      return 1;
    }
    completed.add(exercise.id);
    _saveProgress(completed);
    print('OK');
  }

  print('\n[OK] Modulo $moduleId completado.');
  return 0;
}

Future<int> _runNext() async {
  final completed = _loadProgress();
  final exercise = _firstPending(completed);
  if (exercise == null) {
    print('Completaste los ${_exercises.length} ejercicios.');
    print('Confirma el laboratorio con: ./lab verify');
    return 0;
  }

  _printHeading(exercise, completed.length);
  if (!await _checkExercise(exercise, showFailure: true)) {
    print('\nCorrige este unico ejercicio y vuelve a ejecutar `next`.');
    return 1;
  }

  completed.add(exercise.id);
  _saveProgress(completed);
  print('\n[OK] ${exercise.id} completado.');
  final following = _firstPending(completed);
  if (following == null) {
    print('Terminaste. Ejecuta: ./lab verify');
  } else {
    print('Siguiente: ${following.id} — ${following.title}');
  }
  return 0;
}

int _showStatus() {
  final completed = _loadProgress();
  final validCompleted = _exercises
      .where((exercise) => completed.contains(exercise.id))
      .length;
  final pending = _firstPending(completed);

  print('Progreso: $validCompleted/${_exercises.length} ejercicios.');
  if (pending == null) {
    print('No quedan ejercicios pendientes.');
  } else {
    print('Siguiente: ${pending.id} — ${pending.title}');
  }
  return 0;
}

Future<int> _verifyAll() async {
  final completed = _loadProgress();
  print('Verificacion progresiva: se detiene en el primer problema.\n');

  for (final exercise in _exercises) {
    stdout.write('${exercise.id} ... ');
    if (!await _checkExercise(exercise, showFailure: true)) {
      print(
        '\nDetenido en ${exercise.id}; no se ocultaron fallos posteriores.',
      );
      return 1;
    }
    completed.add(exercise.id);
    _saveProgress(completed);
    print('OK');
  }

  stdout.write('contratos publicos ... ');
  final contracts = await _run(<String>[
    'test',
    'test/public_contract_test.dart',
    '--fail-fast',
    '--reporter',
    'expanded',
  ]);
  if (contracts.exitCode != 0) {
    _showProcessFailure(contracts);
    return contracts.exitCode;
  }
  print('OK');

  stdout.write('analisis estatico ... ');
  final analysis = await _run(<String>['analyze']);
  if (analysis.exitCode != 0) {
    _showProcessFailure(analysis);
    return analysis.exitCode;
  }
  print('OK');
  print('\nLaboratorio completo: comportamiento, estructura y analisis pasan.');
  return 0;
}

Future<bool> _checkExercise(
  _Exercise exercise, {
  required bool showFailure,
}) async {
  final behavior = await _runTest(exercise.testPath, exercise.id);
  if (behavior.exitCode != 0) {
    if (showFailure) {
      _showProcessFailure(behavior);
    }
    return false;
  }

  if (!exercise.checksStructure) {
    return true;
  }

  final structure = await _runTest('test/structure_test.dart', exercise.id);
  if (structure.exitCode != 0) {
    if (showFailure) {
      print(
        '\nEl resultado es correcto, pero falta practicar la estructura pedida:',
      );
      _showProcessFailure(structure);
    }
    return false;
  }
  return true;
}

Future<ProcessResult> _runTest(String path, String exerciseId) {
  return _run(<String>[
    'test',
    path,
    '--name',
    exerciseId,
    '--fail-fast',
    '--reporter',
    'expanded',
  ]);
}

Future<ProcessResult> _run(List<String> arguments) {
  return Process.run(Platform.resolvedExecutable, <String>[
    '--suppress-analytics',
    ...arguments,
  ], workingDirectory: Directory.current.path);
}

void _showProcessFailure(ProcessResult result) {
  final processOutput = result.stdout;
  final processError = result.stderr;
  if (processOutput is String && processOutput.trim().isNotEmpty) {
    stdout.write(processOutput);
  }
  if (processError is String && processError.trim().isNotEmpty) {
    stderr.write(processError);
  }
}

Set<String> _loadProgress() {
  final file = File(_progressPath);
  if (!file.existsSync()) {
    return <String>{};
  }

  try {
    final Object? decoded = jsonDecode(file.readAsStringSync());
    if (decoded is! Map<String, Object?>) {
      return <String>{};
    }
    final values = decoded['completed'];
    if (values is! List<Object?>) {
      return <String>{};
    }
    final knownIds = _exercises.map((exercise) => exercise.id).toSet();
    return values.whereType<String>().where(knownIds.contains).toSet();
  } on FormatException {
    return <String>{};
  }
}

void _saveProgress(Set<String> completed) {
  final directory = Directory('.dart_tool')..createSync(recursive: true);
  final knownIds = _exercises.map((exercise) => exercise.id).toSet();
  final ordered = completed.where(knownIds.contains).toList()..sort();
  final data = <String, Object>{'schemaVersion': 1, 'completed': ordered};
  File(
    '${directory.path}/lab_progress.json',
  ).writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(data)}\n');
}

_Exercise? _firstPending(Set<String> completed) {
  for (final exercise in _exercises) {
    if (!completed.contains(exercise.id)) {
      return exercise;
    }
  }
  return null;
}

_Exercise? _exerciseById(String id) {
  for (final exercise in _exercises) {
    if (exercise.id == id) {
      return exercise;
    }
  }
  return null;
}

void _printHeading(_Exercise exercise, int completedCount) {
  print('Ejercicio ${completedCount + 1}/${_exercises.length}');
  print('${exercise.id} — ${exercise.title}');
  print('Solo se ejecutaran sus pruebas.\n');
}

int _showHelp() {
  print('''
Laboratorio progresivo de Dart

  lab next           prueba solo el siguiente ejercicio
  lab check <id>     prueba un contrato, por ejemplo m03-2
  lab module <id>    prueba un modulo, por ejemplo m04
  lab status         muestra el progreso guardado
  lab verify         verifica todo y se detiene al primer fallo
''');
  return 0;
}

int _unknownCommand(String command) {
  stderr.writeln('Comando desconocido: $command');
  _showHelp();
  return 64;
}

final class _Exercise {
  const _Exercise(
    this.id,
    this.title,
    this.testPath, {
    this.checksStructure = false,
  });

  final String id;
  final String title;
  final String testPath;
  final bool checksStructure;
}
