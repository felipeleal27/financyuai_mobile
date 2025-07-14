import 'package:flutter_modular/flutter_modular.dart';
import 'package:neo_financyuai/app/service/auth_service.dart';

/// Guard para proteger rotas que requerem autenticação
/// 
/// Verifica se o usuário está autenticado antes de permitir
/// acesso a rotas protegidas. Se não estiver autenticado,
/// redireciona para a tela de login.
class AuthGuard extends RouteGuard {
  final AuthService _authService = AuthService();

  @override
  Future<bool> canActivate(String path, ModularRoute route) async {
    // Verifica se o usuário está autenticado
    if (_authService.isAuthenticated) {
      return true;
    }

    // Se não estiver autenticado, redireciona para login
    Modular.to.navigate('/login/');
    return false;
  }
}

/// Guard para evitar acesso à tela de login quando já autenticado
/// 
/// Redireciona usuários já autenticados para a tela principal
/// quando tentam acessar a tela de login.
class LoginGuard extends RouteGuard {
  final AuthService _authService = AuthService();

  @override
  Future<bool> canActivate(String path, ModularRoute route) async {
    // Se já estiver logado, redireciona para home
    if (_authService.isAuthenticated) {
      Modular.to.navigate('/home/');
      return false;
    }

    // Se não estiver logado, permite acesso ao login
    return true;
  }
}
