import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:neo_financyuai/app/utils/app_theme_helper.dart';
import 'package:neo_financyuai/app/viewmodel/home/home_viewmodel.dart';
import 'package:neo_financyuai/app/views/home/home_page.dart';
import 'package:neo_financyuai/app/views/estatisticas/pages/estatisticas_page.dart';
import 'package:neo_financyuai/app/views/orcamento/pages/orcamento_page.dart';
import 'package:neo_financyuai/app/views/settings/settings_page.dart';
import 'package:neo_financyuai/app/widgets/bottom_navigation_bat.dart';

class TabsShellPage extends StatefulWidget {
  const TabsShellPage({super.key});

  @override
  State<TabsShellPage> createState() => _TabsShellPageState();
}

class _TabsShellPageState extends State<TabsShellPage> {
  int _currentIndex = 0; // 0=Home,1=Stats,2=FAB(space),3=Orcamento,4=Settings

  void _openNewTransaction() {
    // Garante que estamos na Home e abre o modal via ViewModel
    if (_currentIndex != 0) {
      setState(() => _currentIndex = 0);
      // agenda o modal após o frame de troca de aba
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          final homeVm = Modular.get<HomeViewmodel>();
          homeVm.isDialogOpen(true);
        } catch (_) {}
      });
    } else {
      try {
        final homeVm = Modular.get<HomeViewmodel>();
        homeVm.isDialogOpen(true);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final helper = AppThemeHelper.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex > 2 ? _currentIndex : _currentIndex, // mantém estados
        children: const [
          HomePage(embedded: true),
          EstatisticasPage(embedded: true),
          SizedBox.shrink(), // espaço do FAB
          OrcamentoPage(embedded: true),
          SettingsPage(embedded: true),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 64,
        height: 64,
        child: FloatingActionButton(
          onPressed: _openNewTransaction,
          backgroundColor: helper.colorScheme.primary,
          foregroundColor: helper.colorScheme.onPrimary,
          elevation: helper.brightness == Brightness.light ? 6 : 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          child: const Icon(Icons.add, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTapOverride: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
