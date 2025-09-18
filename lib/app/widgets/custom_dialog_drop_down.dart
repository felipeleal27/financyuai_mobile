import 'package:flutter/material.dart';
import 'package:neo_financyuai/app/utils/app_theme_helper.dart';
import 'package:neo_financyuai/app/data/model/categoria_model.dart';
import 'package:neo_financyuai/app/service/category_icon_service.dart';

class CustomDialogDropdown<T> extends StatelessWidget {
  final List<T> items;
  final T? itemSelected;
  final ValueChanged<T> onChange;
  final String Function(T) itemLabel;
  final Color? dialogBackground;
  final String? Function(T?)? validator;
  final String title;
  final String labelText;
  final GlobalKey<FormState> formkey;
  // Aparência avançada (opcionais e retrocompatíveis)
  final Widget Function(T item)? leadingBuilder; // Ícone/leading custom por item
  final IconData? dialogTitleIcon; // Ícone do título do diálogo
  final String? searchHintText; // Placeholder custom da busca
  // Emojis e cores por item (opcionais). Se não informados, usa heurística por label
  final String Function(T item)? emojiBuilder;
  final Color Function(T item)? colorBuilder;

  const CustomDialogDropdown({
    super.key,
    required this.items,
    required this.onChange,
    required this.itemLabel,
    this.itemSelected,
    this.dialogBackground,
    this.validator,
    this.title = "Selecione um item",
    this.labelText = "Selecionar Item",
    required this.formkey,
    this.leadingBuilder,
    this.dialogTitleIcon,
    this.searchHintText,
    this.emojiBuilder,
    this.colorBuilder,
  });

