import 'package:sqflite/sqflite.dart';

/// Extensão utilitária para Iterable que adiciona métodos null-safe
extension SafeIterable<T> on Iterable<T> {
  /// Retorna o primeiro elemento ou null se a coleção estiver vazia
  T? get firstOrNull => isEmpty ? null : first;

  /// Retorna o primeiro elemento que satisfaz a condição ou null
  T? firstWhereOrNull(bool Function(T element) test) {
    final list = where(test);
    return list.isEmpty ? null : list.first;
  }
}

/// Extensão para Database que adiciona métodos utilitários
extension DatabaseUtils on Database {
  /// Verifica se uma coluna existe em uma tabela
  /// 
  /// [table] Nome da tabela
  /// [column] Nome da coluna
  /// Retorna true se a coluna existir, false caso contrário
  Future<bool> isColumnExists(String table, String column) async {
    bool isExists = false;
    List<Map> cursor = await rawQuery("PRAGMA table_info($table)", null);
    for (var element in cursor) {
      String name = element["name"];
      if (name.toUpperCase() == column.toUpperCase()) {
        isExists = true;
        break;
      }
    }
    return isExists;
  }
}
