import 'dart:math';

class CurrencyService {
  static const Map<String, double> _exchangeRates = {
    'USD': 1.0,
    'EUR': 0.85,
    'IDR': 15000.0,
  };

  static const Map<String, String> _currencySymbols = {
    'USD': '\$',
    'EUR': '€',
    'IDR': 'Rp',
  };

  static double generateRandomMarketValue() {
    final random = Random();

    final minValue = 100000;
    // final maxValue = 150000000;

    final randomValue = random.nextDouble();
    double marketValue;

    if (randomValue < 0.4) {
      marketValue = minValue + (random.nextDouble() * 1900000);
    } else if (randomValue < 0.7) {
      marketValue = 2000000 + (random.nextDouble() * 13000000);
    } else if (randomValue < 0.9) {
      marketValue = 15000000 + (random.nextDouble() * 35000000);
    } else {
      marketValue = 50000000 + (random.nextDouble() * 100000000);
    }

    return marketValue;
  }

  static double convertCurrency(
    double amount,
    String fromCurrency,
    String toCurrency,
  ) {
    if (fromCurrency == toCurrency) return amount;

    double usdAmount = amount;
    if (fromCurrency != 'USD') {
      usdAmount = amount / _exchangeRates[fromCurrency]!;
    }

    if (toCurrency == 'USD') {
      return usdAmount;
    }

    return usdAmount * _exchangeRates[toCurrency]!;
  }

  static String formatCurrency(double amount, String currency) {
    final symbol = _currencySymbols[currency] ?? '';

    if (currency == 'IDR') {
      if (amount >= 1000000000) {
        return '$symbol${(amount / 1000000000).toStringAsFixed(1)}B';
      } else if (amount >= 1000000) {
        return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
      } else if (amount >= 1000) {
        return '$symbol${(amount / 1000).toStringAsFixed(0)}K';
      }
      return '$symbol${amount.toStringAsFixed(0)}';
    } else {
      if (amount >= 1000000) {
        return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
      } else if (amount >= 1000) {
        return '$symbol${(amount / 1000).toStringAsFixed(0)}K';
      }
      return '$symbol${amount.toStringAsFixed(0)}';
    }
  }

  static List<String> getAvailableCurrencies() {
    return _exchangeRates.keys.toList();
  }

  static String getCurrencySymbol(String currency) {
    return _currencySymbols[currency] ?? '';
  }
}
