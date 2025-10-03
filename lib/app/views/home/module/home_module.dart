import 'package:flutter_modular/flutter_modular.dart';
import 'package:neo_financyuai/app/core_module.dart';
import 'package:neo_financyuai/app/views/home/home_page.dart';
import 'package:neo_financyuai/app/views/home/module/home_nome_rotas.dart';
import 'package:neo_financyuai/app/views/nova_transacao/module/nova_transacao_module.dart';
import 'package:neo_financyuai/app/views/nova_transacao/module/nova_transacao_nome_rotas.dart';

/// Módulo responsável pela configuração da Home.
/// 
/// Define as dependências, rotas e bindings necessários para o funcionamento
/// da funcionalidade Home da aplicação.
class HomeModule extends Module {
  @override
  List<Module> get imports => [CoreModule()];

  @override
  void binds(Injector i) {
    // HomeViewmodel e HomeRepository já estão registrados no CoreModule como Singleton
    // i.addSingleton(HomeViewmodel.new);
    // i.addSingleton<HomeRepository>(HomeRepositoryImpl.new);
  }

  @override
  void routes(RouteManager r) {
    r.child(
      HomeNomeRotas.inicial,
      child: (context) => const HomePage(),
      transition: TransitionType.noTransition,
    );
    // r.module("${HomeNomeRotas.inicial}${ConfiguracoesNomeRotas.modulo}", module: ConfiguracoesModule());
    r.module(
      "${HomeNomeRotas.inicial}${NovaTransacaoNomeRotas.modulo}",
      module: NovaTransacaoModule(),
      transition: TransitionType.noTransition,
    );
  }
}