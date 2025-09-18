


  import 'dart:async';
  import 'package:flutter/foundation.dart';
  import 'package:mobx/mobx.dart';
  import 'package:neo_financyuai/app/service/saldo_service.dart';
  import 'package:uuid/uuid.dart';
  import 'package:neo_financyuai/app/data/model/movimentacao_model.dart';
  import 'package:neo_financyuai/app/data/model/categoria_model.dart';
  import 'package:neo_financyuai/app/repository/home_repository/home_repository.dart';
  import 'package:neo_financyuai/app/service/firebase_sync_service.dart';
  import 'package:neo_financyuai/app/service/notification_service.dart';
  import 'package:neo_financyuai/app/service/auth_service.dart';

  part 'home_viewmodel.g.dart';


/// ViewModel principal responsável pela lógica da tela inicial
///
/// Gerencia:
/// - Estado das movimentações financeiras
/// - Categorias de transações
/// - Sincronização com Firebase
/// - Notificações inteligentes
/// - Formulários de entrada de dados
class HomeViewmodel = HomeViewmodelBase with _$HomeViewmodel;

/// Classe base do ViewModel principal
abstract class HomeViewmodelBase with Store {
  /// Remove todas as transações relacionadas (parcelas ou fixas)
  @action
  Future<void> removerTransacoesRelacionadas(MovimentacaoModel movimentacao) async {
    try {
      final id = movimentacao.id ?? '';
      String? prefixo;
      if (id.contains('_parcela_')) {
        prefixo = '${id.split('_parcela_').first}_parcela_';
      } else if (id.contains('_fixa_')) {
        prefixo = '${id.split('_fixa_').first}_fixa_';
      }
      if (prefixo == null) return;
      // Busca todas as movimentações do usuário
      final todas = await _homeRepository.getMovimentacoesTodas();
  final relacionadas = todas.where((m) => (m.id ?? '').startsWith(prefixo!)).toList();
      for (final m in relacionadas) {
        await _homeRepository.removerMovimentacao(m);
        _movimentacoes.removeWhere((x) => x.id == m.id);
      }
      // Atualiza saldo imediatamente após remoção
      await carregarSaldo(_mesAtual);
    } catch (e) {
      if (kDebugMode) debugPrint('Erro ao remover relacionadas: $e');
    }
  }

  /// Remove esta e todas as seguintes (por data ou número de parcela)
  @action
  Future<void> removerTransacoesDestaPraFrente(MovimentacaoModel movimentacao) async {
    try {
      final id = movimentacao.id ?? '';
      String? prefixo;
      int? numeroAtual;
      if (id.contains('_parcela_')) {
        prefixo = '${id.split('_parcela_').first}_parcela_';
        numeroAtual = int.tryParse(id.split('_parcela_').last);
      } else if (id.contains('_fixa_')) {
        prefixo = '${id.split('_fixa_').first}_fixa_';
        numeroAtual = int.tryParse(id.split('_fixa_').last);
      }
      if (prefixo == null || numeroAtual == null) return;
      final numeroAtualSeguro = numeroAtual;
      // Busca todas as movimentações do usuário
      final todas = await _homeRepository.getMovimentacoesTodas();
      final relacionadas = todas.where((m) {
        final mid = m.id ?? '';
        if (!mid.startsWith(prefixo!)) return false;
  final n = int.tryParse(mid.replaceFirst(prefixo, ''));
        return n != null && n >= numeroAtualSeguro;
      }).toList();
      for (final m in relacionadas) {
        await _homeRepository.removerMovimentacao(m);
        _movimentacoes.removeWhere((x) => x.id == m.id);
      }
      // Atualiza saldo imediatamente após remoção
      await carregarSaldo(_mesAtual);
    } catch (e) {
      if (kDebugMode) debugPrint('Erro ao remover desta pra frente: $e');
    }
  }
  final HomeRepository _homeRepository;
  final FirebaseSyncService _syncService;
  final NotificationService _notificationService;
  final AuthService _authService;
  final SaldoService _saldoService;

