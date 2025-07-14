import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:neo_financyuai/app/utils/ui_config_theme.dart';
import 'package:neo_financyuai/app/utils/theme_manager.dart';
import 'package:neo_financyuai/app/views/splash_screen/module/splash_screen_nome_rotas.dart';

/// Widget principal da aplicação.
/// 
/// Configura o MaterialApp com temas, localização e gerenciamento
/// de rotas através do Modular e ThemeManager.
class AppWidget extends StatefulWidget {
  /// Cria uma nova instância de [AppWidget].
  const AppWidget({super.key});

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

/// Estado do widget principal da aplicação.
/// 
/// Gerencia a inicialização do ThemeManager e responde a mudanças de tema.
class _AppWidgetState extends State<AppWidget> {
  /// Gerenciador de temas da aplicação.
  late ThemeManager themeManager;

  @override
  void initState() {
    super.initState();
    themeManager = Modular.get<ThemeManager>();
    // Carrega a preferência de tema salva
    themeManager.loadThemePreference();
  }

  @override
  Widget build(BuildContext context) {
    Modular.setInitialRoute(SplashScreenNomeRotas.navigate);
    Modular.setObservers([FlutterSmartDialog.observer]);

    return AnimatedBuilder(
      animation: themeManager,
      builder: (context, child) {
        return MaterialApp.router(
          builder: FlutterSmartDialog.init(),
          title: UiConfigTheme.title,
          debugShowCheckedModeBanner: false,
          theme: UiConfigTheme.themelight,
          darkTheme: UiConfigTheme.themedark,
          themeMode: themeManager.themeMode, // Usa o ThemeManager
          routeInformationParser: Modular.routeInformationParser,
          routerDelegate: Modular.routerDelegate,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('pt', 'BR')],
        );
      },
    );
  }
}