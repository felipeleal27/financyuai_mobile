import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:neo_financyuai/app/service/auth_service.dart';
import 'package:neo_financyuai/app/utils/app_theme_helper.dart';
import 'package:neo_financyuai/app/utils/theme_manager.dart';
import 'package:neo_financyuai/app/utils/theme_preference.dart';
import 'package:neo_financyuai/app/viewmodel/settings/settings_viewmodel.dart';
import 'package:neo_financyuai/app/viewmodel/home/home_viewmodel.dart';
import 'package:neo_financyuai/app/views/home/module/home_nome_rotas.dart';
import 'package:neo_financyuai/app/views/login/module/login_nome_rotas.dart';
import 'package:neo_financyuai/app/widgets/bottom_navigation_bat.dart';
import 'package:neo_financyuai/app/widgets/cached_user_avatar_sqlite.dart';
import 'package:neo_financyuai/app/views/chat_ia/module/chat_ia_nome_rotas.dart';
import 'package:neo_financyuai/app/views/settings/module/settings_nome_rotas.dart';

class SettingsPageNew extends StatefulWidget {
  const SettingsPageNew({super.key});

  @override
  State<SettingsPageNew> createState() => _SettingsPageNewState();
}

class _SettingsPageNewState extends State<SettingsPageNew> {
  final viewmodel = Modular.get<SettingsViewmodel>();
  final authService = AuthService();
  final themeManager = Modular.get<ThemeManager>();

  @override
  void initState() {
    super.initState();
    viewmodel.load();
  }

