import 'package:flutter/material.dart';
import 'package:neo_financyuai/app/utils/app_theme_helper.dart';

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
            return AlertDialog(
              backgroundColor: helper.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                title,
                style: TextStyle(
                  color: helper.colorScheme.onSurface,
                  fontFamily: 'Poppins',
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Barra de pesquisa
                    TextField(
                      controller: searchController,
                      style: TextStyle(color: helper.colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Pesquisar...',
                        hintStyle: TextStyle(
                          color: helper.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: helper.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        filled: true,
                        fillColor: helper.isDark 
                            ? helper.colorScheme.surface.withOpacity(0.8)
                            : helper.colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: helper.colorScheme.outline.withOpacity(0.5),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: helper.colorScheme.outline.withOpacity(0.5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: helper.colorScheme.primary,
                            width: 2,
                          ),
                        ),
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
                    const SizedBox(height: 16),
                    // Lista de itens
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          final isSelected = item == itemSelected;
                          
                          return ListTile(
                            title: Text(
                              itemLabel(item),
                              style: TextStyle(
                                color: isSelected 
                                    ? helper.colorScheme.primary
                                    : helper.colorScheme.onSurface,
                                fontWeight: isSelected 
                                    ? FontWeight.bold 
                                    : FontWeight.normal,
                              ),
                            ),
                            leading: isSelected
                                ? Icon(
                                    Icons.check_circle,
                                    color: helper.colorScheme.primary,
                                  )
                                : Icon(
                                    Icons.circle_outlined,
                                    color: helper.colorScheme.onSurface.withOpacity(0.5),
                                  ),
                            onTap: () {
                              onSelected(item);
                              Navigator.of(context).pop();
                            },
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
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
              decoration: BoxDecoration(
                color: helper.isDark 
                    ? helper.colorScheme.surface.withOpacity(0.8)
                    : helper.colorScheme.surface,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: state.hasError 
                      ? helper.colorScheme.error
                      : helper.colorScheme.outline.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  // Ícone de categoria à esquerda
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Icon(
                      Icons.category,
                      color: helper.colorScheme.onSurface.withOpacity(0.7),
                      size: 20,
                    ),
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
}
