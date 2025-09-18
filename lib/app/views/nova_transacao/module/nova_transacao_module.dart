import 'package:flutter_modular/flutter_modular.dart';
import 'package:neo_financyuai/app/core_module.dart';
import 'package:neo_financyuai/app/views/nova_transacao/nova_transacao_page.dart';
import 'package:neo_financyuai/app/views/nova_transacao/module/nova_transacao_nome_rotas.dart';

/// Módulo responsável pela configuração da Nova Transação.
/// 
/// Define as dependências, rotas e bindings necessários para o funcionamento
/// da funcionalidade Nova Transação da aplicação.
class NovaTransacaoModule extends Module {
  @override
  List<Module> get imports => [CoreModule()];

  @override
  void binds(Injector i) {
    // NovaTransacaoViewmodel será registrado no CoreModule como Lazy
    // Os repositories já estão registrados no CoreModule
  }

  @override
  void routes(RouteManager r) {
    r.child(
      NovaTransacaoNomeRotas.receita,
      child: (context) => const NovaTransacaoPage(isDespesa: false),
    );
    r.child(
      NovaTransacaoNomeRotas.despesa,
      child: (context) => const NovaTransacaoPage(isDespesa: true),
    );
  }
}