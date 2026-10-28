import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';

class CampMeetingLocationsScreen extends StatefulWidget {
  const CampMeetingLocationsScreen({super.key});

  @override
  State<CampMeetingLocationsScreen> createState() => _CampMeetingLocationsScreenState();
}

class _CampMeetingLocationsScreenState extends State<CampMeetingLocationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showBroadcastLocationDialog() {
    final colporteurNameController = TextEditingController();
    final phoneController = TextEditingController();
    final eventNameController = TextEditingController(text: 'SDA Camp Meeting 2026');
    final boothController = TextEditingController();
    final cityController = TextEditingController(text: 'Nairobi');
    final descriptionController = TextEditingController();
    bool hasHardCopy = true;
    bool hasSoftCopy = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Broadcast Camp Meeting Spot',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),
                TextField(
                  controller: colporteurNameController,
                  decoration: const InputDecoration(labelText: 'Your Name / Team *', prefixIcon: Icon(Icons.person_outline)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Contact Phone / WhatsApp *', prefixIcon: Icon(Icons.phone_outlined)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: eventNameController,
                  decoration: const InputDecoration(labelText: 'Camp Meeting / Event Name *', prefixIcon: Icon(Icons.campaign_outlined)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: boothController,
                  decoration: const InputDecoration(labelText: 'Exact Booth / Tent Location *', prefixIcon: Icon(Icons.location_on_outlined)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(labelText: 'Town / City', prefixIcon: Icon(Icons.location_city_outlined)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Featured Books in Stock (e.g. Great Controversy, Diet & Foods)',
                    prefixIcon: Icon(Icons.menu_book),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Hard Copies', style: TextStyle(fontSize: 12)),
                        value: hasHardCopy,
                        activeColor: AppTheme.primaryBlue,
                        onChanged: (val) => setModalState(() => hasHardCopy = val ?? true),
                      ),
                    ),
                    Expanded(
                      child: CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Soft Copies', style: TextStyle(fontSize: 12)),
                        value: hasSoftCopy,
                        activeColor: AppTheme.primaryGreen,
                        onChanged: (val) => setModalState(() => hasSoftCopy = val ?? true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      if (colporteurNameController.text.trim().isEmpty ||
                          phoneController.text.trim().isEmpty ||
                          boothController.text.trim().isEmpty) {
                        return;
                      }

                      await FirebaseFirestore.instance.collection('camp_meeting_locations').add({
                        'colporteurName': colporteurNameController.text.trim(),
                        'phone': phoneController.text.trim(),
                        'eventName': eventNameController.text.trim(),
                        'boothLocation': boothController.text.trim(),
                        'city': cityController.text.trim(),
                        'description': descriptionController.text.trim(),
                        'hasHardCopy': hasHardCopy,
                        'hasSoftCopy': hasSoftCopy,
                        'status': 'Active Now',
                        'postedAt': FieldValue.serverTimestamp(),
                      });

                      if (mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Your Camp Meeting location is live for all attendees!'),
                            backgroundColor: AppTheme.primaryGreen,
                          ),
                        );
                      }
                    },
                    child: const Text('BROADCAST TO ATTENDEES', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final Uri launchUri = Uri(scheme: 'tel', path: cleanPhone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _openWhatsApp(String phone, String name, String event) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final message = Uri.encodeComponent(
      'Hello $name, I saw your Literature Evangelism book stand at $event on Harvion. Are you currently at the booth?',
    );
    final Uri launchUri = Uri.parse('https://wa.me/$cleanPhone?text=$message');
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Camp Meeting Book Stands', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.sacredGold,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_location_alt),
        label: const Text('POST MY BOOTH', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: _showBroadcastLocationDialog,
      ),
      body: Column(
        children: [
          // Header Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppTheme.primaryBlue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Live Colporteur Field Directory',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Find nearby literature evangelists stationed at camp meetings and outreach sites to buy hard copies or get instant soft copies.',
                  style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search by camp meeting, town, or colporteur...',
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.search, color: AppTheme.primaryBlue),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Live Feed
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('camp_meeting_locations').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
                }

                List<Map<String, dynamic>> locations = [];
                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  locations = snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return {
                      'id': doc.id,
                      ...data,
                    };
                  }).toList();
                }

                if (_searchQuery.isNotEmpty) {
                  locations = locations.where((loc) {
                    final event = (loc['eventName'] ?? '').toString().toLowerCase();
                    final booth = (loc['boothLocation'] ?? '').toString().toLowerCase();
                    final name = (loc['colporteurName'] ?? '').toString().toLowerCase();
                    final city = (loc['city'] ?? '').toString().toLowerCase();
                    return event.contains(_searchQuery) ||
                        booth.contains(_searchQuery) ||
                        name.contains(_searchQuery) ||
                        city.contains(_searchQuery);
                  }).toList();
                }

                if (locations.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_off_outlined, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 14),
                          const Text(
                            'No Active Camp Meeting Spots Found',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Are you selling books at a camp meeting or convention? Tap the gold button below to broadcast your booth.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                  itemCount: locations.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final spot = locations[index];
                    final colporteurName = spot['colporteurName'] ?? 'Literature Evangelist';
                    final phone = spot['phone'] ?? '';
                    final eventName = spot['eventName'] ?? 'SDA Camp Meeting';
                    final boothLocation = spot['boothLocation'] ?? 'Main Entrance';
                    final city = spot['city'] ?? '';
                    final desc = spot['description'] ?? '';
                    final hasHard = spot['hasHardCopy'] ?? true;
                    final hasSoft = spot['hasSoftCopy'] ?? true;
                    final status = spot['status'] ?? 'Active Now';

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Status & City
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.green.shade200),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const CircleAvatar(radius: 4, backgroundColor: Colors.green),
                                      const SizedBox(width: 6),
                                      Text(status, style: TextStyle(color: Colors.green.shade800, fontSize: 10, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                                if (city.isNotEmpty)
                                  Row(
                                    children: [
                                      const Icon(Icons.location_city, size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(city, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                                    ],
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Event & Booth
                            Text(
                              eventName,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.pin_drop, size: 16, color: Colors.redAccent),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    boothLocation,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Colporteur Name
                            Text(
                              'Stationed Colporteur: $colporteurName',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                            ),

                            if (desc.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                desc,
                                style: const TextStyle(fontSize: 12, height: 1.3, color: Colors.black87),
                              ),
                            ],
                            const SizedBox(height: 10),

                            // Format badges (Wrap to prevent overflow on narrow screens)
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                if (hasHard)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text('Hard Copies Available', style: TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold)),
                                  ),
                                if (hasSoft)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text('Soft Copies (Instant)', style: TextStyle(fontSize: 10, color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                                  ),
                              ],
                            ),
                            const Divider(height: 20),

                            // Action buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppTheme.primaryBlue,
                                      side: const BorderSide(color: AppTheme.primaryBlue),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    icon: const Icon(Icons.phone, size: 16),
                                    label: const Text('CALL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    onPressed: phone.isNotEmpty ? () => _makePhoneCall(phone) : null,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF25D366),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    icon: const Icon(Icons.chat, size: 16),
                                    label: const Text('WHATSAPP', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    onPressed: phone.isNotEmpty ? () => _openWhatsApp(phone, colporteurName, eventName) : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
