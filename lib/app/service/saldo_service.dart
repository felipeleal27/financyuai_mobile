import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:neo_financyuai/app/data/model/movimentacao_model.dart';
import 'package:neo_financyuai/app/repository/home_repository/home_repository.dart';
import 'package:neo_financyuai/app/service/auth_service.dart';

/// Serviço responsável pelo cálculo e cache de saldos mensais
/// 
/// Implementa a lógica de cálculo acumulativo de saldos por mês
/// e cache local para otimizar performance.
class SaldoService {
  static final SaldoService _instance = SaldoService._internal();
  
  /// Retorna a instância singleton do serviço
  factory SaldoService() => _instance;
  
  SaldoService._internal();

  late final HomeRepository _homeRepository;
  late final AuthService _authService;
  
  /// Inicializa o serviço com as dependências necessárias
  void initialize({
    required HomeRepository homeRepository,
    required AuthService authService,
  }) {
    _homeRepository = homeRepository;
    _authService = authService;
  }

  /// Calcula o saldo acumulado (previsto) até o fim do mês selecionado.
  /// Soma todas as transações com data <= último dia do mês.
  Future<double> calculaSaldoExibido(DateTime mesSelecionado) async {
    try {
      final uid = await _getUidWithFallback();
      if (uid == null) {
        if (kDebugMode) print('⚠️ Sem UID (nem fallback) para calcular saldo');
        return 0.0;
      }
      final mesNormalizado = DateTime(mesSelecionado.year, mesSelecionado.month, 1);
      return await _getSaldoAcumuladoAteMes(mesNormalizado, uid);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao calcular saldo acumulativo: $e');
      }
      return 0.0;
    }
  }

  /// Limpa o cache de saldo (forçar recálculo)
  Future<void> limparCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith('saldo_'));
      for (final key in keys) {
        await prefs.remove(key);
      }
      
      if (kDebugMode) {
        print('🗑️ Cache de saldo limpo');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao limpar cache: $e');
      }
    }
  }

  /// Obtém (ou calcula) o saldo acumulado até o fim do mês (inclusive)
  Future<double> _getSaldoAcumuladoAteMes(DateTime mes, String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final chaveCache = _getChaveCache(mes, uid);
    final cache = prefs.getDouble(chaveCache);
    if (cache != null) return cache;
    return await _recalcularSaldoAcumulado(mes, uid);
  }

  /// Recalcula o saldo acumulado desde o início até um mês específico
  Future<double> _recalcularSaldoAcumulado(DateTime mesLimite, String uid) async {
    try {
      final todas = await _homeRepository.getMovimentacoesTodas();
      if (todas.isEmpty) return 0.0;
      final fimMes = DateTime(mesLimite.year, mesLimite.month + 1, 0, 23, 59, 59, 999);
      final acumulado = todas
          .where((t) => !t.dataMovimentacao.isAfter(fimMes))
          .fold<double>(0.0, (tot, t) => tot + t.valor);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_getChaveCache(mesLimite, uid), acumulado);
      if (kDebugMode) {
        print('💾 Cache saldo acumulado ${mesLimite.month}/${mesLimite.year} = ${acumulado.toStringAsFixed(2)}');
      }
      return acumulado;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao recalcular saldo acumulado: $e');
      }
      return 0.0;
    }
  }

  /// Obtém as transações de um mês específico
  Future<List<MovimentacaoModel>> _getTransacoesDoMes(DateTime mes) async {
    // Usa o método disponível no repository com ano
    final todasTransacoes = await _homeRepository.getMovimentacoes(mes.month, mes.year);
    
    // Filtra apenas as transações do mês/ano especificado
    return todasTransacoes.where((transacao) {
      return transacao.dataMovimentacao.year == mes.year &&
             transacao.dataMovimentacao.month == mes.month;
    }).toList();
  }

  // (removido) _updateCacheMensal não é mais necessário com a estratégia cumulativa

  /// Gera a chave do cache para um mês específico
  String _getChaveCache(DateTime mes, String uid) {
    final ym = '${mes.year}-${mes.month.toString().padLeft(2, '0')}';
    return 'saldo_${uid}_$ym';
  }

  /// Obtém UID atual ou o último UID persistido (para uso offline)
  Future<String?> _getUidWithFallback() async {
    final uid = _authService.userId;
    if (uid != null) return uid;
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('last_user_uid');
    } catch (_) {
      return null;
    }
  }

  /// Recalcula o cache a partir de um mês específico
  /// 
  /// Usado quando uma transação é inserida, editada ou excluída
  Future<void> recalcularCacheAPartirDe(DateTime mesAlterado) async {
    try {
      final inicio = DateTime(mesAlterado.year, mesAlterado.month, 1);
      final agora = DateTime.now();
      await _limparCacheAPartirDe(inicio);
      var cursor = inicio;
      while (!cursor.isAfter(DateTime(agora.year, agora.month, 1))) {
        await calculaSaldoExibido(cursor);
        cursor = DateTime(cursor.year, cursor.month + 1, 1);
      }
      if (kDebugMode) {
        print('🔄 Cache acumulado recalculado desde ${inicio.month}/${inicio.year} até ${agora.month}/${agora.year}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao recalcular cache acumulado: $e');
      }
    }
  }

  /// Limpa o cache a partir de um mês específico
  Future<void> _limparCacheAPartirDe(DateTime mesInicial) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = await _getUidWithFallback();
    if (uid == null) return; // sem UID não há cache válido para limpar
    final prefix = 'saldo_${uid}_';
    final keys = prefs.getKeys().where((key) => key.startsWith(prefix));

    for (final key in keys) {
      try {
        // Formato: 'saldo_${uid}_YYYY-MM'
        final ymPart = key.substring(prefix.length); // 'YYYY-MM'
        final parts = ymPart.split('-');
        if (parts.length != 2) continue;
        final ano = int.parse(parts[0]);
        final mes = int.parse(parts[1]);
        final dataCache = DateTime(ano, mes, 1);

        if (!dataCache.isBefore(mesInicial)) {
          await prefs.remove(key);
        }
      } catch (_) {
        // Ignora chaves fora do formato esperado
      }
    }
  }

  /// Limpa todo o cache de saldos
  Future<void> limparTodoCache() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = await _getUidWithFallback();
    if (uid == null) return;
    final prefix = 'saldo_${uid}_';
    final keys = prefs.getKeys().where((key) => key.startsWith(prefix));

    for (final key in keys) {
      await prefs.remove(key);
    }

    if (kDebugMode) {
      print('🧹 Cache de saldos limpo para uid=$uid');
    }
  }

  /// Obtém o saldo atual (mês atual)
  Future<double> getSaldoAtual() async {
    final agora = DateTime.now();
    return await calculaSaldoExibido(agora);
  }

  /// Obtém todos os saldos mensais do ano atual
  Future<Map<int, double>> getSaldosDoAno([int? ano]) async {
    final anoAtual = ano ?? DateTime.now().year;
    final Map<int, double> saldos = {};
    
    for (int mes = 1; mes <= 12; mes++) {
      final data = DateTime(anoAtual, mes);
      saldos[mes] = await calculaSaldoExibido(data);
    }
    
    return saldos;
  }

  /// Obtém estatísticas do mês
  Future<Map<String, double>> getEstatisticasDoMes(DateTime mes) async {
    final transacoes = await _getTransacoesDoMes(mes);
    
    double totalReceitas = 0.0;
    double totalDespesas = 0.0;
    
    for (final transacao in transacoes) {
      if (transacao.isSaida) {
        totalDespesas += transacao.valor.abs();
      } else {
        totalReceitas += transacao.valor.abs();
      }
    }
    
    return {
      'receitas': totalReceitas,
      'despesas': totalDespesas,
      'saldo': totalReceitas - totalDespesas,
      'quantidade': transacoes.length.toDouble(),
    };
  }

  /// Recalcula todos os saldos do usuário após sincronização
  Future<void> recalcularTodosOsSaldos() async {
    try {
      // await limparTodoCache();
      final agora = DateTime.now();
      // Recalcula saldo de todos os meses até o atual
      for (int ano = 2020; ano <= agora.year; ano++) {
        for (int mes = 1; mes <= 12; mes++) {
          // Só calcula até o mês atual do ano atual
          if (ano == agora.year && mes > agora.month) break;
          await calculaSaldoExibido(DateTime(ano, mes));
        }
      }
      if (kDebugMode) {
        print('🔄 Todos os saldos recalculados após sincronização!');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao recalcular todos os saldos: $e');
      }
    }
  }
}
