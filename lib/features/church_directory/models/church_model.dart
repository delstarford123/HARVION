class SdaChurch {
  final String id;
  final String name;
  final String conference; // e.g. 'Central Kenya Conference', 'Western Kenya Field'
  final String city;
  final String address;
  final String pastorName;
  final String pastorPhone;
  final String clerkPhone;
  final String email;
  final Map<String, String> serviceTimes; // {'Sabbath School': '9:00 AM', 'Divine Service': '11:00 AM', 'AY (Adventist Youth)': '2:30 PM', 'Midweek Prayer': 'Wed 6:00 PM'}
  final List<String> upcomingEvents;
  final bool hasBookstoreDepot; // Can users pick up books here?
  final double latitude;
  final double longitude;

  SdaChurch({
    required this.id,
    required this.name,
    required this.conference,
    required this.city,
    required this.address,
    required this.pastorName,
    required this.pastorPhone,
    required this.clerkPhone,
    required this.email,
    required this.serviceTimes,
    required this.upcomingEvents,
    this.hasBookstoreDepot = false,
    this.latitude = -1.286389,
    this.longitude = 36.817223,
  });

  static List<SdaChurch> getSampleChurches() {
    return [
      SdaChurch(
        id: 'chu_01',
        name: 'Nairobi Central SDA Church (Maxwell)',
        conference: 'Central Kenya Conference',
        city: 'Nairobi',
        address: 'Jakaya Kikwete Rd / Milimani, Opposite Integrity Centre',
        pastorName: 'Pastor J. Ouko',
        pastorPhone: '+254 722 000 111',
        clerkPhone: '+254 722 000 222',
        email: 'info@maxwellsda.org',
        serviceTimes: {
          'Sabbath School': '9:00 AM - 10:45 AM',
          'Divine Service': '11:00 AM - 12:45 PM',
          'Bible Study & Choir': '2:00 PM - 3:30 PM',
          'Adventist Youth (AY)': '3:30 PM - 5:00 PM',
          'Midweek Prayer': 'Wednesday 5:30 PM - 7:00 PM',
        },
        upcomingEvents: [
          'Health Expo & Lifestyle Seminar (Next Sabbath 2 PM)',
          'Youth Camp Meeting & Pathfinders Fair (Aug 15-22)',
          'Literature Evangelism Book Fair at Maxwell Hall (Sunday 10 AM)',
        ],
        hasBookstoreDepot: true,
        latitude: -1.2933,
        longitude: 36.8123,
      ),
      SdaChurch(
        id: 'chu_02',
        name: 'Newlife SDA Church Nairobi',
        conference: 'Central Kenya Conference',
        city: 'Nairobi',
        address: 'Fifth Ngong Avenue, off Ngong Road',
        pastorName: 'Pastor D. Musyoka',
        pastorPhone: '+254 733 111 222',
        clerkPhone: '+254 733 111 333',
        email: 'connect@newlifesda.org',
        serviceTimes: {
          'Sabbath School': '8:45 AM - 10:30 AM',
          'Divine Service': '10:45 AM - 12:30 PM',
          'Adventist Youth (AY)': '2:30 PM - 4:45 PM',
          'Vesper & Sunset': 'Friday 6:00 PM',
        },
        upcomingEvents: [
          'Revelation Seminars: Prophecy Unsealed (Starting Nov 5)',
          'Total Member Involvement (TMI) Literature Blitz',
        ],
        hasBookstoreDepot: true,
        latitude: -1.2989,
        longitude: 36.8065,
      ),
      SdaChurch(
        id: 'chu_03',
        name: 'Kisumu Central SDA Church',
        conference: 'Greater Lake Field / Western Kenya',
        city: 'Kisumu',
        address: 'Nyerere Road, near Milimani',
        pastorName: 'Pastor E. Omondi',
        pastorPhone: '+254 711 222 333',
        clerkPhone: '+254 711 222 444',
        email: 'kisumucentralsda@gmail.com',
        serviceTimes: {
          'Sabbath School': '9:00 AM - 10:45 AM',
          'Divine Service': '11:00 AM - 1:00 PM',
          'Afternoon Fellowship': '2:30 PM - 5:00 PM',
        },
        upcomingEvents: [
          'Regional Camp Meeting at Maseno Grounds',
          'Community Organic Agriculture Workshop',
        ],
        hasBookstoreDepot: true,
        latitude: -0.1022,
        longitude: 34.7617,
      ),
      SdaChurch(
        id: 'chu_04',
        name: 'Mombasa Central SDA Church',
        conference: 'Coast Kenya Conference',
        city: 'Mombasa',
        address: 'Haile Selassie Avenue, Mombasa Island',
        pastorName: 'Pastor A. Kazungu',
        pastorPhone: '+254 720 333 444',
        clerkPhone: '+254 720 333 555',
        email: 'mombasacentralsda@gmail.com',
        serviceTimes: {
          'Sabbath School': '9:00 AM - 10:30 AM',
          'Divine Service': '10:45 AM - 12:45 PM',
          'AY & Sunset Vespers': '3:00 PM - 6:15 PM',
        },
        upcomingEvents: [
          'Beachside Youth Revival & Pathfinder Investiture',
          'Medical Missionary Outreach at Likoni Ferry',
        ],
        hasBookstoreDepot: true,
        latitude: -4.0583,
        longitude: 39.6636,
      ),
      SdaChurch(
        id: 'chu_05',
        name: 'Eldoret Central SDA Church',
        conference: 'North Rift Valley Conference',
        city: 'Eldoret',
        address: 'Uganda Road, Pioneer Estate',
        pastorName: 'Pastor B. Kipchumba',
        pastorPhone: '+254 723 444 555',
        clerkPhone: '+254 723 444 666',
        email: 'eldoretcentralsda@gmail.com',
        serviceTimes: {
          'Sabbath School': '9:00 AM - 10:45 AM',
          'Divine Service': '11:00 AM - 1:00 PM',
          'Adventist Men / Dorcas Outreach': '2:30 PM - 4:30 PM',
        },
        upcomingEvents: [
          'Farming God\'s Way & Natural Farming Seminar',
          'Evangelistic Tent Effort (Oct 10-24)',
        ],
        hasBookstoreDepot: false,
        latitude: 0.5143,
        longitude: 35.2698,
      ),
    ];
  }
}

