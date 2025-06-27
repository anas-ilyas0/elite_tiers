import 'package:elite_tiers/Models/cart_model.dart';
import 'package:flutter/material.dart';
import 'package:tabby_flutter_inapp_sdk/tabby_flutter_inapp_sdk.dart';

class MyCartProvider with ChangeNotifier {
  final List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;

  List<OrderItem> getOrderItemsForTabby() {
    return _cartItems
        .map((item) => OrderItem(
              title: item.title,
              quantity: item.quantity,
              unitPrice: (item.discountedPrice != 0
                      ? item.discountedPrice
                      : item.actualPrice)
                  .toString(),
              category: "general",
              imageUrl: item.image,
            ))
        .toList();
  }

  List<Map<String, dynamic>> getOrderItemsForTamara() {
    return _cartItems.map((item) {
      final int unitPrice =
          item.discountedPrice != 0 ? item.discountedPrice : item.actualPrice;

      final int totalAmount = unitPrice * item.quantity;

      return {
        "name": item.title,
        "type": "Physical",
        "reference_id": item.id.toString(),
        "sku": "DEFAULT_SKU",
        "quantity": item.quantity,
        "discount_amount": {
          "amount": (item.discountedPrice != 0)
              ? (item.actualPrice - item.discountedPrice) * item.quantity
              : 0,
          "currency": "SAR"
        },
        "tax_amount": {"amount": 0.0, "currency": "SAR"},
        "unit_price": {"amount": unitPrice, "currency": "SAR"},
        "total_amount": {"amount": totalAmount, "currency": "SAR"},
        "image_url": item.image,
        "category": "",
      };
    }).toList();
  }

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
