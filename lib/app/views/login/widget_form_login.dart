// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:neo_financyuai/app/utils/toastification_utils.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:neo_financyuai/app/utils/app_theme_helper.dart';
import 'package:neo_financyuai/app/viewmodel/login/login_viewmodel.dart';
import 'package:neo_financyuai/app/views/registrar/module/registar_nome_rotas.dart';
import 'package:neo_financyuai/app/widgets/custom_text_form_field.dart';
import 'package:neo_financyuai/app/widgets/theme_selector.dart';
import 'package:neo_financyuai/app/widgets/oauth_button.dart';

/// Widget de formulário de login customizado.
/// 
/// Apresenta campos de email e senha, botões de ação e animações
/// para uma experiência de usuário fluida na autenticação.
class WidgetFormLogin extends StatefulWidget {
  /// ViewModel que gerencia a lógica de autenticação.
  final LoginViewModel viewmodel;

  /// Cria uma nova instância de [WidgetFormLogin].
  /// 
  /// [viewmodel] é obrigatório para gerenciar o estado de autenticação.
  const WidgetFormLogin({super.key, required this.viewmodel});

  @override
  State<WidgetFormLogin> createState() => _WidgetFormLoginState();
}

/// Estado do widget de formulário de login.
/// 
/// Gerencia animações, controladores de texto e validações do formulário.
class _WidgetFormLoginState extends State<WidgetFormLogin>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final helper = AppThemeHelper.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: helper.isDark
                ? [
                    helper.colorScheme.surface,
                    helper.colorScheme.surface.withOpacity(0.8),
                    helper.colorScheme.primary.withOpacity(0.1),
                  ]
                : [
                    helper.colorScheme.primary.withOpacity(0.1),
                    helper.colorScheme.secondary.withOpacity(0.05),
                    Colors.white,
                  ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Header com botão de tema - menor
                  const SizedBox(
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ThemeToggleButton(),
                      ],
                    ),
                  ),
                  
                  // Conteúdo principal - ocupa o espaço restante
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo e título - menor e mais compacto
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: _buildCompactLogoSection(helper),
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Formulário compacto
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: _buildCompactFormSection(helper),
                            ),
                          ),
                          
                          // Espaço extra para garantir que não corte
                          SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 20 : 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactLogoSection(AppThemeHelper helper) {
    return Column(
      children: [
        // Container com sombra para a logo - menor
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: helper.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: helper.colorScheme.primary.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Image(
            image: AssetImage('assets/img/logo.png'),
            height: 60,
            width: 60,
            fit: BoxFit.contain,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Título com gradiente - menor
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              helper.colorScheme.primary,
              helper.colorScheme.secondary,
            ],
          ).createShader(bounds),
          child: const Text(
            'Financy uAI',
            style: TextStyle(
              fontFamily: 'Shrikhand',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        
        const SizedBox(height: 4),
        
        Text(
          'Sua vida financeira organizada',
          style: TextStyle(
            fontSize: 14,
            color: helper.colorScheme.onSurface.withOpacity(0.7),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactFormSection(AppThemeHelper helper) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: helper.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: helper.colorScheme.shadow.withOpacity(helper.isDark ? 0.3 : 0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bem-vindo de volta!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: helper.colorScheme.onSurface,
            ),
          ),
          
          const SizedBox(height: 6),
          
          Text(
            'Entre com sua conta para continuar',
            style: TextStyle(
              fontSize: 13,
              color: helper.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          
          const SizedBox(height: 24),
          
          _buildCompactFormEmail(helper),
          const SizedBox(height: 16),
          _buildCompactFormSenha(helper),
          const SizedBox(height: 16),
          _buildCompactOptionsRow(helper),
          const SizedBox(height: 24),
          _buildCompactButtons(helper),
        ],
      ),
    );
  }

  Widget _buildCompactFormEmail(AppThemeHelper helper) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: helper.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        CustomTextFormField(
          labelText: "",
          hintText: "Digite seu email",
          prefixIcon: Icon(
            LucideIcons.mail,
            color: helper.colorScheme.primary,
            size: 18,
          ),
          controller: _emailController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, insira seu email';
            }
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
              return 'Por favor, insira um email válido';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCompactFormSenha(AppThemeHelper helper) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Senha',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: helper.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        CustomTextFormField(
          labelText: "",
          hintText: "Digite sua senha",
          controller: _passwordController,
          isObscureText: widget.viewmodel.chengeObscureText,
          prefixIcon: Icon(
            LucideIcons.lock,
            color: helper.colorScheme.primary,
            size: 18,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              widget.viewmodel.chengeObscureText
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: helper.colorScheme.primary,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                widget.viewmodel.toggleObscureText();
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, insira sua senha';
            }
            if (value.length < 6) {
              return 'A senha deve ter pelo menos 6 caracteres';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCompactOptionsRow(AppThemeHelper helper) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              height: 18,
              width: 18,
              child: Checkbox(
                value: true,
                onChanged: (value) {},
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Lembrar senha',
              style: TextStyle(
                fontSize: 12,
                color: helper.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            // widget.viewmodel.recuperarSenha();
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Recuperar senha',
            style: TextStyle(
              fontSize: 12,
              color: helper.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactButtons(AppThemeHelper helper) {
    return Observer(
      builder: (context) => Column(
        children: [
          // Mostrar erro se houver
          if (widget.viewmodel.errorMessage != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: helper.colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: helper.colorScheme.error.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.alertCircle,
                    color: helper.colorScheme.error,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.viewmodel.errorMessage!,
                      style: TextStyle(
                        color: helper.colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: widget.viewmodel.clearError,
                    icon: Icon(
                      LucideIcons.x,
                      color: helper.colorScheme.error,
                      size: 16,
                    ),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ],

          // Botão de login com Google
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                side: BorderSide(
                  color: helper.colorScheme.outline.withOpacity(0.3),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 1,
              ),
              onPressed: widget.viewmodel.isLoading ? null : () async {
                await widget.viewmodel.loginWithGoogle();
              },
              icon: widget.viewmodel.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          helper.colorScheme.primary,
                        ),
                      ),
                    )
                  : const GoogleIcon(size: 20),
              label: Text(
                widget.viewmodel.isLoading ? 'Entrando...' : 'Continuar com Google',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Divisor com "ou"
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: helper.colorScheme.outline.withOpacity(0.3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'ou',
                  style: TextStyle(
                    color: helper.colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: helper.colorScheme.outline.withOpacity(0.3),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Botão de login com email
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: helper.colorScheme.primary,
                foregroundColor: helper.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
                shadowColor: helper.colorScheme.primary.withOpacity(0.3),
              ),
              onPressed: widget.viewmodel.isLoading ? null : () async {
                if (_formKey.currentState?.validate() ?? false) {
                  final email = _emailController.text.trim();
                  final password = _passwordController.text;
                  await widget.viewmodel.loginWithEmailAndPassword(email, password);
                }
              },
              child: widget.viewmodel.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          helper.colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : const Text(
                      'Entrar com Email',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Botão de criar conta
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: helper.colorScheme.primary,
                side: BorderSide(
                  color: helper.colorScheme.primary,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: widget.viewmodel.isLoading ? null : () {
                Modular.to.pushNamed(RegistrarNomeRotas.navigate);
                // _showRegisterDialog(context, helper);
              },
              child: const Text(
                'Criar conta',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Botão de modo offline (se houver usuário salvo)
          Observer(
            builder: (_) => FutureBuilder<bool>(
              future: widget.viewmodel.hasOfflineUser(),
              builder: (context, snapshot) {
                final hasOfflineUser = snapshot.data ?? false;
                
                if (!hasOfflineUser) {
                  return const SizedBox.shrink();
                }
                
                return SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: helper.colorScheme.primary,
                      side: BorderSide(
                        color: helper.colorScheme.primary.withOpacity(0.5),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: widget.viewmodel.isLoading ? null : () async {
                      await widget.viewmodel.loginOffline();
                    },
                    icon: const Icon(
                      LucideIcons.wifiOff,
                      size: 20,
                    ),
                    label: const Text(
                      'Continuar no modo offline',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Mostra dialog de registro de nova conta
  // ignore: unused_element
  void _showRegisterDialog(BuildContext context, AppThemeHelper helper) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: helper.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Criar Nova Conta',
          style: TextStyle(
            color: helper.colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nome
                CustomTextFormField(
                  labelText: "Nome completo",
                  hintText: "Digite seu nome",
                  controller: nameController,
                  prefixIcon: Icon(
                    LucideIcons.user,
                    color: helper.colorScheme.primary,
                    size: 18,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, insira seu nome';
                    }
                    if (value.trim().length < 2) {
                      return 'Nome deve ter pelo menos 2 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Email
                CustomTextFormField(
                  labelText: "Email",
                  hintText: "Digite seu email",
                  controller: emailController,
                  prefixIcon: Icon(
                    LucideIcons.mail,
                    color: helper.colorScheme.primary,
                    size: 18,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Por favor, insira um email válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Senha
                CustomTextFormField(
                  labelText: "Senha",
                  hintText: "Digite sua senha",
                  controller: passwordController,
                  isObscureText: true,
                  prefixIcon: Icon(
                    LucideIcons.lock,
                    color: helper.colorScheme.primary,
                    size: 18,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira sua senha';
                    }
                    if (value.length < 6) {
                      return 'A senha deve ter pelo menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Confirmar senha
                CustomTextFormField(
                  labelText: "Confirmar senha",
                  hintText: "Digite sua senha novamente",
                  controller: confirmPasswordController,
                  isObscureText: true,
                  prefixIcon: Icon(
                    LucideIcons.lock,
                    color: helper.colorScheme.primary,
                    size: 18,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, confirme sua senha';
                    }
                    if (value != passwordController.text) {
                      return 'As senhas não coincidem';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: helper.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Observer(
            builder: (_) => ElevatedButton(
              onPressed: widget.viewmodel.isLoading ? null : () async {
                if (formKey.currentState!.validate()) {
                  try {
                    // Registra o usuário
                    final success = await widget.viewmodel.registerWithEmailAndPassword(
                      emailController.text.trim(),
                      passwordController.text,
                      nameController.text.trim(),
                    );
                    
                    if (success && mounted) {
                      Navigator.pop(context);
                      ToastificationUtils.success(
                        title: 'Conta criada com sucesso!',
                        context: context,
                      );
                    }
                  } catch (e) {
                    // Erro será mostrado pelo viewmodel
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: helper.colorScheme.primary,
                foregroundColor: helper.colorScheme.onPrimary,
              ),
              child: widget.viewmodel.isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Criar Conta'),
            ),
          ),
        ],
      ),
    );
  }
}
