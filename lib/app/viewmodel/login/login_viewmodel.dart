import 'package:mobx/mobx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:neo_financyuai/app/service/auth_service.dart';
import 'package:neo_financyuai/app/service/connectivity_service.dart';
import 'package:neo_financyuai/app/repository/usuario_google_repository.dart';
import 'package:neo_financyuai/app/data/model/usuario_google_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'login_viewmodel.g.dart';

/// ViewModel responsável pela lógica de autenticação
/// 
/// Gerencia:
/// - Login com Google
/// - Login com email/senha
/// - Registro de novos usuários
/// - Estados de carregamento e erro
/// - Navegação pós-autenticação
class LoginViewModel = LoginViewmodelBase with _$LoginViewModel;

abstract class LoginViewmodelBase with Store {
  final AuthService _authService = AuthService();
  final ConnectivityService _connectivityService = ConnectivityService();
  final UsuarioGoogleRepository _usuarioGoogleRepository = UsuarioGoogleRepository();

  @observable
  bool _chengeObscureText = false;

  @observable
  bool _isLoading = false;

  @observable
  String? _errorMessage;

  /// Indica se a senha está visível
  bool get chengeObscureText => _chengeObscureText;

  /// Indica se há operação de login em andamento
  bool get isLoading => _isLoading;

  /// Mensagem de erro atual
  String? get errorMessage => _errorMessage;

  @action
  void toggleObscureText() {
    _chengeObscureText = !_chengeObscureText;
  }

  @action
  void clearError() {
    _errorMessage = null;
  }

  /// Define o estado de carregamento
  @action
  void _setLoading(bool value) {
    _isLoading = value;
  }

  /// Define mensagem de erro
  @action
  void _setErrorMessage(String? message) {
    _errorMessage = message;
  }

  @action
  Future<bool> loginWithGoogle() async {
    try {
      _setLoading(true);
      _setErrorMessage(null);
      
      if (kDebugMode) {
        debugPrint('🚀 Iniciando login com Google...');
      }

      // Verifica conectividade primeiro
      final hasConnection = await _connectivityService.hasInternetConnection();
      if (!hasConnection) {
        if (kDebugMode) {
          debugPrint('📶 Sem conexão com internet, verificando cache offline...');
        }
        
        // Tenta usar usuário offline
        final offlineSuccess = await _tryOfflineLogin();
        if (offlineSuccess) {
          return true;
        }
        
        _setErrorMessage('Sem conexão com internet. Verifique sua conexão e tente novamente.');
        return false;
      }

      final userCredential = await _authService.signInWithGoogle();
      
      if (userCredential != null) {
        if (kDebugMode) {
          debugPrint('✅ Login Google bem-sucedido!');
          debugPrint('📧 Email: ${userCredential.user?.email}');
          debugPrint('🆔 UID: ${userCredential.user?.uid}');
        }
        
        // Salva/atualiza o usuário Google no SQLite com cache da foto
        final user = userCredential.user;
        if (user != null) {
          await _salvarUsuarioGoogle(user);
         // Recalcula todos os saldos após sincronização do usuário
        //  await SaldoService().errecalcularTodosOsSaldos();
        }
        
  // Login bem-sucedido, navegar para o shell de abas
  Modular.to.navigate('/app/tabs');
        return true;
      }
      
      if (kDebugMode) {
        debugPrint('❌ UserCredential é null');
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro no login Google: $e');
        debugPrint('🔍 Tipo do erro: ${e.runtimeType}');
      }

      // Tratamento específico para erros de rede
      if (e.toString().contains('network_error') || e.toString().contains('ApiException: 7')) {
        if (kDebugMode) {
          debugPrint('🌐 Erro de rede detectado, tentando login offline...');
        }
        
        final offlineSuccess = await _tryOfflineLogin();
        if (offlineSuccess) {
          return true;
        }
        
        _setErrorMessage('Erro de conexão. Verifique sua internet.');
      } else if (e.toString().contains('ApiException: 10')) {
        if (kDebugMode) {
          debugPrint('');
          debugPrint('🚨 ERRO CONHECIDO: OAuth client não configurado');
          debugPrint('📋 Verifique:');
          debugPrint('   1. SHA-1 fingerprint no Firebase Console');
          debugPrint('   2. Google Sign-In habilitado na Authentication');
          debugPrint('   3. google-services.json atualizado');
          debugPrint('');
        }
        _setErrorMessage('Erro de configuração. Contate o desenvolvedor.');
      } else {
        _setErrorMessage('Erro ao fazer login: ${e.toString()}');
      }
      
      return false;
    } finally {
      _setLoading(false);
    }
  }

