import 'dart:io';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:test/test.dart';

void main() {
  group('m02-4 estructura', () {
    test('diasHabiles se declara con const', () {
      final declaration = _topLevelVariable(
        'lib/m02_tipos.dart',
        'diasHabiles',
      );

      expect(
        declaration.variables.isConst,
        isTrue,
        reason: 'El valor debe declararse con const, no solo construirse con const.',
      );
    });
  });

  group('m03-5 estructura', () {
    test('_inicio es late final DateTime', () {
      final unit = _parse('lib/m03_null_safety.dart');
      final session = unit.declarations
          .whereType<ClassDeclaration>()
          .singleWhere(
            (node) => node.namePart.typeName.lexeme == 'SesionDeEstudio',
          );
      final field = session.body.members
          .whereType<FieldDeclaration>()
          .singleWhere(
            (node) => node.fields.variables.any(
              (variable) => variable.name.lexeme == '_inicio',
            ),
          );

      expect(field.fields.isLate, isTrue, reason: '_inicio debe usar late.');
      expect(field.fields.isFinal, isTrue, reason: '_inicio debe usar final.');
      expect(field.fields.type?.toSource(), 'DateTime');
    });

    test('minutosHasta deja que late haga fallar la lectura prematura', () {
      final method = _method(
        'lib/m03_null_safety.dart',
        'SesionDeEstudio',
        'minutosHasta',
      );

      expect(
        _nodes<ThrowExpression>(method.body),
        isEmpty,
        reason:
            'No escribas un throw manual: lee _inicio y deja actuar a late.',
      );
      expect(
        method.body.toSource(),
        contains('_inicio'),
        reason: 'El calculo debe usar el campo _inicio.',
      );
    });
  });

  group('m04-1 estructura', () {
    test('usa switch expression y patterns relacionales', () {
      final body = _function('lib/m04_control.dart', 'clasificarEdad').body;

      expect(_nodes<SwitchExpression>(body), isNotEmpty);
      expect(_nodes<RelationalPattern>(body), isNotEmpty);
    });
  });

  group('m04-2 estructura', () {
    test('usa switch expression y casos agrupados', () {
      final body = _function('lib/m04_control.dart', 'tipoDeDia').body;

      expect(_nodes<SwitchExpression>(body), isNotEmpty);
      expect(
        _nodes<LogicalOrPattern>(body),
        isNotEmpty,
        reason: 'Agrupa dias equivalentes con el pattern ||.',
      );
    });
  });

  group('m04-3 estructura', () {
    test('desarma el record con patterns', () {
      final body = _function('lib/m04_control.dart', 'describirPunto').body;

      expect(_nodes<SwitchExpression>(body), isNotEmpty);
      expect(_nodes<RecordPattern>(body), isNotEmpty);
    });
  });

  group('m04-4 estructura', () {
    test('practica una iteracion', () {
      final body = _function('lib/m04_control.dart', 'contarVocales').body;

      expect(
        [..._nodes<ForStatement>(body), ..._nodes<MethodInvocation>(body)],
        isNotEmpty,
        reason: 'Recorre el texto con for o con una cadena de colecciones.',
      );
    });
  });

  group('m04-5 estructura', () {
    test('construye Fibonacci de forma iterativa', () {
      final body = _function('lib/m04_control.dart', 'fibonacci').body;

      expect(
        _nodes<ForStatement>(body),
        isNotEmpty,
        reason: 'En este ejercicio Fibonacci se implementa con for.',
      );
    });
  });

  group('m05-3 estructura', () {
    test('crearContador devuelve una closure', () {
      final body = _function('lib/m05_funciones.dart', 'crearContador').body;

      expect(_nodes<FunctionExpression>(body), isNotEmpty);
    });
  });

  group('m05-4 estructura', () {
    test('multiplicadorPor devuelve una closure', () {
      final body = _function('lib/m05_funciones.dart', 'multiplicadorPor').body;

      expect(_nodes<FunctionExpression>(body), isNotEmpty);
    });
  });

  group('m05-5 estructura', () {
    test('la version final usa map y toList', () {
      final body = _function('lib/m05_funciones.dart', 'transformarTodos').body;
      final methodNames = _nodes<MethodInvocation>(body)
          .map((node) => node.methodName.name)
          .toSet();

      expect(methodNames, containsAll(<String>{'map', 'toList'}));
    });
  });

  group('m05-6 estructura', () {
    test('usa Stopwatch y llama la accion exactamente una vez', () {
      final body = _function(
        'lib/m05_funciones.dart',
        'medirMilisegundos',
      ).body;
      final methods = _nodes<MethodInvocation>(body)
          .map((node) => node.methodName.name)
          .toList();
      final directActionCalls = _nodes<MethodInvocation>(body).where(
        (node) => node.target == null && node.methodName.name == 'accion',
      );
      final expressionActionCalls = _nodes<FunctionExpressionInvocation>(body)
          .where((node) => node.function.toSource() == 'accion');

      expect(body.toSource(), contains('Stopwatch'));
      expect(methods, containsAll(<String>{'start', 'stop'}));
      expect(
        directActionCalls.length + expressionActionCalls.length,
        1,
        reason: 'La medicion debe ejecutar accion() exactamente una vez.',
      );
    });
  });
}

CompilationUnit _parse(String path) {
  final result = parseString(
    content: File(path).readAsStringSync(),
    path: path,
    throwIfDiagnostics: false,
  );
  return result.unit;
}

TopLevelVariableDeclaration _topLevelVariable(String path, String name) {
  return _parse(path).declarations
      .whereType<TopLevelVariableDeclaration>()
      .singleWhere(
        (node) => node.variables.variables.any(
          (variable) => variable.name.lexeme == name,
        ),
      );
}

FunctionExpression _function(String path, String name) {
  return _parse(path).declarations
      .whereType<FunctionDeclaration>()
      .singleWhere((node) => node.name.lexeme == name)
      .functionExpression;
}

MethodDeclaration _method(String path, String className, String methodName) {
  final declaration = _parse(path).declarations
      .whereType<ClassDeclaration>()
      .singleWhere((node) => node.namePart.typeName.lexeme == className);
  return declaration.body.members.whereType<MethodDeclaration>().singleWhere(
    (node) => node.name.lexeme == methodName,
  );
}

List<T> _nodes<T extends AstNode>(AstNode root) {
  final collector = _NodeCollector<T>();
  collector.visitAllNodes(root);
  return collector.nodes;
}

final class _NodeCollector<T extends AstNode>
    extends BreadthFirstVisitor<void> {
  final List<T> nodes = <T>[];

  @override
  void visitNode(AstNode node) {
    if (node is T) {
      nodes.add(node);
    }
    super.visitNode(node);
  }
}
