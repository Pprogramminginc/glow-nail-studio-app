import '../models/cart_item.dart';

class CartStore {
  static final List<CartItem> items = [];

  static void addItem(CartItem item) {
    items.add(item);
  }

  static void removeItemAt(int index) {
    items.removeAt(index);
  }

  static void clearCart() {
    items.clear();
  }

  static int get totalPrice {
    int total = 0;
    for (final item in items) {
      total += item.totalPrice;
    }
    return total;
  }

  static int get totalDurationMinutes {
    int total = 0;
    for (final item in items) {
      total += item.durationMinutes;
    }
    return total;
  }

  static bool get isEmpty => items.isEmpty;
}