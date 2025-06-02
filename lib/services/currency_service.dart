import 'dart:math';

class CurrencyService {
  // Exchange rates (update these with real rates if needed)
  static const Map<String, double> _exchangeRates = {
    'USD': 1.0, // Base currency
    'EUR': 0.85,
    'IDR': 15000.0, // Rupiah
  };

  static const Map<String, String> _currencySymbols = {
    'USD': '\$',
    'EUR': '€',
    'IDR': 'Rp',
  };

  // Generate random market value for a player (in USD)
  static double generateRandomMarketValue() {
    final random = Random();
    // Generate market value between 100K - 150M USD
    final minValue = 100000; // 100K
    final maxValue = 150000000; // 150M

    // Create realistic distribution (more players with lower values)
    final randomValue = random.nextDouble();
    double marketValue;

    if (randomValue < 0.4) {
      // 40% of players: 100K - 2M
      marketValue = minValue + (random.nextDouble() * 1900000);
    } else if (randomValue < 0.7) {
      // 30% of players: 2M - 15M
      marketValue = 2000000 + (random.nextDouble() * 13000000);
    } else if (randomValue < 0.9) {
      // 20% of players: 15M - 50M
      marketValue = 15000000 + (random.nextDouble() * 35000000);
    } else {
      // 10% of players: 50M - 150M
      marketValue = 50000000 + (random.nextDouble() * 100000000);
    }

    return marketValue;
  }

  // Convert amount from one currency to another
  static double convertCurrency(
    double amount,
    String fromCurrency,
    String toCurrency,
  ) {
    if (fromCurrency == toCurrency) return amount;

    // Convert to USD first if not already
    double usdAmount = amount;
    if (fromCurrency != 'USD') {
      usdAmount = amount / _exchangeRates[fromCurrency]!;
    }

    // Convert from USD to target currency
    if (toCurrency == 'USD') {
      return usdAmount;
    }

    return usdAmount * _exchangeRates[toCurrency]!;
  }

  // Format currency with appropriate symbol and formatting
  static String formatCurrency(double amount, String currency) {
    final symbol = _currencySymbols[currency] ?? '';

    if (currency == 'IDR') {
      // Format Indonesian Rupiah
      if (amount >= 1000000000) {
        return '$symbol${(amount / 1000000000).toStringAsFixed(1)}B';
      } else if (amount >= 1000000) {
        return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
      } else if (amount >= 1000) {
        return '$symbol${(amount / 1000).toStringAsFixed(0)}K';
      }
      return '$symbol${amount.toStringAsFixed(0)}';
    } else {
      // Format USD and EUR
      if (amount >= 1000000) {
        return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
      } else if (amount >= 1000) {
        return '$symbol${(amount / 1000).toStringAsFixed(0)}K';
      }
      return '$symbol${amount.toStringAsFixed(0)}';
    }
  }

  // Get available currencies
  static List<String> getAvailableCurrencies() {
    return _exchangeRates.keys.toList();
  }

  // Get currency symbol
  static String getCurrencySymbol(String currency) {
    return _currencySymbols[currency] ?? '';
  }
}
