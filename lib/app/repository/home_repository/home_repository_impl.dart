import 'package:flutter/foundation.dart';
import 'package:neo_financyuai/app/data/model/movimentacao_model.dart';
import 'package:neo_financyuai/app/data/model/categoria_model.dart';
import 'package:neo_financyuai/app/database/local_storage/local_storage.dart';
import 'package:neo_financyuai/app/database/sqllite/db.dart';
import 'package:neo_financyuai/app/database/sqllite/sql_lite.dart';
import 'package:neo_financyuai/app/repository/home_repository/home_repository.dart';
import 'package:neo_financyuai/app/service/firebase_sync_service.dart';
import 'package:neo_financyuai/app/service/auth_service.dart';
import 'package:sqflite/sqflite.dart';

/// Implementação do repositório de dados da tela principal
/// Gerencia movimentações, categorias e sincronização com Firebase
class HomeRepositoryImpl extends HomeRepository {

  @override
  Future<List<MovimentacaoModel>> getMovimentacoesTodas() async {
    try {
      final db = await DB.instance.database;
      final userId = _authService.userId;
      if (userId == null) {
        if (kDebugMode) {
          print('❌ getMovimentacoesTodas: userId nulo, retornando lista vazia');
        }
        return [];
      }
      final movimentacao = await CommandSql(db)
          .select('movimentacao', where: 'IdUsuario = ?', whereArgs: [userId]);
      if (kDebugMode) {
        print('🔍 getMovimentacoesTodas: total = ${movimentacao.length}');
      }
      return movimentacao.map((e) => MovimentacaoModel.fromMap(e, sqlLite: true)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao buscar todas movimentações: $e');
      }
      return [];
    }
  }
  final LocalStorage _localStorage;
  final FirebaseSyncService _syncService;
  final AuthService _authService;

  HomeRepositoryImpl({
    required LocalStorage localStorage,
    required FirebaseSyncService syncService,
    required AuthService authService,
  }) : _localStorage = localStorage,
       _syncService = syncService,
       _authService = authService;

  @override
  Future<bool> novaMovimentacao(MovimentacaoModel movimentacao) async {
    try {
      // Use o FirebaseSyncService que cuida do SQLite + Firebase
      final userId = _authService.userId;

      if (userId != null) {
        if (kDebugMode) {
          print('🟢 Salvando movimentação no Firebase para userId: $userId, id: ${movimentacao.id}');
        }
        await _syncService.addMovimentacao(movimentacao, userId);
      } else {
        if (kDebugMode) {
          print('🔴 userId está nulo! Salvando apenas localmente. Não irá para o Firebase.');
        }
        final db = await DB.instance.database;
        final query = CommandSql(db);
        await query.insert('movimentacao', movimentacao.toMap());
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao salvar movimentação: $e');
      }
      return false;
    }
  }

  @override
  Future<bool> atualizarMovimentacao(MovimentacaoModel movimentacao) async {
    try {
      final userId = _authService.userId;

      if (userId != null) {
        if (kDebugMode) {
          print('🟡 Atualizando movimentação no Firebase para userId: $userId, id: ${movimentacao.id}');
        }
        await _syncService.updateMovimentacao(movimentacao, userId);
      } else {
        if (kDebugMode) {
          print('🔴 userId está nulo! Atualizando apenas localmente.');
        }
        final db = await DB.instance.database;
        final query = CommandSql(db);
        await query.update(
          'movimentacao',
          movimentacao.toMap(),
          where: 'Id = ?',
          whereArgs: [movimentacao.id],
        );
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao atualizar movimentação: $e');
      }
      return false;
    }
  }

  @override
  Future<bool> removerMovimentacao(MovimentacaoModel movimentacao) async {
    try {
      // Use o FirebaseSyncService que cuida do SQLite + Firebase
      final userId = _authService.userId;

      if (userId != null) {
        await _syncService.removeMovimentacao(
          movimentacao.id.toString(),
          userId,
        );
      } else {
        // Fallback: apenas SQLite se não tiver userId
        final db = await DB.instance.database;
        final query = CommandSql(db);
        await query.delete(
          'movimentacao',
          where: 'Id = ?',
          whereArgs: [movimentacao.id],
        );
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao remover movimentação: $e');
      }
      return false;
    }
  }

