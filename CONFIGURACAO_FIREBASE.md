# 🔥 Configurações Necessárias no Firebase Console

## ✅ Status Atual da Configuração

Analisando seu projeto, identifiquei que você já tem:
- ✅ Firebase Core inicializado (`firebase_options.dart`)
- ✅ Google Services configurado (`google-services.json`)
- ✅ Firebase Auth implementado no código
- ✅ Firestore configurado para categorias

## 🚨 Configurações OBRIGATÓRIAS no Firebase Console

### **1. Firebase Authentication - Métodos de Login**

Você precisa ativar os seguintes métodos no Firebase Console:

#### 📧 **Email/Password Authentication**
```
1. Acesse: Firebase Console > Authentication > Sign-in method
2. Clique em "Email/Password"
3. Ative "Enable"
4. ✅ Salve as alterações
```

#### 🔍 **Google Sign-In**
```
1. Acesse: Firebase Console > Authentication > Sign-in method
2. Clique em "Google"
3. Ative "Enable"
4. Configure o "Project support email" (seu email)
5. ✅ Salve as alterações
```

### **2. Firestore Database - Regras de Segurança**

Suas regras atuais podem estar muito restritivas. Configure:

#### 📝 **Regras Recomendadas para Desenvolvimento:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Permite acesso a usuários autenticados
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
    
    // Regras específicas para categorias
    match /categories/{categoryId} {
      allow read: if true; // Categorias padrão são públicas
      allow write: if request.auth != null;
    }
    
    // Regras específicas para dados do usuário
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Regras para categorias do usuário
    match /user_categories/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### **3. Android Configuration (Google Sign-In)**

#### 📱 **SHA-1 Fingerprints**
Você precisa adicionar as impressões digitais SHA-1:

```bash
# No terminal, navegue até seu projeto e execute:
cd android
./gradlew signingReport

# Copie o SHA-1 fingerprint que aparece em "Variant: debug"
```

#### ⚙️ **Adicionar SHA-1 no Firebase:**
```
1. Firebase Console > Project Settings
2. Aba "Your apps" > Android app
3. Clique em "Add fingerprint"
4. Cole o SHA-1 copiado
5. ✅ Salve
```

### **4. Configurações de Domínio Autorizado**

#### 🌐 **Domínios para OAuth:**
```
1. Firebase Console > Authentication > Settings
2. Aba "Authorized domains"
3. Verifique se contém:
   - localhost (para desenvolvimento)
   - Seu domínio de produção (se houver)
```

## 🔧 Verificação Rápida - Checklist

### **Console Firebase:**
- [ ] Authentication > Email/Password ativado
- [ ] Authentication > Google ativado
- [ ] Firestore regras configuradas
- [ ] SHA-1 fingerprint adicionado
- [ ] Domínios autorizados configurados

### **Projeto Flutter:**
- [x] firebase_options.dart presente
- [x] google-services.json configurado
- [x] Firebase inicializado no main.dart
- [x] AuthService implementado

## 🚀 Teste da Configuração

Após fazer essas configurações, teste:

### **1. Teste Email/Password:**
```dart
// Cadastro
await authService.registerWithEmailAndPassword(
  'teste@exemplo.com', 
  '123456', 
  'Teste'
);

// Login
await authService.signInWithEmailAndPassword(
  'teste@exemplo.com', 
  '123456'
);
```

### **2. Teste Google Sign-In:**
```dart
await authService.signInWithGoogle();
```

## ⚠️ Possíveis Erros e Soluções

### **Erro: "weak-password"**
```
Solução: Use senhas com pelo menos 6 caracteres
```

### **Erro: "email-already-in-use"**
```
Solução: Email já cadastrado, tente fazer login
```

### **Erro: "user-not-found"**
```
Solução: Email não existe, faça cadastro primeiro
```

### **Erro: Google Sign-In falha**
```
Solução: 
1. Verifique SHA-1 fingerprint
2. Confirme google-services.json atualizado
3. Rebuild do projeto
```

### **Erro: "permission-denied" Firestore**
```
Solução: Atualize as regras do Firestore conforme mostrado acima
```

## 📞 Comandos para Debug

### **Verificar SHA-1:**
```bash
cd android && ./gradlew signingReport
```

### **Rebuild projeto:**
```bash
flutter clean
flutter pub get
flutter run
```

### **Logs detalhados:**
```bash
flutter run --verbose
```

## 🎯 Ordem de Implementação

1. **Primeiro:** Ative Authentication Email/Password
2. **Segundo:** Ative Google Sign-In  
3. **Terceiro:** Configure regras Firestore
4. **Quarto:** Adicione SHA-1 fingerprint
5. **Quinto:** Teste ambos os métodos

**🔥 Após essas configurações, seu sistema de autenticação estará 100% funcional!**
