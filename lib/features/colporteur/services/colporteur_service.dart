import 'package:flutter/foundation.dart';
import '../models/colporteur_model.dart';

class ColporteurService extends ChangeNotifier {
  static final ColporteurService _instance = ColporteurService._internal();
  factory ColporteurService() => _instance;
  ColporteurService._internal() {
    _initSampleData();
  }

  ColporteurProfile _profile = ColporteurProfile(
    leId: 'LE-KE-2026-042',
    name: 'Alfredo Onuko',
    churchConference: 'Central Kenya Conference (CKC) - Publishing Dept',
    referralCode: 'COLP-ALFREDO10',
    totalSalesCommission: 14850.0,
    booksDistributed: 64,
    activeCustomers: 28,
    commissionRate: 0.25,
  );

  final List<ColporteurLead> _leads = [];

  ColporteurProfile get profile => _profile;
  List<ColporteurLead> get leads => List.unmodifiable(_leads);

  void addLead({
    required String name,
    required String phone,
    required String location,
    required String interestBook,
    required String notes,
  }) {
    final lead = ColporteurLead(
      id: 'lead_${DateTime.now().millisecondsSinceEpoch}',
      customerName: name,
      phone: phone,
      location: location,
      interestBook: interestBook,
      notes: notes,
      status: 'New Lead',
      dateAdded: DateTime.now(),
    );
    _leads.insert(0, lead);
    _profile = ColporteurProfile(
      leId: _profile.leId,
      name: _profile.name,
      churchConference: _profile.churchConference,
      referralCode: _profile.referralCode,
      totalSalesCommission: _profile.totalSalesCommission,
      booksDistributed: _profile.booksDistributed,
      activeCustomers: _profile.activeCustomers + 1,
      commissionRate: _profile.commissionRate,
    );
    notifyListeners();
  }

  void updateLeadStatus(String leadId, String newStatus) {
    final index = _leads.indexWhere((l) => l.id == leadId);
    if (index >= 0) {
      final old = _leads[index];
      _leads[index] = ColporteurLead(
        id: old.id,
        customerName: old.customerName,
        phone: old.phone,
        location: old.location,
        interestBook: old.interestBook,
        notes: old.notes,
        status: newStatus,
        dateAdded: old.dateAdded,
      );
      notifyListeners();
    }
  }

  String generateReferralLink() {
    return 'https://harvion.app/le/${_profile.referralCode}';
  }

  String generateWhatsAppShareText() {
    return '🌱 *Greetings in Christ!* 📚\n\n'
        'I am sharing life-changing Seventh-day Adventist books on Health, Prophecy, and Faith through the Harvion ministry.\n\n'
        'Use my Colporteur code *${_profile.referralCode}* to get *10% OFF* plus free prayer & direct delivery to your home or local church depot!\n\n'
        'Order here: ${generateReferralLink()}';
  }

  void _initSampleData() {
    _leads.addAll([
      ColporteurLead(
        id: 'lead_01',
        customerName: 'Elder Joseph Mwangi',
        phone: '0722 123 456',
        location: 'Westlands, Nairobi',
        interestBook: 'The Great Controversy',
        notes: 'Interested in Daniel & Revelation prophecy series and family edition.',
        status: 'Ordered',
        dateAdded: DateTime.now().subtract(const Duration(days: 3)),
      ),
      ColporteurLead(
        id: 'lead_02',
        customerName: 'Sister Grace Achieng',
        phone: '0733 987 654',
        location: 'Kilimani, Nairobi',
        interestBook: 'The Ministry of Healing & Plant-based Recipes',
        notes: 'Requested consultation on natural hydrotherapy remedies and cooking.',
        status: 'Followed Up',
        dateAdded: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ColporteurLead(
        id: 'lead_03',
        customerName: 'Pastor Samuel Kiprop',
        phone: '0711 445 566',
        location: 'Nakuru Town',
        interestBook: 'Sabbath School Lesson Quarterlies (Bulk for Church)',
        notes: 'Wants 25 copies for the local youth Sabbath School division.',
        status: 'New Lead',
        dateAdded: DateTime.now(),
      ),
    ]);
  }
}

