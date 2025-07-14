import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:neo_financyuai/app/viewmodel/login/login_viewmodel.dart';
import 'package:neo_financyuai/app/views/login/widget_form_login.dart';

/// Página principal de autenticação do usuário.
/// 
/// Exibe o formulário de login e gerencia a autenticação através
/// do LoginViewModel injetado pelo Modular.
class LoginPage extends StatefulWidget {
  /// Cria uma nova instância de [LoginPage].
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

/// Estado da página de login.
/// 
/// Gerencia o ciclo de vida da página e a integração com o ViewModel.
class _LoginPageState extends State<LoginPage> {
  /// ViewModel responsável pela lógica de autenticação.
  final viewmodel = Modular.get<LoginViewModel>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WidgetFormLogin(viewmodel: viewmodel),
    );
  }
}
