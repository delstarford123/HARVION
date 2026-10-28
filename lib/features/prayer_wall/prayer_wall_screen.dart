import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'services/prayer_wall_service.dart';

class PrayerWallScreen extends StatefulWidget {
  const PrayerWallScreen({super.key});

  @override
  State<PrayerWallScreen> createState() => _PrayerWallScreenState();
}

class _PrayerWallScreenState extends State<PrayerWallScreen> {
  final prayerService = PrayerWallService();
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Health & Healing',
    'Family & Salvation',
    'Evangelism & Mission',
    'Faith & Stewardship',
  ];

  void _showAddPrayerDialog() {
    final nameController = TextEditingController();
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String category = 'Health & Healing';
    bool isAnonymous = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.volunteer_activism, color: AppTheme.primaryGreen),
                SizedBox(width: 8),
                Text('Submit Prayer Need', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CheckboxListTile(
                    title: const Text('Post Anonymously', style: TextStyle(fontSize: 13)),
                    value: isAnonymous,
                    activeColor: AppTheme.primaryGreen,
                    onChanged: (val) => setModalState(() => isAnonymous = val ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (!isAnonymous)
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Your Name (Brother/Sister)'),
                    ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Prayer Subject / Need'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: [
                      'Health & Healing',
                      'Family & Salvation',
                      'Evangelism & Mission',
                      'Faith & Stewardship',
                    ].map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)))).toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => category = val);
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Describe how the body of Christ can pray for you...'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  if (titleController.text.trim().isEmpty) return;
                  prayerService.addPrayerRequest(
                    authorName: isAnonymous ? 'A Fellow Believer' : (nameController.text.trim().isNotEmpty ? nameController.text.trim() : 'Anonymous'),
                    isAnonymous: isAnonymous,
                    title: titleController.text.trim(),
                    description: descController.text.trim(),
                    category: category,
                  );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Your prayer need has been placed on the Prayer Wall.'),
                      backgroundColor: AppTheme.primaryGreen,
                    ),
                  );
                },
                child: const Text('POST PRAYER NEED'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: prayerService,
      builder: (context, _) {
        final prayers = _selectedCategory == 'All'
            ? prayerService.prayers
            : prayerService.prayers.where((p) => p.category == _selectedCategory).toList();

        return Scaffold(
          backgroundColor: AppTheme.backgroundLight,
          appBar: AppBar(
            title: const Text('Community Prayer Wall', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: AppTheme.primaryBlue,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                tooltip: 'Submit Request',
                icon: const Icon(Icons.add_circle_outline),
                onPressed: _showAddPrayerDialog,
              ),
            ],
          ),
          body: Column(
            children: [
              // Encouragement banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: AppTheme.primaryGreen.withOpacity(0.1),
                child: const Row(
                  children: [
                    Icon(Icons.handshake, color: AppTheme.primaryGreen, size: 24),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '"The effectual fervent prayer of a righteous man availeth much." — James 5:16',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Categories
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: _categories.map((c) {
                    final isSel = _selectedCategory == c;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(c),
                        selected: isSel,
                        selectedColor: AppTheme.primaryBlue,
                        labelStyle: TextStyle(
                          color: isSel ? Colors.white : Colors.black87,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (val) {
                          if (val) setState(() => _selectedCategory = c);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Prayers list
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: prayers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final p = prayers[index];
                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: AppTheme.primaryBlue.withOpacity(0.12),
                                      child: const Icon(Icons.person, size: 16, color: AppTheme.primaryBlue),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      p.displayName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: p.isAnswered
                                        ? Colors.amber.shade100
                                        : AppTheme.primaryGreen.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    p.isAnswered ? 'PRAISE REPORT' : p.category,
                                    style: TextStyle(
                                      color: p.isAnswered ? Colors.brown.shade800 : AppTheme.primaryGreen,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              p.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryBlue),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              p.description,
                              style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
                            ),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${p.prayerCount} believers prayed',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                                ),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: p.hasUserPrayed ? AppTheme.primaryGreen : Colors.white,
                                    foregroundColor: p.hasUserPrayed ? Colors.white : AppTheme.primaryGreen,
                                    side: const BorderSide(color: AppTheme.primaryGreen),
                                    visualDensity: VisualDensity.compact,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  icon: Icon(
                                    p.hasUserPrayed ? Icons.check : Icons.favorite_border,
                                    size: 16,
                                  ),
                                  label: Text(
                                    p.hasUserPrayed ? 'PRAYED FOR' : 'PRAY FOR THIS',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () {
                                    prayerService.togglePrayed(p);
                                  },
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
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('SUBMIT PRAYER'),
            onPressed: _showAddPrayerDialog,
          ),
        );
      },
    );
  }
}

