// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:neo_financyuai/app/data/model/categoria_model.dart';
import 'package:neo_financyuai/app/utils/app_theme_helper.dart';
import 'package:neo_financyuai/app/viewmodel/nova_transacao/nova_transacao_viewmodel.dart';
import 'package:neo_financyuai/app/widgets/custom_date_container.dart';
import 'package:neo_financyuai/app/widgets/custom_dialog_drop_down.dart';
import 'package:neo_financyuai/app/widgets/custom_text_form_field.dart';
import 'package:neo_financyuai/app/utils/toastification_utils.dart';

/// Página responsável pela criação de nova transação
/// 
/// Recebe um parâmetro [isDespesa] que define se é uma despesa ou receita
/// e apresenta o formulário apropriado para cada tipo de transação.
class NovaTransacaoPage extends StatefulWidget {
  final bool isDespesa;

  const NovaTransacaoPage({
    super.key,
    required this.isDespesa,
  });

  @override
  State<NovaTransacaoPage> createState() => _NovaTransacaoPageState();
}

class _NovaTransacaoPageState extends State<NovaTransacaoPage> {
  final viewmodel = Modular.get<NovaTransacaoViewmodel>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late TextEditingController nomeController;
  late TextEditingController valorController;
  late TextEditingController descricaoController;
  late TextEditingController quantidadeParcelasController;
  late TextEditingController parcelaInicialController;
  late TextEditingController intervaloPersonalizadoController;
  late TextEditingController quantidadeRepeticoesController;
  bool _recorrenciaExpanded = false;
  bool _prefilledEdicao = false;
  bool _isEdicao = false;

  @override
  void initState() {
    super.initState();
    nomeController = TextEditingController();
    valorController = TextEditingController();
    descricaoController = TextEditingController();
    quantidadeParcelasController = TextEditingController();
    parcelaInicialController = TextEditingController();
    intervaloPersonalizadoController = TextEditingController();
    quantidadeRepeticoesController = TextEditingController();
    
    // Define o tipo de transação
    viewmodel.setIsSaida(widget.isDespesa);
    
    // Carrega as categorias
    viewmodel.carregarCategorias();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Verifica se há argumentos de edição
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (!_prefilledEdicao && arguments != null && arguments['isEdicao'] == true) {
      _preencherDadosEdicao(arguments);
    }
  }

  void _preencherDadosEdicao(Map<String, dynamic> arguments) {
    final movimentacao = arguments['movimentacao'];
    final tipoEdicao = arguments['tipoEdicao'];
    
    if (movimentacao != null) {
      // Preenche os campos básicos
      nomeController.text = movimentacao.nome ?? '';
      // Formata para pt_BR sem símbolo para não deslocar casas ao editar
      if (movimentacao.valor != null) {
        final valorAbs = (movimentacao.valor as num).toDouble().abs();
        final texto = valorAbs.toStringAsFixed(2).replaceAll('.', ',');
        valorController.text = texto;
      } else {
        valorController.text = '';
      }
      descricaoController.text = movimentacao.descricao ?? '';
      
      // Define os valores no viewmodel
      viewmodel.setNomeMovimentacao(movimentacao.nome ?? '');
      viewmodel.setValor(movimentacao.valor ?? 0.0);
      viewmodel.setDescricao(movimentacao.descricao ?? '');
      
      // Define a data
      viewmodel.setDataSelecionada(movimentacao.dataMovimentacao ?? DateTime.now());
      
      // Define a categoria
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final categoria = viewmodel.categorias.firstWhere(
          (cat) => cat.id == movimentacao.idCategoria,
          orElse: () => viewmodel.categorias.isNotEmpty ? viewmodel.categorias.first : CategoriaModel(id: 0, nome: '', icone: ''),
        );
        if (categoria.id != 0) {
          viewmodel.setCategoria(categoria);
        }
      });
      
      // Se for transação recorrente, identifica o tipo
      final id = movimentacao.id ?? '';
      if (id.contains('_parcela_') || id.contains('_fixa_')) {
        viewmodel.setIsRecorrente(true);
        _recorrenciaExpanded = false;
        
        if (id.contains('_parcela_')) {
          viewmodel.setTipoRecorrencia('parcelas');
          // Tenta extrair o número da parcela atual
          final partes = id.split('_parcela_');
          if (partes.length > 1) {
            final numeroAtual = int.tryParse(partes.last);
            if (numeroAtual != null) {
              parcelaInicialController.text = numeroAtual.toString();
              viewmodel.setParcelaInicial(numeroAtual);
            }
          }
        } else if (id.contains('_fixa_')) {
          viewmodel.setTipoRecorrencia('fixo');
          viewmodel.setPeriodoRecorrencia('mensal'); // Padrão
        }
      }
      
