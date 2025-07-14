import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Serviço para monitorar e verificar conectividade de rede
/// 
/// Fornece métodos para verificar se há conexão com internet
/// e notificar sobre mudanças de conectividade.
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<bool>? _connectivitySubscription;
  
  /// Stream que notifica sobre mudanças de conectividade
  Stream<bool> get connectivityStream => _connectivity.onConnectivityChanged
      .map((results) => _hasInternetConnection(results));

  /// Verifica se há conexão com internet
  Future<bool> hasInternetConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return _hasInternetConnection(results);
    } catch (e) {
      debugPrint('❌ Erro ao verificar conectividade: $e');
      return false;
    }
  }

  /// Verifica se os resultados de conectividade indicam internet
  bool _hasInternetConnection(List<ConnectivityResult> results) {
    return results.any((result) => 
        result == ConnectivityResult.wifi || 
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet);
  }

  /// Inicia o monitoramento de conectividade
  void startMonitoring() {
    _connectivitySubscription = connectivityStream.listen(
      (hasConnection) {
        debugPrint('📶 Conectividade alterada: ${hasConnection ? "Online" : "Offline"}');
      },
      onError: (error) {
        debugPrint('❌ Erro no monitoramento de conectividade: $error');
      },
    );
  }

  /// Para o monitoramento de conectividade
  void stopMonitoring() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  /// Aguarda até ter conexão com internet (com timeout)
  Future<bool> waitForConnection({Duration timeout = const Duration(seconds: 10)}) async {
    if (await hasInternetConnection()) {
      return true;
    }

    final completer = Completer<bool>();
    late StreamSubscription subscription;

    subscription = connectivityStream.listen((hasConnection) {
      if (hasConnection && !completer.isCompleted) {
        completer.complete(true);
        subscription.cancel();
      }
    });

    // Timeout
    Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.complete(false);
        subscription.cancel();
      }
    });

    return completer.future;
  }

  /// Retorna uma descrição amigável do status de conectividade
  Future<String> getConnectionDescription() async {
    try {
      final results = await _connectivity.checkConnectivity();
      
      if (results.isEmpty || results.contains(ConnectivityResult.none)) {
        return 'Sem conexão';
      }
      
      if (results.contains(ConnectivityResult.wifi)) {
        return 'Conectado via WiFi';
      }
      
      if (results.contains(ConnectivityResult.mobile)) {
        return 'Conectado via dados móveis';
      }
      
      if (results.contains(ConnectivityResult.ethernet)) {
        return 'Conectado via cabo';
      }
      
      return 'Conectado';
      
    } catch (e) {
      debugPrint('❌ Erro ao obter descrição de conectividade: $e');
      return 'Status desconhecido';
    }
  }

  void dispose() {
    stopMonitoring();
  }
}
