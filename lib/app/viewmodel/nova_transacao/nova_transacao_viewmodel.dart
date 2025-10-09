import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';
import 'package:neo_financyuai/app/data/model/movimentacao_model.dart';
import 'package:neo_financyuai/app/data/model/categoria_model.dart';
import 'package:neo_financyuai/app/repository/home_repository/home_repository.dart';
import 'package:neo_financyuai/app/service/firebase_sync_service.dart';
import 'package:neo_financyuai/app/service/auth_service.dart';
import 'package:uuid/uuid.dart';

part 'nova_transacao_viewmodel.g.dart';

/// ViewModel responsável pela lógica da nova transação
///
/// Gerencia:
/// - Estado do formulário de nova transação
/// - Validação de dados
/// - Salvamento da transação
/// - Sincronização com Firebase
class NovaTransacaoViewmodel = NovaTransacaoViewmodelBase with _$NovaTransacaoViewmodel;

/// Classe base do ViewModel da nova transação
abstract class NovaTransacaoViewmodelBase with Store {
  final HomeRepository _homeRepository;
  final FirebaseSyncService _syncService;
  final AuthService _authService;

  NovaTransacaoViewmodelBase({
    required HomeRepository homeRepository,
    required FirebaseSyncService syncService,
    required AuthService authService,
  }) : _homeRepository = homeRepository,
       _syncService = syncService,
       _authService = authService;

  @observable
  bool _carregandoCategorias = false;

  @observable
  bool _salvandoTransacao = false;

  @observable
  double _valor = 0.00;

  @observable
  CategoriaModel? _categoriaSelecionada;

  @observable
  DateTime _dataSelecionada = DateTime.now();

  @observable
  String _nomeMovimentacao = '';

  @observable
  String _descricao = '';

  @observable
  bool _isSaida = false;

  @observable
  ObservableList<CategoriaModel> _categorias = ObservableList<CategoriaModel>();

  // Propriedades para transações recorrentes
  @observable
  bool _isRecorrente = false;

  @observable
  String _tipoRecorrencia = 'unica';

  @observable
  String _periodoRecorrencia = 'mensal';

  @observable
  int _quantidadeParcelas = 1;

  @observable
  int _parcelaAtual = 1;

  @observable
  int _intervaloPersonalizado = 1;

  @observable
  String _unidadePersonalizada = 'dias';

  @observable
  int? _quantidadeRepeticoes;

  @observable
  String _tipoValorParcela = 'valor_parcela'; // 'valor_parcela' ou 'valor_total'

  // Edição
  @observable
  bool _isEdicao = false;

  @observable
  MovimentacaoModel? _movimentacaoOriginal;

  // Getters
  bool get carregandoCategorias => _carregandoCategorias;
  bool get salvandoTransacao => _salvandoTransacao;
  List<CategoriaModel> get categorias => _categorias;
  double get valor => _valor;
  DateTime get dataSelecionada => _dataSelecionada;
  CategoriaModel? get categoriaSelecionada => _categoriaSelecionada;
  String get nomeMovimentacao => _nomeMovimentacao;
  String get descricao => _descricao;
  bool get isSaida => _isSaida;
  
  // Getters para transações recorrentes
  bool get isRecorrente => _isRecorrente;
  String get tipoRecorrencia => _tipoRecorrencia;
  String get periodoRecorrencia => _periodoRecorrencia;
  int get quantidadeParcelas => _quantidadeParcelas;
  int get parcelaAtual => _parcelaAtual;
  int get intervaloPersonalizado => _intervaloPersonalizado;
  String get unidadePersonalizada => _unidadePersonalizada;
  int? get quantidadeRepeticoes => _quantidadeRepeticoes;
  String get tipoValorParcela => _tipoValorParcela;
  bool get isEdicao => _isEdicao;
  MovimentacaoModel? get movimentacaoOriginal => _movimentacaoOriginal;

  /// Verifica se os campos básicos obrigatórios estão preenchidos
  bool get camposBasicosPreenchidos => 
      _nomeMovimentacao.isNotEmpty && _valor > 0;

