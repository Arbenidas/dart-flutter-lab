// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

const _copiedFiles = <String>[
  'analysis_options.yaml',
  'pubspec.lock',
  'pubspec.yaml',
  'tool/lab.dart',
];

const _copiedDirectories = <String>['lib', 'soluciones', 'test'];

Future<void> main() async {
  final source = Directory.current.absolute;
  if (!File('${source.path}/pubspec.yaml').existsSync() ||
      !Directory('${source.path}/soluciones').existsSync()) {
    stderr.writeln('Ejecuta la verificacion desde dart_lab/.');
    exitCode = 64;
    return;
  }

  final sandbox = await Directory.systemTemp.createTemp('dart-lab-reference-');
  try {
    for (final relativePath in _copiedFiles) {
      await _copyFile(source, sandbox, relativePath);
    }
    for (final relativePath in _copiedDirectories) {
      await _copyDirectory(
        Directory('${source.path}/$relativePath'),
        Directory('${sandbox.path}/$relativePath'),
      );
    }

    await _applySolutions(sandbox);
    await _expectSuccess(sandbox, const <String>[
      'pub',
      'get',
      '--offline',
      '--enforce-lockfile',
    ], 'resolver el lockfile en el sandbox');
    await _expectSuccess(sandbox, const <String>[
      'run',
      'tool/lab.dart',
      'verify',
    ], 'runner y contratos de referencia');

    final fixturesFile = File('${source.path}/tool/fixtures/mutants.json');
    final decoded = jsonDecode(await fixturesFile.readAsString());
    if (decoded is! List<Object?>) {
      throw const FormatException('mutants.json debe contener una lista');
    }

    var killed = 0;
    for (final value in decoded) {
      final mutant = _Mutant.fromJson(value);
      final canonical = File('${source.path}/soluciones/${mutant.target}');
      final target = File('${sandbox.path}/lib/${mutant.target}');
      final original = await canonical.readAsString();
      final occurrences = mutant.find.allMatches(original).length;
      if (occurrences != 1) {
        throw StateError(
          '${mutant.id}: el fragmento canónico debe aparecer una vez; '
          'aparece $occurrences.',
        );
      }

      await target.writeAsString(
        original.replaceFirst(mutant.find, mutant.replace),
      );
      final result = await _run(sandbox, const <String>['test', '--fail-fast']);
      await target.writeAsString(original);
      if (result.exitCode == 0) {
        throw StateError(
          '${mutant.id}: el mutante sobrevivió a los contratos.',
        );
      }
      killed += 1;
      print('[OK] ${mutant.id} rechazado');
    }

    print(
      '\nReferencia válida y $killed/${decoded.length} mutantes rechazados.',
    );
  } finally {
    await sandbox.delete(recursive: true);
  }
}

Future<void> _applySolutions(Directory sandbox) async {
  final solutions = Directory('${sandbox.path}/soluciones');
  await for (final entity in solutions.list()) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final name = entity.uri.pathSegments.last;
    await entity.copy('${sandbox.path}/lib/$name');
  }
}

Future<void> _copyFile(
  Directory source,
  Directory destination,
  String relativePath,
) async {
  final target = File('${destination.path}/$relativePath');
  await target.parent.create(recursive: true);
  await File('${source.path}/$relativePath').copy(target.path);
}

Future<void> _copyDirectory(Directory source, Directory destination) async {
  await destination.create(recursive: true);
  await for (final entity in source.list()) {
    final name = entity.uri.pathSegments.where((part) => part.isNotEmpty).last;
    if (entity is Directory) {
      await _copyDirectory(entity, Directory('${destination.path}/$name'));
    } else if (entity is File) {
      await entity.copy('${destination.path}/$name');
    }
  }
}

Future<ProcessResult> _run(Directory directory, List<String> arguments) {
  return Process.run(Platform.resolvedExecutable, <String>[
    '--suppress-analytics',
    ...arguments,
  ], workingDirectory: directory.path);
}

Future<void> _expectSuccess(
  Directory directory,
  List<String> arguments,
  String label,
) async {
  stdout.write('$label ... ');
  final result = await _run(directory, arguments);
  if (result.exitCode != 0) {
    stdout.writeln('FALLO');
    stdout.write(result.stdout);
    stderr.write(result.stderr);
    throw ProcessException(
      Platform.resolvedExecutable,
      arguments,
      '$label falló',
      result.exitCode,
    );
  }
  print('OK');
}

final class _Mutant {
  const _Mutant({
    required this.id,
    required this.target,
    required this.find,
    required this.replace,
  });

  factory _Mutant.fromJson(Object? value) {
    if (value is! Map<String, Object?>) {
      throw const FormatException('Cada mutante debe ser un objeto JSON.');
    }
    String field(String name) {
      final fieldValue = value[name];
      if (fieldValue is! String || fieldValue.isEmpty) {
        throw FormatException('El mutante necesita «$name».');
      }
      return fieldValue;
    }

    return _Mutant(
      id: field('id'),
      target: field('target'),
      find: field('find'),
      replace: field('replace'),
    );
  }

  final String id;
  final String target;
  final String find;
  final String replace;
}
