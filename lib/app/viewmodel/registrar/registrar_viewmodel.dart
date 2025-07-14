import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';
import 'package:neo_financyuai/app/service/auth_service.dart';

part 'registrar_viewmodel.g.dart';

class RegistrarViewmodel = _RegistrarViewmodelBase with _$RegistrarViewmodel;

abstract class _RegistrarViewmodelBase with Store {
  final AuthService _authService;

  _RegistrarViewmodelBase(this._authService);

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  String? successMessage;

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
  void clearMessages() {
    errorMessage = null;
    successMessage = null;
  }

  @action
  Future<bool> registerWithEmailAndPassword(
    String name,
    String email,
    String password,
    String confirmPassword,
  ) async {
    isLoading = true;
    errorMessage = null;
    successMessage = null;

    try {
      // Validações básicas
      if (name.trim().isEmpty) {
        errorMessage = 'Nome é obrigatório';
        return false;
      }

      if (email.trim().isEmpty) {
        errorMessage = 'Email é obrigatório';
        return false;
      }

      if (password.isEmpty) {
        errorMessage = 'Senha é obrigatória';
        return false;
      }

      if (confirmPassword.isEmpty) {
        errorMessage = 'Confirmação de senha é obrigatória';
        return false;
      }

      if (password != confirmPassword) {
        errorMessage = 'Senhas não coincidem';
        return false;
      }

      if (password.length < 6) {
        errorMessage = 'Senha deve ter pelo menos 6 caracteres';
        return false;
      }

      // Validação de email básica
      if (!_isValidEmail(email)) {
        errorMessage = 'Email inválido';
        return false;
      }

      // Tenta fazer o registro
      final result = await _authService.registerWithEmailAndPassword(
        email.trim(),
        password,
        name.trim(),
      );

      if (result != null) {
        successMessage = 'Conta criada com sucesso! Bem-vindo(a), ${name.trim()}!';
        if (kDebugMode) {
          print('✅ Registro realizado com sucesso: ${result.user?.email}');
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
    successMessage = null;

    try {
      final result = await _authService.signInWithGoogle();

      if (result != null) {
        successMessage = 'Login com Google realizado com sucesso!';
        if (kDebugMode) {
          print('✅ Login com Google realizado: ${result.user?.email}');
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

  /// Valida se o email tem formato válido
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Converte códigos de erro do Firebase em mensagens amigáveis
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Este email já está em uso. Tente fazer login.';
      case 'weak-password':
        return 'Senha muito fraca. Use pelo menos 6 caracteres.';
      case 'invalid-email':
        return 'Email inválido. Verifique o formato.';
      case 'operation-not-allowed':
        return 'Cadastro com email não permitido.';
      case 'network-request-failed':
        return 'Erro de conexão. Verifique sua internet.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      case 'user-disabled':
        return 'Esta conta foi desabilitada.';
      default:
        return 'Erro inesperado. Tente novamente.';
    }
  }
}
