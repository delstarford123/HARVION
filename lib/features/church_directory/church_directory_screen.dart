import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import 'models/church_model.dart';

class ChurchDirectoryScreen extends StatefulWidget {
  const ChurchDirectoryScreen({super.key});

  @override
  State<ChurchDirectoryScreen> createState() => _ChurchDirectoryScreenState();
}

class _ChurchDirectoryScreenState extends State<ChurchDirectoryScreen> {
  final List<SdaChurch> _churches = SdaChurch.getSampleChurches();
  final TextEditingController _searchController = TextEditingController();
  String _selectedCity = 'All';

  final List<String> _cities = ['All', 'Nairobi', 'Kisumu', 'Mombasa', 'Eldoret'];

  Future<void> _makeCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber.replaceAll(' ', ''));
    if (!await launchUrl(launchUri)) {
      debugPrint('Could not call $phoneNumber');
    }
  }

  Future<void> _openMaps(double lat, double lng, String name) async {
    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch maps');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = _churches.where((c) {
      if (_selectedCity != 'All' && c.city != _selectedCity) return false;
      if (query.isNotEmpty) {
        final matchesName = c.name.toLowerCase().contains(query);
        final matchesConf = c.conference.toLowerCase().contains(query);
        final matchesAddr = c.address.toLowerCase().contains(query);
        return matchesName || matchesConf || matchesAddr;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Church & Event Directory', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search & City Filter
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search church name, conference, city...',
                    prefixIcon: const Icon(Icons.search, color: AppTheme.primaryBlue),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _cities.map((city) {
                      final isSel = _selectedCity == city;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(city),
                          selected: isSel,
                          selectedColor: AppTheme.primaryBlue,
                          labelStyle: TextStyle(
                            color: isSel ? Colors.white : Colors.black87,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (val) {
                            if (val) setState(() => _selectedCity = city);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Church List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text('No churches found matching your query.',
                        style: TextStyle(color: Colors.grey.shade600)),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final c = filtered[index];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top badges
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryBlue.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      c.conference,
                                      style: const TextStyle(
                                        color: AppTheme.primaryBlue,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                  if (c.hasBookstoreDepot)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryGreen.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(Icons.local_shipping, size: 12, color: AppTheme.primaryGreen),
                                          SizedBox(width: 4),
                                          Text(
                                            'Bookstore Depot Pickup',
                                            style: TextStyle(
                                              color: AppTheme.primaryGreen,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Name
                              Text(
                                c.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppTheme.primaryBlue),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.location_on, size: 16, color: Colors.redAccent),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      '${c.address}, ${c.city}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Service Times Box
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Sabbath Fellowship Hours:',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.primaryBlue)),
                                    const SizedBox(height: 6),
                                    ...c.serviceTimes.entries.map((st) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(st.key, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                                            Text(st.value,
                                                style: const TextStyle(
                                                    fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),

                              // Upcoming events
                              if (c.upcomingEvents.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                const Text('Upcoming Events & Health Expos:',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black87)),
                                const SizedBox(height: 4),
                                ...c.upcomingEvents.map((e) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('📅 ', style: TextStyle(fontSize: 12)),
                                          Expanded(child: Text(e, style: const TextStyle(fontSize: 12))),
                                        ],
                                      ),
                                    )),
                              ],
                              const SizedBox(height: 14),

                              // Actions row
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        visualDensity: VisualDensity.compact,
                                        side: const BorderSide(color: AppTheme.primaryBlue),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      icon: const Icon(Icons.map, size: 16, color: AppTheme.primaryBlue),
                                      label: const Text('Map & Directions', style: TextStyle(fontSize: 12, color: AppTheme.primaryBlue)),
                                      onPressed: () => _openMaps(c.latitude, c.longitude, c.name),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryGreen,
                                        foregroundColor: Colors.white,
                                        visualDensity: VisualDensity.compact,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      icon: const Icon(Icons.phone, size: 16),
                                      label: const Text('Contact Pastor', style: TextStyle(fontSize: 12)),
                                      onPressed: () => _makeCall(c.pastorPhone),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

