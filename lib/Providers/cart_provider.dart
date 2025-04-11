import 'package:elite_tiers/Models/cart_model.dart';
import 'package:flutter/material.dart';

class MyCartProvider with ChangeNotifier {
  final List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;

  bool addItem(CartItem item) {
    if (_cartItems.any((i) => i.id == item.id)) {
      return false;
    } else {
      _cartItems.add(item);
      notifyListeners();
      return true;
    }
  }

  void removeItem(CartItem item) {
    _cartItems.remove(item);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  void increaseQuantity(int id) {
    var item = _cartItems.firstWhere((i) => i.id == id);
    item.quantity++;
    notifyListeners();
  }

  void decreaseQuantity(int id) {
    var item = _cartItems.firstWhere((i) => i.id == id);
    if (item.quantity > 1) {
      item.quantity--;
      notifyListeners();
    }
  }

  int get total {
    return _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }
}
