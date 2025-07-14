import 'package:flutter_modular/flutter_modular.dart';
import 'package:neo_financyuai/app/core_module.dart';
import 'package:neo_financyuai/app/viewmodel/settings/settings_viewmodel.dart';
import 'package:neo_financyuai/app/views/settings/module/settings_nome_rotas.dart';
import 'package:neo_financyuai/app/views/settings/settings_page.dart';

/// Módulo responsável pela configuração das Settings (Configurações).
/// 
/// Define as dependências, rotas e bindings necessários para o funcionamento
/// da funcionalidade de configurações da aplicação.
class SettingsModule extends Module {
  @override
  List<Module> get imports => [CoreModule()];

  @override
  void binds(Injector i) {
    i.addLazySingleton<SettingsViewmodel>(
      () => SettingsViewmodel(),
    );
  }

  @override
  void routes(RouteManager r) {
    r.child(SettingsNomeRotas.inicial, child: (context) => const SettingsPage());
  }
}
