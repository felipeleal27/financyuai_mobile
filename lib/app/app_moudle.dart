import 'package:flutter_modular/flutter_modular.dart';
import 'package:neo_financyuai/app/core_module.dart';
import 'package:neo_financyuai/app/utils/auth_guard.dart';
import 'package:neo_financyuai/app/views/categorias/module/categorias_module.dart';
import 'package:neo_financyuai/app/views/categorias/module/categorias_nome_rotas.dart';
import 'package:neo_financyuai/app/views/home/module/home_module.dart';
import 'package:neo_financyuai/app/views/home/module/home_nome_rotas.dart';
import 'package:neo_financyuai/app/views/login/module/login_module.dart';
import 'package:neo_financyuai/app/views/login/module/login_nome_rotas.dart';
import 'package:neo_financyuai/app/views/registrar/module/registar_nome_rotas.dart';
import 'package:neo_financyuai/app/views/registrar/module/registrar_module.dart';
import 'package:neo_financyuai/app/views/settings/module/settings_module.dart';
import 'package:neo_financyuai/app/views/settings/module/settings_nome_rotas.dart';
import 'package:neo_financyuai/app/views/splash_screen/module/splash_screen_module.dart';
import 'package:neo_financyuai/app/views/splash_screen/module/splash_screen_nome_rotas.dart';

/// Módulo principal da aplicação.
/// 
/// Configura as rotas principais e define os módulos de cada seção
/// da aplicação com seus respectivos guards de autenticação.
class AppModule extends Module {
  @override
  List<Module> get imports => [CoreModule()];

  @override
  void binds(Injector i) {}

  @override
  void routes(r) {
    r.module(SplashScreenNomeRotas.modulo, module: SplashScreenModule());
    r.module(LoginNomeRotas.modulo, module: LoginModule(), guards: [LoginGuard()]);
    r.module(RegistrarNomeRotas.modulo, module: RegistrarModule(), guards: [LoginGuard()]);
    r.module(HomeNomeRotas.modulo, module: HomeModule(), guards: [AuthGuard()]);
    r.module(SettingsNomeRotas.modulo, module: SettingsModule(), guards: [AuthGuard()]);
    r.module(CategoriasNomeRotas.modulo, module: CategoriasModule(), guards: [AuthGuard()]);
  }
}