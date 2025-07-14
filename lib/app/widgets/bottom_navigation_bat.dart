import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:neo_financyuai/app/utils/app_theme_helper.dart';
import 'package:neo_financyuai/app/views/home/module/home_nome_rotas.dart';
import 'package:neo_financyuai/app/views/settings/module/settings_nome_rotas.dart';

/// Widget de barra de navegação inferior customizada.
/// 
/// Fornece navegação entre as principais seções da aplicação
/// com design adaptativo e suporte a FAB central.
class CustomBottomNavigationBar extends StatelessWidget {
  /// Índice da aba atualmente selecionada.
  final int currentIndex;

  /// Cria uma nova instância de [CustomBottomNavigationBar].
  /// 
  /// [currentIndex] é obrigatório para indicar a aba ativa.
  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
  });

  /// Manipula o toque em um item da barra de navegação.
  /// 
  /// [index] é o índice do item tocado.
  void _onItemTapped(int index) {
    // Pula o índice 2 que é onde fica o FAB
    if (index == 2) return;
    
    switch (index) {
      case 0:
        Modular.to.navigate(HomeNomeRotas.navigate);
        break;
      case 1:
        // Navegar para gráficos/estatísticas
        // Modular.to.navigate(GraficosNomeRotas.navigate);
        break;
      case 3:
        // Navegar para carteira/conta
        // Modular.to.navigate(CarteiraNomoRotas.navigate);
        break;
      case 4:
        // Navegar para configurações
        Modular.to.navigate(SettingsNomeRotas.navigate);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final helper = AppThemeHelper.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: helper.colorScheme.surface,
        boxShadow: helper.brightness == Brightness.light
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ]
            : [
                BoxShadow(
                  color: helper.colorScheme.outline.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, -1),
                ),
              ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex > 2 ? currentIndex : currentIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: helper.colorScheme.primary,
        unselectedItemColor: helper.onSurfaceColor.withOpacity(0.6),
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          fontFamily: 'Poppins',
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 11,
          fontFamily: 'Poppins',
        ),
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              currentIndex == 0 ? Icons.home : Icons.home_outlined,
              size: 24,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              currentIndex == 1 ? Icons.analytics : Icons.analytics_outlined,
              size: 24,
            ),
            label: 'Estatísticas',
          ),
          const BottomNavigationBarItem(
            icon: SizedBox(width: 24, height: 24), // Espaço para o FAB
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              currentIndex == 3 ? Icons.account_balance_wallet : Icons.account_balance_wallet_outlined,
              size: 24,
            ),
            label: 'Carteira',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              currentIndex == 4 ? Icons.settings : Icons.settings_outlined,
              size: 24,
            ),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}