  HomeViewmodelBase({
    required HomeRepository homeRepository,
    required FirebaseSyncService syncService,
    required NotificationService notificationService,
    required AuthService authService,
    required SaldoService saldoService,
  }) : _homeRepository = homeRepository,
       _syncService = syncService,
       _notificationService = notificationService,
       _authService = authService,
       _saldoService = saldoService;

  /// Inicializa os serviços em segundo plano
  @action
  Future<void> initializeServices() async {
  await _syncService.initialize();
    await _notificationService.initialize();
    await carregarCategorias();

    // Sincronização desativada: nenhuma ação pós-login

    await carregarMovimentacoes(); 
    await carregarSaldo(_mesAtual);
  }

  @action
  Future<void> carregarSaldo(DateTime mesAtual) async {
    try {
      final saldo = await _saldoService.calculaSaldoExibido(mesAtual);
      _saldoAtual = saldo;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao carregar saldo: $e');
      }
    }
  }

  @observable
  bool _carregou = false;

  @observable
  bool _canSeeValue = true;

  @observable
  double _valor = 0.00;

  @observable
  double _saldoAtual = 0.00;

  @observable
  CategoriaModel? _categoriaSelecionada;

  @observable
  DateTime _dataSelecionada = DateTime.now();

  @observable
  String _nomeMovimentacao = '';

  @observable
  bool _isSaida = false;

  @observable
  // ignore: prefer_final_fields
  ObservableList<CategoriaModel> _categorias = ObservableList<CategoriaModel>();

  @observable
  // ignore: prefer_final_fields
  ObservableList<MovimentacaoModel> _movimentacoes =
      ObservableList<MovimentacaoModel>();

  final DateTime _mesAtual = DateTime.now();

  @observable
  bool _shouldOpenDialog = false;

  bool get carregou => _carregou;
  bool get canSeeValue => _canSeeValue;
  List<CategoriaModel> get categoria => _categorias;
  List<MovimentacaoModel> get movimentacoes => _movimentacoes;
  double get valor => _valor;
  DateTime get dataSelecionada => _dataSelecionada;
  CategoriaModel? get categoriaSelecionada => _categoriaSelecionada;
  String get nomeMovimentacao => _nomeMovimentacao;
  bool get isSaida => _isSaida;
  bool get shouldOpenDialog => _shouldOpenDialog;
  double get saldoAtual => _saldoAtual;

  /// Obtém o ID do usuário atualmente logado
  String? get currentUserId => _authService.userId;

  /// Verifica se o usuário está autenticado
  bool get isUserAuthenticated => _authService.isAuthenticated;

  @action
  void setCarregou(bool value) => _carregou = value;

  @action
  void setCanSeeValue(bool value) => _canSeeValue = value;

  @action
  void setValor(double value) => _valor = value;

  @action
  void setDataSelecionada(DateTime data) => _dataSelecionada = data;

  @action
  void setCategoria(CategoriaModel? value) => _categoriaSelecionada = value;

  @action
  void setNomeMovimentacao(String value) => _nomeMovimentacao = value;

  @action
  void setIsSaida(bool value) => _isSaida = value;

  @action
  void setSaldoAtual(double value) => _saldoAtual = value;

  @action
  void isDialogOpen(bool value) {
    debugPrint('HomeViewmodel: isDialogOpen chamado com valor: $value');
    debugPrint('HomeViewmodel: shouldOpenDialog antes: $_shouldOpenDialog');
    _shouldOpenDialog = value;
    debugPrint('HomeViewmodel: shouldOpenDialog depois: $_shouldOpenDialog');
  }

  @action
  void setCategorias(List<CategoriaModel> categorias) {
    _categorias.clear();
    _categorias.addAll(categorias);
  }

  @action
  void addMovimentacao(MovimentacaoModel? movimentacao) {
    if (movimentacao != null) {
      movimentacoes.add(movimentacao);
    }
  }

  @action
  void setMovimentacoes(List<MovimentacaoModel> movimentacoes) {
    _movimentacoes.clear();
    _movimentacoes.addAll(movimentacoes);
  }

  @action
  void adicionarCategoria(CategoriaModel categoria) {
    _categorias.add(categoria);
  }

  @action
  void removerCategoria(CategoriaModel categoria) {
    _categorias.remove(categoria);
  }

  @action
  void adicionarMovimentacao(MovimentacaoModel movimentacao) {
    _movimentacoes.add(movimentacao);

    // Persistência local já é feita no repository; sync remoto desativado

    // Notificações inteligentes
    _checkForNotifications(movimentacao);
  }

  @action
  Future<void> removerMovimentacao(MovimentacaoModel movimentacao) async {
    try {
      // 1. Remove via repository (SQLite + Firebase)
      final sucesso = await _homeRepository.removerMovimentacao(movimentacao);

      if (sucesso) {
        // 2. Remove da lista observável
        _movimentacoes.remove(movimentacao);

        if (kDebugMode) {
          debugPrint('✅ Movimentação removida: ${movimentacao.nome}');
        }
      } else {
        if (kDebugMode) {
          debugPrint('❌ Falha ao remover movimentação');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao remover movimentação: $e');
      }
    }
  }

  /// Verifica se deve enviar notificações baseado na movimentação
  void _checkForNotifications(MovimentacaoModel movimentacao) {
    // Notifica gasto alto (acima de R$ 500)
    if (movimentacao.isSaida && movimentacao.valor.abs() > 500) {
      _notificationService.notifyHighExpense(movimentacao.valor.abs());
    }

    // Aqui você pode adicionar mais lógicas:
    // - Meta atingida
    // - Orçamento ultrapassado
    // - Economia conquistada
  }

  /// Força sincronização manual
  Future<void> sincronizarManual() async {
    // Desativado
  }

  /// Verifica status da conexão
  Future<bool> isOnline() async {
    return await _syncService.isOnline();
  }

  /// Carrega as categorias do banco de dados
  Future<void> carregarCategorias() async {
    try {
      final categorias = await _homeRepository.getCategorias();

      // Se não há categorias, cria algumas padrão
      if (categorias.isEmpty) {
        await _criarCategoriasPadrao();
        final novasCategorias = await _homeRepository.getCategorias();
        setCategorias(novasCategorias);
      } else {
        setCategorias(categorias);
      }

      if (kDebugMode) {
        debugPrint('📂 ${_categorias.length} categorias carregadas');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao carregar categorias: $e');
      }
    }
  }

  /// Cria categorias padrão se não existir nenhuma
  Future<void> _criarCategoriasPadrao() async {
    final categoriasDefault = [
      CategoriaModel(id: 1, nome: 'Alimentação', icone: 'restaurant'),
      CategoriaModel(id: 2, nome: 'Transporte', icone: 'directions_car'),
      CategoriaModel(id: 3, nome: 'Casa', icone: 'home'),
      CategoriaModel(id: 4, nome: 'Vestuário', icone: 'shopping_bag'),
      CategoriaModel(id: 5, nome: 'Saúde', icone: 'local_hospital'),
      CategoriaModel(id: 6, nome: 'Educação', icone: 'school'),
      CategoriaModel(id: 7, nome: 'Lazer', icone: 'sports_esports'),
      CategoriaModel(id: 8, nome: 'Salário', icone: 'attach_money'),
      CategoriaModel(id: 9, nome: 'Outros', icone: 'category'),
    ];

    for (final categoria in categoriasDefault) {
      await _homeRepository.inserirCategoria(categoria);
    }

    if (kDebugMode) {
      debugPrint('✅ Categorias padrão criadas');
    }
  }

  Future<bool> gravarMovimentacao(MovimentacaoModel movimentacao) async {
    try {
      // 1. Salva no SQLite via repository (já cuida do Firebase automaticamente)
      final sucesso = await _homeRepository.novaMovimentacao(movimentacao);

      if (sucesso) {
        // 2. 🔄 Recarrega a lista do SQLite para garantir consistência
        await carregarMovimentacoes();

        // 3. Notificações inteligentes
        _checkForNotifications(movimentacao);

        // 4. Sincroniza com Firebase automaticamente
        await sincronizarMovimentacoes();

        if (kDebugMode) {
          debugPrint('✅ Transação salva, lista recarregada e sincronizada com Firebase');
        }
      }

      return sucesso;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao gravar movimentação: $e');
      }
      return false;
    }
  }

  /// Sincroniza categorias com Firebase
  Future<void> sincronizarCategorias() async {
    try {
      await _homeRepository.syncCategoriasToFirebase();
      if (kDebugMode) {
        debugPrint('✅ Categorias sincronizadas com Firebase');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao sincronizar categorias: $e');
      }
    }
  }

  /// Sincroniza movimentações com Firebase
  Future<void> sincronizarMovimentacoes() async {
    try {
      await _homeRepository.syncMovimentacoesToFirebase();
      if (kDebugMode) {
        debugPrint('✅ Movimentações sincronizadas com Firebase');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao sincronizar movimentações: $e');
      }
    }
  }

  /// Sincroniza todos os dados com Firebase
  Future<void> sincronizarTodosDados() async {
    await sincronizarMovimentacoes();
    await sincronizarCategorias();
    // Força sincronização da fila pendente (somente se autenticado)
    if (currentUserId != null) {
      await _syncService.forcSync(currentUserId!);
    } else {
      if (kDebugMode) {
        debugPrint('⚠️ Não autenticado, ignorando forcSync');
      }
    }
  }

  /// Método de teste para Firebase (apenas debug)
  Future<void> testarFirebase() async {
    if (!kDebugMode) return;

    try {
      // Verifica se usuário está autenticado
      if (!isUserAuthenticated || currentUserId == null) {
        debugPrint('❌ Usuário não autenticado para teste Firebase');
        return;
      }

      // Cria uma transação de teste
      const uuid = Uuid();
      final movimentacaoTeste = MovimentacaoModel(
        id: uuid.v4(), // Gera UUID único
        nome:
            "Teste Firebase - ${DateTime.now().hour}:${DateTime.now().minute}",
        valor: -99.99,
        idCategoria: 1,
        isSaida: true,
        dataMovimentacao: DateTime.now(),
        descricao: "Transação criada para testar Firebase",
        idUsuario: currentUserId!, // Usa UID do Firebase Auth
      );

      // Adiciona via Firebase
      await gravarMovimentacao(movimentacaoTeste);

      // Força sincronização
      await sincronizarTodosDados();

      debugPrint('🧪 Teste Firebase executado - verifique o console Firebase!');
      debugPrint('📱 UserID para buscar no Firebase: ${await _getUserId()}');
    } catch (e) {
      debugPrint('❌ Erro no teste Firebase: $e');
    }
  }

  /// Obtém o ID do usuário para debug
  Future<String> _getUserId() async {
    return _authService.userId ?? 'user_anonymous';
  }

  /// Cria uma nova MovimentacaoModel com os dados atuais do formulário
  MovimentacaoModel? createMovimentacaoFromForm() {
    // Verifica se usuário está logado
    if (!isUserAuthenticated || currentUserId == null) {
      if (kDebugMode) {
        debugPrint('⚠️  Usuário não autenticado para criar movimentação');
      }
      return null;
    }

    // Se categoria não foi selecionada, tenta sugerir automaticamente (IA leve)
    int? categoriaIdSugestao;
    if (_categoriaSelecionada == null) {
      try {
        // Import tardio para evitar dependência circular
        // ignore: avoid_dynamic_calls
        // A classe está em app/ai/classifier.dart
        // Usamos uma função local para evitar problemas de import no código gerado
        categoriaIdSugestao = _classifyCategoriaId(_nomeMovimentacao, _valor);
        if (kDebugMode) {
          debugPrint('🤖 Categoria sugerida automaticamente: $categoriaIdSugestao');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Falha ao sugerir categoria automaticamente: $e');
        }
      }
    }

    const uuid = Uuid();
    // Combina a data selecionada com o horário atual para ordenação correta
    final dataComHorario = DateTime(
      _dataSelecionada.year,
      _dataSelecionada.month,
      _dataSelecionada.day,
      DateTime.now().hour,
      DateTime.now().minute,
      DateTime.now().second,
      DateTime.now().millisecond,
    );

    return MovimentacaoModel(
      id: uuid.v4(), // Gera UUID único
      nome: _nomeMovimentacao,
      valor: _valor,
  idCategoria: (_categoriaSelecionada?.id) ?? (categoriaIdSugestao ?? 9),
      isSaida: _isSaida,
      dataMovimentacao: dataComHorario, // Data selecionada + horário atual
      descricao: '',
      idUsuario: currentUserId!, // Usa o UID do Firebase Auth
    );
  }

  /// Heurística mínima para sugerir categoria quando usuário não escolhe.
  /// 1=Alimentação, 2=Transporte, 8=Salário, 9=Outros
  int _classifyCategoriaId(String nome, double valor) {
    final text = (nome).toLowerCase();
    bool hasAny(Iterable<String> words) => words.any((w) => text.contains(w));

    if (hasAny(['ifood', 'restaurante', 'pizza', 'lanche', 'mercado', 'supermercado'])) return 1;
    if (hasAny(['uber', '99', 'cabify', 'metro', 'onibus', 'combustivel', 'gasolina', 'posto'])) return 2;
    if (valor > 0 && hasAny(['salario', 'receita', 'bonus', 'provento'])) return 8;
    return 9;
  }

  /// 🆕 Carrega as movimentações do banco de dados
  Future<void> carregarMovimentacoes() async {
    try {
      final userId = _authService.userId;

      if (kDebugMode) {
        print('🔍 CARREGAR MOVIMENTAÇÕES - userId: $userId');
        print('🔍 Usuário autenticado: ${_authService.isAuthenticated}');
        print(
          '🔍 Mês selecionado: ${_dataSelecionada.month}/${_dataSelecionada.year}',
        );
      }

      if (userId != null) {
        // 1. Limpa o stream anterior para evitar conflitos
        _limparStream();

        // 2. Carrega do SQLite primeiro (mais rápido) - usando o mês e ano da data selecionada
        final movimentacoesLocal = await _homeRepository.getMovimentacoes(
          _dataSelecionada.month,
          _dataSelecionada.year,
        );

        // 3. Filtra pelo ano também para garantir que estamos no ano correto
        final movimentacoesFiltradas =
            movimentacoesLocal.where((mov) {
              return mov.dataMovimentacao.year == _dataSelecionada.year &&
                  mov.dataMovimentacao.month == _dataSelecionada.month;
            }).toList();

        setMovimentacoes(movimentacoesFiltradas);
        await _saldoService.calculaSaldoExibido(_mesAtual);

        if (kDebugMode) {
          print(
            '📊 ${movimentacoesFiltradas.length} movimentações carregadas do SQLite para ${_dataSelecionada.month}/${_dataSelecionada.year}',
          );
          print('📊 Lista atual no viewmodel: ${_movimentacoes.length} itens');
          for (var mov in movimentacoesFiltradas) {
            print(
              '   - ${mov.nome}: R\$ ${mov.valor} (${mov.isSaida ? "Saída" : "Entrada"}) - ${mov.dataMovimentacao}',
            );
          }
        }

        // Streams e sincronizações remotas desativadas
      } else {
        if (kDebugMode) {
          print(
            '❌ Usuário não autenticado - não é possível carregar movimentações',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao carregar movimentações: $e');
        print('❌ Stack trace: $e');
      }
    }
  }

  /// Configura stream do Firebase para updates em tempo real
  StreamSubscription<List<MovimentacaoModel>>? _streamSubscription;

  // Removido: stream remota desativada

  /// Limpa o stream anterior quando o mês muda
  void _limparStream() {
  _streamSubscription?.cancel();
  _streamSubscription = null;
  }

  /// Limpa recursos e estado ao fazer logout
  @action
  Future<void> onLogout() async {
    try {
      _limparStream();
      _movimentacoes.clear();
      _saldoAtual = 0.0;
      _carregou = false;
    } catch (_) {}
  }

  /// Recarrega as categorias do banco de dados
  /// Útil para atualizar a lista após alterações em outras telas
  Future<void> recarregarCategorias() async {
    await carregarCategorias();
  }
}