  void _navigateToHomeAndOpenModal() async {
    debugPrint('⚙️ Settings: FloatingActionButton clicado');

    // Define a flag ANTES de navegar (igual ao app antigo)
    try {
      final homeVm = Modular.get<HomeViewmodel>();
      debugPrint('⚙️ Settings: HomeViewmodel obtido: $homeVm');
      debugPrint(
        '⚙️ Settings: Antes de definir flag: ${homeVm.shouldOpenDialog}',
      );
      homeVm.isDialogOpen(true);
      debugPrint(
        '⚙️ Settings: Depois de definir flag: ${homeVm.shouldOpenDialog}',
      );

      // Aguarda um momento para garantir que a flag foi definida
      await Future.delayed(const Duration(milliseconds: 50));

      // Navega para home (modal será aberto instantaneamente)
      debugPrint('⚙️ Settings: Navegando para home...');
      Modular.to.navigate(HomeNomeRotas.navigate);
      debugPrint('⚙️ Settings: Navegação concluída');
    } catch (e) {
      debugPrint('⚙️ Settings: Erro ao definir flag: $e');
      // Se houve erro, navega normalmente
      Modular.to.navigate(HomeNomeRotas.navigate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final helper = AppThemeHelper.of(context);

    return Scaffold(
      backgroundColor: helper.surfaceColor,
      appBar: AppBar(
        backgroundColor: helper.surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Configurações',
          style: TextStyle(
            color: helper.onSurfaceColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: helper.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: helper.colorScheme.primary,
              size: 16,
            ),
          ),
          onPressed: () => Modular.to.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Profile Section
            _buildProfileSection(helper),

            const SizedBox(height: 32),

            // Settings Sections
            _buildSettingsSection(helper, 'Geral', [
              _buildSettingItem(
                helper,
                Icons.person_outline,
                'Perfil',
                'Editar informações pessoais',
                onTap: () {},
              ),
              _buildThemeSelector(helper),
              _buildSettingItem(
                helper,
                Icons.logout,
                'Sair',
                'Desconectar da conta',
                onTap: () => _showLogoutDialog(helper),
                isDestructive: true,
              ),
            ]),

            const SizedBox(height: 24),

            _buildSettingsSection(helper, 'Assistente IA', [
              _buildChatbotToggle(helper),
              _buildSettingItem(
                helper,
                Icons.chat_bubble_outline,
                'Conversar com IA',
                'Abrir chat com assistente',
                onTap: () {
                  Modular.to.pushNamed(ChatIANomeRotas.navigate);
                },
              ),
            ]),

            const SizedBox(height: 24),

            _buildSettingsSection(helper, 'Configurações', [
              _buildSettingItem(
                helper,
                Icons.category_outlined,
                'Gerenciar Categorias',
                'Adicionar, editar ou remover categorias',
                onTap: () {},
              ),
              _buildSettingItem(
                helper,
                Icons.notifications_outlined,
                'Notificações',
                'Configurar alertas e lembretes',
                onTap: () => Modular.to.pushNamed(SettingsNomeRotas.navigateNotifications),
              ),
            ]),

            const SizedBox(height: 24),

            _buildSettingsSection(helper, 'Sobre', [
              _buildSettingItem(
                helper,
                Icons.info_outline,
                'Sobre o App',
                'Versão 1.0.0',
                onTap: () {},
              ),
              _buildSettingItem(
                helper,
                Icons.privacy_tip_outlined,
                'Política de Privacidade',
                'Termos e condições',
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 100), // Espaço para bottom nav
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: 64,
        height: 64,
        child: FloatingActionButton(
          onPressed: _navigateToHomeAndOpenModal,
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
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 4),
    );
  }

  Widget _buildProfileSection(AppThemeHelper helper) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color:
            helper.brightness == Brightness.light
                ? Colors.white
                : helper.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow:
            helper.brightness == Brightness.light
                ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
                : null,
        border:
            helper.brightness == Brightness.dark
                ? Border.all(
                  color: helper.colorScheme.outline.withOpacity(0.2),
                  width: 1,
                )
                : null,
      ),
      child: Row(
        children: [
          // Avatar com cache local
          const CachedUserAvatar(radius: 32),

          const SizedBox(width: 16),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  authService.currentUser?.displayName ?? 'Usuário',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: helper.onSurfaceColor,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  authService.currentUser?.email ?? 'email@exemplo.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: helper.onSurfaceColor.withOpacity(0.7),
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),

          // Edit Icon
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.edit_outlined, color: helper.colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    AppThemeHelper helper,
    String title,
    List<Widget> children,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color:
            helper.brightness == Brightness.light
                ? Colors.white
                : helper.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow:
            helper.brightness == Brightness.light
                ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
                : null,
        border:
            helper.brightness == Brightness.dark
                ? Border.all(
                  color: helper.colorScheme.outline.withOpacity(0.2),
                  width: 1,
                )
                : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: helper.onSurfaceColor,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    AppThemeHelper helper,
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
    Widget? trailing,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    isDestructive
                        ? helper.colorScheme.error.withOpacity(0.1)
                        : helper.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color:
                    isDestructive
                        ? helper.colorScheme.error
                        : helper.colorScheme.primary,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color:
                          isDestructive
                              ? helper.colorScheme.error
                              : helper.onSurfaceColor,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: helper.onSurfaceColor.withOpacity(0.6),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ],
              ),
            ),

            trailing ??
                Icon(
                  Icons.chevron_right,
                  color: helper.onSurfaceColor.withOpacity(0.4),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelector(AppThemeHelper helper) {
    return _buildSettingItem(
      helper,
      Icons.palette_outlined,
      'Tema',
      'Selecionar aparência do app',
      trailing: Observer(builder: (_) => _buildThemeToggle(helper)),
    );
  }

  Widget _buildThemeToggle(AppThemeHelper helper) {
    return Container(
      decoration: BoxDecoration(
        color: helper.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: helper.colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildThemeOption(
            helper,
            Icons.brightness_auto,
            ThemePreference.system,
            'Sistema',
          ),
          _buildThemeOption(
            helper,
            Icons.wb_sunny,
            ThemePreference.light,
            'Claro',
          ),
          _buildThemeOption(
            helper,
            Icons.nights_stay,
            ThemePreference.dark,
            'Escuro',
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    AppThemeHelper helper,
    IconData icon,
    ThemePreference preference,
    String tooltip,
  ) {
    final isSelected = themeManager.currentPreference == preference;

    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: () => themeManager.setThemePreference(preference),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? helper.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: helper.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : null,
          ),
          child: Icon(
            icon,
            size: 18,
            color:
                isSelected
                    ? helper.colorScheme.onPrimary
                    : helper.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildChatbotToggle(AppThemeHelper helper) {
    return _buildSettingItem(
      helper,
      Icons.smart_toy_outlined,
      'Assistente Flutuante',
      'Mostrar chatbot na tela inicial',
      trailing: Observer(
        builder:
            (_) => Switch(
              value: viewmodel.isChatbotEnabled,
              onChanged: viewmodel.setChatbot,
              activeColor: helper.colorScheme.primary,
            ),
      ),
    );
  }

  void _showLogoutDialog(AppThemeHelper helper) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: helper.surfaceColor,
            title: Text(
              'Sair',
              style: TextStyle(
                color: helper.onSurfaceColor,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Tem certeza que deseja sair da sua conta?',
              style: TextStyle(
                color: helper.onSurfaceColor,
                fontFamily: 'Poppins',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Cancelar',
                  style: TextStyle(
                    color: helper.onSurfaceColor.withOpacity(0.7),
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Modular.to.navigate(LoginNomeRotas.navigate);
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Sair',
                  style: TextStyle(
                    color: helper.colorScheme.error,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
