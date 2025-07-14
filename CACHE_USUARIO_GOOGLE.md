# Sistema de Cache SQLite para Usuário Google

## ✅ Funcionalidades Implementadas

### 📊 Banco de Dados
- **Tabela `usuario_google`** criada no SQLite com os campos:
  - `Uid` (TEXT PRIMARY KEY) - UID único do usuário Google
  - `Nome` (TEXT) - Nome do usuário
  - `Email` (TEXT) - Email do usuário
  - `PhotoURL` (TEXT) - URL original da foto
  - `PhotoBlob` (BLOB) - Dados binários da foto (para offline)
  - `DataLogin` (INTEGER) - Timestamp do primeiro login
  - `DataAtualizacao` (INTEGER) - Timestamp da última atualização
  - `IsAtivo` (INTEGER) - Flag indicando se o usuário está ativo

### 🏗️ Arquitetura
- **Modelo**: `UsuarioGoogleModel` - Representa os dados do usuário
- **Repositório**: `UsuarioGoogleRepository` - Gerencia operações CRUD
- **Widget**: `CachedUserAvatar` - Exibe avatar com cache offline

### 🔄 Fluxo de Funcionamento

#### 1. **Login com Google**
```dart
// No LoginViewModel, quando usuario faz login:
await _salvarUsuarioGoogle(user);
```
- Cria um `UsuarioGoogleModel` com os dados do Firebase Auth
- Chama o repositório para salvar no SQLite
- Automaticamente baixa e salva a foto como BLOB

#### 2. **Exibição do Avatar**
```dart
// Na tela de settings:
const CachedUserAvatar(radius: 32)
```
- Busca o usuário ativo no SQLite
- Se tem foto cached (BLOB), exibe ela
- Senão, exibe fallback com iniciais ou ícone

#### 3. **Logout**
```dart
// No LoginViewModel, quando usuario faz logout:
await _usuarioGoogleRepository.limparUsuarios();
```
- Marca todos os usuários como inativos
- Mantém dados para próximo login

## 🎯 Funcionamento Offline

### ✅ **COM INTERNET** (Primeiro Login)
1. Usuário faz login com Google
2. Sistema salva dados no SQLite
3. **Baixa a foto** da URL e salva como BLOB
4. Avatar exibe a foto baixada

### ✅ **SEM INTERNET** (Uso Offline)
1. App inicia sem conexão
2. Widget busca usuário no SQLite
3. **Carrega foto do BLOB** salvo localmente
4. Avatar funciona normalmente offline!

## 📱 Widgets Disponíveis

### `CachedUserAvatar`
```dart
const CachedUserAvatar(
  radius: 32,                    // Tamanho do avatar
  fallbackIcon: Icons.person,    // Ícone quando sem foto
  fallbackIconSize: 24,          // Tamanho do ícone
)
```

### `SimpleUserAvatar` (Versão Simplificada)
```dart
const SimpleUserAvatar(
  radius: 20,           // Tamanho
  userUid: "user123",   // UID específico (opcional)
)
```

## 🔧 Métodos do Repositório

### Operações Principais
```dart
// Salvar/atualizar usuário (com download da foto)
await repository.salvarUsuario(usuario, downloadPhoto: true);

// Buscar usuário por UID
final usuario = await repository.buscarUsuarioPorUid("uid123");

// Buscar usuário ativo atual
final usuarioAtivo = await repository.buscarUsuarioAtivo();

// Atualizar apenas a foto
await repository.atualizarFoto("uid123", "nova_url");

// Marcar como inativo (logout)
await repository.desativarUsuario("uid123");

// Limpar todos os dados
await repository.limparUsuarios();
```

## 🎨 Telas Atualizadas

### Settings Page
- ✅ Usando `CachedUserAvatar` 
- ✅ Funciona offline
- ✅ Fallback para iniciais do nome

### Outras Telas
Para usar em outras telas, apenas importe e use:
```dart
import 'package:neo_financyuai/app/widgets/cached_user_avatar.dart';

// No build:
const CachedUserAvatar(radius: 24)
```

## 🔄 Estados do Widget

1. **🔄 Carregando**: Mostra CircularProgressIndicator
2. **🖼️ Com Foto**: Exibe a imagem do cache SQLite  
3. **👤 Sem Foto**: Mostra iniciais do nome ou ícone de pessoa
4. **❌ Erro**: Fallback para estado sem foto

## 🧪 Como Testar

1. **Teste Online**:
   - Faça login com Google
   - Verifique se a foto aparece
   - Verifique o banco: dados salvos e BLOB da foto

2. **Teste Offline**:
   - Desligue a internet
   - Abra o app
   - ✅ A foto deve aparecer do cache local!

3. **Teste Fallback**:
   - Use uma conta sem foto
   - ✅ Deve mostrar iniciais ou ícone

## 📋 Dependências Necessárias

```yaml
dependencies:
  http: ^1.2.2      # Para download da foto
  crypto: ^3.0.5    # Para hash/validação
  sqflite: ^2.4.1   # Banco SQLite
```

## 🎉 Resultado Final

✅ **Avatar funciona 100% offline**  
✅ **Foto salva como BLOB no SQLite**  
✅ **Fallback inteligente para contas sem foto**  
✅ **Performance otimizada (uma consulta SQLite)**  
✅ **Estado gerenciado automaticamente**  

O sistema está completo e pronto para uso! 🚀
