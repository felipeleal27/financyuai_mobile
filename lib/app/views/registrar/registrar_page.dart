import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:neo_financyuai/app/utils/app_theme_helper.dart';
import 'package:neo_financyuai/app/viewmodel/registrar/registrar_viewmodel.dart';
import 'package:neo_financyuai/app/widgets/custom_text_form_field.dart';

/// Página dedicada para registro de novos usuários
class RegistrarPage extends StatefulWidget {
  const RegistrarPage({super.key});

  @override
  State<RegistrarPage> createState() => _RegistrarPageState();
}

class _RegistrarPageState extends State<RegistrarPage> {
  final viewmodel = Modular.get<RegistrarViewmodel>();
  
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
        title: Text(
          'Criar Conta',
          style: TextStyle(
            color: helper.onSurfaceColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Logo/Header
              _buildHeader(helper),

              const SizedBox(height: 40),

              // Formulário de Registro
              _buildRegistrationForm(helper),

              const SizedBox(height: 24),

              // Botão de Registro
              _buildRegisterButton(helper),

              const SizedBox(height: 16),

              // Divisor
              _buildDivider(helper),

              const SizedBox(height: 16),

              // Botão Google
              _buildGoogleButton(helper),

              const SizedBox(height: 24),

              // Link para Login
              _buildLoginLink(helper),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppThemeHelper helper) {
    return Column(
      children: [
        // Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                helper.colorScheme.primary,
                helper.colorScheme.primary.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: helper.colorScheme.primary.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(
            Icons.person_add_rounded,
            color: helper.colorScheme.onPrimary,
            size: 40,
          ),
        ),
        
        const SizedBox(height: 24),
        
        Text(
          'Crie sua conta',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: helper.onSurfaceColor,
            fontFamily: 'Poppins',
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'Preencha os dados abaixo para começar',
          style: TextStyle(
            fontSize: 16,
            color: helper.onSurfaceColor.withOpacity(0.6),
            fontFamily: 'Poppins',
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRegistrationForm(AppThemeHelper helper) {
    return Observer(
      builder: (_) => Form(
        key: _formKey,
        child: Column(
          children: [
            // Mensagens de erro/sucesso
            if (viewmodel.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: helper.colorScheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: helper.colorScheme.error.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: helper.colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        viewmodel.errorMessage!,
                        style: TextStyle(
                          color: helper.colorScheme.error,
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (viewmodel.successMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        viewmodel.successMessage!,
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Nome
            CustomTextFormField(
              controller: _nameController,
              labelText: 'Nome completo',
              hintText: 'Digite seu nome completo',
              prefixIcon: const Icon(Icons.person_outline),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nome é obrigatório';
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
              controller: _emailController,
              labelText: 'Email',
              hintText: 'Digite seu email',
              prefixIcon: const Icon(Icons.email_outlined),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email é obrigatório';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Email inválido';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Senha
            CustomTextFormField(
              controller: _passwordController,
              labelText: 'Senha',
              hintText: 'Digite sua senha',
              prefixIcon: const Icon(Icons.lock_outline),
              isPassword: true,
              isObscureText: !viewmodel.showPassword,
              suffixIcon: IconButton(
                onPressed: viewmodel.togglePasswordVisibility,
                icon: Icon(
                  viewmodel.showPassword ? Icons.visibility_off : Icons.visibility,
                  color: helper.colorScheme.primary,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Senha é obrigatória';
                }
                if (value.length < 6) {
                  return 'Senha deve ter pelo menos 6 caracteres';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Confirmar Senha
            CustomTextFormField(
              controller: _confirmPasswordController,
              labelText: 'Confirmar senha',
              hintText: 'Digite sua senha novamente',
              prefixIcon: const Icon(Icons.lock_outline),
              isPassword: true,
              isObscureText: !viewmodel.showConfirmPassword,
              suffixIcon: IconButton(
                onPressed: viewmodel.toggleConfirmPasswordVisibility,
                icon: Icon(
                  viewmodel.showConfirmPassword ? Icons.visibility_off : Icons.visibility,
                  color: helper.colorScheme.primary,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Confirmação de senha é obrigatória';
                }
                if (value != _passwordController.text) {
                  return 'Senhas não coincidem';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterButton(AppThemeHelper helper) {
    return Observer(
      builder: (_) => ElevatedButton(
        onPressed: viewmodel.isLoading ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: helper.colorScheme.primary,
          foregroundColor: helper.colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: viewmodel.isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: helper.colorScheme.onPrimary,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Criar Conta',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
      ),
    );
  }

  Widget _buildDivider(AppThemeHelper helper) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: helper.onSurfaceColor.withOpacity(0.2),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'ou',
            style: TextStyle(
              color: helper.onSurfaceColor.withOpacity(0.6),
              fontSize: 14,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: helper.onSurfaceColor.withOpacity(0.2),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleButton(AppThemeHelper helper) {
    return Observer(
      builder: (_) => OutlinedButton.icon(
        onPressed: viewmodel.isLoading ? null : _handleGoogleSignIn,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(
            color: helper.onSurfaceColor.withOpacity(0.2),
          ),
        ),
        icon: Image.asset(
          'assets/img/google-logo.png',
          width: 20,
          height: 20,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.g_mobiledata,
            color: helper.onSurfaceColor,
            size: 24,
          ),
        ),
        label: Text(
          'Continuar com Google',
          style: TextStyle(
            color: helper.onSurfaceColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink(AppThemeHelper helper) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Já tem uma conta? ',
          style: TextStyle(
            color: helper.onSurfaceColor.withOpacity(0.6),
            fontSize: 14,
            fontFamily: 'Poppins',
          ),
        ),
        TextButton(
          onPressed: () => Modular.to.pop(),
          child: Text(
            'Fazer login',
            style: TextStyle(
              color: helper.colorScheme.primary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ],
    );
  }

  void _handleRegister() async {
    viewmodel.clearMessages();
    
    if (_formKey.currentState?.validate() ?? false) {
      final success = await viewmodel.registerWithEmailAndPassword(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
        _confirmPasswordController.text,
      );

      if (success && mounted) {
        // Aguarda um momento para mostrar a mensagem de sucesso
        await Future.delayed(const Duration(seconds: 1));
        Modular.to.navigate('/home/');
      }
    }
  }

  void _handleGoogleSignIn() async {
    viewmodel.clearMessages();
    
    final success = await viewmodel.signInWithGoogle();
    
    if (success && mounted) {
      // Aguarda um momento para mostrar a mensagem de sucesso
      await Future.delayed(const Duration(seconds: 1));
      Modular.to.navigate('/home/');
    }
  }
}
