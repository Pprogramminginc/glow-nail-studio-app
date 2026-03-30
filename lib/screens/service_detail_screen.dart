import 'package:flutter/material.dart';
import '../data/cart_store.dart';
import '../models/cart_item.dart';
import 'booking_cart_screen.dart';

class ServiceDetailScreen extends StatefulWidget {
  final String title;
  final String time;
  final int durationMinutes;
  final String price;
  final String image;

  const ServiceDetailScreen({
    super.key,
    required this.title,
    required this.time,
    required this.durationMinutes,
    required this.price,
    required this.image,
  });

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  final Map<String, int> addOns = {
    "French Tip": 10,
    "Nail Art": 15,
    "Chrome Finish": 12,
    "Gel Removal": 8,
    "Rhinestones": 7,
    "Cuticle Treatment": 6,
  };

  final Set<String> selectedAddOns = {};

  String _getServiceDescription(String title) {
    switch (title) {
      case 'Classic Manicure':
        return 'A clean, polished manicure with nail shaping, cuticle care, and your choice of finish.';
      case 'Gel Manicure':
        return 'A glossy, chip-resistant manicure cured for long-lasting shine and everyday durability.';
      case 'Classic Pedicure':
        return 'A refreshing foot treatment with soak, exfoliation, nail care, and a polished finish.';
      case 'Deluxe Manicure':
        return 'An elevated manicure with exfoliation, massage, and deep hydration for a luxury feel.';
      case 'Acrylic Set':
        return 'Durable nail enhancements tailored to your preferred length, shape, and finished look.';
      case 'Nail Repair':
        return 'A quick restorative service to fix cracked, broken, or weakened nails with care.';
      default:
        return 'A professional nail service designed to leave your hands and feet looking polished and refreshed.';
    }
  }

  int get basePrice {
    return int.parse(widget.price.replaceAll('\$', '').replaceAll('+', ''));
  }

  int get totalPrice {
    int total = basePrice;
    for (final addOn in selectedAddOns) {
      total += addOns[addOn] ?? 0;
    }
    return total;
  }

  void _addCurrentItemToCart() {
    final item = CartItem(
      title: widget.title,
      time: widget.time,
      image: widget.image,
      selectedAddOns: selectedAddOns.toList(),
      totalPrice: totalPrice,
      durationMinutes: widget.durationMinutes,
    );

    CartStore.addItem(item);
  }

  void _showBookingOptions() {
    _addCurrentItemToCart();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF6F4F1),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                "Added to Booking",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2F241D),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "${widget.title} has been added.",
                style: const TextStyle(fontSize: 15, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.brown.shade100),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        widget.image,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF2F241D),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${selectedAddOns.length} add-on(s)",
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "\$$totalPrice",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF7B5B43),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF7B5B43),
                    side: const BorderSide(color: Color(0xFF7B5B43)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Continue Shopping",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7B5B43),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BookingCartScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Order Summary + Checkout",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F4F1),
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFF7B5B43),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    widget.image,
                    height: 240,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2F241D),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${widget.time} • ${widget.price}",
                  style: const TextStyle(fontSize: 18, color: Colors.black54),
                ),
                const SizedBox(height: 10),
                Text(
                  _getServiceDescription(widget.title),
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF6F6258),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Choose Add-Ons",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2F241D),
                  ),
                ),
                const SizedBox(height: 12),
                ...addOns.entries.map((entry) {
                  final name = entry.key;
                  final price = entry.value;
                  final isSelected = selectedAddOns.contains(name);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF7B5B43)
                            : Colors.grey.shade300,
                        width: 1.3,
                      ),
                    ),
                    child: CheckboxListTile(
                      activeColor: const Color(0xFF7B5B43),
                      title: Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text("+\$$price"),
                      value: isSelected,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            selectedAddOns.add(name);
                          } else {
                            selectedAddOns.remove(name);
                          }
                        });
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text(
                      "Total",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "\$$totalPrice",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7B5B43),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B5B43),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _showBookingOptions,
                    child: const Text(
                      "Add to Booking",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