  /// Gera exemplo dinâmico para valor de cada parcela
  String get exemploValorParcela {
    final valor = _valor > 0 ? _valor : 1000; // Valor padrão para exemplo
    final parcelas = _quantidadeParcelas > 1 ? _quantidadeParcelas : 12; // Usa 12 se ainda for 1
    return 'Ex: R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')} é o valor da parcela = $parcelas parcelas de R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Gera exemplo dinâmico para valor total a dividir
  String get exemploValorTotal {
    final valor = _valor > 0 ? _valor : 1000; // Valor padrão para exemplo
    final parcelas = _quantidadeParcelas > 1 ? _quantidadeParcelas : 12; // Usa 12 se ainda for 1
    final valorParcela = valor / parcelas;
    return 'Ex: R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')} em ${parcelas}x = $parcelas parcelas de R\$ ${valorParcela.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Obtém o ID do usuário atualmente logado
  String? get currentUserId => _authService.userId;

  /// Verifica se o usuário está autenticado
  bool get isUserAuthenticated => _authService.isAuthenticated;

  // Setters
  @action
  void setValor(double value) => _valor = value;

  @action
  void setDataSelecionada(DateTime data) => _dataSelecionada = data;

  @action
  void setCategoria(CategoriaModel? value) => _categoriaSelecionada = value;

  @action
  void setNomeMovimentacao(String value) => _nomeMovimentacao = value;

  @action
  void setDescricao(String value) => _descricao = value;

  @action
  void setIsSaida(bool value) => _isSaida = value;

  // Setters para transações recorrentes
  @action
  void setIsRecorrente(bool value) => _isRecorrente = value;

  @action
  void setTipoRecorrencia(String value) => _tipoRecorrencia = value;

  @action
  void setPeriodoRecorrencia(String value) => _periodoRecorrencia = value;

  @action
  void setQuantidadeParcelas(int value) => _quantidadeParcelas = value;

  @action
  void setParcelaAtual(int value) => _parcelaAtual = value;

  @action
  void setIntervaloPersonalizado(int value) => _intervaloPersonalizado = value;

  @action
  void setUnidadePersonalizada(String value) => _unidadePersonalizada = value;

  @action
  void setParcelaInicial(int value) => _parcelaAtual = value;

  @action
  void setTipoValorParcela(String value) => _tipoValorParcela = value;

  @action
  void setQuantidadeRepeticoes(int? value) => _quantidadeRepeticoes = value;

  // Edição
  @action
  void setEditMode(MovimentacaoModel original) {
    _isEdicao = true;
    _movimentacaoOriginal = original;
    _isSaida = original.isSaida;
  }

  /// Carrega as categorias disponíveis
  @action
  Future<void> carregarCategorias() async {
    try {
      _carregandoCategorias = true;
      final categorias = await _homeRepository.getCategorias();
      _categorias.clear();
      _categorias.addAll(categorias);
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao carregar categorias: $e');
      }
    } finally {
      _carregandoCategorias = false;
    }
  }

  /// Cria uma nova movimentação com base nos dados do formulário
  MovimentacaoModel? createMovimentacaoFromForm() {
    if (!isUserAuthenticated || currentUserId == null) {
      return null;
    }

    if (_nomeMovimentacao.isEmpty || _valor <= 0) {
      return null;
    }

    const uuid = Uuid();
    
    return MovimentacaoModel(
      id: uuid.v4(),
      nome: _nomeMovimentacao.trim(),
      valor: _isSaida ? -_valor.abs() : _valor.abs(),
      dataMovimentacao: _dataSelecionada,
      isSaida: _isSaida,
      idCategoria: _categoriaSelecionada?.id ?? 9, // ID 9 para categoria sugerida pela IA
      idUsuario: currentUserId!,
      descricao: _descricao.trim(),
    );
  }

  /// Cria um modelo atualizado mantendo o ID original (para edição)
  MovimentacaoModel? buildUpdatedMovimentacao(String idOriginal) {
    if (!isUserAuthenticated || currentUserId == null) return null;
    if (_nomeMovimentacao.isEmpty || _valor <= 0) return null;

    return MovimentacaoModel(
      id: idOriginal,
      nome: _nomeMovimentacao.trim(),
      valor: _isSaida ? -_valor.abs() : _valor.abs(),
      dataMovimentacao: _dataSelecionada,
      isSaida: _isSaida,
      idCategoria: _categoriaSelecionada?.id ?? (_movimentacaoOriginal?.idCategoria ?? 9),
      idUsuario: currentUserId!,
      descricao: _descricao.trim(),
    );
  }

  /// Salva a movimentação no banco de dados e sincroniza
  @action
  Future<bool> gravarMovimentacao(MovimentacaoModel movimentacao) async {
    try {
      _salvandoTransacao = true;

      if (kDebugMode) {
        print('DEBUG: Salvando transação');
        print('DEBUG: _isRecorrente = $_isRecorrente');
        print('DEBUG: _tipoRecorrencia = $_tipoRecorrencia');
        print('DEBUG: _quantidadeRepeticoes = $_quantidadeRepeticoes');
      }

      // Se for edição, decide fluxo de atualização
      if (_isEdicao && _movimentacaoOriginal != null) {
        final idOriginal = _movimentacaoOriginal!.id ?? '';
        final isRecorrente = idOriginal.contains('_parcela_') || idOriginal.contains('_fixa_');
        if (!isRecorrente) {
          // Atualiza apenas este registro
          await _homeRepository.atualizarMovimentacao(movimentacao);
          if (currentUserId != null) {
            await _syncService.updateMovimentacao(movimentacao, currentUserId!);
          }
          return true;
        } else {
          // Caso recorrente, quem chama deve tratar o escopo (apenas este mês, etc.)
          // Aqui não aplicamos em lote para permitir escolha de escopo.
          // Retorna true apenas para indicar que os dados são válidos; a aplicação em lote ocorre externamente.
          return true;
        }
      }

      if (!_isRecorrente || _tipoRecorrencia == 'unica') {
        // Transação única
        if (kDebugMode) {
          print('DEBUG: Salvando como transação única');
        }
        await _homeRepository.novaMovimentacao(movimentacao);
      } else {
        // Transações recorrentes
        if (kDebugMode) {
          print('DEBUG: Salvando como transações recorrentes');
        }
        final transacoes = _gerarTransacoesRecorrentes(movimentacao);
        
        if (kDebugMode) {
          print('DEBUG: Geradas ${transacoes.length} transações');
        }
        
        for (final transacao in transacoes) {
          await _homeRepository.novaMovimentacao(transacao);
        }
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao gravar movimentação: $e');
      }
      return false;
    } finally {
      _salvandoTransacao = false;
    }
  }

  /// Atualiza uma série de transações de acordo com o escopo escolhido
  /// escopo: 'apenas_esta' | 'desta_pra_frente' | 'todas_relacionadas'
  @action
  Future<bool> aplicarAtualizacaoPorEscopo(MovimentacaoModel atualizado, String escopo) async {
    try {
      _salvandoTransacao = true;
      final original = _movimentacaoOriginal;
      if (original == null) return false;
      final id = original.id ?? '';
      final isParcela = id.contains('_parcela_');
      final isFixa = id.contains('_fixa_');
      if (!isParcela && !isFixa) {
        // fallback: atualizar único
        await _homeRepository.atualizarMovimentacao(atualizado);
        if (currentUserId != null) {
          await _syncService.updateMovimentacao(atualizado, currentUserId!);
        }
        return true;
      }

      // Base da série
      late String base;
      if (isParcela) {
        base = id.split('_parcela_').first;
      } else {
        base = id.split('_fixa_').first;
      }

      // Carrega todas movimentações do usuário e filtra pela série
      final todas = await _homeRepository.getMovimentacoesTodas();
      final serie = todas.where((m) {
        final mid = m.id ?? '';
        return mid.startsWith(isParcela ? '${base}_parcela_' : '${base}_fixa_');
      }).toList();

      // Define cutoff para 'desta_pra_frente'
      final cutoff = DateTime(original.dataMovimentacao.year, original.dataMovimentacao.month, 1);

      // Decide quais atualizar
      Iterable<MovimentacaoModel> alvos;
      switch (escopo) {
        case 'apenas_esta':
          alvos = serie.where((m) => (m.id ?? '') == id);
          break;
        case 'desta_pra_frente':
          alvos = serie.where((m) {
            final d = m.dataMovimentacao;
            final k = DateTime(d.year, d.month, 1);
            return k.isAfter(cutoff) || k.isAtSameMomentAs(cutoff);
          });
          break;
        case 'todas_relacionadas':
          alvos = serie;
          break;
        default:
          alvos = [original];
      }

      // Para cada alvo, aplica os campos editados (nome, valor, categoria, descricao).
      // Mantém id e data de cada ocorrência, exceto se usuário alterou data desta ocorrência específica.
      for (final m in alvos) {
        final novo = MovimentacaoModel(
          id: m.id,
          nome: atualizado.nome,
          valor: atualizado.isSaida ? -atualizado.valor.abs() : atualizado.valor.abs(),
          idCategoria: atualizado.idCategoria,
          isSaida: atualizado.isSaida,
          dataMovimentacao: (escopo == 'apenas_esta' && (m.id ?? '') == id)
              ? atualizado.dataMovimentacao
              : m.dataMovimentacao,
          descricao: atualizado.descricao,
          idUsuario: m.idUsuario,
        );
        await _homeRepository.atualizarMovimentacao(novo);
        if (currentUserId != null) {
          await _syncService.updateMovimentacao(novo, currentUserId!);
        }
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Erro em aplicarAtualizacaoPorEscopo: $e');
      }
      return false;
    } finally {
      _salvandoTransacao = false;
    }
  }

  /// Gera a lista de transações recorrentes baseada nos parâmetros configurados
  List<MovimentacaoModel> _gerarTransacoesRecorrentes(MovimentacaoModel movimentacaoBase) {
    final transacoes = <MovimentacaoModel>[];
    
    if (kDebugMode) {
      print('DEBUG: Gerando transações recorrentes');
      print('DEBUG: _tipoRecorrencia = $_tipoRecorrencia');
      print('DEBUG: _quantidadeRepeticoes = $_quantidadeRepeticoes');
    }
    
    if (_tipoRecorrencia == 'parcelas') {
      // Gera parcelas
      final totalParcelas = _quantidadeParcelas;
      final parcelaInicial = _parcelaAtual;
      
      // Calcula o valor de cada parcela baseado no tipo escolhido
      double valorParcela;
      if (_tipoValorParcela == 'valor_total') {
        // Usuário informou o valor total, dividir pelas parcelas
        valorParcela = movimentacaoBase.valor.abs() / totalParcelas;
      } else {
        // Usuário informou o valor de cada parcela (padrão)
        valorParcela = movimentacaoBase.valor.abs();
      }
      
      for (int i = 0; i < (totalParcelas - parcelaInicial + 1); i++) {
        final dataTransacao = _calcularProximaData(_dataSelecionada, i);
        final numeroParcelaAtual = parcelaInicial + i;
        
        final transacao = MovimentacaoModel(
          id: '${movimentacaoBase.id}_parcela_$numeroParcelaAtual',
          nome: '${movimentacaoBase.nome} ($numeroParcelaAtual/$totalParcelas)',
          valor: movimentacaoBase.isSaida ? -valorParcela : valorParcela,
          dataMovimentacao: dataTransacao,
          isSaida: movimentacaoBase.isSaida,
          idCategoria: movimentacaoBase.idCategoria,
          idUsuario: movimentacaoBase.idUsuario,
          descricao: _tipoValorParcela == 'valor_total' 
              ? '${movimentacaoBase.descricao} - Parcela $numeroParcelaAtual de $totalParcelas (Total: R\$ ${movimentacaoBase.valor.abs().toStringAsFixed(2)})'
              : '${movimentacaoBase.descricao} - Parcela $numeroParcelaAtual de $totalParcelas',
        );
        
        transacoes.add(transacao);
      }
      
    } else if (_tipoRecorrencia == 'fixo') {
      // Gera transações fixas baseado na quantidade de repetições
      // Se quantidadeRepeticoes for null (infinita), gera um primeiro lote de 24 meses (2 anos)
      final quantidadeFixa = _quantidadeRepeticoes ?? 24;
      
      if (kDebugMode) {
        print('DEBUG: Entrando em transações fixas');
        print('DEBUG: quantidadeFixa = $quantidadeFixa');
        print('DEBUG: _quantidadeRepeticoes = $_quantidadeRepeticoes');
      }
      
      for (int i = 0; i < quantidadeFixa; i++) {
        final dataTransacao = _calcularProximaData(_dataSelecionada, i);
        
        final transacao = MovimentacaoModel(
          id: '${movimentacaoBase.id}_fixa_${i + 1}',
          nome: '${movimentacaoBase.nome} (Recorrente)',
          valor: movimentacaoBase.valor,
          dataMovimentacao: dataTransacao,
          isSaida: movimentacaoBase.isSaida,
          idCategoria: movimentacaoBase.idCategoria,
          idUsuario: movimentacaoBase.idUsuario,
          descricao: _quantidadeRepeticoes == null 
              ? '${movimentacaoBase.descricao} - Transação recorrente (Infinita)'
              : '${movimentacaoBase.descricao} - Transação recorrente (${i + 1}/$quantidadeFixa)',
        );
        
        transacoes.add(transacao);
        
        if (kDebugMode && i < 3) {
          debugPrint('DEBUG: Transação ${i + 1} criada: ${transacao.nome} - ${transacao.dataMovimentacao}');
        }
      }
      
      if (kDebugMode) {
        print('DEBUG: Total de transações fixas criadas: ${transacoes.length}');
      }
    }
    
    return transacoes;
  }

  /// Calcula a próxima data baseada no período de recorrência
  DateTime _calcularProximaData(DateTime dataBase, int incremento) {
    switch (_periodoRecorrencia) {
      case 'diario':
        return dataBase.add(Duration(days: incremento));
      case 'semanal':
        return dataBase.add(Duration(days: incremento * 7));
      case 'mensal':
        return DateTime(
          dataBase.year,
          dataBase.month + incremento,
          dataBase.day,
        );
      case 'anual':
        return DateTime(
          dataBase.year + incremento,
          dataBase.month,
          dataBase.day,
        );
      case 'personalizado':
        final dias = _intervaloPersonalizado;
        switch (_unidadePersonalizada) {
          case 'dias':
            return dataBase.add(Duration(days: incremento * dias));
          case 'semanas':
            return dataBase.add(Duration(days: incremento * dias * 7));
          case 'meses':
            return DateTime(
              dataBase.year,
              dataBase.month + (incremento * dias),
              dataBase.day,
            );
          case 'anos':
            return DateTime(
              dataBase.year + (incremento * dias),
              dataBase.month,
              dataBase.day,
            );
          default:
            return dataBase.add(Duration(days: incremento));
        }
      default:
        return dataBase.add(Duration(days: incremento));
    }
  }

  /// Limpa todos os campos do formulário
  @action
  void limparFormulario() {
    _valor = 0.00;
    _categoriaSelecionada = null;
    _dataSelecionada = DateTime.now();
    _nomeMovimentacao = '';
    _descricao = '';
    _isSaida = false;
    
    // Limpa campos de recorrência
    _isRecorrente = false;
    _tipoRecorrencia = 'unica';
    _periodoRecorrencia = 'mensal';
    _quantidadeParcelas = 1;
    _parcelaAtual = 1;
    _intervaloPersonalizado = 1;
    _unidadePersonalizada = 'dias';
    _tipoValorParcela = 'valor_parcela';
    _quantidadeRepeticoes = null;

    // Reseta estado de edição
    _isEdicao = false;
    _movimentacaoOriginal = null;
  }

  /// Valida se o formulário está válido para salvamento
  bool get isFormValid {
    final basicValidation = _nomeMovimentacao.trim().isNotEmpty && 
                           _valor > 0 && 
                           isUserAuthenticated;
    
    if (kDebugMode) {
      print('DEBUG: isFormValid - basicValidation = $basicValidation');
      print('DEBUG: _nomeMovimentacao = "$_nomeMovimentacao"');
      print('DEBUG: _valor = $_valor');
      print('DEBUG: isUserAuthenticated = $isUserAuthenticated');
      print('DEBUG: _isRecorrente = $_isRecorrente');
      print('DEBUG: _tipoRecorrencia = $_tipoRecorrencia');
    }
    
    if (!basicValidation) return false;
    
    // Validações específicas para recorrência
    if (_isRecorrente) {
      if (_tipoRecorrencia == 'parcelas') {
        final parcelasValid = _quantidadeParcelas > 0 && 
               _parcelaAtual > 0 && 
               _parcelaAtual <= _quantidadeParcelas;
        if (kDebugMode) {
          print('DEBUG: Validação parcelas = $parcelasValid');
        }
        return parcelasValid;
      }
      
      if (_tipoRecorrencia == 'fixo') {
        if (kDebugMode) {
          print('DEBUG: Transação fixa - sempre válida');
        }
        return true; // Transações fixas são sempre válidas
      }
      
      if (_periodoRecorrencia == 'personalizado') {
        final personalizadoValid = _intervaloPersonalizado > 0;
        if (kDebugMode) {
          print('DEBUG: Validação personalizado = $personalizadoValid');
        }
        return personalizadoValid;
      }
    }
    
    if (kDebugMode) {
      print('DEBUG: Formulário válido - retornando true');
    }
    return true;
  }
}