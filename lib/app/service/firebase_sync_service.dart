import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:neo_financyuai/app/data/model/movimentacao_model.dart';
import 'package:neo_financyuai/app/database/sqllite/db.dart';
import 'package:neo_financyuai/app/service/saldo_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Connectivity _connectivity = Connectivity();
  
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  Timer? _syncTimer;
  
  // Fila de operações pendentes
  final List<Map<String, dynamic>> _pendingOperations = [];
  
  /// Inicializa o serviço de sincronização
  Future<void> initialize() async {
    await _enableOfflinePersistence();
    _startConnectivityListener();
    _startPeriodicSync();
    
    if (kDebugMode) {
      print('🔥 Firebase Sync Service inicializado (apenas transações)');
    }
  }

  /// Habilita persistência offline do Firestore
  Future<void> _enableOfflinePersistence() async {
    try {
      await _firestore.enablePersistence(
        const PersistenceSettings(synchronizeTabs: true),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Persistência offline já habilitada ou não suportada: $e');
      }
    }
  }

  /// Monitora mudanças na conectividade
  void _startConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        final isConnected = results.any((result) => 
          result == ConnectivityResult.mobile || 
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet);
        
        if (isConnected) {
          _onConnectivityRestored();
        }
      },
    );
  }

  /// Quando a conectividade for restaurada
  void _onConnectivityRestored() {
    if (kDebugMode) {
      print('🌐 Conectividade restaurada - iniciando sincronização');
    }
    
    // Sincroniza operações pendentes
    _syncPendingOperations();
    
    // Força sincronização do Firestore
    _firestore.enableNetwork();
  }

  /// Inicia sincronização periódica (a cada 30 segundos quando conectado)
  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _syncPendingOperations();
    });
  }

  /// ✅ Adiciona uma transação (SQLite + Firebase)
  Future<void> addMovimentacao(MovimentacaoModel movimentacao, String userId) async {
    // 1. SEMPRE salva no SQLite primeiro (funciona offline)
    // Garante que a movimentação tenha o IdUsuario correto no mapa
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
    
    if (kDebugMode) {
      print('✅ Transação salva no SQLite');
    }
    
    // 2. Verifica se está online e tenta sincronizar com Firebase
    try {
      if (await _isOnline()) {
        // Se online, envia direto para Firebase
  await _syncSingleTransactionToFirebase(toInsert, userId);
        
        if (kDebugMode) {
          print('✅ Transação sincronizada diretamente com Firebase');
        }
      } else {
        // Se offline, adiciona à fila para sincronizar depois
        _pendingOperations.add({
          'type': 'add_transacao',
          'data': _convertToFirebaseFormat(toInsert.toMap()),
          'userId': userId,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'localId': toInsert.id,
        });
        
        await _savePendingOperationsLocally();
        
        if (kDebugMode) {
          print('📝 Transação adicionada à fila (offline)');
        }
      }
    } catch (e) {
      // Se der erro (offline), adiciona à fila
      _pendingOperations.add({
        'type': 'add_transacao',
        'data': _convertToFirebaseFormat(toInsert.toMap()),
        'userId': userId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'localId': toInsert.id,
      });
      
      await _savePendingOperationsLocally();
      
      if (kDebugMode) {
        print('📝 Erro ao sincronizar - transação adicionada à fila: $e');
      }
    }
  }

  /// Sincroniza uma única transação para o Firebase
  Future<void> _syncSingleTransactionToFirebase(MovimentacaoModel movimentacao, String userId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('transacoes')
        .doc(movimentacao.id!) // Agora é String, não precisa de toString()
        .set(_convertToFirebaseFormat(movimentacao.toMap()));
  }

  /// Verifica se está online
  Future<bool> _isOnline() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult.any((result) => 
      result == ConnectivityResult.mobile || 
      result == ConnectivityResult.wifi ||
      result == ConnectivityResult.ethernet);
  }

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
  Map<String, dynamic> _convertToFirebaseFormat(Map<String, dynamic> sqliteData) {
    return {
      'id': sqliteData['Id'],
      'nome': sqliteData['Nome'],
      'descricao': sqliteData['Descricao'],
      'valor': sqliteData['Valor'],
      'dataMovimentacao': sqliteData['DataMovimentacao'] != null 
          ? Timestamp.fromDate(DateTime.fromMillisecondsSinceEpoch(sqliteData['DataMovimentacao'] as int))
          : Timestamp.now(),
      'isSaida': sqliteData['IsSaida'] == 1,
      'idCategoria': sqliteData['IdCategoria'],
      'idUsuario': sqliteData['IdUsuario'],
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    };
  }

  /// ✅ Remove uma transação (SQLite + Firebase)
  Future<void> removeMovimentacao(String movimentacaoId, String userId) async {
    // 1. SEMPRE remove do SQLite primeiro
    await _removeFromSQLite(movimentacaoId);
    
    if (kDebugMode) {
      print('✅ Transação removida do SQLite');
    }
    
    // 2. Verifica se está online e tenta remover do Firebase
    try {
      if (await _isOnline()) {
        // Se online, remove direto do Firebase
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('transacoes')
            .doc(movimentacaoId)
            .delete();
        
        if (kDebugMode) {
          print('✅ Transação removida diretamente do Firebase');
        }
      } else {
        // Se offline, adiciona à fila para remover depois
        _pendingOperations.add({
          'type': 'remove_transacao',
          'transacaoId': movimentacaoId,
          'userId': userId,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
        
        await _savePendingOperationsLocally();
        
        if (kDebugMode) {
          print('📝 Remoção adicionada à fila (offline)');
        }
      }
    } catch (e) {
      // Se der erro (offline), adiciona à fila
      _pendingOperations.add({
        'type': 'remove_transacao',
        'transacaoId': movimentacaoId,
        'userId': userId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      
      await _savePendingOperationsLocally();
      
      if (kDebugMode) {
        print('📝 Erro ao remover - operação adicionada à fila: $e');
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

  /// ✅ Sincroniza operações pendentes quando conexão for restaurada
  Future<void> _syncPendingOperations() async {
    if (_pendingOperations.isEmpty) return;

    final operationsToSync = List<Map<String, dynamic>>.from(_pendingOperations);
    _pendingOperations.clear();

    for (final operation in operationsToSync) {
      try {
        switch (operation['type']) {
          case 'add_transacao':
            await _firestore
                .collection('users')
                .doc(operation['userId'])
                .collection('transacoes')
                .doc(operation['localId']) // Agora é String, não precisa de toString()
                .set(operation['data']);
            break;
          case 'remove_transacao':
            await _firestore
                .collection('users')
                .doc(operation['userId'])
                .collection('transacoes')
                .doc(operation['transacaoId'])
                .delete();
            break;
        }
        
        if (kDebugMode) {
          print('✅ Operação sincronizada: ${operation['type']}');
        }
      } catch (e) {
        // Se falhar novamente, recoloca na fila
        _pendingOperations.add(operation);
        if (kDebugMode) {
          print('❌ Erro ao sincronizar ${operation['type']}: $e');
        }
      }
    }

    await _savePendingOperationsLocally();
  }

  /// Salva operações pendentes localmente
  Future<void> _savePendingOperationsLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final operationsJson = _pendingOperations
        .map((op) => op.toString())
        .toList();
    await prefs.setStringList('pending_operations', operationsJson);
  }

  /// ✅ Stream de transações em tempo real
  Stream<List<MovimentacaoModel>> getTransacoesStream(String userId) {
    if (kDebugMode) {
      print('🔄 Criando stream Firebase para userId: $userId');
      print('🔄 Collection path: users/$userId/transacoes');
    }
    
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('transacoes')
        .orderBy('dataMovimentacao', descending: true)
        .snapshots()
        .map((snapshot) {
      if (kDebugMode) {
        print('📡 Stream Firebase: ${snapshot.docs.length} documentos recebidos');
        for (var doc in snapshot.docs) {
          print('   Doc ID: ${doc.id}');
          print('   Data: ${doc.data()}');
        }
      }
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        
        // Converte Timestamp do Firebase para o formato esperado
        DateTime dataMovimentacao = DateTime.now();
        if (data['dataMovimentacao'] is Timestamp) {
          dataMovimentacao = (data['dataMovimentacao'] as Timestamp).toDate();
        }
        
        // Mapeia os campos do Firebase para o formato SQLite
        return MovimentacaoModel.fromMap({
          'Id': data['id'],
          'Nome': data['nome'] ?? '',
          'Descricao': data['descricao'] ?? '',
          'Valor': data['valor'] ?? 0.0,
          'DataMovimentacao': dataMovimentacao.toIso8601String(),
          'IsSaida': data['isSaida'] ?? false,
          'IdCategoria': data['idCategoria'] ?? 1,
          'IdUsuario': data['idUsuario'] ?? '',
        });
      }).toList();
    });
  }

  /// ✅ Sincroniza transações SQLite → Firebase (quando voltar online)
  Future<void> syncTransacoesToFirebase(String userId) async {
    try {
      final db = await DB.instance.database;
      final List<Map<String, dynamic>> localTransacoes =
          await db.query('movimentacao', where: 'IdUsuario = ?', whereArgs: [userId]);
      
      for (final transacao in localTransacoes) {
        // Garante que o idUsuario esteja correto ao subir para o Firebase
        transacao['IdUsuario'] = userId;
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('transacoes')
            .doc(transacao['Id']) // Agora é String, não precisa de toString()
            .set(_convertToFirebaseFormat(transacao), SetOptions(merge: true));
      }
      
      if (kDebugMode) {
        print('🔄 Sincronização transações SQLite → Firebase: ${localTransacoes.length} itens');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro na sincronização de transações: $e');
      }
    }
  }

  /// ✅ Sincronização completa: Firebase → SQLite (para novos dispositivos)
  Future<void> syncFirebaseToSQLite(String userId) async {
    try {
      if (kDebugMode) {
        print('🔄 Iniciando sincronização Firebase → SQLite para usuário: $userId');
      }

      // 1. Busca todas as transações do Firebase
      final firebaseSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('transacoes')
          .orderBy('dataMovimentacao', descending: true)
          .get();

      if (firebaseSnapshot.docs.isEmpty) {
        if (kDebugMode) {
          print('📭 Nenhuma transação encontrada no Firebase');
        }
        return;
      }

      // 2. Converte para MovimentacaoModel
      final transacoesFirebase = firebaseSnapshot.docs.map((doc) {
        final data = doc.data();
        
        DateTime dataMovimentacao = DateTime.now();
        if (data['dataMovimentacao'] is Timestamp) {
          dataMovimentacao = (data['dataMovimentacao'] as Timestamp).toDate();
        }

        return MovimentacaoModel(
          id: data['id'] as String?,
          nome: data['nome'] ?? '',
          valor: (data['valor'] ?? 0.0).toDouble(),
          idCategoria: data['idCategoria'] ?? 1,
          isSaida: data['isSaida'] ?? false,
          dataMovimentacao: dataMovimentacao,
          descricao: data['descricao'] ?? '',
          idUsuario: userId,
        );
      }).toList();

      // 3. Limpa SQLite antes de inserir (opcional, para sincronização limpa)
      final db = await DB.instance.database;
      await db.delete('movimentacao', where: 'IdUsuario = ?', whereArgs: [userId]);

      // 4. Insere todas as transações no SQLite
      for (final transacao in transacoesFirebase) {
        await db.insert('movimentacao', transacao.toMap());
      }

      // 5. Recalcula todos os saldos após a sincronização
      await SaldoService().recalcularTodosOsSaldos();

      if (kDebugMode) {
        print('✅ ${transacoesFirebase.length} transações sincronizadas Firebase → SQLite');
      }

    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro na sincronização Firebase → SQLite: $e');
      }
    }
  }

  /// ✅ Sincronização inteligente ao fazer login
  Future<void> syncOnLogin(String userId) async {
    try {
      if (kDebugMode) {
        print('🔑 Sincronização pós-login para usuário: $userId');
      }

      // 1. Verifica quantas transações existem no SQLite para este usuário
      final db = await DB.instance.database;
      final localCount = await db.rawQuery(
        'SELECT COUNT(*) as count FROM movimentacao WHERE IdUsuario = ?', 
        [userId]
      );
      
      final localTransactions = (localCount.first['count'] as int? ?? 0);

      // 2. Verifica quantas transações existem no Firebase
      final firebaseSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('transacoes')
          .get();
      
      final firebaseTransactions = firebaseSnapshot.docs.length;

      if (kDebugMode) {
        print('📊 Transações locais: $localTransactions');
        print('📊 Transações Firebase: $firebaseTransactions');
      }

      // 3. Se SQLite está vazio ou Firebase tem mais dados, sincroniza
      if (localTransactions == 0 || firebaseTransactions > localTransactions) {
        await syncFirebaseToSQLite(userId);
      } 
      // 4. Se SQLite tem dados que Firebase não tem, sincroniza para Firebase
      else if (localTransactions > firebaseTransactions) {
        await syncTransacoesToFirebase(userId);
      }

      if (kDebugMode) {
        print('✅ Sincronização pós-login concluída');
      }

    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro na sincronização pós-login: $e');
      }
    }
  }

  /// Verifica se está online
  Future<bool> isOnline() async {
    final connectivityResults = await _connectivity.checkConnectivity();
    return connectivityResults.any((result) => 
      result == ConnectivityResult.mobile || 
      result == ConnectivityResult.wifi ||
      result == ConnectivityResult.ethernet);
  }

  /// Força sincronização manual
  Future<void> forcSync() async {
    await _syncPendingOperations();
    if (kDebugMode) {
      print('🔄 Sincronização manual de transações executada');
    }
  }

  /// Dispose dos recursos
  void dispose() {
    _connectivitySubscription.cancel();
    _syncTimer?.cancel();
  }
}
