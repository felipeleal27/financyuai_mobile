# ♻️ Chat IA + Firestore (Acesso Autenticado)

Este guia explica como o fluxo da IA recupera as transações do usuário no Firestore após o endurecimento das regras de segurança (`request.auth != null`). A grande mudança é que o app agora envia o **Firebase ID Token** em cada chamada para o n8n, e o workflow o reutiliza ao consultar o Firestore REST API.

## 🔄 Visão Geral do Fluxo

1. **App Flutter** (`ChatIAPage`)
   - Recupera o ID token via `AuthService().getIdToken()` sempre que envia uma mensagem para a IA.
   - Inclui o token no corpo JSON (`idToken`).
2. **Webhook n8n** (`tools/n8n/workflows/financyuai_optimized.json`)
   - Copia o `idToken` no nó "Edit Fields".
   - Encaminha o token no header `Authorization: Bearer <token>` ao chamar o Firestore.
   - Caso a chamada retorne erro, responde ao usuário com uma mensagem amigável.
3. **Firestore REST**
   - Valida o token conforme as regras (UID precisa bater com o `userId`).
   - Retorna as transações da coleção `users/{userId}/transacoes`.

## ✅ Pré-requisitos

- Regras do Firestore exigindo autenticação de usuário, por exemplo:
  ```javascript
  match /users/{userId}/{document=**} {
    allow read: if request.auth != null && request.auth.uid == userId;
  }
  ```
- Usuário autenticado no app (Firebase Auth).
- Workflow do n8n importado a partir de `tools/n8n/workflows/financyuai_optimized.json`.

## 🛠️ Como testar

1. Abra o app já logado e envie qualquer pergunta para a IA.
2. No painel do n8n, inspecione a execução do workflow:
   - O `Webhook` deve receber `idToken` no corpo.
   - O `HTTP Request` deve enviar o header `Authorization`.
   - A resposta do Firestore deve conter as transações.
3. Se receber `401` ou `403`:
   - Confirme que o token está chegando.
   - Verifique se o `userId` do corpo é o mesmo `uid` presente no token.
   - Faça logout/login no app para renovar o token.

## 🔐 Renovando o token manualmente

O `AuthService` já encapsula `getIdToken()`. Em caso de falha persistente você pode forçar a renovação chamando:
```dart
await AuthService().getIdToken(forceRefresh: true);
```
E reenviando a mensagem.

## 💡 Próximos passos sugeridos

- Implementar tentativa automática de renovação do token (force refresh) ao detectar `401/403`.
- Adicionar logs estruturados no n8n para facilitar auditoria.
- Trocar o `HTTP Request` por um nó oficial do Firestore quando estiver disponível.

Com isso, a IA volta a enxergar as transações mesmo com regras restritivas, mantendo a segurança dos dados do usuário. ✨