  void _showDialog(BuildContext context, ValueChanged<T> onSelected) {
    final helper = AppThemeHelper.of(context);
    List<T> filteredItems = List.from(items);
    final TextEditingController searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final maxHeight = MediaQuery.of(context).size.height * 0.6;
            return AlertDialog(
              backgroundColor: helper.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              titlePadding: const EdgeInsets.fromLTRB(20, 18, 8, 0),
              contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              title: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: helper.colorScheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      dialogTitleIcon ?? Icons.category,
                      color: helper.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: helper.colorScheme.onSurface,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: helper.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    tooltip: 'Fechar',
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: maxHeight,
                child: Column(
                  children: [
                    // Barra de pesquisa
                    Container(
                      decoration: BoxDecoration(
                        color: helper.modalFieldColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: helper.isDark
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                )
                              ],
                      ),
                      child: TextField(
                        controller: searchController,
                        style: TextStyle(color: helper.colorScheme.onSurface),
                        decoration: InputDecoration(
                          hintText: searchHintText ?? 'Pesquisar...',
                          hintStyle: TextStyle(
                            color: helper.colorScheme.onSurface.withOpacity(0.5),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: helper.colorScheme.onSurface.withOpacity(0.7),
                          ),
                          suffixIcon: searchController.text.isEmpty
                              ? null
                              : IconButton(
                                  onPressed: () {
                                    searchController.clear();
                                    setState(() {
                                      filteredItems = List.from(items);
                                    });
                                  },
                                  icon: Icon(
                                    Icons.clear,
                                    color: helper.colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          filled: true,
                          fillColor: Colors.transparent,
                        ),
                        onChanged: (value) {
                          setState(() {
                            filteredItems = items
                                .where((item) => itemLabel(item)
                                    .toLowerCase()
                                    .contains(value.toLowerCase()))
                                .toList();
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Lista de itens
                    Expanded(
                      child: filteredItems.isEmpty
                          ? Center(
                              child: Text(
                                'Nenhum resultado',
                                style: TextStyle(
                                  color: helper.colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            )
                          : ListView.separated(
                              itemCount: filteredItems.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final item = filteredItems[index];
                                final isSelected = item == itemSelected;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? helper.colorScheme.primary.withOpacity(0.08)
                                        : helper.isDark
                                            ? helper.colorScheme.surface.withOpacity(0.6)
                                            : helper.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? helper.colorScheme.primary
                                          : helper.colorScheme.outline.withOpacity(0.4),
                                    ),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      onSelected(item);
                                      Navigator.of(context).pop();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      child: Row(
                                        children: [
                                          // Leading customizável
                                          if (leadingBuilder != null)
                                            Padding(
                                              padding: const EdgeInsets.only(right: 10),
                                              child: leadingBuilder!(item),
                                            )
                                          else
                                            Padding(
                                              padding: const EdgeInsets.only(right: 10),
                                              child: _buildLeadingBubbleForItem(helper, item),
                                            ),
                                          // Label
                                          Expanded(
                                            child: Text(
                                              itemLabel(item),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: helper.colorScheme.onSurface,
                                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          // Check
                                          AnimatedSwitcher(
                                            duration: const Duration(milliseconds: 200),
                                            child: isSelected
                                                ? Icon(Icons.check_circle, key: const ValueKey('on'), color: helper.colorScheme.primary)
                                                : Icon(Icons.radio_button_unchecked, key: const ValueKey('off'), color: helper.colorScheme.onSurface.withOpacity(0.45)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      color: helper.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final helper = AppThemeHelper.of(context);
    
    return FormField<T>(
      initialValue: itemSelected,
      validator: validator,
      builder: (FormFieldState<T> state) {
        return _buildLabelOverBorder(
          labelText,
          helper,
          GestureDetector(
            onTap: () {
              _showDialog(context, (T selectedItem) {
                onChange(selectedItem);
                state.didChange(selectedItem);
              });
            },
            child: Material(
              elevation: helper.isDark ? 0 : 2,
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12.0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                decoration: BoxDecoration(
                  color: helper.isDark 
                      ? helper.colorScheme.surface.withOpacity(0.8)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: state.hasError 
                        ? helper.colorScheme.error
                        : helper.colorScheme.outline.withOpacity(0.4),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    // Leading com ícone/emoji bubble quando houver seleção
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: _buildLeadingBubbleForField(helper, state.value),
                    ),
                    Expanded(
                      child: Text(
                        itemSelected != null 
                            ? itemLabel(itemSelected as T) 
                            : 'Selecione uma categoria',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: itemSelected != null
                              ? helper.colorScheme.onSurface
                              : helper.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: helper.colorScheme.onSurface.withOpacity(0.7),
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
          state.hasError ? state.errorText : null,
        );
      },
    );
  }
  
  // Widget para criar o label posicionado sobre a borda
  Widget _buildLabelOverBorder(String labelText, AppThemeHelper helper, Widget child, String? errorText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            child,
            Positioned(
              left: 20,
              top: -8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                color: helper.isDark 
                    ? helper.colorScheme.surface.withOpacity(0.8)
                    : helper.colorScheme.surface,
                child: Text(
                  labelText,
                  style: TextStyle(
                    fontSize: 12.0,
                    color: helper.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 8),
            child: Text(
              errorText,
              style: TextStyle(
                color: helper.colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  // Helpers de leading (ícone de categoria quando disponível; fallback para emoji)
  Widget _buildLeadingBubbleForField(AppThemeHelper helper, T? value) {
    if (value is CategoriaModel) {
      final color = _colorFor(item: value as T, label: value.nome);
      // Usa ícone salvo; se for padrão, tenta sugestão pelo nome
      String iconName = value.icone;
      if (iconName == 'category') {
        final suggestions = CategoryIconService.getSuggestedIcons(value.nome);
        if (suggestions.isNotEmpty) iconName = suggestions.first;
      }
      return _buildIconBubble(
        helper: helper,
        iconData: CategoryIconService.getIconData(iconName),
        bg: color,
      );
    }

    // Fallback: emoji
    final emoji = value == null
        ? '🏷️'
        : (emojiBuilder != null ? emojiBuilder!(value as T) : _emojiFor(label: itemLabel(value as T)));
    final color = value == null
        ? helper.colorScheme.primary
        : _colorFor(item: value as T, label: itemLabel(value));
    return _buildEmojiBubble(bg: color, emoji: emoji, opacity: 0.15);
  }

  Widget _buildLeadingBubbleForItem(AppThemeHelper helper, T item) {
    if (item is CategoriaModel) {
      final color = _colorFor(item: item as T, label: item.nome);
      // Usa ícone salvo; se for padrão, tenta sugestão pelo nome
      String iconName = item.icone;
      if (iconName == 'category') {
        final suggestions = CategoryIconService.getSuggestedIcons(item.nome);
        if (suggestions.isNotEmpty) iconName = suggestions.first;
      }
      return _buildIconBubble(
        helper: helper,
        iconData: CategoryIconService.getIconData(iconName),
        bg: color,
      );
    }

    // Fallback: emoji
    final label = itemLabel(item);
    final emoji = emojiBuilder != null ? emojiBuilder!(item) : _emojiFor(label: label);
    final color = _colorFor(item: item, label: label);
    return _buildEmojiBubble(bg: color, emoji: emoji, opacity: 0.18);
  }

  Widget _buildIconBubble({required AppThemeHelper helper, required IconData iconData, required Color bg}) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: bg.withOpacity(0.16),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        iconData,
        size: 16,
        color: bg,
      ),
    );
  }

  Widget _buildEmojiBubble({required Color bg, required String emoji, double opacity = 0.18}) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: bg.withOpacity(opacity),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: const TextStyle(fontSize: 16)),
    );
  }

  String _emojiFor({required String label}) {
    final l = label.toLowerCase();
    if (l.contains('fam')) return '👪';
    if (l.contains('lazer') || l.contains('diver') || l.contains('jogo')) return '🎉';
    if (l.contains('mora') || l.contains('casa') || l.contains('alug')) return '🏠';
    if (l.contains('pag') || l.contains('conta') || l.contains('bole')) return '💳';
    if (l.contains('saúde') || l.contains('saude') || l.contains('medic') || l.contains('remed')) return '💊';
    if (l.contains('serv') ) return '🧰';
    if (l.contains('trans') || l.contains('uber') || l.contains('bus') || l.contains('ônibus') || l.contains('onibus') || l.contains('combus') || l.contains('gas')) return '🚗';
    if (l.contains('vest') || l.contains('roup') || l.contains('calc')) return '👕';
    if (l.contains('merc') || l.contains('super')) return '🛒';
    if (l.contains('edu') || l.contains('curso') || l.contains('escol') || l.contains('facul')) return '🎓';
    if (l.contains('rest') || l.contains('comid') || l.contains('lanche') || l.contains('alim')) return '🍽️';
    if (l.contains('viag') || l.contains('hotel') || l.contains('passa')) return '✈️';
    return '🏷️';
  }

  Color _colorFor({required T item, required String label}) {
    if (colorBuilder != null) return colorBuilder!(item);
    final l = label.toLowerCase();
    if (l.contains('fam')) return Colors.purple;
    if (l.contains('lazer') || l.contains('diver') ) return Colors.indigo;
    if (l.contains('mora') || l.contains('casa')) return Colors.deepPurple;
    if (l.contains('pag') || l.contains('conta')) return Colors.redAccent;
    if (l.contains('saúde') || l.contains('saude')) return Colors.teal;
    if (l.contains('serv')) return Colors.amber;
    if (l.contains('trans')) return Colors.orange;
    if (l.contains('vest') || l.contains('roup')) return Colors.green;
    if (l.contains('merc') || l.contains('super')) return Colors.lightGreen;
    if (l.contains('edu') || l.contains('curso')) return Colors.blue;
    if (l.contains('rest')) return Colors.deepOrange;
    if (l.contains('viag')) return Colors.lightBlue;
    // fallback: palette por hash
    final palette = [
      Colors.blue, Colors.cyan, Colors.deepPurple, Colors.orange, Colors.teal,
      Colors.indigo, Colors.pinkAccent, Colors.green, Colors.amber,
    ];
    final idx = label.hashCode.abs() % palette.length;
    return palette[idx];
  }
}
