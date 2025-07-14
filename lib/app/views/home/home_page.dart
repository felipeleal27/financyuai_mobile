import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:neo_financyuai/app/data/model/categoria_model.dart';
import 'package:neo_financyuai/app/data/model/movimentacao_model.dart';
import 'package:neo_financyuai/app/utils/app_theme_helper.dart';
import 'package:neo_financyuai/app/viewmodel/home/home_viewmodel.dart';
import 'package:neo_financyuai/app/views/home/widgets/app_bar_container.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:neo_financyuai/app/widgets/bottom_navigation_bat.dart';
import 'package:neo_financyuai/app/widgets/custom_date_container.dart';
import 'package:neo_financyuai/app/widgets/custom_dialog_drop_down.dart';
import 'package:neo_financyuai/app/widgets/custom_text_form_field.dart';
import 'package:neo_financyuai/app/widgets/draggable_chat_bubble.dart';
import 'package:neo_financyuai/app/widgets/chat_ia_dialog.dart';
import 'package:neo_financyuai/app/service/category_icon_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final viewmodel = Modular.get<HomeViewmodel>();
  late TextEditingController textEditingController = TextEditingController();
  late TextEditingController valorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Inicializa locales para português brasileiro
    initializeDateFormatting('pt_BR', null);
    // Adiciona observer para detectar mudanças no ciclo de vida da app
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Remove observer ao sair da tela
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Quando a app volta para primeiro plano, recarrega categorias
    if (state == AppLifecycleState.resumed) {
      viewmodel.recarregarCategorias();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initializeDateFormatting('pt_BR', null);

    // Carrega dados iniciais apenas uma vez
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!viewmodel.carregou) {
        await Future.wait([
          viewmodel.carregarCategorias(),
          viewmodel.carregarMovimentacoes(),
        ]);
        viewmodel.setCarregou(true);
      }
    });
  }

  void _openChatIA() {
    showDialog(context: context, builder: (context) => const ChatIADialog());
  }

  void showDialogDespesaReceita(BuildContext context) {
    final helper = AppThemeHelper.of(context); // Captura helper ANTES do modal

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        // Usa modalContext para evitar conflitos
        return Container(
          decoration: BoxDecoration(
            color: helper.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: helper.onSurfaceColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Nova Transação',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: helper.onSurfaceColor,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 32),
                // Botão Receita
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(modalContext).pop();
                      showDialogNovaMovimentacao(
                        context,
                        false,
                      ); // Usa context original
                    },
                    icon: Icon(
                      Icons.trending_up,
                      color: helper.colorScheme.onPrimary,
                      size: 24,
                    ),
                    label: Text(
                      'Receita',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: helper.colorScheme.onPrimary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: helper.colorScheme.primary,
                      foregroundColor: helper.colorScheme.onPrimary,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Botão Despesa
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(modalContext).pop();
                      showDialogNovaMovimentacao(context, true);
                    },
                    icon: Icon(
                      Icons.trending_down,
                      color: helper.colorScheme.onError,
                      size: 24,
                    ),
                    label: Text(
                      'Despesa',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: helper.colorScheme.onError,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: helper.colorScheme.error,
                      foregroundColor: helper.colorScheme.onError,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Botão Cancelar
                TextButton(
                  onPressed: () => Navigator.of(modalContext).pop(),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      fontSize: 16,
                      color: helper.onSurfaceColor.withOpacity(0.7),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void showDialogNovaMovimentacao(BuildContext context, bool isDespesa) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final helper = AppThemeHelper.of(context); // Captura helper ANTES do modal

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      backgroundColor: helper.modalBackgroundColor, // Usa helper capturado
      builder: (modalContext) {
        // Usa modalContext para evitar conflitos
        return Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 24.0,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 16.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child:
                        isDespesa
                            ? Text(
                              'Nova Despesa',
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                                color:
                                    helper
                                        .onSurfaceColor, // Usa helper capturado
                              ),
                            )
                            : Text(
                              'Nova Receita',
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                                color:
                                    helper
                                        .onSurfaceColor, // Usa helper capturado
                              ),
                            ),
                  ),
                  const SizedBox(height: 24.0),
                  CustomTextFormField(
                    labelText: 'Nome Movimentação',
                    hintText: 'Digite um nome para movimentação',
                    controller: TextEditingController(),
                    prefixIcon: const Icon(Icons.edit),
                    onChanged: (value) {
                      viewmodel.setNomeMovimentacao(value);
                    },
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 14.0),
                  CustomTextFormField(
                    labelText: 'Valor',
                    hintText: 'Digite o valor',
                    controller: valorController,
                    isCurrency: true,
                    onChanged: (value) {
                      // Remove pontos de separadores de milhar
                      final rawValue = value.replaceAll('.', '');

                      // Substitui vírgula por ponto
                      final formattedValue = rawValue.replaceAll(',', '.');

                      // Tenta parsear o valor para double
                      final parsedValue =
                          double.tryParse(formattedValue) ?? 0.0;

                      // Atualiza o valor no viewmodel
                      if (isDespesa) {
                        viewmodel.setValor(-parsedValue);
                      } else {
                        viewmodel.setValor(parsedValue);
                      }
                    },
                  ),
                  const SizedBox(height: 14.0),
                  CustomDateContainer(
                    labelText: 'Data',
                    dataSelecionada: viewmodel.dataSelecionada,
                    onTap: () async {
                      DateTime? selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now().subtract(
                          const Duration(days: 365),
                        ),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (selectedDate != null) {
                        viewmodel.setDataSelecionada(selectedDate);
                      }
                    },
                  ),
                  const SizedBox(height: 14.0),
                  Observer(
                    builder:
                        (_) => CustomDialogDropdown<CategoriaModel>(
                          items: viewmodel.categoria,
                          itemSelected: viewmodel.categoriaSelecionada,
                          onChange: (categoria) {
                            viewmodel.setCategoria(categoria);
                          },
                          itemLabel: (categoria) => categoria.nome,
                          labelText: 'Categoria',
                          validator:
                              (value) =>
                                  value == null
                                      ? "Selecione uma categoria"
                                      : null,
                          formkey: formKey,
                        ),
                  ),
                  const SizedBox(height: 14.0),
                  CustomTextFormField(
                    labelText: 'Descrição',
                    hintText: 'Descrição',
                    controller: TextEditingController(),
                    prefixIcon: const Icon(Icons.description),
                    onChanged: (value) {},
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 16.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Cancelar',
                            style: TextStyle(
                              fontSize: 16.0,
                              color:
                                  helper
                                      .errorColor, // Cor adaptativa para cancelar
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              // Define se é saída baseado no tipo de movimentação
                              viewmodel.setIsSaida(isDespesa);

                              final movimentacao =
                                  viewmodel.createMovimentacaoFromForm();

                              if (movimentacao != null) {
                                // Salva no banco de dados e sincroniza (já adiciona na lista automaticamente)
                                await viewmodel.gravarMovimentacao(
                                  movimentacao,
                                );

                                // Limpa o form e fecha o modal
                                valorController.clear();
                                Modular.to.pop();
                              } else {
                                // Mostra erro se não conseguir criar a movimentação
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Erro: Usuário não autenticado ou dados inválidos',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0XFF7AE49A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              side: const BorderSide(
                                color: Colors.black,
                              ), // Added black border
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 14.0,
                              horizontal: 24.0,
                            ),
                            elevation: 6.0,
                          ),
                          child: const Text(
                            'Confirmar',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Color(0XFF005218),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Constrói a lista de transações agrupadas por data e ordenadas como pilha
  Widget _buildTransactionsList() {
    if (viewmodel.movimentacoes.isEmpty) {
      return const SizedBox.shrink();
    }

    // 1. Agrupa as transações por data (sem ordenar ainda)
    final Map<String, List<MovimentacaoModel>> groupedByDate = {};

    for (final transaction in viewmodel.movimentacoes) {
      // Formatar o dia da semana sem "-feira" e com primeira letra maiúscula
      String dayName = DateFormat(
        'EEEE',
        'pt_BR',
      ).format(transaction.dataMovimentacao);
      dayName = dayName.replaceAll('-feira', '');
      dayName = dayName[0].toUpperCase() + dayName.substring(1);

      final dateKey =
          '$dayName, ${DateFormat('dd', 'pt_BR').format(transaction.dataMovimentacao)}';

      if (!groupedByDate.containsKey(dateKey)) {
        groupedByDate[dateKey] = [];
      }
      groupedByDate[dateKey]!.add(transaction);
    }

    // 2. Ordena cada grupo por data/hora completa decrescente (pilha - último primeiro)
    for (final group in groupedByDate.values) {
      group.sort((a, b) => b.dataMovimentacao.compareTo(a.dataMovimentacao));
    }

    // 3. Ordena os grupos de datas por data decrescente (data mais recente primeiro)
    final sortedDateKeys =
        groupedByDate.keys.toList()..sort((a, b) {
          // Pega a primeira transação de cada grupo para comparar as datas
          final dateA = groupedByDate[a]!.first.dataMovimentacao;
          final dateB = groupedByDate[b]!.first.dataMovimentacao;
          return dateB.compareTo(dateA); // Decrescente
        });

    // 4. Constrói a lista de widgets
    final List<Widget> widgets = [];

    for (final dateKey in sortedDateKeys) {
      final transactions = groupedByDate[dateKey]!;

      // Header da data
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateKey,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppThemeHelper.of(context).onSurfaceColor,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
              // Divider/underline mais grosso e da mesma cor do texto
              Container(
                height: 3,
                width: 80,
                decoration: BoxDecoration(
                  color: AppThemeHelper.of(
                    context,
                  ).onSurfaceColor.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ],
          ),
        ),
      );

      // Transações do dia (já ordenadas como pilha)
      for (final transaction in transactions) {
        widgets.add(_cardTransacao(transaction));
      }
    }

    // Adiciona espaço para o FAB
    widgets.add(const SizedBox(height: 100));

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: widgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    final helper = AppThemeHelper.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Observer para detectar mudanças no shouldOpenDialog
          Observer(
            builder: (_) {
              // Lógica igual ao app antigo: verifica shouldOpenDialog no build e abre instantaneamente
              debugPrint('🏠 Home Observer: shouldOpenDialog = ${viewmodel.shouldOpenDialog}');
              if (viewmodel.shouldOpenDialog) {
                debugPrint('🏠 Home Observer: Flag detectada, abrindo modal...');
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  debugPrint('🏠 Home Observer: PostFrameCallback executando...');
                  showDialogDespesaReceita(context);
                  viewmodel.isDialogOpen(false);
                  debugPrint('🏠 Home Observer: Modal aberto e flag resetada');
                });
              }
              return const SizedBox.shrink();
            },
          ),
          
          // Conteúdo principal com header fixo
          Column(
            children: [
              // Header fixo (AppBar + Barra de pesquisa)
              SafeArea(
                child: Column(
                  children: [
                    AppBarContainer(helper: helper),
                    barraDePesquisa(helper),
                  ],
                ),
              ),
              // Lista de transações expansível
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await viewmodel.carregarMovimentacoes();
                  },
                  child: Observer(
                    builder: (_) {
                      if (viewmodel.carregou) {
                        if (viewmodel.movimentacoes.isEmpty) {
                          return ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(32),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.receipt_long_outlined,
                                        size: 64,
                                        color: helper.onSurfaceColor
                                            .withOpacity(0.5),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Nenhuma transação ainda',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: helper.onSurfaceColor,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Toque no + para adicionar sua primeira transação',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: helper.onSurfaceColor
                                              .withOpacity(0.7),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                        return _buildTransactionsList();
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          // Chat bubble (já é Positioned internamente)
          DraggableChatBubble(onTap: _openChatIA),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 64,
        height: 64,
        child: FloatingActionButton(
          onPressed: () {
            showDialogDespesaReceita(context);
          },
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
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 0),
    );
  }

  Padding barraDePesquisa(AppThemeHelper helper) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Material(
        elevation: helper.brightness == Brightness.light ? 2 : 0,
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: TextField(
          style: TextStyle(
            color: helper.onSurfaceColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          cursorColor: helper.colorScheme.primary,
          decoration: InputDecoration(
            filled: true,
            fillColor:
                helper.brightness == Brightness.light
                    ? const Color(0xFFECF3FB)
                    : helper.colorScheme.onSurface.withOpacity(0.08),
            prefixIcon: Icon(
              Icons.search,
              color: helper.onSurfaceColor,
              size: 22,
            ),
            hintText: 'Buscar',
            hintStyle: TextStyle(
              color: helper.onSurfaceColor.withOpacity(0.7),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 0,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(
                color: helper.colorScheme.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardTransacao(MovimentacaoModel movimentacao) {
    final helper = AppThemeHelper.of(context);
    final isSaida = movimentacao.isSaida;

    // Cores adaptativas baseadas no tema
    final cardColor =
        isSaida
            ? helper
                .despesaCardColor // Vermelho adaptativo para DESPESAS
            : helper.receitaCardColor; // Verde adaptativo para RECEITAS

    final iconBg =
        isSaida
            ? helper
                .despesaIconColor // Ícone vermelho adaptativo para DESPESAS
            : helper.receitaIconColor; // Ícone verde adaptativo para RECEITAS

    final valueColor =
        isSaida
            ? helper
                .despesaValueColor // Valor vermelho adaptativo para DESPESA
            : helper.receitaValueColor; // Valor verde adaptativo para RECEITA

    return Observer(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Material(
            color: cardColor,
            borderRadius: BorderRadius.circular(14),
            elevation: helper.brightness == Brightness.light ? 2 : 0,
            shadowColor: Colors.black.withOpacity(0.07),
            child: Slidable(
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                extentRatio: 0.4,
                children: [
                  CustomSlidableAction(
                    onPressed: (context) async {
                      // Confirmação antes de remover
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Remover Transação'),
                              content: Text(
                                'Deseja remover "${movimentacao.nome}"?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(true),
                                  child: const Text('Remover'),
                                ),
                              ],
                            ),
                      );

                      if (confirmed == true) {
                        await viewmodel.removerMovimentacao(movimentacao);
                      }
                    },
                    padding: EdgeInsets.zero,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: helper.colorScheme.error,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          bottomLeft: Radius.circular(15),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delete,
                            color: helper.colorScheme.onError,
                            size: 24,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Remover',
                            style: TextStyle(
                              color: helper.colorScheme.onError,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  CustomSlidableAction(
                    onPressed: (context) {},
                    padding: EdgeInsets.zero,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: helper.colorScheme.secondary,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.more_horiz,
                            color: helper.colorScheme.onSecondary,
                            size: 24,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Mais',
                            style: TextStyle(
                              color: helper.colorScheme.onSecondary,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: iconBg,
                            child: Icon(
                              CategoryIconService.getIconData(
                                viewmodel.categoria
                                    .firstWhere(
                                      (e) => movimentacao.idCategoria == e.id,
                                      orElse: () => CategoriaModel(
                                        id: 0,
                                        nome: 'Categoria não encontrada',
                                        icone: 'category',
                                      ),
                                    )
                                    .icone,
                              ),
                              color: helper.colorScheme.onPrimary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                movimentacao.nome,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: helper.onSurfaceColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                viewmodel.categoria
                                    .firstWhere(
                                      (e) => movimentacao.idCategoria == e.id,
                                      orElse:
                                          () => CategoriaModel(
                                            id: 0,
                                            nome: 'Categoria não encontrada',
                                          ),
                                    )
                                    .nome,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  color: helper.onSurfaceColor.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        viewmodel.canSeeValue
                            ? NumberFormat.currency(
                              locale: 'pt_BR',
                              symbol: 'R\$',
                              decimalDigits: 2,
                            ).format(movimentacao.valor)
                            : 'R\$ ***',
                        style: TextStyle(
                          color: valueColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
