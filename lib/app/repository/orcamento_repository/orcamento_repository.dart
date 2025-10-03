import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrcamentoRepository {
  static const _kMonthlyLimit = 'budget.monthlyLimit';
  static const _kSavingsGoal = 'budget.savingsGoal';
  static const _kCategoryCaps = 'budget.categoryCaps'; // json map {"Categoria": 500.0}
  static const _kAlertThresholds = 'budget.alertThresholds'; // json list [0.7,0.9,1.0]
  static const _kLimitEnabled = 'budget.limitEnabled'; // bool
  static const _kLastBandNotified = 'budget.lastBandNotified'; // double 0.0/0.7/0.9/1.0

  Future<double?> getMonthlyLimit() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getDouble(_kMonthlyLimit);
  }

  Future<void> setMonthlyLimit(double? value) async {
    final sp = await SharedPreferences.getInstance();
    if (value == null) {
      await sp.remove(_kMonthlyLimit);
    } else {
      await sp.setDouble(_kMonthlyLimit, value);
    }
  }

  Future<double?> getSavingsGoal() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getDouble(_kSavingsGoal);
  }

  Future<void> setSavingsGoal(double? value) async {
    final sp = await SharedPreferences.getInstance();
    if (value == null) {
      await sp.remove(_kSavingsGoal);
    } else {
      await sp.setDouble(_kSavingsGoal, value);
    }
  }

  Future<Map<String, double>> getCategoryCaps() async {
    final sp = await SharedPreferences.getInstance();
    final s = sp.getString(_kCategoryCaps);
    if (s == null) return {};
    final m = jsonDecode(s) as Map<String, dynamic>;
    return m.map((k, v) => MapEntry(k, (v as num).toDouble()));
  }

  Future<void> setCategoryCaps(Map<String, double> caps) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kCategoryCaps, jsonEncode(caps));
  }

  Future<List<double>> getAlertThresholds() async {
    final sp = await SharedPreferences.getInstance();
    final s = sp.getString(_kAlertThresholds);
    if (s == null) return const [0.7, 0.9, 1.0];
    final l = (jsonDecode(s) as List).map((e) => (e as num).toDouble()).toList();
    return l.isEmpty ? const [0.7, 0.9, 1.0] : l;
  }

  Future<void> setAlertThresholds(List<double> thresholds) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kAlertThresholds, jsonEncode(thresholds));
  }

  Future<bool> getLimitEnabled() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_kLimitEnabled) ?? false;
  }

  Future<void> setLimitEnabled(bool enabled) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kLimitEnabled, enabled);
  }

  Future<double> getLastBandNotified() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getDouble(_kLastBandNotified) ?? 0.0;
  }

  Future<void> setLastBandNotified(double band) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setDouble(_kLastBandNotified, band);
  }

  Future<void> syncToCloud({required String userId}) async {
    try {
      final limit = await getMonthlyLimit();
      final savings = await getSavingsGoal();
      final caps = await getCategoryCaps();
      final enabled = await getLimitEnabled();
      final thresholds = await getAlertThresholds();

      final data = {
        'budget': {
          'monthlyLimit': limit,
          'savingsGoal': savings,
          'categoryCaps': caps,
          'limitEnabled': enabled,
          'thresholds': thresholds,
          'updatedAt': FieldValue.serverTimestamp(),
        }
      };
      // Escreve dentro do documento do usuário existente, compatível com as regras atuais
      await FirebaseFirestore.instance.collection('users').doc(userId).set(data, SetOptions(merge: true));
    } catch (_) {
      // silencioso: Firestore offline já faz fila; se falhar, tenta no próximo save
    }
  }
}
