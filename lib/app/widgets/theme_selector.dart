import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:neo_financyuai/app/utils/theme_manager.dart';
import 'package:neo_financyuai/app/utils/theme_preference.dart';

class ThemeSelector extends StatefulWidget {
  const ThemeSelector({super.key});

  @override
  State<ThemeSelector> createState() => _ThemeSelectorState();
}

class _ThemeSelectorState extends State<ThemeSelector> {
  late ThemeManager themeManager;

  @override
  void initState() {
    super.initState();
    themeManager = Modular.get<ThemeManager>();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Aparência',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: themeManager,
              builder: (context, child) {
                return Column(
                  children: ThemePreference.values.map((preference) {
                    return RadioListTile<ThemePreference>(
                      title: Text(preference.displayName),
                      subtitle: _getSubtitle(preference),
                      value: preference,
                      groupValue: themeManager.currentPreference,
                      onChanged: (ThemePreference? value) {
                        if (value != null) {
                          themeManager.setThemePreference(value);
                        }
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget? _getSubtitle(ThemePreference preference) {
    switch (preference) {
      case ThemePreference.system:
        return const Text('Segue a configuração do sistema');
      case ThemePreference.light:
        return const Text('Sempre usar tema claro');
      case ThemePreference.dark:
        return const Text('Sempre usar tema escuro');
    }
  }
}

/// Widget simples para alternar tema (botão)
class ThemeToggleButton extends StatefulWidget {
  const ThemeToggleButton({super.key});

  @override
  State<ThemeToggleButton> createState() => _ThemeToggleButtonState();
}

class _ThemeToggleButtonState extends State<ThemeToggleButton> {
  late ThemeManager themeManager;

  @override
  void initState() {
    super.initState();
    themeManager = Modular.get<ThemeManager>();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeManager,
      builder: (context, child) {
        IconData icon;
        String tooltip;
        
        switch (themeManager.currentPreference) {
          case ThemePreference.system:
            icon = Icons.brightness_auto;
            tooltip = 'Tema: Sistema';
            break;
          case ThemePreference.light:
            icon = Icons.light_mode;
            tooltip = 'Tema: Claro';
            break;
          case ThemePreference.dark:
            icon = Icons.dark_mode;
            tooltip = 'Tema: Escuro';
            break;
        }

        return IconButton(
          icon: Icon(icon),
          tooltip: tooltip,
          onPressed: () => themeManager.toggleTheme(),
        );
      },
    );
  }
}
