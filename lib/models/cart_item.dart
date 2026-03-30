class CartItem {
  final String title;
  final String time;
  final String image;
  final List<String> selectedAddOns;
  final int totalPrice;
  final int durationMinutes;

  CartItem({
    required this.title,
    required this.time,
    required this.image,
    required this.selectedAddOns,
    required this.totalPrice,
    required this.durationMinutes,
  });
}