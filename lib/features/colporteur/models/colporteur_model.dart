class ColporteurLead {
  final String id;
  final String customerName;
  final String phone;
  final String location;
  final String interestBook;
  final String notes;
  final String status; // 'New Lead', 'Followed Up', 'Ordered', 'Baptism Interest'
  final DateTime dateAdded;

  ColporteurLead({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.location,
    required this.interestBook,
    required this.notes,
    this.status = 'New Lead',
    required this.dateAdded,
  });
}

class ColporteurProfile {
  final String leId;
  final String name;
  final String churchConference;
  final String referralCode;
  final double totalSalesCommission; // Ksh earned
  final int booksDistributed;
  final int activeCustomers;
  final double commissionRate; // e.g. 0.25 (25%)

  ColporteurProfile({
    required this.leId,
    required this.name,
    required this.churchConference,
    required this.referralCode,
    required this.totalSalesCommission,
    required this.booksDistributed,
    required this.activeCustomers,
    this.commissionRate = 0.25,
  });
}

