import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme.dart';
import 'models/tract_model.dart';

class DigitalTractsScreen extends StatefulWidget {
  const DigitalTractsScreen({super.key});

  @override
  State<DigitalTractsScreen> createState() => _DigitalTractsScreenState();
}

class _DigitalTractsScreenState extends State<DigitalTractsScreen> {
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Salvation',
    'Sabbath',
    'Prophecy',
    'Health',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _shareTract(DigitalTract tract) async {
    // 1. Share via native share dialog
    await Share.share(tract.generateShareMessage());

    // 2. Increment real-time share metric in Firestore
    try {
      await FirebaseFirestore.instance
          .collection('digital_tracts')
          .doc(tract.id)
          .update({'shareCount': FieldValue.increment(1)});
    } catch (_) {}
  }

  void _showTractDetail(DigitalTract tract) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      tract.category.toUpperCase(),
                      style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                tract.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
              ),
              const SizedBox(height: 4),
              Text(
                tract.subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const Divider(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Scripture Anchor
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.sacredGold.withOpacity(0.4)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Scripture Anchor:',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.primaryBlue)),
                            const SizedBox(height: 4),
                            Text(tract.keyVerse,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        tract.fullText,
                        style: const TextStyle(fontSize: 14, height: 1.7, color: Colors.black87),
                      ),
                      const SizedBox(height: 20),

                      // Quote Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2)),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.format_quote, color: AppTheme.sacredGold, size: 28),
                            const SizedBox(height: 6),
                            Text(
                              tract.shareCardQuote,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366), // WhatsApp Green
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.share),
                  label: const Text('SHARE ON WHATSAPP & SOCIAL MEDIA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  onPressed: () {
                    _shareTract(tract);
                    Navigator.pop(ctx);
                  },
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
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Digital Tracts & Evangelism', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('digital_tracts').snapshots(),
        builder: (context, snapshot) {
          List<DigitalTract> tracts = [];

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            tracts = snapshot.data!.docs.map((doc) {
              final d = doc.data() as Map<String, dynamic>;
              return DigitalTract(
                id: doc.id,
                title: d['title'] ?? 'Digital Tract',
                subtitle: d['subtitle'] ?? '',
                category: d['category'] ?? 'General',
                summary: d['summary'] ?? '',
                fullText: d['fullText'] ?? '',
                keyVerse: d['keyVerse'] ?? '',
                shareCardQuote: d['shareCardQuote'] ?? '',
                shareCount: d['shareCount'] ?? 100,
              );
            }).toList();
          } else {
            tracts = DigitalTract.getSampleTracts();
          }

          final filtered = tracts.where((t) {
            if (_selectedCategory != 'All' && t.category.toLowerCase() != _selectedCategory.toLowerCase()) {
              return false;
            }
            if (_searchQuery.isNotEmpty) {
              final q = _searchQuery.toLowerCase();
              return t.title.toLowerCase().contains(q) ||
                  t.summary.toLowerCase().contains(q) ||
                  t.keyVerse.toLowerCase().contains(q);
            }
            return true;
          }).toList();

          return Column(
            children: [
              // Search & Category Bar
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val.trim()),
                      decoration: InputDecoration(
                        hintText: 'Search gospel truth, Bible topics...',
                        prefixIcon: const Icon(Icons.search, color: AppTheme.primaryBlue),
                        isDense: true,
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, idx) {
                          final cat = _categories[idx];
                          final isSel = _selectedCategory == cat;
                          return ChoiceChip(
                            label: Text(cat, style: TextStyle(fontSize: 11, color: isSel ? Colors.white : Colors.black87)),
                            selected: isSel,
                            selectedColor: AppTheme.primaryBlue,
                            onSelected: (val) => setState(() => _selectedCategory = cat),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Tracts List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final tract = filtered[i];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _showTractDetail(tract),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryBlue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      tract.category.toUpperCase(),
                                      style: const TextStyle(
                                          color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 10),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.share, size: 13, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text('${tract.shareCount} shares',
                                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                tract.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryBlue),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tract.summary,
                                style: TextStyle(fontSize: 12, height: 1.4, color: Colors.grey.shade700),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '📖 ${tract.keyVerse}',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primaryGreen),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF25D366),
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(0, 32),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    icon: const Icon(Icons.share, size: 14),
                                    label: const Text('SHARE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                    onPressed: () => _shareTract(tract),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
