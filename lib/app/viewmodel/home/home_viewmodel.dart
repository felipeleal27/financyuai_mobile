import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';
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
  final HomeRepository _homeRepository;
  final FirebaseSyncService _syncService;
  final NotificationService _notificationService;
  final AuthService _authService;

  HomeViewmodelBase({
    required HomeRepository homeRepository,
    required FirebaseSyncService syncService,
    required NotificationService notificationService,
    required AuthService authService,
  })  : _homeRepository = homeRepository,
        _syncService = syncService,
        _notificationService = notificationService,
        _authService = authService {
    _initializeServices();
  }

  /// Inicializa os serviços em segundo plano
  Future<void> _initializeServices() async {
    await _syncService.initialize();
    await _notificationService.initialize();
    await carregarCategorias(); // Carrega as categorias automaticamente
    
    // 🆕 Sincronização inteligente pós-login
    final userId = _authService.userId;
    if (userId != null) {
      await _syncService.syncOnLogin(userId);
    }
    
    await carregarMovimentacoes(); // Carrega as movimentações após sync
  }

  @observable
  bool _carregou = false;

  @observable
  bool _canSeeValue = true;

  @observable
  double _valor = 0.00;

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
  ObservableList<MovimentacaoModel> _movimentacoes = ObservableList<MovimentacaoModel>();

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
    
    // Sincroniza com Firebase (funciona offline) - usa o userId real
    final userId = _authService.userId;
    if (userId != null) {
      _syncService.addMovimentacao(movimentacao, userId);
    }

    
    
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
    await _syncService.forcSync();
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
        // Isso evita duplicação e garante que mostra os dados corretos imediatamente
        await carregarMovimentacoes();
        
        // 3. Notificações inteligentes
        _checkForNotifications(movimentacao);
        
        if (kDebugMode) {
          debugPrint('✅ Transação salva e lista recarregada do SQLite');
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
    await _syncService.forcSync(); // Força sincronização da fila pendente
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
        nome: "Teste Firebase - ${DateTime.now().hour}:${DateTime.now().minute}",
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

    // Verifica se categoria foi selecionada
    if (_categoriaSelecionada == null) {
      if (kDebugMode) {
        debugPrint('⚠️  Categoria não selecionada');
      }
      return null;
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
      idCategoria: _categoriaSelecionada!.id,
      isSaida: _isSaida,
      dataMovimentacao: dataComHorario, // Data selecionada + horário atual
      descricao: '',
      idUsuario: currentUserId!, // Usa o UID do Firebase Auth
    );
  }

  /// 🆕 Carrega as movimentações do banco de dados
  Future<void> carregarMovimentacoes() async {
    try {
      final userId = _authService.userId;
      
      if (kDebugMode) {
        print('🔍 CARREGAR MOVIMENTAÇÕES - userId: $userId');
        print('🔍 Usuário autenticado: ${_authService.isAuthenticated}');
      }
      
      if (userId != null) {
        // 1. Carrega do SQLite primeiro (mais rápido)
        final movimentacoesLocal = await _homeRepository.getMovimentacoes(DateTime.now().month);
        setMovimentacoes(movimentacoesLocal);
        
        if (kDebugMode) {
          print('📊 ${movimentacoesLocal.length} movimentações carregadas do SQLite');
          print('📊 Lista atual no viewmodel: ${_movimentacoes.length} itens');
          for (var mov in movimentacoesLocal) {
            print('   - ${mov.nome}: R\$ ${mov.valor} (${mov.isSaida ? "Saída" : "Entrada"})');
          }
        }
        
        // 2. Configura stream do Firebase para atualizações em tempo real
        _configurarStreamFirebase(userId);
        
        // 3. Força sincronização se estiver online
        if (await isOnline()) {
          await _syncService.syncTransacoesToFirebase(userId);
        }
      } else {
        if (kDebugMode) {
          print('❌ Usuário não autenticado - não é possível carregar movimentações');
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
  void _configurarStreamFirebase(String userId) {
    if (kDebugMode) {
      print('🔄 Configurando stream Firebase para userId: $userId');
    }
    
    _syncService.getTransacoesStream(userId).listen(
      (movimentacoesFirebase) {
        if (kDebugMode) {
          print('🔄 ${movimentacoesFirebase.length} movimentações recebidas do Firebase');
          for (var mov in movimentacoesFirebase) {
            print('   Firebase - ${mov.nome}: R\$ ${mov.valor}');
          }
        }
        
        // ✅ Só atualiza se recebeu dados do Firebase (online) 
        // e se há diferença no número de itens ou conteúdo
        if (movimentacoesFirebase.isNotEmpty && 
            movimentacoesFirebase.length != _movimentacoes.length) {
          if (kDebugMode) {
            print('🔄 Atualizando lista com dados do Firebase (${movimentacoesFirebase.length} itens)');
          }
          setMovimentacoes(movimentacoesFirebase);
        } else if (movimentacoesFirebase.isEmpty && _movimentacoes.isNotEmpty) {
          // Se Firebase está vazio mas temos dados locais, mantém os dados locais
          if (kDebugMode) {
            print('📱 Mantendo dados locais (Firebase vazio, ${_movimentacoes.length} itens locais)');
          }
        }
      },
      onError: (error) {
        if (kDebugMode) {
          print('❌ Erro no stream Firebase: $error');
        }
      },
    );
  }

  /// Recarrega as categorias do banco de dados
  /// Útil para atualizar a lista após alterações em outras telas
  Future<void> recarregarCategorias() async {
    await carregarCategorias();
  }
}