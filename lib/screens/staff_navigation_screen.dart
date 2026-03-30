import 'package:flutter/material.dart';
import '../data/business_store.dart';
import '../data/studio_settings_store.dart';
import 'edit_business_screen.dart';
import 'edit_business_hours_screen.dart';
import 'edit_policies_screen.dart';
import 'owner_appointments_screen.dart';
import 'owner_dashboard_screen.dart';
import 'role_selection_screen.dart';

class StaffNavigationScreen extends StatefulWidget {
  const StaffNavigationScreen({super.key});

  @override
  State<StaffNavigationScreen> createState() => _StaffNavigationScreenState();
}

class _StaffNavigationScreenState extends State<StaffNavigationScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7B5B43),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Logout"),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RoleSelectionScreen(),
                  ),
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return const OwnerDashboardScreen();
      case 1:
        return const OwnerAppointmentsScreen();
      case 2:
        return StudioProfileScreen(onLogout: _logout);
      default:
        return const OwnerDashboardScreen();
    }
  }

  String _getTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Appointments';
      case 2:
        return 'Studio Profile';
      default:
        return 'Dashboard';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F4F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7B5B43),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(_getTitle()),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: _logout,
          ),
        ],
      ),
      body: _buildCurrentScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF6F4E37),
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color(0xFFF8F3EF),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: "Appointments",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            label: "Studio",
          ),
        ],
      ),
    );
  }
}

class StudioProfileScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const StudioProfileScreen({super.key, required this.onLogout});

  @override
  State<StudioProfileScreen> createState() => _StudioProfileScreenState();
}

class _StudioProfileScreenState extends State<StudioProfileScreen> {
  Future<void> _openEditBusinessScreen() async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditBusinessScreen()),
    );

    if (updated == true) setState(() {});
  }

  Future<void> _openEditBusinessHoursScreen() async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditBusinessHoursScreen()),
    );

    if (updated == true) setState(() {});
  }

  Future<void> _openEditPoliciesScreen() async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditPoliciesScreen()),
    );

    if (updated == true) setState(() {});
  }

  String _formatCutoffHour() {
    final hour = StudioSettingsStore.sameDayCutoffHour;
    final display = hour > 12 ? hour - 12 : hour;
    final period = hour >= 12 ? 'PM' : 'AM';
    return '$display:00 $period';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 16),
          _buildInfoCard(),
          const SizedBox(height: 16),
          _buildHoursCard(),
          const SizedBox(height: 16),
          _buildPoliciesCard(),
          const SizedBox(height: 16),
          _buildQuickActionsCard(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: widget.onLogout,
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF7B5B43),
                side: const BorderSide(color: Color(0xFF7B5B43)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF7B5B43),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: const [
          CircleAvatar(
            radius: 36,
            backgroundColor: Color(0xFFF6F4F1),
            child: Icon(Icons.spa_outlined, size: 34, color: Color(0xFF7B5B43)),
          ),
          SizedBox(height: 12),
          Text(
            "Glow Nail Studio",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Luxury manicures, pedicures, and nail care",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFFF3EDE8)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return _buildSectionCard(
      title: "Business Information",
      icon: Icons.business_center_outlined,
      child: Column(
        children: [
          _InfoRow(label: "Owner", value: BusinessStore.owner),
          const SizedBox(height: 12),
          _InfoRow(label: "Phone", value: BusinessStore.phone),
          const SizedBox(height: 12),
          _InfoRow(label: "Email", value: BusinessStore.email),
          const SizedBox(height: 12),
          _InfoRow(label: "Location", value: BusinessStore.location),
          const SizedBox(height: 12),
          _InfoRow(label: "About", value: BusinessStore.about),
        ],
      ),
    );
  }

  Widget _buildHoursCard() {
    return _buildSectionCard(
      title: "Business Hours",
      icon: Icons.access_time_outlined,
      child: Column(
        children: [
          _InfoRow(label: "Monday", value: StudioSettingsStore.monday),
          const SizedBox(height: 10),
          _InfoRow(label: "Tuesday", value: StudioSettingsStore.tuesday),
          const SizedBox(height: 10),
          _InfoRow(label: "Wednesday", value: StudioSettingsStore.wednesday),
          const SizedBox(height: 10),
          _InfoRow(label: "Thursday", value: StudioSettingsStore.thursday),
          const SizedBox(height: 10),
          _InfoRow(label: "Friday", value: StudioSettingsStore.friday),
          const SizedBox(height: 10),
          _InfoRow(label: "Saturday", value: StudioSettingsStore.saturday),
          const SizedBox(height: 10),
          _InfoRow(label: "Sunday", value: StudioSettingsStore.sunday),
        ],
      ),
    );
  }

  Widget _buildPoliciesCard() {
    return _buildSectionCard(
      title: "Booking Policies",
      icon: Icons.policy_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PolicyItem(text: StudioSettingsStore.depositPolicy),
          const SizedBox(height: 10),
          _PolicyItem(text: StudioSettingsStore.reschedulePolicy),
          const SizedBox(height: 10),
          _PolicyItem(text: StudioSettingsStore.cancellationPolicy),
          const SizedBox(height: 10),
          _PolicyItem(text: StudioSettingsStore.lateArrivalPolicy),
          const SizedBox(height: 10),
          _PolicyItem(text: "Same-Day Cutoff: ${_formatCutoffHour()}"),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return _buildSectionCard(
      title: "Quick Actions",
      icon: Icons.flash_on_outlined,
      child: Column(
        children: [
          _ActionTile(
            icon: Icons.edit_outlined,
            title: "Edit Business Details",
            subtitle: "Update studio information",
            onTap: _openEditBusinessScreen,
          ),
          const Divider(height: 20),
          _ActionTile(
            icon: Icons.schedule_outlined,
            title: "Update Business Hours",
            subtitle: "Adjust availability hours",
            onTap: _openEditBusinessHoursScreen,
          ),
          const Divider(height: 20),
          _ActionTile(
            icon: Icons.rule_folder_outlined,
            title: "Manage Policies",
            subtitle: "Review booking rules",
            onTap: _openEditPoliciesScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF7B5B43)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E2A27),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 88,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF7A746E),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 15, color: Color(0xFF2E2A27)),
          ),
        ),
      ],
    );
  }
}

class _PolicyItem extends StatelessWidget {
  final String text;

  const _PolicyItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Icon(
            Icons.check_circle_outline,
            size: 18,
            color: Color(0xFF7B5B43),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 15, height: 1.4)),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF3ECE7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF7B5B43)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF7A746E),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