      // Armazena informações da edição no viewmodel
      _configurarModoEdicao(movimentacao, tipoEdicao);
    }
    _prefilledEdicao = true;
  }

  void _configurarModoEdicao(dynamic movimentacao, String? tipoEdicao) {
    // Por enquanto, apenas definir que estamos em modo de edição
    // Em futuras implementações, isso pode ser usado para:
    // - Alterar o texto do botão (Salvar -> Atualizar)
    // - Modificar a lógica de salvamento
    // - Etc.
    viewmodel.setEditMode(movimentacao);
    setState(() {
      _isEdicao = true;
    });
  }

  @override
  void dispose() {
    nomeController.dispose();
    valorController.dispose();
    descricaoController.dispose();
    quantidadeParcelasController.dispose();
    parcelaInicialController.dispose();
    intervaloPersonalizadoController.dispose();
    quantidadeRepeticoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final helper = AppThemeHelper.of(context);
    final accentColor = widget.isDespesa ? helper.colorScheme.error : helper.colorScheme.primary;

    return Scaffold(
      backgroundColor: helper.colorScheme.background,
      appBar: AppBar(
        backgroundColor: helper.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Modular.to.pop(),
          icon: Icon(
            Icons.arrow_back,
            color: helper.onSurfaceColor,
          ),
        ),
        title: Text(
          _isEdicao
              ? (widget.isDespesa ? 'Editar Despesa' : 'Editar Receita')
              : (widget.isDespesa ? 'Nova Despesa' : 'Nova Receita'),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: helper.onSurfaceColor,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
      ),
      body: Observer(
        builder: (_) {
          if (viewmodel.carregandoCategorias) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              ),
            );
          }

          return Form(
            key: formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Campo Nome da Transação
                  CustomTextFormField(
                    labelText: 'Nome da Transação',
                    hintText: 'Digite um nome para a transação',
                    controller: nomeController,
                    prefixIcon: const Icon(Icons.edit),
                    backgroundColor: Colors.white,
                    onChanged: (value) {
                      viewmodel.setNomeMovimentacao(value);
                    },
                    textCapitalization: TextCapitalization.sentences,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nome da transação é obrigatório';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20.0),

                  // Campo Valor
                  CustomTextFormField(
                    labelText: 'Valor',
                    hintText: 'R\$ 0,00',
                    controller: valorController,
                    isCurrency: true,
                    backgroundColor: Colors.white,
                    prefixIcon: const Icon(Icons.attach_money),
                    onChanged: (value) {
                      // Listener de moeda envia geralmente "1800.0"; se vier formatado, faz fallback robusto
                      double? parsedValue = double.tryParse(value);
                      parsedValue ??= double.tryParse(
                        value.replaceAll('.', '').replaceAll(',', '.'),
                      );
                      viewmodel.setValor(parsedValue ?? 0.0);
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Valor é obrigatório';
                      }
                      
                      // Aceita tanto string numérica quanto texto formatado pt-BR
                      double? parsedValue = double.tryParse(value);
                      parsedValue ??= double.tryParse(
                        value.replaceAll('.', '').replaceAll(',', '.'),
                      );
                      
                      if ((parsedValue ?? 0.0) <= 0) {
                        return 'Valor deve ser maior que zero';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20.0),

                  // Campo Data
                  Observer(
                    builder: (_) => CustomDateContainer(
                      labelText: 'Data',
                      dataSelecionada: viewmodel.dataSelecionada,
                      backgroundColor: Colors.white,
                      onTap: () async {
                        DateTime? selectedDate = await showDatePicker(
                          context: context,
                          initialDate: viewmodel.dataSelecionada,
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
                  ),
                  const SizedBox(height: 20.0),

                  // Campo Categoria
                  Observer(
                    builder: (_) => CustomDialogDropdown<CategoriaModel>(
                      items: viewmodel.categorias,
                      itemSelected: viewmodel.categoriaSelecionada,
                      onChange: (categoria) {
                        viewmodel.setCategoria(categoria);
                      },
                      itemLabel: (categoria) => categoria.nome,
                      labelText: 'Categoria',
                      validator: (value) => null,
                      formkey: formKey,
                    ),
                  ),
                  const SizedBox(height: 20.0),

                  // Campo Descrição (opcional)
                  CustomTextFormField(
                    labelText: 'Descrição (Opcional)',
                    hintText: 'Adicione uma descrição...',
                    controller: descricaoController,
                    prefixIcon: const Icon(Icons.description),
                    backgroundColor: Colors.white,
                    onChanged: (value) {
                      viewmodel.setDescricao(value);
                    },
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 20.0),

                  // Seção de Recorrência
                  Observer(
                    builder: (_) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.transparent,
                        ),
                        child: IgnorePointer(
                          ignoring: _isEdicao,
                          child: ExpansionTile(
                          initiallyExpanded: _recorrenciaExpanded && !_isEdicao,
                          onExpansionChanged: (expanded) {
                            if (_isEdicao) return;
                            setState(() {
                              _recorrenciaExpanded = expanded;
                            });
                          },
                          title: Row(
                            children: [
                              Icon(
                                Icons.repeat,
                                color: helper.primaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Transação Recorrente',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: helper.onSurfaceColor,
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (viewmodel.isRecorrente)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: helper.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Ativo',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: helper.primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              Icon(
                                _recorrenciaExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                color: helper.onSurfaceColor.withOpacity(0.6),
                              ),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Switch para ativar recorrência
                                    Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Ativar transação recorrente',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: viewmodel.camposBasicosPreenchidos 
                                                ? helper.onSurfaceColor 
                                                : Colors.grey.shade500,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Switch.adaptive(
                                        value: viewmodel.isRecorrente && viewmodel.camposBasicosPreenchidos,
                                        onChanged: viewmodel.camposBasicosPreenchidos 
                                            ? (value) {
                                                viewmodel.setIsRecorrente(value);
                                              }
                                            : null,
                                        activeColor: helper.primaryColor,
                                      ),
                                    ],
                                  ),
                                  
                                  // Mensagem explicativa quando campos não estão preenchidos
                                  if (!viewmodel.camposBasicosPreenchidos) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.orange.shade200),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.info_outline, color: Colors.orange.shade600, size: 16),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Preencha o nome e valor da transação para ativar a recorrência.',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.orange.shade700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  
                                  if (viewmodel.isRecorrente && viewmodel.camposBasicosPreenchidos) ...[
                                    const SizedBox(height: 20),
                                    
                                    // Tipo de recorrência (Parcelas ou Pagamento Fixo)
                                    Text(
                                      'Tipo de Recorrência',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: helper.onSurfaceColor,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    
                                    Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => viewmodel.setTipoRecorrencia('parcelas'),
                                            child: Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: viewmodel.tipoRecorrencia == 'parcelas'
                                                    ? helper.primaryColor.withOpacity(0.1)
                                                    : Colors.grey.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: viewmodel.tipoRecorrencia == 'parcelas'
                                                      ? helper.primaryColor
                                                      : Colors.grey.withOpacity(0.3),
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: Column(
                                                children: [
                                                  Icon(
                                                    Icons.credit_card,
                                                    color: viewmodel.tipoRecorrencia == 'parcelas'
                                                        ? helper.primaryColor
                                                        : Colors.grey,
                                                    size: 24,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    'Parcelas',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                      color: viewmodel.tipoRecorrencia == 'parcelas'
                                                          ? helper.primaryColor
                                                          : Colors.grey,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Ex: Parcelei em 12x',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.grey.shade600,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => viewmodel.setTipoRecorrencia('fixo'),
                                            child: Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: viewmodel.tipoRecorrencia == 'fixo'
                                                    ? helper.primaryColor.withOpacity(0.1)
                                                    : Colors.grey.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: viewmodel.tipoRecorrencia == 'fixo'
                                                      ? helper.primaryColor
                                                      : Colors.grey.withOpacity(0.3),
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: Column(
                                                children: [
                                                  Icon(
                                                    Icons.repeat,
                                                    color: viewmodel.tipoRecorrencia == 'fixo'
                                                        ? helper.primaryColor
                                                        : Colors.grey,
                                                    size: 24,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    'Pagamento Fixo',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                      color: viewmodel.tipoRecorrencia == 'fixo'
                                                          ? helper.primaryColor
                                                          : Colors.grey,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Ex: Aluguel todo mês',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.grey.shade600,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    if (viewmodel.tipoRecorrencia == 'parcelas') ...[
                                      const SizedBox(height: 20),
                                      
                                      // Configuração de Parcelas
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Parcelas',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: helper.onSurfaceColor,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                CustomTextFormField(
                                                  labelText: 'Ex: 12',
                                                  hintText: 'Quantidade de parcelas',
                                                  controller: quantidadeParcelasController,
                                                  keyboardType: TextInputType.number,
                                                  backgroundColor: Colors.grey.shade50,
                                                  onChanged: (value) {
                                                    final parcelas = int.tryParse(value) ?? 1;
                                                    viewmodel.setQuantidadeParcelas(parcelas);
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            flex: 2,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Parcela Atual',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: helper.onSurfaceColor,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                CustomTextFormField(
                                                  labelText: 'Ex: 4',
                                                  hintText: 'Parcela atual',
                                                  controller: parcelaInicialController,
                                                  keyboardType: TextInputType.number,
                                                  backgroundColor: Colors.grey.shade50,
                                                  onChanged: (value) {
                                                    final parcela = int.tryParse(value) ?? 1;
                                                    viewmodel.setParcelaInicial(parcela);
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.blue.shade200),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.info_outline, color: Colors.blue.shade600, size: 16),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Se você já está pagando a 4ª parcela, coloque "4" em parcela atual. O app criará as parcelas restantes.',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.blue.shade700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      const SizedBox(height: 20),
                                      
                                      // Tipo de valor das parcelas
                                      Text(
                                        'Como interpretar o valor informado?',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: helper.onSurfaceColor,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      
                                      Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () => viewmodel.setTipoValorParcela('valor_parcela'),
                                            child: Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: viewmodel.tipoValorParcela == 'valor_parcela'
                                                    ? helper.primaryColor.withOpacity(0.1)
                                                    : Colors.grey.withOpacity(0.05),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: viewmodel.tipoValorParcela == 'valor_parcela'
                                                      ? helper.primaryColor
                                                      : Colors.grey.withOpacity(0.3),
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    viewmodel.tipoValorParcela == 'valor_parcela'
                                                        ? Icons.radio_button_checked
                                                        : Icons.radio_button_unchecked,
                                                    color: viewmodel.tipoValorParcela == 'valor_parcela'
                                                        ? helper.primaryColor
                                                        : Colors.grey,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          'Valor de cada parcela',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w600,
                                                            color: viewmodel.tipoValorParcela == 'valor_parcela'
                                                                ? helper.primaryColor
                                                                : helper.onSurfaceColor,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 4),
                                                        Text(
                                                          viewmodel.exemploValorParcela,
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.grey.shade600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          
                                          const SizedBox(height: 12),
                                          
                                          GestureDetector(
                                            onTap: () => viewmodel.setTipoValorParcela('valor_total'),
                                            child: Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: viewmodel.tipoValorParcela == 'valor_total'
                                                    ? helper.primaryColor.withOpacity(0.1)
                                                    : Colors.grey.withOpacity(0.05),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: viewmodel.tipoValorParcela == 'valor_total'
                                                      ? helper.primaryColor
                                                      : Colors.grey.withOpacity(0.3),
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    viewmodel.tipoValorParcela == 'valor_total'
                                                        ? Icons.radio_button_checked
                                                        : Icons.radio_button_unchecked,
                                                    color: viewmodel.tipoValorParcela == 'valor_total'
                                                        ? helper.primaryColor
                                                        : Colors.grey,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          'Valor total a dividir',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w600,
                                                            color: viewmodel.tipoValorParcela == 'valor_total'
                                                                ? helper.primaryColor
                                                                : helper.onSurfaceColor,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 4),
                                                        Text(
                                                          viewmodel.exemploValorTotal,
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.grey.shade600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    
                                    if (viewmodel.tipoRecorrencia.isNotEmpty) ...[
                                      const SizedBox(height: 20),
                                      
                                      // Período de recorrência
                                      Text(
                                        'Período de Repetição',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: helper.onSurfaceColor,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      
                                      DropdownButtonFormField<String>(
                                        value: viewmodel.periodoRecorrencia,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.grey.shade50,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: Colors.grey.shade300),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: Colors.grey.shade300),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: helper.primaryColor),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        ),
                                        items: const [
                                          DropdownMenuItem(value: 'diario', child: Text('Diário')),
                                          DropdownMenuItem(value: 'semanal', child: Text('Semanal')),
                                          DropdownMenuItem(value: 'mensal', child: Text('Mensal')),
                                          DropdownMenuItem(value: 'anual', child: Text('Anual')),
                                          DropdownMenuItem(value: 'personalizado', child: Text('Personalizado')),
                                        ],
                                        onChanged: (value) {
                                          if (value != null) {
                                            viewmodel.setPeriodoRecorrencia(value);
                                          }
                                        },
                                      ),
                                      
                                      if (viewmodel.periodoRecorrencia == 'personalizado') ...[
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: CustomTextFormField(
                                                labelText: 'A cada',
                                                hintText: 'Ex: 2',
                                                controller: intervaloPersonalizadoController,
                                                keyboardType: TextInputType.number,
                                                backgroundColor: Colors.grey.shade50,
                                                onChanged: (value) {
                                                  final intervalo = int.tryParse(value) ?? 1;
                                                  viewmodel.setIntervaloPersonalizado(intervalo);
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              flex: 2,
                                              child: DropdownButtonFormField<String>(
                                                value: viewmodel.unidadePersonalizada,
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: Colors.grey.shade50,
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                    borderSide: BorderSide(color: helper.primaryColor),
                                                  ),
                                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                ),
                                                items: const [
                                                  DropdownMenuItem(value: 'dias', child: Text('dias')),
                                                  DropdownMenuItem(value: 'semanas', child: Text('semanas')),
                                                  DropdownMenuItem(value: 'meses', child: Text('meses')),
                                                  DropdownMenuItem(value: 'anos', child: Text('anos')),
                                                ],
                                                onChanged: (value) {
                                                  if (value != null) {
                                                    viewmodel.setUnidadePersonalizada(value);
                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      
                                      // if (viewmodel.tipoRecorrencia == 'fixo') ...[
                                      //   const SizedBox(height: 20),
                                      //   Text(
                                      //     'Quantidade de Repetições (Opcional)',
                                      //     style: TextStyle(
                                      //       fontSize: 14,
                                      //       fontWeight: FontWeight.w600,
                                      //       color: helper.onSurfaceColor,
                                      //     ),
                                      //   ),
                                      //   const SizedBox(height: 8),
                                      //   CustomTextFormField(
                                      //     labelText: 'Ex: 12 (deixe vazio para infinito)',
                                      //     hintText: 'Quantidade de repetições',
                                      //     controller: quantidadeRepeticoesController,
                                      //     keyboardType: TextInputType.number,
                                      //     backgroundColor: Colors.grey.shade50,
                                      //     onChanged: (value) {
                                      //       final quantidade = value.isEmpty ? null : int.tryParse(value);
                                      //       viewmodel.setQuantidadeRepeticoes(quantidade);
                                      //     },
                                      //   ),
                                      //   const SizedBox(height: 8),
                                      //   Text(
                                      //     'Se deixar vazio, as transações continuarão sendo criadas indefinidamente.',
                                      //     style: TextStyle(
                                      //       fontSize: 12,
                                      //       color: Colors.grey.shade600,
                                      //       fontStyle: FontStyle.italic,
                                      //     ),
                                      //   ),
                                      // ],
                                    ],
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                  const SizedBox(height: 40.0),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: Observer(
        builder: (_) => FloatingActionButton(
          onPressed: viewmodel.salvandoTransacao ? null : _salvarTransacao,
          backgroundColor: accentColor,
          foregroundColor: widget.isDespesa ? helper.colorScheme.onError : helper.colorScheme.onPrimary,
          elevation: 6,
          child: viewmodel.salvandoTransacao
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.isDespesa ? helper.colorScheme.onError : helper.colorScheme.onPrimary,
                    ),
                  ),
                )
              : const Icon(Icons.save, size: 24),
        ),
      ),
    );
  }

  Future<void> _salvarTransacao() async {
    print('DEBUG: Iniciando salvamento de transação');
    
    if (!formKey.currentState!.validate()) {
      print('DEBUG: Formulário não validou');
      return;
    }
    
    print('DEBUG: isFormValid = ${viewmodel.isFormValid}');
    print('DEBUG: isRecorrente = ${viewmodel.isRecorrente}');
    print('DEBUG: tipoRecorrencia = ${viewmodel.tipoRecorrencia}');

    if (!viewmodel.isFormValid) {
      print('DEBUG: Formulário inválido - dados insuficientes');
      ToastificationUtils.error(
        title: 'Erro',
        message: 'Usuário não autenticado ou dados inválidos',
        context: context,
      );
      return;
    }

    // Edição ou criação
    bool sucesso = false;
    if (_isEdicao && viewmodel.movimentacaoOriginal != null) {
      final original = viewmodel.movimentacaoOriginal!;
      final atualizado = viewmodel.buildUpdatedMovimentacao(original.id!);
      if (atualizado == null) {
        ToastificationUtils.error(
          title: 'Erro ao preparar atualização',
          context: context,
        );
        return;
      }

      final idOrig = original.id ?? '';
      final isRecorrente = idOrig.contains('_parcela_') || idOrig.contains('_fixa_');
      if (isRecorrente) {
        // Pergunta escopo no momento de salvar
        final escopo = await _showEscopoEdicaoModal(context);
        if (escopo == null) return; // usuário cancelou
        sucesso = await viewmodel.aplicarAtualizacaoPorEscopo(atualizado, escopo);
      } else {
        // Atualiza apenas esta
        sucesso = await viewmodel.gravarMovimentacao(atualizado);
      }
    } else {
      final movimentacao = viewmodel.createMovimentacaoFromForm();
      if (movimentacao == null) {
        print('DEBUG: Erro ao criar movimentação');
        ToastificationUtils.error(
          title: 'Erro ao criar transação',
          context: context,
        );
        return;
      }
      print('DEBUG: Movimentação criada: ${movimentacao.nome}');
      sucesso = await viewmodel.gravarMovimentacao(movimentacao);
    }
    
  if (sucesso) {
      // Limpa o formulário
      viewmodel.limparFormulario();
      nomeController.clear();
      valorController.clear();
      descricaoController.clear();
      
      // Mostra sucesso e volta para a tela anterior
      if (!mounted) return;
      if (_isEdicao) {
        ToastificationUtils.success(
          title: '${widget.isDespesa ? 'Despesa' : 'Receita'} atualizada com sucesso!',
          context: context,
        );
      } else {
        ToastificationUtils.success(
          title: '${widget.isDespesa ? 'Despesa' : 'Receita'} salva com sucesso!',
          context: context,
        );
      }

  if (!mounted) return;
  Modular.to.pop();
      
    } else {
      if (!mounted) return;
      ToastificationUtils.error(
        title: 'Erro ao salvar transação',
        context: context,
      );
    }
  }

  Future<String?> _showEscopoEdicaoModal(BuildContext context) async {
    final helper = AppThemeHelper.of(context);
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return Container(
          decoration: BoxDecoration(
            color: helper.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: helper.onSurfaceColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: helper.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Icon(
                      Icons.edit_outlined,
                      size: 32,
                      color: helper.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Aplicar alterações em',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: helper.onSurfaceColor,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Escolha onde deseja aplicar esta edição',
                    style: TextStyle(
                      fontSize: 14,
                      color: helper.onSurfaceColor.withOpacity(0.7),
                      fontFamily: 'Poppins',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  _buildEditScopeOption(
                    modalContext,
                    icon: Icons.event_outlined,
                    title: 'Apenas este mês',
                    subtitle: 'Edita somente esta ocorrência',
                    color: Colors.orange,
                    value: 'apenas_esta',
                  ),
                  const SizedBox(height: 12),
                  _buildEditScopeOption(
                    modalContext,
                    icon: Icons.arrow_forward_outlined,
                    title: 'A partir deste mês',
                    subtitle: 'Edita esta e as próximas ocorrências',
                    color: Colors.amber.shade700,
                    value: 'desta_pra_frente',
                  ),
                  const SizedBox(height: 12),
                  _buildEditScopeOption(
                    modalContext,
                    icon: Icons.edit_calendar_outlined,
                    title: 'Todas as ocorrências',
                    subtitle: 'Edita toda a série de transações',
                    color: helper.colorScheme.primary,
                    value: 'todas_relacionadas',
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.of(modalContext).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 16,
                          color: helper.onSurfaceColor.withOpacity(0.7),
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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

  Widget _buildEditScopeOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required String value,
  }) {
    final helper = AppThemeHelper.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(value),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
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
                        fontWeight: FontWeight.w600,
                        color: helper.onSurfaceColor,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: helper.onSurfaceColor.withOpacity(0.7),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: helper.onSurfaceColor.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Removido: substituído por ToastificationUtils
}