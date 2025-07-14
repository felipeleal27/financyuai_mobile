import 'dart:io';

import 'package:neo_financyuai/app/utils/util.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

/// Classe responsável pela conexão e configuração do banco SQLite
/// Implementa padrão Singleton para garantir única instância
class DB {
  DB._();

static const int _dbaseVersion = 6; // Incrementado para adicionar campo idUsuario na categoria
  static const String _dbaseName = 'financy.db';

  static final DB instance = DB._();

  static Database? _database;

  /// Getter para obter a instância do banco de dados
  Future<Database> get database async {
    if (_database != null) return _database!;

    return await _initDatabase();
  }
  
  /// Inicializa o banco de dados
  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();

    if (Platform.isWindows) {
      // databaseFactoryOrNull = null;
      // // Initialize FFI
      // sqfliteFfiInit();
      // databaseFactory = databaseFactoryFfi;
      documentsDirectory = await getApplicationSupportDirectory();
    }

    _database = await openDatabase(
      "${documentsDirectory.path}/$_dbaseName",
      version: _dbaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    
    return _database!;
  }

  /// Callback para criação das tabelas
  Future<void> _onCreate(Database db, int versao) async {
    await db.execute(_tabelaUsuario);
    await db.execute(_tabelaCategoria);
    await db.execute(_tabelaMovimentacao);
    await db.execute(_tabelaUsuarioGoogle);
  }

  /// Callback para upgrade do banco
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Versão 2: Mudança de IdUsuario de INTEGER para TEXT
      await db.execute('DROP TABLE IF EXISTS movimentacao');
      await db.execute(_tabelaMovimentacao);
    }
    
    if (oldVersion < 4) {
      // Versão 4: Adiciona tabela de usuário Google
      await db.execute(_tabelaUsuarioGoogle);
    }
    
    if (oldVersion < 5) {
      // Versão 5: Adiciona campo icone na tabela categoria
      await addColumnIfNotExists(db, "categoria", "Icone", "TEXT DEFAULT 'category'");
    }
    if (oldVersion < 6) {
      // Versão 6: Adiciona campo idUsuario para suportar categorias por usuário
      await addColumnIfNotExists(db, "categoria", "IdUsuario", "TEXT");
    }

    //await addColumnIfNotExists(db, "resumo", "conjunto", "INTEGER");
  }

  /// Adiciona coluna se não existir (utilitário para migrations)
  Future<void> addColumnIfNotExists(
      Database db, String table, String column, String type) async {
    if (!await db.isColumnExists(table, column)) {
      await db.execute("ALTER TABLE $table ADD COLUMN $column $type");
    }
  }
  
  /// Apaga completamente o banco de dados
  Future<void> apagarBanco() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    if (Platform.isWindows) {
      documentsDirectory = await getApplicationSupportDirectory();
    }
    String path = "${documentsDirectory.path}/$_dbaseName";

    if (await File(path).exists()) {
      await deleteDatabase(path);

      if (await File(path).exists()) {
        await File(path).delete();
      }
      await openDatabase(path,
          version: _dbaseVersion, onCreate: _onCreate, onUpgrade: _onUpgrade);
    }
  }

  // Definições das tabelas (SQL DDL)

  static const String _tabelaUsuario = '''
    CREATE TABLE IF NOT EXISTS usuario (
      Id INTEGER PRIMARY KEY AUTOINCREMENT,
      Nome TEXT NOT NULL,
      Email TEXT NOT NULL,
      Senha TEXT NOT NULL
  )''';

  static const String _tabelaMovimentacao = '''
    CREATE TABLE IF NOT EXISTS movimentacao (
      Id TEXT PRIMARY KEY,
      Nome TEXT NOT NULL,
      Valor REAL NOT NULL,
      IdCategoria INTEGER NOT NULL,
      IsSaida INTEGER NOT NULL,
      DataMovimentacao INTERGER NOT NULL,
      Descricao TEXT,
      IdUsuario TEXT NOT NULL
  )''';

static const String _tabelaCategoria = '''
    CREATE TABLE IF NOT EXISTS categoria (
      Id INTEGER PRIMARY KEY AUTOINCREMENT,
      Nome TEXT NOT NULL,
      Icone TEXT DEFAULT 'category',
      IdUsuario TEXT
  )''';

  /// Tabela para armazenar informações do usuário Google
  static const String _tabelaUsuarioGoogle = '''
    CREATE TABLE IF NOT EXISTS usuario_google (
      Uid TEXT PRIMARY KEY,
      Nome TEXT,
      Email TEXT,
      PhotoURL TEXT,
      PhotoBlob BLOB,
      DataLogin INTEGER NOT NULL,
      DataAtualizacao INTEGER NOT NULL,
      IsAtivo INTEGER NOT NULL DEFAULT 1
  )''';
}
