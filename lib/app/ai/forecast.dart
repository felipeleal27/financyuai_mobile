class ForecastPoint {
  final DateTime date;
  final double value;
  ForecastPoint(this.date, this.value);
}

// Alisamento exponencial simples para projetar saldo diário futuro
List<ForecastPoint> forecastDailyBalance({
  required List<ForecastPoint> dailyNet, // série diária de delta (receitas - despesas)
  required DateTime startFrom,
  required int daysAhead,
  double alpha = 0.4,
  double currentBalance = 0.0,
}) {
  if (dailyNet.isEmpty) return [];
  double level = dailyNet.first.value;
  for (int i = 1; i < dailyNet.length; i++) {
    level = alpha * dailyNet[i].value + (1 - alpha) * level;
  }
  final List<ForecastPoint> out = [];
  var date = startFrom;
  var balance = currentBalance;
  for (int d = 0; d < daysAhead; d++) {
    balance += level;
    out.add(ForecastPoint(date, balance));
    date = date.add(const Duration(days: 1));
  }
  return out;
}
