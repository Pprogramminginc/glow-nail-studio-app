import 'package:flutter/material.dart';
import '../data/cart_store.dart';
import 'booking_screen.dart';

class BookingCartScreen extends StatefulWidget {
  const BookingCartScreen({super.key});

  @override
  State<BookingCartScreen> createState() => _BookingCartScreenState();
}

class _BookingCartScreenState extends State<BookingCartScreen> {
  void _removeItem(int index) {
    setState(() {
      CartStore.removeItemAt(index);
    });
  }

  void _proceedToScheduling() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingScreen(
          totalDuration: CartStore.totalDurationMinutes,
          services: CartStore.items,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = CartStore.items;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F4F1),
      appBar: AppBar(
        title: const Text("Booking Summary"),
        backgroundColor: const Color(0xFF7B5B43),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: items.isEmpty
          ? const Center(
              child: Text(
                "Your booking cart is empty.",
                style: TextStyle(fontSize: 18),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  item.image,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.time,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    if (item.selectedAddOns.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      const Text(
                                        "Add-ons:",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF7B5B43),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      ...item.selectedAddOns.map(
                                        (addOn) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 2,
                                          ),
                                          child: Text(
                                            "• $addOn",
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 8),
                                    Text(
                                      "\$${item.totalPrice}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _removeItem(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 8,
                        color: Colors.black12,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
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
                            "\$${CartStore.totalPrice}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7B5B43),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _proceedToScheduling,
                          child: const Text(
                            "Choose Date & Time",
                            style: TextStyle(fontSize: 16),
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
