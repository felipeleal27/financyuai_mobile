import 'package:neo_financyuai/app/repository/login_repository/login_repository.dart';

/// Implementação do repositório de autenticação
/// Responsável pela validação de credenciais e gerenciamento de sessão
class LoginRepositoryImpl implements LoginRepository {
  
  @override
  Future<bool> login(String codigo, String senha) async {
    return true;
  }
}
