import 'package:flutter_modular/flutter_modular.dart';
import 'package:neo_financyuai/app/core_module.dart';
import 'package:neo_financyuai/app/repository/login_repository/login_repository.dart';
import 'package:neo_financyuai/app/repository/login_repository/login_repository_impl.dart';
import 'package:neo_financyuai/app/viewmodel/login/login_viewmodel.dart';
import 'package:neo_financyuai/app/views/login/login_page.dart';
import 'package:neo_financyuai/app/views/login/module/login_nome_rotas.dart';
import 'package:neo_financyuai/app/views/registrar/module/registar_nome_rotas.dart';
import 'package:neo_financyuai/app/views/registrar/module/registrar_module.dart';

/// Módulo responsável pela configuração do Login.
/// 
/// Define as dependências, rotas e bindings necessários para o funcionamento
/// da funcionalidade de autenticação da aplicação.
class LoginModule extends Module {
  @override
  List<Module> get imports => [CoreModule()];

  @override
  void binds(Injector i) {
    i.addLazySingleton<LoginRepository>(LoginRepositoryImpl.new);
    i.addLazySingleton(LoginViewModel.new);
  }

  @override
  void routes(RouteManager r) {
    r.child(LoginNomeRotas.login, child: (context) => const LoginPage());
    r.module(RegistrarNomeRotas.modulo, module: RegistrarModule());
    // r.module("${LoginNomeRotas.login}${CadastroNomeRotas.modulo}", module: CadastroModule());
  }
}