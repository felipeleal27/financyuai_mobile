import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:neo_financyuai/app/data/model/movimentacao_model.dart';
import 'package:neo_financyuai/app/database/sqllite/db.dart';
import 'package:neo_financyuai/app/database/sqllite/sql_lite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neo_financyuai/app/service/connectivity_service.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:neo_financyuai/app/service/auth_service.dart';

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
  final _connectivity = ConnectivityService();
  StreamSubscription<bool>? _connSub;
  StreamSubscription? _authSub;

  /// Inicializa o serviço de sincronização
  Future<void> initialize() async {
    if (kDebugMode) {
      print('✅ Sincronização habilitada - Firebase + SQLite');
    }
    // Monitora conectividade para tentar drenar a fila quando voltar a internet
    try {
      _connectivity.startMonitoring();
      _connSub = _connectivity.connectivityStream.listen((online) async {
        if (online) {
          final uid = AuthService().userId;
          if (uid != null) {
            if (kDebugMode) print('🌐 Online: processando fila pendente...');
            await processQueue(uid);
          }
        }
      });
    } catch (e) {
      if (kDebugMode) print('⚠️ Falha ao iniciar monitoramento de conectividade: $e');
    }

    // Ao logar (ou app abrir com usuário já autenticado), sincroniza base
    try {
      _authSub = AuthService().authStateChanges.listen((user) async {
        final uid = user?.uid;
        if (uid != null) {
          if (kDebugMode) print('👤 Login detectado: iniciando syncOnLogin');
          await syncOnLogin(uid);
          await processQueue(uid);
        }
      });
    } catch (e) {
      if (kDebugMode) print('⚠️ Falha ao escutar authStateChanges: $e');
    }
  }

  /// Habilita persistência offline do Firestore
  // Removido: funcionalidades de persistência remota do Firestore

  /// Monitora mudanças na conectividade
  // (não implementado nesta versão)

  /// ✅ Adiciona uma transação (sempre salva local e enfileira sync)
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
    // 2) Enfileira operação para sincronizar
    await _enqueueUpsert('movimentacao', toInsert.id!, userId, _toFirebaseMap(toInsert));
    // 3) Tenta processar fila se houver internet
    await _tryProcessQueueIfOnline(userId);
  }

  /// ✅ Atualiza uma transação (sempre local + fila de sync)
  Future<void> updateMovimentacao(MovimentacaoModel movimentacao, String userId) async {
    // 1) Atualiza no SQLite
    await _updateInSQLite(movimentacao);
    // 2) Enfileira operação para sincronizar
    await _enqueueUpsert('movimentacao', movimentacao.id!, userId, _toFirebaseMap(movimentacao));
    await _tryProcessQueueIfOnline(userId);
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

  /// ✅ Remove uma transação (sempre local + fila de sync)
  Future<void> removeMovimentacao(String movimentacaoId, String userId) async {
    // 1) Remove do SQLite
    await _removeFromSQLite(movimentacaoId);
    
    if (kDebugMode) {
      print('✅ Transação removida do SQLite');
    }
    // 2) Enfileira remoção no Firebase
    await _enqueueDelete('movimentacao', movimentacaoId, userId);
    await _tryProcessQueueIfOnline(userId);
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
        await _enqueueUpsert('movimentacao', id, userId, {
          'Id': e['Id'],
          'Nome': e['Nome'],
          'Valor': e['Valor'],
          'IdCategoria': e['IdCategoria'],
          'IsSaida': (e['IsSaida'] == 1),
          'DataMovimentacao': e['DataMovimentacao'],
          'Descricao': e['Descricao'],
          'IdUsuario': e['IdUsuario'],
        });
      }
      await processQueue(userId);
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
    await processQueue(userId);
    await syncOnLogin(userId);
  }

  /// Dispose dos recursos
  void dispose() {
    _connSub?.cancel();
    _authSub?.cancel();
  }

  // =========================
  // Implementação da fila
  // =========================

  Map<String, dynamic> _toFirebaseMap(MovimentacaoModel m) => {
        'Id': m.id,
        'Nome': m.nome,
        'Valor': m.valor,
        'IdCategoria': m.idCategoria,
        'IsSaida': m.isSaida,
        'DataMovimentacao': m.dataMovimentacao.millisecondsSinceEpoch,
        'Descricao': m.descricao,
        'IdUsuario': m.idUsuario,
      };

  Future<void> _enqueueUpsert(String entity, String entityId, String userId, Map<String, dynamic> payload) async {
    final db = await DB.instance.database;
    await db.insert('sync_queue', {
      'UserId': userId,
      'Op': 'upsert',
      'Entity': entity,
      'EntityId': entityId,
      'Payload': jsonEncode(payload),
      'RetryCount': 0,
      'LastAttempt': null,
      'CreatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> _enqueueDelete(String entity, String entityId, String userId) async {
    final db = await DB.instance.database;
    await db.insert('sync_queue', {
      'UserId': userId,
      'Op': 'delete',
      'Entity': entity,
      'EntityId': entityId,
      'Payload': null,
      'RetryCount': 0,
      'LastAttempt': null,
      'CreatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> _tryProcessQueueIfOnline(String userId) async {
    final online = await _connectivity.hasInternetConnection();
    if (online) {
      await processQueue(userId);
    }
  }

  /// Processa a fila de sincronização (best-effort, com backoff simples)
  Future<void> processQueue(String userId) async {
    final db = await DB.instance.database;
    // Busca até 100 pendências por rodada
    final rows = await CommandSql(db).rawQuery(
      'SELECT * FROM sync_queue WHERE UserId = ? ORDER BY Id LIMIT 100',
      [userId],
    );
    for (final r in rows) {
      final id = r['Id'] as int;
      final op = r['Op'] as String;
      final entity = r['Entity'] as String;
      final entityId = r['EntityId'] as String;
      final payloadStr = r['Payload'] as String?;
      try {
        if (entity == 'movimentacao') {
          if (op == 'upsert') {
            final payload = payloadStr != null ? jsonDecode(payloadStr) as Map<String, dynamic> : <String, dynamic>{};
            await _firestore
                .collection('users')
                .doc(userId)
                .collection('transacoes')
                .doc(entityId)
                .set({
              ...payload,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          } else if (op == 'delete') {
            await _firestore
                .collection('users')
                .doc(userId)
                .collection('transacoes')
                .doc(entityId)
                .delete();
          }
        }
        // Sucesso: remove da fila
        await db.delete('sync_queue', where: 'Id = ?', whereArgs: [id]);
      } catch (e) {
        // Falha: atualiza RetryCount/LastAttempt e segue para próxima
        final retry = (r['RetryCount'] as int? ?? 0) + 1;
        await db.update(
          'sync_queue',
          {
            'RetryCount': retry,
            'LastAttempt': DateTime.now().millisecondsSinceEpoch,
          },
          where: 'Id = ?',
          whereArgs: [id],
        );
        if (kDebugMode) {
          print('⚠️ Falha ao processar item da fila (id=$id op=$op): $e');
        }
      }
    }
  }
}
