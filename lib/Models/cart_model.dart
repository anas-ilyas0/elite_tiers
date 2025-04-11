class CartItem {
  final int id;
  final String image;
  final String tag;
  final String title;
  final int actualPrice;
  final int discountedPrice;
  int quantity;

  CartItem(
      {required this.id,
      required this.image,
      required this.tag,
      required this.title,
      required this.actualPrice,
      required this.discountedPrice,
      this.quantity = 1});
  int get totalPrice => discountedPrice != 0
      ? discountedPrice * quantity
      : actualPrice * quantity;
}