  @action
  Future<bool> loginWithEmailAndPassword(String email, String password) async {
    try {
      _setLoading(true);
      _setErrorMessage(null);

      final userCredential = await _authService.signInWithEmailAndPassword(email, password);
      
      if (userCredential != null) {
  // Login bem-sucedido, navegar para o shell de abas
  Modular.to.navigate('/app/tabs');
        return true;
      }
      
      return false;
    } catch (e) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            _setErrorMessage('Usuário não encontrado.');
            break;
          case 'wrong-password':
            _setErrorMessage('Senha incorreta.');
            break;
          case 'invalid-email':
            _setErrorMessage('Email inválido.');
            break;
          case 'user-disabled':
            _setErrorMessage('Conta desativada.');
            break;
          default:
            _setErrorMessage('Erro no login: ${e.message}');
        }
      } else {
        _setErrorMessage('Erro inesperado: ${e.toString()}');
      }
      
      if (kDebugMode) {
        debugPrint('❌ Erro no login: $e');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  @action
  Future<bool> registerWithEmailAndPassword(String email, String password, String confirmPassword, {String? displayName}) async {
    try {
      _setLoading(true);
      _setErrorMessage(null);

      // Validações básicas
      if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
        _setErrorMessage('Todos os campos são obrigatórios.');
        return false;
      }

      if (password != confirmPassword) {
        _setErrorMessage('As senhas não coincidem.');
        return false;
      }

      if (password.length < 6) {
        _setErrorMessage('A senha deve ter pelo menos 6 caracteres.');
        return false;
      }

      final userCredential = await _authService.registerWithEmailAndPassword(
        email, 
        password, 
        displayName ?? email.split('@')[0] // Use parte do email como displayName padrão
      );
      
      if (userCredential != null) {
  // Registro bem-sucedido, navegar para o shell de abas
  Modular.to.navigate('/app/tabs');
        return true;
      }
      
      return false;
    } catch (e) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'weak-password':
            _setErrorMessage('Senha muito fraca.');
            break;
          case 'email-already-in-use':
            _setErrorMessage('Este email já está em uso.');
            break;
          case 'invalid-email':
            _setErrorMessage('Email inválido.');
            break;
          case 'operation-not-allowed':
            _setErrorMessage('Registro com email/senha não habilitado.');
            break;
          default:
            _setErrorMessage('Erro no registro: ${e.message}');
        }
      } else {
        _setErrorMessage('Erro inesperado: ${e.toString()}');
      }
      
      if (kDebugMode) {
        debugPrint('❌ Erro no registro: $e');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  @action
  Future<void> logout() async {
    try {
      // Marca todos os usuários como inativos no SQLite
      await _usuarioGoogleRepository.limparUsuarios();
      
      // Faz logout do Firebase
      await _authService.signOut();
      
      debugPrint('✅ Logout realizado e usuários marcados como inativos');
      Modular.to.navigate('/login/');
    } catch (e) {
      _setErrorMessage('Erro ao fazer logout: ${e.toString()}');
      if (kDebugMode) {
        debugPrint('❌ Erro no logout: $e');
      }
    }
  }

  /// Salva o usuário Google no SQLite com cache da foto
  /// 
  /// [user] Usuário autenticado do Firebase
  Future<void> _salvarUsuarioGoogle(User user) async {
    try {
      final agora = DateTime.now().millisecondsSinceEpoch;
      
      final usuarioGoogle = UsuarioGoogleModel(
        uid: user.uid,
        nome: user.displayName,
        email: user.email,
        photoURL: user.photoURL,
        dataLogin: agora,
        dataAtualizacao: agora,
        isAtivo: true,
      );
      
      // Salva no SQLite com download automático da foto
      await _usuarioGoogleRepository.salvarUsuario(usuarioGoogle, downloadPhoto: true);
      
      debugPrint('✅ Usuário Google salvo no SQLite: ${user.uid}');
    } catch (e) {
      debugPrint('❌ Erro ao salvar usuário Google no SQLite: $e');
    }
  }

  /// Tenta fazer login offline usando usuário previamente salvo
  /// 
  /// Retorna true se conseguiu autenticar offline
  Future<bool> _tryOfflineLogin() async {
    try {
      if (kDebugMode) {
        debugPrint('🔍 Buscando usuário offline...');
      }

      final usuarioOffline = await _usuarioGoogleRepository.buscarUsuarioAtivo();
      
      if (usuarioOffline != null) {
        if (kDebugMode) {
          debugPrint('✅ Usuário offline encontrado: ${usuarioOffline.nome}');
          debugPrint('📧 Email: ${usuarioOffline.email}');
          debugPrint('🖼️ Tem foto local: ${usuarioOffline.hasLocalPhoto}');
        }
        
  // Navega para o shell de abas com usuário offline
  Modular.to.navigate('/app/tabs');
        
        // Exibe mensagem informativa sobre modo offline
        _setErrorMessage('Conectado no modo offline com ${usuarioOffline.nome ?? usuarioOffline.email ?? 'usuário anterior'}');
        
        return true;
      } else {
        if (kDebugMode) {
          debugPrint('❌ Nenhum usuário offline encontrado');
        }
        
        _setErrorMessage('Sem conexão e nenhum usuário salvo. Conecte-se à internet para fazer login.');
        return false;
      }
      
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao tentar login offline: $e');
      }
      return false;
    }
  }

  /// Verifica se há usuário disponível para modo offline
  Future<bool> hasOfflineUser() async {
    try {
      final usuarioOffline = await _usuarioGoogleRepository.buscarUsuarioAtivo();
      return usuarioOffline != null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao verificar usuário offline: $e');
      }
      return false;
    }
  }

  /// Faz login no modo offline com usuário previamente salvo
  @action
  Future<bool> loginOffline() async {
    try {
      _setLoading(true);
      _setErrorMessage(null);
      
      return await _tryOfflineLogin();
    } finally {
      _setLoading(false);
    }
  }

  /// Login com GitHub (preparado para implementação futura)
  @action
  Future<bool> loginWithGitHub() async {
    try {
      _setLoading(true);
      _setErrorMessage(null);
      
      if (kDebugMode) {
        debugPrint('🚀 Iniciando login com GitHub...');
      }

      // Verifica conectividade
      final hasConnection = await _connectivityService.hasInternetConnection();
      if (!hasConnection) {
        _setErrorMessage('Sem conexão com internet. Verifique sua conexão e tente novamente.');
        return false;
      }

      final userCredential = await _authService.signInWithGitHub();
      
      if (userCredential != null) {
        if (kDebugMode) {
          debugPrint('✅ Login GitHub bem-sucedido!');
        }
        
        await _navigateToHome();
        return true;
      }
      
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro no login com GitHub: $e');
      }
      _setErrorMessage('Erro ao fazer login com GitHub. Tente novamente.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Login com Microsoft (preparado para implementação futura)
  @action
  Future<bool> loginWithMicrosoft() async {
    try {
      _setLoading(true);
      _setErrorMessage(null);
      
      if (kDebugMode) {
        debugPrint('🚀 Iniciando login com Microsoft...');
      }

      // Verifica conectividade
      final hasConnection = await _connectivityService.hasInternetConnection();
      if (!hasConnection) {
        _setErrorMessage('Sem conexão com internet. Verifique sua conexão e tente novamente.');
        return false;
      }

      final userCredential = await _authService.signInWithMicrosoft();
      
      if (userCredential != null) {
        if (kDebugMode) {
          debugPrint('✅ Login Microsoft bem-sucedido!');
        }
        
        await _navigateToHome();
        return true;
      }
      
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro no login com Microsoft: $e');
      }
      _setErrorMessage('Erro ao fazer login com Microsoft. Tente novamente.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Navega para a tela inicial (home) após login bem-sucedido
  Future<void> _navigateToHome() async {
    // Aqui você pode adicionar lógica adicional, se necessário, antes de navegar para a home
  Modular.to.navigate('/app/tabs');
  }
}