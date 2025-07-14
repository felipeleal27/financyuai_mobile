import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:neo_financyuai/app/utils/app_theme_helper.dart';
import 'package:neo_financyuai/app/viewmodel/auth/auth_viewmodel.dart';
import 'package:neo_financyuai/app/widgets/custom_text_form_field.dart';

/// Página de autenticação (Login/Cadastro)
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with TickerProviderStateMixin {
  final viewmodel = Modular.get<AuthViewmodel>();
  late TabController _tabController;

  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();

  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final helper = AppThemeHelper.of(context);
    
    return Scaffold(
      backgroundColor: helper.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header com logo
            _buildHeader(helper),
            
            // Tabs Login/Cadastro
            _buildTabBar(helper),
            
            // Conteúdo das tabs
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLoginTab(helper),
                  _buildRegisterTab(helper),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppThemeHelper helper) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          // Logo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: helper.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.account_balance_wallet,
              size: 40,
              color: helper.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'FinancYuai',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: helper.onSurfaceColor,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gerencie suas finanças com inteligência',
            style: TextStyle(
              fontSize: 16,
              color: helper.onSurfaceColor.withOpacity(0.7),
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(AppThemeHelper helper) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: helper.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: helper.colorScheme.outline.withOpacity(0.2)),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: helper.colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: helper.colorScheme.onPrimary,
        unselectedLabelColor: helper.onSurfaceColor,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Login'),
          Tab(text: 'Cadastro'),
        ],
      ),
    );
  }

  Widget _buildLoginTab(AppThemeHelper helper) {
    return Observer(
      builder: (_) => SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _loginFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              
              // Email
              CustomTextFormField(
                controller: _loginEmailController,
                labelText: 'Email',
                hintText: 'Digite seu email',
                prefixIcon: const Icon(Icons.email),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
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
                controller: _loginPasswordController,
                labelText: 'Senha',
                hintText: 'Digite sua senha',
                prefixIcon: const Icon(Icons.lock),
                isObscureText: !viewmodel.showPassword,
                suffixIcon: IconButton(
                  onPressed: viewmodel.togglePasswordVisibility,
                  icon: Icon(
                    viewmodel.showPassword ? Icons.visibility_off : Icons.visibility,
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
              
              const SizedBox(height: 24),
              
              // Botão Login
              ElevatedButton(
                onPressed: viewmodel.isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: helper.colorScheme.primary,
                  foregroundColor: helper.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: viewmodel.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Entrar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
              ),
              
              const SizedBox(height: 16),
              
              // Divisor
              Row(
                children: [
                  Expanded(child: Divider(color: helper.colorScheme.outline.withOpacity(0.3))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'ou',
                      style: TextStyle(
                        color: helper.onSurfaceColor.withOpacity(0.6),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: helper.colorScheme.outline.withOpacity(0.3))),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Botão Google
              OutlinedButton.icon(
                onPressed: viewmodel.isLoading ? null : _handleGoogleLogin,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: helper.colorScheme.outline.withOpacity(0.3)),
                ),
                icon: Image.asset(
                  'assets/img/google_logo.png', // Você precisa adicionar este asset
                  height: 20,
                  width: 20,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.g_mobiledata,
                    color: helper.colorScheme.primary,
                  ),
                ),
                label: Text(
                  'Continuar com Google',
                  style: TextStyle(
                    color: helper.onSurfaceColor,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              
              // Mensagem de erro
              if (viewmodel.errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: helper.colorScheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: helper.colorScheme.error.withOpacity(0.3)),
                  ),
                  child: Text(
                    viewmodel.errorMessage!,
                    style: TextStyle(
                      color: helper.colorScheme.error,
                      fontFamily: 'Poppins',
                      fontSize: 14,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Link para página de registro
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Não tem uma conta? ',
                    style: TextStyle(
                      color: helper.onSurfaceColor.withOpacity(0.6),
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  TextButton(
                    onPressed: () => Modular.to.pushNamed('/registrar/'),
                    child: Text(
                      'Criar conta',
                      style: TextStyle(
                        color: helper.colorScheme.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterTab(AppThemeHelper helper) {
    return Observer(
      builder: (_) => SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _registerFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              
              // Nome
              CustomTextFormField(
                controller: _registerNameController,
                labelText: 'Nome',
                hintText: 'Digite seu nome completo',
                prefixIcon: const Icon(Icons.person),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nome é obrigatório';
                  }
                  if (value.length < 2) {
                    return 'Nome deve ter pelo menos 2 caracteres';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Email
              CustomTextFormField(
                controller: _registerEmailController,
                labelText: 'Email',
                hintText: 'Digite seu email',
                prefixIcon: const Icon(Icons.email),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
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
                controller: _registerPasswordController,
                labelText: 'Senha',
                hintText: 'Digite sua senha',
                prefixIcon: const Icon(Icons.lock),
                isObscureText: !viewmodel.showPassword,
                suffixIcon: IconButton(
                  onPressed: viewmodel.togglePasswordVisibility,
                  icon: Icon(
                    viewmodel.showPassword ? Icons.visibility_off : Icons.visibility,
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
                controller: _registerConfirmPasswordController,
                labelText: 'Confirmar Senha',
                hintText: 'Digite sua senha novamente',
                prefixIcon: const Icon(Icons.lock_outline),
                isObscureText: !viewmodel.showConfirmPassword,
                suffixIcon: IconButton(
                  onPressed: viewmodel.toggleConfirmPasswordVisibility,
                  icon: Icon(
                    viewmodel.showConfirmPassword ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirmação de senha é obrigatória';
                  }
                  if (value != _registerPasswordController.text) {
                    return 'Senhas não coincidem';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Botão Cadastrar
              ElevatedButton(
                onPressed: viewmodel.isLoading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: helper.colorScheme.primary,
                  foregroundColor: helper.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: viewmodel.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
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
              
              // Mensagem de erro
              if (viewmodel.errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: helper.colorScheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: helper.colorScheme.error.withOpacity(0.3)),
                  ),
                  child: Text(
                    viewmodel.errorMessage!,
                    style: TextStyle(
                      color: helper.colorScheme.error,
                      fontFamily: 'Poppins',
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogin() async {
    if (_loginFormKey.currentState?.validate() ?? false) {
      final success = await viewmodel.signInWithEmailAndPassword(
        _loginEmailController.text.trim(),
        _loginPasswordController.text,
      );
      
      if (success && mounted) {
        Modular.to.navigate('/home/');
      }
    }
  }

  void _handleRegister() async {
    if (_registerFormKey.currentState?.validate() ?? false) {
      final success = await viewmodel.registerWithEmailAndPassword(
        _registerEmailController.text.trim(),
        _registerPasswordController.text,
        _registerNameController.text.trim(),
      );
      
      if (success && mounted) {
        Modular.to.navigate('/home/');
      }
    }
  }

  void _handleGoogleLogin() async {
    final success = await viewmodel.signInWithGoogle();
    
    if (success && mounted) {
      Modular.to.navigate('/home/');
    }
  }
}
