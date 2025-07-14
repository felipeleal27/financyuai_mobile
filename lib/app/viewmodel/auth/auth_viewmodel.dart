import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';
import 'package:neo_financyuai/app/service/auth_service.dart';

part 'auth_viewmodel.g.dart';

class AuthViewmodel = _AuthViewmodelBase with _$AuthViewmodel;

abstract class _AuthViewmodelBase with Store {
  final AuthService _authService;

  _AuthViewmodelBase(this._authService);

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  bool showPassword = false;

  @observable
  bool showConfirmPassword = false;

  @action
  void togglePasswordVisibility() {
    showPassword = !showPassword;
  }

  @action
  void toggleConfirmPasswordVisibility() {
    showConfirmPassword = !showConfirmPassword;
  }

  @action
  void clearError() {
    errorMessage = null;
  }

  @action
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    
    try {
      final result = await _authService.signInWithEmailAndPassword(email, password);
      
      if (result != null) {
        if (kDebugMode) {
          print('✅ Login realizado com sucesso: ${result.user?.email}');
        }
        return true;
      }
      
      errorMessage = 'Erro ao realizar login';
      return false;
    } on FirebaseAuthException catch (e) {
      errorMessage = _getAuthErrorMessage(e.code);
      if (kDebugMode) {
        print('❌ Erro de autenticação: ${e.code} - ${e.message}');
      }
      return false;
    } catch (e) {
      errorMessage = 'Erro inesperado. Tente novamente.';
      if (kDebugMode) {
        print('❌ Erro inesperado: $e');
      }
      return false;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> registerWithEmailAndPassword(String email, String password, String name) async {
    isLoading = true;
    errorMessage = null;
    
    try {
      final result = await _authService.registerWithEmailAndPassword(email, password, name);
      
      if (result != null) {
        if (kDebugMode) {
          print('✅ Cadastro realizado com sucesso: ${result.user?.email}');
        }
        return true;
      }
      
      errorMessage = 'Erro ao criar conta';
      return false;
    } on FirebaseAuthException catch (e) {
      errorMessage = _getAuthErrorMessage(e.code);
      if (kDebugMode) {
        print('❌ Erro de autenticação: ${e.code} - ${e.message}');
      }
      return false;
    } catch (e) {
      errorMessage = 'Erro inesperado. Tente novamente.';
      if (kDebugMode) {
        print('❌ Erro inesperado: $e');
      }
      return false;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> signInWithGoogle() async {
    isLoading = true;
    errorMessage = null;
    
    try {
      final result = await _authService.signInWithGoogle();
      
      if (result != null) {
        if (kDebugMode) {
          print('✅ Login com Google realizado com sucesso: ${result.user?.email}');
        }
        return true;
      }
      
      errorMessage = 'Login cancelado';
      return false;
    } on FirebaseAuthException catch (e) {
      errorMessage = _getAuthErrorMessage(e.code);
      if (kDebugMode) {
        print('❌ Erro de autenticação: ${e.code} - ${e.message}');
      }
      return false;
    } catch (e) {
      errorMessage = 'Erro inesperado. Tente novamente.';
      if (kDebugMode) {
        print('❌ Erro inesperado: $e');
      }
      return false;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      if (kDebugMode) {
        print('✅ Logout realizado com sucesso');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao fazer logout: $e');
      }
    }
  }

  /// Converte códigos de erro do Firebase em mensagens amigáveis
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Usuário não encontrado. Verifique o email.';
      case 'wrong-password':
        return 'Senha incorreta. Tente novamente.';
      case 'email-already-in-use':
        return 'Este email já está em uso. Tente fazer login.';
      case 'weak-password':
        return 'Senha muito fraca. Use pelo menos 6 caracteres.';
      case 'invalid-email':
        return 'Email inválido. Verifique o formato.';
      case 'user-disabled':
        return 'Esta conta foi desabilitada.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      case 'operation-not-allowed':
        return 'Operação não permitida.';
      case 'invalid-credential':
        return 'Credenciais inválidas. Verifique email e senha.';
      case 'network-request-failed':
        return 'Erro de conexão. Verifique sua internet.';
      default:
        return 'Erro inesperado. Tente novamente.';
    }
  }
}
