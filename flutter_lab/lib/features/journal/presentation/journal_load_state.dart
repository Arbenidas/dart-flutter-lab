import '../data/async_journal_repository.dart';
import '../data/models/journal_entry.dart';

/// Los cuatro estados de una carga.
///
/// Es `sealed` para que no exista un quinto y para que no se puedan combinar
/// dos a la vez. Con dos banderas booleanas —`cargando` y `error`— sí se puede
/// llegar a «cargando y con error», que no significa nada.
sealed class JournalLoadState {
  const JournalLoadState();
}

final class JournalLoading extends JournalLoadState {
  const JournalLoading();
}

final class JournalEmpty extends JournalLoadState {
  const JournalEmpty();
}

final class JournalData extends JournalLoadState {
  const JournalData(this.entries);

  final List<JournalEntry> entries;
}

final class JournalFailure extends JournalLoadState {
  const JournalFailure(this.message);

  final String message;
}

/// Convierte un resultado en el estado que le corresponde.
///
/// Una lista vacía no es lo mismo que «todavía no hay datos»: son dos
/// pantallas distintas y dos acciones distintas.
JournalLoadState stateFromResult(List<JournalEntry> entries) =>
    entries.isEmpty ? const JournalEmpty() : JournalData(entries);

/// Qué acción ofrece cada estado.
///
/// Un estado sin salida deja atrapada a la persona que lo encuentra.
String? actionFor(JournalLoadState state) => switch (state) {
  JournalLoading() => null,
  JournalEmpty() => 'Crear la primera entrada',
  JournalData() => null,
  JournalFailure() => 'Reintentar',
};

/// Coordina cargas para que gane la **última pedida**, no la última en llegar.
///
/// Sin este control, una respuesta lenta que se pidió antes pisa a una rápida
/// que se pidió después, y la pantalla termina mostrando datos viejos.
class JournalLoader {
  JournalLoader(this._repository);

  final AsyncJournalRepository _repository;
  int _requestId = 0;

  JournalLoadState state = const JournalLoading();

  Future<void> load() async {
    final id = ++_requestId;
    state = const JournalLoading();
    try {
      final entries = await _repository.fetchAll();
      if (id != _requestId) {
        return;
      }
      state = stateFromResult(entries);
    } catch (_) {
      if (id != _requestId) {
        return;
      }
      // El motivo técnico va al registro, no a la pantalla.
      state = const JournalFailure('No pudimos cargar la bitácora.');
    }
  }
}
