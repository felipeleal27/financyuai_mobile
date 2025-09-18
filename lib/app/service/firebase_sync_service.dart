import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:neo_financyuai/app/data/model/movimentacao_model.dart';
import 'package:neo_financyuai/app/database/sqllite/db.dart';
import 'package:neo_financyuai/app/database/sqllite/sql_lite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';

/// Serviço responsável pela sincronização entre SQLite local e Firebase
/// 
/// Implementa padrão Singleton e fornece:
/// - Sincronização automática online/offline
/// - Fila de operações pendentes
/// - Monitoramento de conectividade
/// - Stream de dados em tempo real
/// - Sincronização inteligente no login
class FirebaseSyncService {
  static final FirebaseSyncService _instance = FirebaseSyncService._internal();
  
  /// Retorna a instância singleton do serviço
  factory FirebaseSyncService() => _instance;
  
  FirebaseSyncService._internal();

  final _firestore = FirebaseFirestore.instance;

  /// Inicializa o serviço de sincronização
  Future<void> initialize() async {
    if (kDebugMode) {
      print('✅ Sincronização habilitada - Firebase + SQLite');
    }
  }

  /// Habilita persistência offline do Firestore
  // Removido: funcionalidades de persistência remota do Firestore

  /// Monitora mudanças na conectividade
  // (não implementado nesta versão)

