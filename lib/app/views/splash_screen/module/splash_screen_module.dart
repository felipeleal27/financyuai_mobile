import 'package:flutter_modular/flutter_modular.dart';
import 'package:neo_financyuai/app/core_module.dart';
import 'package:neo_financyuai/app/viewmodel/slpash_screen/splash_screen_viewmodel.dart';
import 'package:neo_financyuai/app/views/splash_screen/module/splash_screen_nome_rotas.dart';
import 'package:neo_financyuai/app/views/splash_screen/splash_screen_page.dart';

/// Módulo responsável pela configuração da Splash Screen.
/// 
/// Define as dependências, rotas e bindings necessários para o funcionamento
/// da funcionalidade de tela inicial da aplicação.
class SplashScreenModule extends Module {
  @override
  List<Module> get imports => [CoreModule()];

  @override
  void binds(Injector i) {
    i.addLazySingleton<SplashScreenViewmodel>(
      () => SplashScreenViewmodel(
        splashScreenRepository: i.get(),
        initializationService: i.get(),
      ),
    );
  }

  @override
  void routes(RouteManager r) {
    r.child(SplashScreenNomeRotas.inicial, child: (context) => const SplashScreenPage());
  }
}
