import 'package:sqflite/sqflite.dart';

/// Classe responsável por executar comandos SQL no banco de dados
/// Encapsula operações CRUD e queries customizadas
class CommandSql {
  late final Database _db;

  /// Construtor que recebe a instância do banco de dados
  CommandSql(Database database) {
    _db = database;
  }

  /// Executa uma consulta SELECT
  Future<List<Map<String, dynamic>>> select(String table,
      {String? where, List<dynamic>? whereArgs}) async {
    return await _db.query(table, where: where, whereArgs: whereArgs);
  }

  /// Executa uma consulta SELECT e retorna apenas o primeiro resultado
  Future<Map<String, dynamic>?> selectFirst(String table,
      {String? where, List<dynamic>? whereArgs}) async {
    var result = await _db.query(table, where: where, whereArgs: whereArgs);
    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  /// Executa um INSERT e retorna o ID inserido
  Future<int> insert(String table, Map<String, dynamic> values) async {
    return await _db.insert(table, values);
  }

  /// Executa um UPDATE e retorna o número de linhas afetadas
  Future<int> update(String table, Map<String, dynamic> values,
      {String? where, List<dynamic>? whereArgs}) async {
    return await _db.update(table, values,
        where: where,
        whereArgs: whereArgs,
        conflictAlgorithm: ConflictAlgorithm.fail);
  }

  /// Executa um DELETE e retorna o número de linhas afetadas
  Future<int> delete(String table,
      {String? where, List<dynamic>? whereArgs}) async {
    return await _db.delete(table, where: where, whereArgs: whereArgs);
  }

  /// Executa uma query SQL customizada
  Future<List<Map<String, dynamic>>> rawQuery(String sql,
      [List<dynamic>? arguments]) async {
    return await _db.rawQuery(sql, arguments);
  }

  /// Executa um INSERT SQL customizado
  Future<int> rawInsert(String sql, [List<dynamic>? arguments]) async {
    return await _db.rawInsert(sql, arguments);
  }

  /// Executa um UPDATE SQL customizado
  Future<int> rawUpdate(String sql, [List<dynamic>? arguments]) async {
    return await _db.rawUpdate(sql, arguments);
  }

  /// Executa um DELETE SQL customizado
  Future<int> rawDelete(String sql, [List<dynamic>? arguments]) async {
    return await _db.rawDelete(sql, arguments);
  }

  /// Sincroniza dados no banco (método específico - considerar refatoração)
  Future<void> sincronizar(dados) async {
    // Código comentado para referência:
    // for (var dado in Sincronizar.values) {
    //   await delete(dado.toString().split('.').last);
    // }

    // Insert dados
    for (var element in dados.armazem) {
      await insert('usuario', element.toMap());
    }

    for (var element in dados.peneiras) {
      await insert('movimentacao', element.toMap());
    }

    for (var element in dados.balanca) {
      await insert('categoria', element.toMap());
    }
  }

  /// Limpa todas as tabelas principais
  Future<void> reset() async {
    // Código comentado para referência:
    // for (var dado in Sincronizar.values) {
    //   await delete(dado.toString().split('.').last);
    // }

    // Delete movimentos
    await delete('usuario');
    await delete('movimentacao');
    await delete('categoria');
  }
}