  /// ✅ Adiciona uma transação (SQLite + Firebase)
  Future<void> addMovimentacao(MovimentacaoModel movimentacao, String userId) async {
    // 1) Salva no SQLite (offline-first)
    final toInsert = MovimentacaoModel(
      id: movimentacao.id,
      nome: movimentacao.nome,
      valor: movimentacao.valor,
      idCategoria: movimentacao.idCategoria,
      isSaida: movimentacao.isSaida,
      dataMovimentacao: movimentacao.dataMovimentacao,
      descricao: movimentacao.descricao,
      idUsuario: userId,
    );
    await _saveToSQLite(toInsert);

    // 2) Tenta espelhar no Firebase
    try {
    await _firestore
      .collection('users')
      .doc(userId)
      .collection('transacoes')
      .doc(toInsert.id)
      .set({
        'Id': toInsert.id,
        'Nome': toInsert.nome,
        'Valor': toInsert.valor,
        'IdCategoria': toInsert.idCategoria,
        'IsSaida': toInsert.isSaida,
        'DataMovimentacao': toInsert.dataMovimentacao.millisecondsSinceEpoch,
        'Descricao': toInsert.descricao,
        'IdUsuario': toInsert.idUsuario,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Falha ao espelhar no Firebase: $e');
      }
    }
  }

  /// ✅ Atualiza uma transação (SQLite + Firebase)
  Future<void> updateMovimentacao(MovimentacaoModel movimentacao, String userId) async {
    // 1) Atualiza no SQLite
    await _updateInSQLite(movimentacao);

    // 2) Espelha no Firebase
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('transacoes')
          .doc(movimentacao.id)
          .set({
        'Id': movimentacao.id,
        'Nome': movimentacao.nome,
        'Valor': movimentacao.valor,
        'IdCategoria': movimentacao.idCategoria,
        'IsSaida': movimentacao.isSaida,
        'DataMovimentacao': movimentacao.dataMovimentacao.millisecondsSinceEpoch,
        'Descricao': movimentacao.descricao,
        'IdUsuario': userId,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Falha ao atualizar no Firebase: $e');
      }
    }
  }

  /// Sincroniza uma única transação para o Firebase
  // Removido: envio pontual ao Firebase

  /// Verifica se está online
  // Removido: verificação real de conectividade

  /// Salva no SQLite local
  Future<void> _saveToSQLite(MovimentacaoModel movimentacao) async {
    try {
      final db = await DB.instance.database;
      await db.insert(
        'movimentacao',
        movimentacao.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } on DatabaseException catch (e) {
      if (e.isDatabaseClosedError()) {
        if (kDebugMode) {
          print('⚠️ DB fechado ao inserir. Reabrindo e tentando novamente...');
        }
        final db = await DB.instance.database; // getter reabre se preciso
        await db.insert(
          'movimentacao',
          movimentacao.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } else {
        rethrow;
      }
    }
  }

  /// ✅ Converte formato SQLite para Firebase (apenas transações)
  // Removido: conversão para formato Firebase

  /// ✅ Remove uma transação (SQLite + Firebase)
  Future<void> removeMovimentacao(String movimentacaoId, String userId) async {
    // 1) Remove do SQLite
    await _removeFromSQLite(movimentacaoId);
    
    if (kDebugMode) {
      print('✅ Transação removida do SQLite');
    }
    
    // 2) Remove do Firebase
    try {
    await _firestore
      .collection('users')
      .doc(userId)
      .collection('transacoes')
      .doc(movimentacaoId)
      .delete();
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Falha ao remover no Firebase: $e');
      }
    }
  }

  /// Remove do SQLite local
  Future<void> _removeFromSQLite(String movimentacaoId) async {
    try {
      final db = await DB.instance.database;
      await db.delete(
        'movimentacao',
        where: 'Id = ?',
        whereArgs: [movimentacaoId],
      );
    } on DatabaseException catch (e) {
      if (e.isDatabaseClosedError()) {
        if (kDebugMode) {
          print('⚠️ DB fechado ao remover. Reabrindo e tentando novamente...');
        }
        final db = await DB.instance.database;
        await db.delete(
          'movimentacao',
          where: 'Id = ?',
          whereArgs: [movimentacaoId],
        );
      } else {
        rethrow;
      }
    }
  }

  /// Atualiza no SQLite local
  Future<void> _updateInSQLite(MovimentacaoModel movimentacao) async {
    try {
      final db = await DB.instance.database;
      await db.update(
        'movimentacao',
        movimentacao.toMap(),
        where: 'Id = ?',
        whereArgs: [movimentacao.id],
      );
    } on DatabaseException catch (e) {
      if (e.isDatabaseClosedError()) {
        if (kDebugMode) {
          print('⚠️ DB fechado ao atualizar. Reabrindo e tentando novamente...');
        }
        final db = await DB.instance.database;
        await db.update(
          'movimentacao',
          movimentacao.toMap(),
          where: 'Id = ?',
          whereArgs: [movimentacao.id],
        );
      } else {
        rethrow;
      }
    }
  }

  /// ✅ Sincroniza operações pendentes quando conexão for restaurada
  // Removido: fila de operações pendentes

  /// Salva operações pendentes localmente
  // Removido: persistência local da fila

  /// ✅ Stream de transações em tempo real (Firebase)
  Stream<List<MovimentacaoModel>> getTransacoesStream(String userId) {
  return _firestore
    .collection('users')
    .doc(userId)
    .collection('transacoes')
    .orderBy('DataMovimentacao', descending: true)
    .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return MovimentacaoModel(
                id: data['Id'] as String?,
                nome: (data['Nome'] ?? '') as String,
                valor: (data['Valor'] as num).toDouble(),
                idCategoria: (data['IdCategoria'] as num).toInt(),
                isSaida: data['IsSaida'] as bool,
                dataMovimentacao: DateTime.fromMillisecondsSinceEpoch(
                  (data['DataMovimentacao'] as num).toInt(),
                ),
                descricao: (data['Descricao'] ?? '') as String,
                idUsuario: (data['IdUsuario'] ?? userId) as String,
              );
            }).toList());
  }

  /// ✅ Sincroniza transações SQLite → Firebase (quando voltar online)
  Future<void> syncTransacoesToFirebase(String userId) async {
    try {
      final db = await DB.instance.database;
      final rows = await CommandSql(db)
          .select('movimentacao', where: 'IdUsuario = ?', whereArgs: [userId]);
      for (final e in rows) {
        final id = e['Id'] as String?;
        if (id == null) continue;
    await _firestore
      .collection('users')
      .doc(userId)
      .collection('transacoes')
      .doc(id)
      .set({
          'Id': e['Id'],
          'Nome': e['Nome'],
          'Valor': e['Valor'],
          'IdCategoria': e['IdCategoria'],
          'IsSaida': (e['IsSaida'] == 1),
          'DataMovimentacao': e['DataMovimentacao'],
          'Descricao': e['Descricao'],
          'IdUsuario': e['IdUsuario'],
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ syncTransacoesToFirebase falhou: $e');
      }
    }
  }

  /// ✅ Sincronização completa: Firebase → SQLite (para novos dispositivos)
  Future<void> syncFirebaseToSQLite(String userId) async {
    try {
      final db = await DB.instance.database;
      final batch = db.batch();
    final qs = await _firestore
      .collection('users')
      .doc(userId)
      .collection('transacoes')
      .get();
      for (final doc in qs.docs) {
        final d = doc.data();
        final model = MovimentacaoModel(
          id: d['Id'] as String?,
          nome: (d['Nome'] ?? '') as String,
          valor: (d['Valor'] as num).toDouble(),
          idCategoria: (d['IdCategoria'] as num).toInt(),
          isSaida: d['IsSaida'] as bool,
          dataMovimentacao: DateTime.fromMillisecondsSinceEpoch(
            (d['DataMovimentacao'] as num).toInt(),
          ),
          descricao: (d['Descricao'] ?? '') as String,
          idUsuario: (d['IdUsuario'] ?? userId) as String,
        );
        batch.insert('movimentacao', model.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true);
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ syncFirebaseToSQLite falhou: $e');
      }
    }
  }

  /// ✅ Sincronização inteligente ao fazer login
  Future<void> syncOnLogin(String userId) async {
    // Estratégia simples: puxa tudo do Firebase para garantir base local,
    // depois sobe o que estiver local (merge com replace) — idempotente.
    await syncFirebaseToSQLite(userId);
    await syncTransacoesToFirebase(userId);
  }

  /// Verifica se está online
  Future<bool> isOnline() async {
    try {
      await _firestore.collection('health').limit(1).get(const GetOptions(source: Source.server));
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Força sincronização manual
  Future<void> forcSync(String userId) async {
    await syncOnLogin(userId);
  }

  /// Dispose dos recursos
  void dispose() {}
}
