import 'package:flutter/foundation.dart';
import 'package:neo_financyuai/app/data/model/movimentacao_model.dart';
import 'package:neo_financyuai/app/database/sqllite/db.dart';
import 'package:neo_financyuai/app/database/sqllite/sql_lite.dart';
import 'package:neo_financyuai/app/service/firebase_sync_service.dart';

/// Serviço que "estende" séries de transações fixas infinitas em lotes.
///
/// Estratégia:
/// - Considera transações com Id no formato `<base>_fixa_<n>` como pertencentes à mesma série.
/// - Mantém um horizonte pré-gerado (batch) de [batchMonths] meses à frente.
/// - Quando o último mês gerado estiver a <= [thresholdMonths] meses do "agora",
///   gera mais [batchMonths] ocorrências, continuando a numeração e as datas mensais.
class RecurrenceTopUpService {
  static const int batchMonths = 24; // gera 24 meses por lote (2 anos)
  static const int thresholdMonths = 12; // quando faltar 12 meses, gera mais 24

  final _syncService = FirebaseSyncService();

  Future<void> runTopUp(String userId) async {
    try {
      final db = await DB.instance.database;
      final rows = await CommandSql(db).select(
        'movimentacao',
        where: "IdUsuario = ? AND Id LIKE ?",
        whereArgs: [userId, '%_fixa_%'],
      );

      if (rows.isEmpty) return;

      // Agrupa por prefixo base (antes de "_fixa_")
      final Map<String, List<MovimentacaoModel>> grupos = {};
      for (final r in rows) {
        final id = r['Id'] as String?;
        if (id == null) continue;
        final idx = id.indexOf('_fixa_');
        if (idx <= 0) continue;
        final base = id.substring(0, idx);
        final m = MovimentacaoModel.fromMap(r, sqlLite: true);
        grupos.putIfAbsent(base, () => <MovimentacaoModel>[]).add(m);
      }

      final now = DateTime.now();
      final todayMonth = DateTime(now.year, now.month, 1);

      for (final entry in grupos.entries) {
        final base = entry.key;
        final list = entry.value;
        if (list.isEmpty) continue;

        // Encontra maior sufixo e última data
        int maxSufixo = 0;
        MovimentacaoModel ref = list.first;
        DateTime lastDate = list.first.dataMovimentacao;
        bool isInfinite = false;
        for (final m in list) {
          final id = m.id ?? '';
          final parts = id.split('_fixa_');
          if (parts.length == 2) {
            final suf = int.tryParse(parts[1]) ?? 0;
            if (suf > maxSufixo) maxSufixo = suf;
          }
          if (m.dataMovimentacao.isAfter(lastDate)) {
            lastDate = m.dataMovimentacao;
            ref = m; // usa a última como referência de campos
          }
          final desc = m.descricao;
          if (!isInfinite && desc.contains('Infinita')) {
            isInfinite = true;
          }
        }

        // Só faz top-up em séries infinitas
        if (!isInfinite) {
          if (kDebugMode) {
            print('ℹ️ Série "$base" não é infinita (sem flag na descrição). Pulando top-up.');
          }
          continue;
        }

        final lastMonth = DateTime(lastDate.year, lastDate.month, 1);
        final monthsAhead = _diffInMonths(todayMonth, lastMonth);

        // Se o horizonte restante for <= limiar, gerar mais um lote
        if (monthsAhead <= thresholdMonths) {
          final baseDay = lastDate.day;
          if (kDebugMode) {
            print('♻️ TopUp "$base": horizon=$monthsAhead <= $thresholdMonths, gerando +$batchMonths');
          }
          for (int i = 1; i <= batchMonths; i++) {
            final nextIndex = maxSufixo + i;
            final newDate = DateTime(lastDate.year, lastDate.month + i, baseDay);
            final novo = MovimentacaoModel(
              id: '${base}_fixa_$nextIndex',
              nome: '${ref.nome} (Recorrente)',
              valor: ref.valor,
              dataMovimentacao: newDate,
              isSaida: ref.isSaida,
              idCategoria: ref.idCategoria,
              idUsuario: userId,
              descricao: ref.descricao,
            );
            await _syncService.addMovimentacao(novo, userId);
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ RecurrenceTopUpService.runTopUp erro: $e');
      }
    }
  }

  int _diffInMonths(DateTime fromMonth, DateTime toMonth) {
    return (toMonth.year - fromMonth.year) * 12 + (toMonth.month - fromMonth.month);
  }
}
