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

  /// Calcula o saldo exibido para um mês específico
  /// 
  /// Fórmula: saldoExibido = saldoAcumuladoAteMesAnterior + somaTransacoesDoMes
  Future<double> calculaSaldoExibido(DateTime mesSelecionado) async {
    try {
      // 1. Obtém o saldo acumulado até o mês anterior
      final saldoAnterior  = await _getSaldoAcumuladoAteMes(
        DateTime(mesSelecionado.year, mesSelecionado.month - 1),
      );
      
      // 2. Soma as transações do mês selecionado
      final transacoesDoMes = await _getTransacoesDoMes(mesSelecionado);
      final totalMes = transacoesDoMes.fold(0.0, (total, t) => total + t.valor);
      
      // 3. Calcula o saldo final
      final saldoFinal = saldoAnterior + totalMes;
      
      // 4. Atualiza o cache para o mês atual
      await _updateCacheMensal(mesSelecionado, saldoFinal);
      
      if (kDebugMode) {
        print('💰 Saldo calculado para ${mesSelecionado.month}/${mesSelecionado.year}:');
        print('   Saldo anterior: R\$ ${saldoAnterior.toStringAsFixed(2)}');
        print('   Total do mês: R\$ ${totalMes.toStringAsFixed(2)}');
        print('   Saldo final: R\$ ${saldoFinal.toStringAsFixed(2)}');
      }
      
      return saldoFinal;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao calcular saldo: $e');
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

  /// Obtém o saldo acumulado até um mês específico
  Future<double> _getSaldoAcumuladoAteMes(DateTime mes) async {
    final prefs = await SharedPreferences.getInstance();
    final chaveCache = _getChaveCache(mes);
    
    // Verifica se existe no cache
    final saldoCache = prefs.getDouble(chaveCache);
    if (saldoCache != null) {
      return saldoCache;
    }
    
    // Se não existe no cache, recalcula desde o início
    return await _recalcularSaldoAcumulado(mes);
  }

  /// Recalcula o saldo acumulado desde o início até um mês específico
  Future<double> _recalcularSaldoAcumulado(DateTime mesLimite) async {
    try {
      final userId = _authService.userId;
      if (userId == null) return 0.0;
      
      // Obtém todas as transações do mês especificado
      final transacoesMes = await _homeRepository.getMovimentacoes(mesLimite.month, mesLimite.year);
      
      double saldoAcumulado = 0.0;
      final prefs = await SharedPreferences.getInstance();
      
      // Calcula o saldo do mês especificado
      for (final transacao in transacoesMes) {
        if (transacao.dataMovimentacao.year == mesLimite.year &&
            transacao.dataMovimentacao.month == mesLimite.month) {
          saldoAcumulado += transacao.valor;
        }
      }
      
      // Salva no cache
      final chave = _getChaveCache(mesLimite);
      await prefs.setDouble(chave, saldoAcumulado);
      
      if (kDebugMode) {
        print('🔄 Recalculado saldo acumulado para ${mesLimite.month}/${mesLimite.year}: R\$ ${saldoAcumulado.toStringAsFixed(2)}');
      }
      
      return saldoAcumulado;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao recalcular saldo acumulado: $e');
      }
      return 0.0;
    }
  }

  /// Obtém as transações de um mês específico
  Future<List<MovimentacaoModel>> _getTransacoesDoMes(DateTime mes) async {
    final userId = _authService.userId;
    if (userId == null) return [];
    
    // Usa o método disponível no repository com ano
    final todasTransacoes = await _homeRepository.getMovimentacoes(mes.month, mes.year);
    
    // Filtra apenas as transações do mês/ano especificado
    return todasTransacoes.where((transacao) {
      return transacao.dataMovimentacao.year == mes.year &&
             transacao.dataMovimentacao.month == mes.month;
    }).toList();
  }

  /// Atualiza o cache mensal
  Future<void> _updateCacheMensal(DateTime mes, double saldo) async {
    final prefs = await SharedPreferences.getInstance();
  final chave = _getChaveCache(mes);
    await prefs.setDouble(chave, saldo);
  }

  /// Gera a chave do cache para um mês específico
  String _getChaveCache(DateTime mes) {
  final uid = _authService.userId ?? 'anon';
  final ym = '${mes.year}-${mes.month.toString().padLeft(2, '0')}';
  return '${uid}_$ym';
  }

  /// Recalcula o cache a partir de um mês específico
  /// 
  /// Usado quando uma transação é inserida, editada ou excluída
  Future<void> recalcularCacheAPartirDe(DateTime mesAlterado) async {
    try {
      final agora = DateTime.now();
      final mesInicial = DateTime(mesAlterado.year, mesAlterado.month);
      final mesFinal = DateTime(agora.year, agora.month);
      
      // Limpa o cache dos meses afetados
      await _limparCacheAPartirDe(mesInicial);
      
      // Recalcula desde o mês alterado até o atual
      for (int mes = mesInicial.month; mes <= mesFinal.month; mes++) {
        await calculaSaldoExibido(DateTime(mesInicial.year, mes));
      }
      
      if (kDebugMode) {
        print('🔄 Cache recalculado de ${mesAlterado.month}/${mesAlterado.year} até ${agora.month}/${agora.year}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao recalcular cache: $e');
      }
    }
  }

  /// Limpa o cache a partir de um mês específico
  Future<void> _limparCacheAPartirDe(DateTime mesInicial) async {
    final prefs = await SharedPreferences.getInstance();
  final uid = _authService.userId;
  final keys = prefs
    .getKeys()
    .where((key) => key.contains('-') && (uid == null || key.startsWith('${uid}_')));
    
    for (final key in keys) {
      try {
  final keyPart = uid != null ? key.replaceFirst('${uid}_', '') : key;
  final parts = keyPart.split('-');
  if (parts.length != 2) continue;
  final ano = int.parse(parts[0]);
  final mes = int.parse(parts[1]);
        final dataCache = DateTime(ano, mes);
        
        if (dataCache.isAfter(mesInicial) || dataCache.isAtSameMomentAs(mesInicial)) {
          await prefs.remove(key);
        }
      } catch (e) {
        // Ignora chaves inválidas
      }
    }
  }

  /// Limpa todo o cache de saldos
  Future<void> limparTodoCache() async {
    final prefs = await SharedPreferences.getInstance();
  final uid = _authService.userId;
  final keys = prefs
    .getKeys()
    .where((key) => key.contains('-') && (uid == null || key.startsWith('${uid}_')));
    
    for (final key in keys) {
      await prefs.remove(key);
    }
    
    if (kDebugMode) {
      print('🧹 Cache de saldos limpo');
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