  @override
  Future<List<MovimentacaoModel>> getMovimentacoes(
    int mesAtual, [
    int? ano,
  ]) async {
  try {
      final db = await DB.instance.database;
      final anoSelecionado = ano ?? DateTime.now().year;
      final userId = _authService.userId;

      if (userId == null) {
        if (kDebugMode) {
          print('❌ getMovimentacoes: userId nulo, retornando lista vazia');
        }
        return [];
      }

      if (kDebugMode) {
        print('🔍 BUSCANDO MOVIMENTAÇÕES no SQLite');
        print('🔍 Mês: $mesAtual, Ano: $anoSelecionado');
      }

    // Busca somente movimentações do usuário atual
    List<Map<String, dynamic>> movimentacao;
    try {
      movimentacao = await CommandSql(db)
          .select('movimentacao', where: 'IdUsuario = ?', whereArgs: [userId]);
    } on DatabaseException catch (e) {
      if (e.isDatabaseClosedError()) {
        if (kDebugMode) {
          print('⚠️ DB fechado ao consultar. Reabrindo e tentando novamente...');
        }
        final reopened = await DB.instance.database;
        movimentacao = await CommandSql(reopened)
            .select('movimentacao', where: 'IdUsuario = ?', whereArgs: [userId]);
      } else {
        rethrow;
      }
    }

      if (kDebugMode) {
        print('🔍 Total de movimentações no SQLite: ${movimentacao.length}');
        for (var mov in movimentacao) {
          final dataMovimentacao = DateTime.fromMillisecondsSinceEpoch(
            mov['DataMovimentacao'],
          );
          print(
            '   - ${mov['Nome']}: R\$ ${mov['Valor']} em ${dataMovimentacao.day}/${dataMovimentacao.month}/${dataMovimentacao.year}',
          );
        }
      }

      final result =
          movimentacao.where((e) {
            final dataMovimentacao = DateTime.fromMillisecondsSinceEpoch(
              e['DataMovimentacao'],
            );
            return dataMovimentacao.month == mesAtual &&
                dataMovimentacao.year == anoSelecionado;
          }).toList();

      if (kDebugMode) {
        print('🔍 Movimentações filtradas por mês/ano: ${result.length}');
      }

  return result.map((e) => MovimentacaoModel.fromMap(e, sqlLite: true)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao buscar movimentações: $e');
      }
      return [];
    }
  }

  @override
  Future<double> setSaldo(double value, bool removendo) async {
    try {
      var saldoAtual = await _localStorage.read<String>('saldo');
      double? saldoDouble = double.tryParse(saldoAtual ?? '0');
      if (removendo) {
        saldoDouble = (saldoDouble ?? 0) - value;
        await _localStorage.write('saldo', saldoDouble.toString());
        return saldoDouble;
      } else {
        saldoDouble = (saldoDouble ?? 0) + value;
        await _localStorage.write('saldo', saldoDouble.toString());
        return saldoDouble;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return 0.0;
    }
  }

  @override
  Future<bool> calcularSaldoTotal() async {
    try {
      if (await _primeiroAcesso()) {
        final db = await DB.instance.database;
        final query = CommandSql(db);
        var saldo = await query.rawQuery(
          'SELECT SUM(valor) as saldo FROM movimentacao',
        );
        if (saldo.isNotEmpty) {
          await _localStorage.write('saldo', saldo.first['saldo'].toString());
          return true;
        } else {
          return false;
        }
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    }
  }

  Future<bool> _primeiroAcesso() async {
    return await _localStorage.isFirstAccess();
  }

  @override
  Future<List<CategoriaModel>> getCategorias() async {
    try {
      final db = await DB.instance.database;
      final categorias = await CommandSql(db).select('categoria');

      final result =
          categorias
              .map((e) => CategoriaModel.fromMap(e, sqlLite: true))
              .toList();

      // Se não há categorias locais, avisa que são gerenciadas apenas localmente
      if (result.isEmpty) {
        if (kDebugMode) {
          print(
            'ℹ️ Nenhuma categoria encontrada. Categorias são gerenciadas apenas localmente.',
          );
        }
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao buscar categorias: $e');
      }
      return [];
    }
  }

  @override
  Future<bool> inserirCategoria(CategoriaModel categoria) async {
    try {
      final db = await DB.instance.database;
      final query = CommandSql(db);

      await query.insert('categoria', categoria.toMap());

      if (kDebugMode) {
        print('✅ Categoria salva no SQLite local: ${categoria.nome}');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao inserir categoria: $e');
      }
      return false;
    }
  }

  @override
  Future<bool> atualizarCategoria(CategoriaModel categoria) async {
    try {
      final db = await DB.instance.database;
      final query = CommandSql(db);

      await query.update(
        'categoria',
        categoria.toMap(),
        where: 'Id = ?',
        whereArgs: [categoria.id],
      );

      if (kDebugMode) {
        print('✅ Categoria atualizada no SQLite local: ${categoria.nome}');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao atualizar categoria: $e');
      }
      return false;
    }
  }

  @override
  Future<bool> removerCategoria(int id) async {
    try {
      final db = await DB.instance.database;
      final query = CommandSql(db);

      // Verificar se existem transações usando esta categoria
      final movimentacoes = await query.rawQuery(
        'SELECT COUNT(*) as count FROM movimentacao WHERE IdCategoria = ?',
        [id],
      );
      final count = movimentacoes.first['count'] as int;

      if (count > 0) {
        if (kDebugMode) {
          print(
            '❌ Não é possível remover categoria: existem $count transações associadas',
          );
        }
        return false;
      }

      await query.delete('categoria', where: 'Id = ?', whereArgs: [id]);

      if (kDebugMode) {
        print('✅ Categoria removida do SQLite local');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao remover categoria: $e');
      }
      return false;
    }
  }

  /// ❌ Categorias não são mais sincronizadas com Firebase
  @override
  Future<void> syncCategoriasToFirebase() async {
    if (kDebugMode) {
      print('ℹ️ Categorias são gerenciadas apenas localmente (SQLite)');
    }
  }

  /// ✅ Sincroniza apenas transações com Firebase
  @override
  Future<void> syncMovimentacoesToFirebase() async {
    // Desativado: mantém apenas operações locais
    if (kDebugMode) {
      print('ℹ️ Sincronização de movimentações desativada');
    }
  }
}
