# IA de Datas Comemorativas (Previsão de Gastos)

A IA de feriados/datas especiais antecipa a chegada de eventos como Natal, Ano Novo, Carnaval e Páscoa e lembra o usuário que é comum gastar mais nessa época. Ela também estima um valor típico com base no seu histórico para ajudar no planejamento.

## Como funciona
- Executa diariamente em segundo plano via Workmanager (mesma tarefa `ai_routine_task`).
- Também roda uma vez no startup do app para efeito imediato.
- Para cada data comemorativa próxima, se estamos dentro da janela de aviso e ainda não notificamos este ano, envia uma notificação simples (template igual ao da notificação de teste).

## Datas suportadas (inicial)
- Natal (25/12)
- Ano Novo (01/01)
- Páscoa (cálculo por algoritmo de Meeus/Jones/Butcher)
- Carnaval (terça-feira de carnaval = Páscoa – 47 dias)

> Futuro: aniversários (via agenda/contatos) e outras datas nacionais/regionais, sob opt-in do usuário.

## Janelas de aviso
- Natal: 10 dias antes até o dia 25
- Ano Novo: 5 dias antes até 01/01
- Carnaval: 14 dias antes até a terça de carnaval
- Páscoa: 10 dias antes até o domingo de Páscoa

## Estimativa de gasto
- Consulta seu histórico (últimos ~3 anos) em janelas ±7 dias em torno da data.
- Usa a mediana dos valores de saída (IsSaida=1) como estimativa robusta.
- Exibe no texto algo como: “Você costuma gastar cerca de R$ X” quando possível.

## Onde está o código
- Serviço: `lib/app/service/ai_holiday_service.dart`
- Agendamento: `lib/app/service/background_task_service.dart` (tarefa `ai_routine_task`)
- Startup: `lib/main.dart`
- Notificação simples: `sendSimpleNotification()` em `lib/app/service/notification_service.dart`

## Personalização
- Janelas: ajuste `_daysBeforeFor(key)` para cada feriado.
- Texto: edite `_titleFor()`, `_label()` e a mensagem que monta `title`/`body`.
- Estimativa: ajuste a janela temporal e a métrica (mediana/média, filtros de outliers, etc.).

## Como desativar
- Comente a chamada em `main.dart` para execução no startup.
- Comente o registro da `ai_routine_task` em `BackgroundTaskService._schedulePeriodicTasks()` para desligar o background.
- Ou, retorne cedo no início de `AiHolidayService.runDailyAnalysis()` como um kill-switch rápido.

## Observações
- Execuções de background no Android podem variar de horário por causa do Doze e otimizações de bateria; o sistema garante execução dentro de janela.
- Não há logs/notificações de debug visíveis ao usuário; somente a notificação final aparece.
