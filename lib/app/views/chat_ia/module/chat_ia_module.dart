import 'package:flutter_modular/flutter_modular.dart';
import 'package:neo_financyuai/app/core_module.dart';
import 'package:neo_financyuai/app/views/chat_ia/module/chat_ia_nome_rotas.dart';
import 'package:neo_financyuai/app/views/chat_ia/pages/chat_ia_page.dart';

class ChatIAModule extends Module {
  @override
  List<Module> get imports => [CoreModule()];

  @override
  void routes(RouteManager r) {
    r.child(ChatIANomeRotas.inicial, child: (_) => const ChatIAPage());
  }
}
