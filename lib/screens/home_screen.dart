import 'package:flutter/material.dart';
import '../data/cart_store.dart';
import 'service_detail_screen.dart';
import 'booking_cart_screen.dart';
import 'staff_pin_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> services = const [
    {
      "title": "Classic Manicure",
      "time": "30 min",
      "durationMinutes": 30,
      "price": "\$25",
      "image": "assets/images/manicure.png"
    },
    {
      "title": "Gel Manicure",
      "time": "45 min",
      "durationMinutes": 45,
      "price": "\$40",
      "image": "assets/images/gel.png"
    },
    {
      "title": "Classic Pedicure",
      "time": "45 min",
      "durationMinutes": 45,
      "price": "\$35",
      "image": "assets/images/pedicure.png"
    },
    {
      "title": "Deluxe Manicure",
      "time": "60 min",
      "durationMinutes": 60,
      "price": "\$55",
      "image": "assets/images/deluxe.png"
    },
    {
      "title": "Acrylic Set",
      "time": "75 min",
      "durationMinutes": 75,
      "price": "\$70",
      "image": "assets/images/acrylic.png"
    },
    {
      "title": "Nail Repair",
      "time": "20 min",
      "durationMinutes": 20,
      "price": "\$15",
      "image": "assets/images/repair.png"
    },
  ];

  String _getServiceDescription(String title) {
    switch (title) {
      case 'Classic Manicure':
        return 'Nail shaping, cuticle care, and polish for a clean, natural look.';
      case 'Gel Manicure':
        return 'Chip-resistant gel polish with a glossy finish that lasts up to two weeks.';
      case 'Classic Pedicure':
        return 'Relaxing foot soak, exfoliation, and nail care for refreshed feet.';
      case 'Deluxe Manicure':
        return 'Includes exfoliation, massage, and deep hydration for a luxury finish.';
      case 'Acrylic Set':
        return 'Durable nail extensions customized to your desired length and shape.';
      case 'Nail Repair':
        return 'Quick fix for broken or damaged nails to restore strength and shape.';
      default:
        return '';
    }
  }

  Future<void> _openServiceDetail(Map<String, dynamic> service) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceDetailScreen(
          title: service["title"] as String,
          time: service["time"] as String,
          durationMinutes: service["durationMinutes"] as int,
          price: service["price"] as String,
          image: service["image"] as String,
        ),
      ),
    );

    setState(() {});
  }

  Future<void> _openCart() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BookingCartScreen(),
      ),
    );

    setState(() {});
  }

  Future<void> _openStaffLogin() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const StaffPinScreen(),
      ),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final int cartCount = CartStore.items.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Glow Nail Studio"),
        backgroundColor: const Color(0xFF7B5B43),
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              tooltip: "View Cart",
              onPressed: _openCart,
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_bag_outlined, size: 28),
                  if (cartCount > 0)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          cartCount > 99 ? '99+' : '$cartCount',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF6F4F1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF9B7A63),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Luxury Nail Care",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Book elegant manicures, pedicures, and custom nail services with ease.",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _openStaffLogin,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      "Continue as staff",
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Popular Services",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2E22),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: services.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.54,
                  ),
                  itemBuilder: (context, index) {
                    final service = services[index];

                    return GestureDetector(
                      onTap: () => _openServiceDetail(service),
                      child: Card(
                        elevation: 3,
                        color: const Color(0xFFF3E8E0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(18),
                              ),
                              child: Image.asset(
                                service["image"] as String,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  10,
                                  12,
                                  10,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      service["title"] as String,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Color(0xFF2F241D),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getServiceDescription(
                                        service["title"] as String,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        color: Color(0xFF7A746E),
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      service["time"] as String,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      service["price"] as String,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Color(0xFF2F241D),
                                      ),
                                    ),
                                    const Spacer(),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 38,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF7B5B43),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          padding: EdgeInsets.zero,
                                        ),
                                        onPressed: () =>
                                            _openServiceDetail(service),
                                        child: const Text(
                                          "Book Now",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
