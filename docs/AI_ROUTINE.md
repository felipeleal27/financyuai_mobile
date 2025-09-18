# IA de Rotinas de Despesas (Lembretes Inteligentes)

Este documento descreve como a IA identifica despesas recorrentes e envia lembretes quando você provavelmente esqueceu de lançar uma movimentação neste mês. O objetivo é ser leve, local (SQLite) e com execução automática em segundo plano.

## Visão Geral
- A IA analisa o histórico de movimentações do usuário no SQLite e detecta rotinas por favorecido (campo `Nome` da movimentação).
- Padrões suportados:
  - Mensal: ocorre todo mês por volta do mesmo dia (tolerância pequena de variação de dias)
  - Semi-mensal: duas vezes por mês (começo e fim)
- Quando chega o período esperado deste mês e passam ~10–12 dias sem lançamento daquele favorecido, a IA envia um lembrete simples com o mesmo template visual da notificação de teste (apenas ícone pequeno do app).
- Anti-spam: no máximo um lembrete por favorecido por mês.

## Onde está o código
- Serviço principal: `lib/app/service/ai_routine_service.dart`
  - Método público principal: `AiRoutineService().runDailyAnalysis()`
  - Usa `DB.instance.database` + `CommandSql` para consultar a tabela `movimentacao`
  - Persiste a trava de “já notificado” no mês via `SharedPreferences`
- Disparo de notificação: `lib/app/service/notification_service.dart`
  - Método: `sendSimpleNotification({title, body})` (libera envio mesmo com o flag global desativando outras notificações)
- Agendamento em segundo plano: `lib/app/service/background_task_service.dart`
  - Tarefa diária no Workmanager: `ai_routine_task` (rodando por volta das 09:00, 1x/dia)
  - O dispatcher executa `AiRoutineService().runDailyAnalysis()` quando a tarefa dispara
- Ponto de execução imediato (startup): `lib/main.dart`
  - Após inicializar `NotificationService`, o app também chama `AiRoutineService().runDailyAnalysis()` para efeito imediato na abertura

## Como a IA detecta uma rotina
1. Carrega movimentações dos últimos ~18 meses do usuário (somente saídas: `IsSaida = 1`).
2. Agrupa por nome normalizado (favorecido): transforma em minúsculas, remove caracteres especiais e normaliza espaços.
3. Exige histórico mínimo (≥ 4 ocorrências) para considerar uma rotina.
4. Detecta padrões:
   - Mensal: dias do mês com baixa variabilidade (desvio padrão ≤ ~2,5 dias)
   - Semi-mensal: presença significativa de lançamentos no início (≤10) e no fim (≥20) do mês
5. Define o(s) dia(s) esperado(s) do mês atual:
   - Mensal: usa a mediana dos dias históricos (cortada para 1–28)
   - Semi-mensal: heurística 5 e 25

## Quando o lembrete é disparado
- Janela de alerta: entre D+10 e D+12 a partir do primeiro dia esperado do mês.
- Condições para enviar:
  - Usuário logado (para filtrar por `IdUsuario`)
  - Não há movimentação daquele favorecido no mês corrente
  - Ainda não foi enviado lembrete para esse favorecido neste mês (travado por `SharedPreferences`)

### Exemplo de texto
- Título: `Você já pagou Leonardo?`
- Descrição: `Percebemos que ainda não adicionou a despesa para Leonardo Feliciano este mês. Um lembrete para você não esquecer e evitar transtornos.`

Observação: O texto é personalizável (veja "Personalização"). O nome é capitalizado automaticamente a partir do agrupamento normalizado.

## Personalização
- Janela de alerta: ajuste a constante `graceDays` em `AiRoutineService` (padrão 10; janela efetiva ~10 a 12 dias).
- Padrões:
  - Critério de mensalidade (desvio padrão): ajuste o limite de `stddev` em `_detectPattern()`.
  - Semi-mensal: parâmetros dos dias-limite (hoje 5 e 25) em `_expectedDaysThisMonth()`.
- Texto:
  - Edite a montagem de `title` e `body` antes do `sendSimpleNotification`.
- Anti-spam: a chave de trava mensal fica no formato `ai_last_notify_<hash>_<ano>_<mes>`.

## Como testar
1. Garanta que existam várias movimentações de um mesmo favorecido em meses anteriores.
2. Altere temporariamente a data esperada ou a janela de `graceDays` para simular a condição de lembrete.
3. Abra o app (o serviço roda no startup). Se os critérios forem atendidos, a notificação aparece.
4. A notificação usa o mesmo template visual da de teste (ícone pequeno `@mipmap/launcher_icon`).

## Garantias e limitações
- Com background: há uma tarefa diária do Workmanager (`ai_routine_task`). O Android pode atrasar a execução dependendo de otimizações de bateria, modo Doze e restrições do fabricante; mesmo assim, a execução ocorrerá dentro de uma janela.
- O agrupamento por nome é heurístico. Diferenças de grafia podem agrupar separadamente ("Barbeiro L. Feliciano" vs "Leonardo Feliciano").
- A detecção é leve e local, sem aprendizado avançado. Serve para 80% dos casos práticos de rotina.
- Logs/Notificações de debug do Workmanager estão desativados; apenas a notificação final (quando aplicável) aparece ao usuário.

## Próximos passos sugeridos
- Ação na notificação: abrir o app já no formulário de nova movimentação com o nome preenchido
- UI de rotinas: listar e permitir que o usuário confirme/edite rotinas detectadas
- Mais sinais para o padrão: considerar o valor aproximado (±20%) e categoria
- Nova janela de tentativa: relembrar alguns dias depois se continuar sem lançamento
- Option “tornar recorrente”: permitir marcar manualmente como rotina, com periodicidade e tolerâncias escolhidas

## API rápida
- Executar análise manualmente:
  ```dart
  await AiRoutineService().runDailyAnalysis();
  ```
- Enviar notificação simples manualmente (mesmo com flag global desligado):
  ```dart
  await NotificationService().sendSimpleNotification(
    title: 'Título',
    body: 'Descrição',
  );
  ```

## Arquivos relacionados
- `lib/app/service/ai_routine_service.dart` — lógica de detecção e envio
- `lib/app/service/notification_service.dart` — `sendSimpleNotification()` e template visual
- `lib/main.dart` — gatilho de execução no startup
- `lib/app/database/sqllite/db.dart` — schema da tabela `movimentacao`
- `lib/app/database/sqllite/sql_lite.dart` — utilitário de queries `CommandSql`

## Como desativar temporariamente
- Startup imediato: comente a linha em `main.dart` que chama `AiRoutineService().runDailyAnalysis()`.
- Background diário:
  - Comente o agendamento em `BackgroundTaskService._schedulePeriodicTasks()` (registro da `ai_routine_task`), ou
  - Chame `BackgroundTaskService.cancelTask(BackgroundTaskService.aiRoutineTask)` em um ponto de configuração.
- Alternativa rápida: dentro do `AiRoutineService`, retorne cedo no início de `runDailyAnalysis()` para desabilitar a IA sem mexer em agendamentos.

---
Dúvidas ou ajustes finos? Podemos calibrar a heurística (janela, dias esperados, texto, anti-spam) conforme seu uso real. 