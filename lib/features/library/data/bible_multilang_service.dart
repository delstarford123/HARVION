import 'package:hive/hive.dart';
import '../../../core/constants.dart';

enum BibleTranslation {
  kjv('King James Version (KJV)', 'English', '🇬🇧', 'en-US'),
  swahili('Biblia Takatifu (SUV)', 'Kiswahili', '🇰🇪', 'sw-KE'),
  spanish('Reina-Valera 1960', 'Español', '🇪🇸', 'es-ES'),
  french('Louis Segond 1910', 'Français', '🇫🇷', 'fr-FR');

  final String label;
  final String languageName;
  final String flag;
  final String locale;

  const BibleTranslation(this.label, this.languageName, this.flag, this.locale);
}

class BibleMultiLangService {
  static final BibleMultiLangService instance = BibleMultiLangService._internal();
  BibleMultiLangService._internal();

  BibleTranslation _currentTranslation = BibleTranslation.kjv;

  BibleTranslation get currentTranslation => _currentTranslation;

  void init() {
    try {
      if (Hive.isBoxOpen(AppConstants.boxSavedArticles)) {
        final box = Hive.box(AppConstants.boxSavedArticles);
        final saved = box.get('sda_bible_translation');
        if (saved is String) {
          _currentTranslation = BibleTranslation.values.firstWhere(
            (e) => e.name == saved,
            orElse: () => BibleTranslation.kjv,
          );
        }
      }
    } catch (_) {}
  }

  void setTranslation(BibleTranslation translation) {
    _currentTranslation = translation;
    try {
      if (Hive.isBoxOpen(AppConstants.boxSavedArticles)) {
        final box = Hive.box(AppConstants.boxSavedArticles);
        box.put('sda_bible_translation', translation.name);
      }
    } catch (_) {}
  }

  /// Map standard English canonical book name to the selected translation
  String getLocalizedBookName(String englishBookName) {
    final lower = englishBookName.toLowerCase().trim();
    switch (_currentTranslation) {
      case BibleTranslation.swahili:
        return _swahiliBookNames[lower] ?? englishBookName;
      case BibleTranslation.spanish:
        return _spanishBookNames[lower] ?? englishBookName;
      case BibleTranslation.french:
        return _frenchBookNames[lower] ?? englishBookName;
      case BibleTranslation.kjv:
      default:
        return englishBookName;
    }
  }

  /// Multi-language translated core scripture database
  List<Map<String, dynamic>>? getTranslatedVerses(String bookName, int chapter) {
    final lower = bookName.toLowerCase().trim();

    if (_currentTranslation == BibleTranslation.swahili) {
      return _swahiliChapters['${lower}_$chapter'];
    } else if (_currentTranslation == BibleTranslation.spanish) {
      return _spanishChapters['${lower}_$chapter'];
    } else if (_currentTranslation == BibleTranslation.french) {
      return _frenchChapters['${lower}_$chapter'];
    }
    return null;
  }

  // ==========================================
  // 🇰🇪 SWAHILI BIBLE TRANSLATION (SUV)
  // ==========================================
  static const Map<String, String> _swahiliBookNames = {
    'genesis': 'Mwanzo',
    'exodus': 'Kutoka',
    'leviticus': 'Mambo ya Walawi',
    'numbers': 'Hesabu',
    'deuteronomy': 'Kumbukumbu la Torati',
    'joshua': 'Yoshua',
    'judges': 'Waamuzi',
    'ruth': 'Ruthu',
    '1 samuel': '1 Samweli',
    '2 samuel': '2 Samweli',
    '1 kings': '1 Wafalme',
    '2 kings': '2 Wafalme',
    '1 chronicles': '1 Mambo ya Nyakati',
    '2 chronicles': '2 Mambo ya Nyakati',
    'ezra': 'Ezra',
    'nehemiah': 'Nehemia',
    'esther': 'Esta',
    'job': 'Ayubu',
    'psalms': 'Zaburi',
    'proverbs': 'Mithali',
    'ecclesiastes': 'Mhubiri',
    'song of solomon': 'Wimbo Ulio Bora',
    'isaiah': 'Isaya',
    'jeremiah': 'Yeremia',
    'lamentations': 'Maombolezo',
    'ezekiel': 'Ezekieli',
    'daniel': 'Danieli',
    'hosea': 'Hosea',
    'joel': 'Yoeli',
    'amos': 'Amosi',
    'obadiah': 'Obadia',
    'jonah': 'Yona',
    'micah': 'Mika',
    'nahum': 'Nahumu',
    'habakkuk': 'Habakuki',
    'zephaniah': 'Sefania',
    'haggai': 'Hagai',
    'zechariah': 'Zekaria',
    'malachi': 'Malaki',
    'matthew': 'Mathayo',
    'mark': 'Marko',
    'luke': 'Luka',
    'john': 'Yohana',
    'acts': 'Matendo ya Mitume',
    'romans': 'Warumi',
    '1 corinthians': '1 Wakorintho',
    '2 corinthians': '2 Wakorintho',
    'galatians': 'Wagalatia',
    'ephesians': 'Waefeso',
    'philippians': 'Wafilipi',
    'colossians': 'Wakolosai',
    '1 thessalonians': '1 Wathesalonike',
    '2 thessalonians': '2 Wathesalonike',
    '1 timothy': '1 Timotheo',
    '2 timothy': '2 Timotheo',
    'titus': 'Tito',
    'philemon': 'Filemoni',
    'hebrews': 'Waebrania',
    'james': 'Yakobo',
    '1 peter': '1 Petro',
    '2 peter': '2 Petro',
    '1 john': '1 Yohana',
    '2 john': '2 Yohana',
    '3 john': '3 Yohana',
    'jude': 'Yuda',
    'revelation': 'Ufunuo wa Yohana',
  };

  // ==========================================
  // 🇪🇸 SPANISH BIBLE TRANSLATION (RVR1960)
  // ==========================================
  static const Map<String, String> _spanishBookNames = {
    'genesis': 'Génesis',
    'exodus': 'Éxodo',
    'leviticus': 'Levítico',
    'numbers': 'Números',
    'deuteronomy': 'Deuteronomio',
    'joshua': 'Josué',
    'judges': 'Jueces',
    'ruth': 'Rut',
    '1 samuel': '1 Samuel',
    '2 samuel': '2 Samuel',
    '1 kings': '1 Reyes',
    '2 kings': '2 Reyes',
    'psalms': 'Salmos',
    'proverbs': 'Proverbios',
    'isaiah': 'Isaías',
    'daniel': 'Daniel',
    'matthew': 'Mateo',
    'mark': 'Marcos',
    'luke': 'Lucas',
    'john': 'Juan',
    'acts': 'Hechos',
    'romans': 'Romanos',
    '1 corinthians': '1 Corintios',
    '2 corinthians': '2 Corintios',
    'galatians': 'Gálatas',
    'ephesians': 'Efesios',
    'revelation': 'Apocalipsis',
  };

  // ==========================================
  // 🇫🇷 FRENCH BIBLE TRANSLATION (LSG 1910)
  // ==========================================
  static const Map<String, String> _frenchBookNames = {
    'genesis': 'Genèse',
    'exodus': 'Exode',
    'leviticus': 'Lévitique',
    'numbers': 'Nombres',
    'deuteronomy': 'Deutéronome',
    'joshua': 'Josué',
    'judges': 'Juges',
    'ruth': 'Ruth',
    'psalms': 'Psaumes',
    'proverbs': 'Proverbes',
    'isaiah': 'Ésaïe',
    'daniel': 'Daniel',
    'matthew': 'Matthieu',
    'mark': 'Marc',
    'luke': 'Luc',
    'john': 'Jean',
    'acts': 'Actes',
    'romans': 'Romains',
    'revelation': 'Apocalypse',
  };

  // Core translated chapters in Swahili
  static final Map<String, List<Map<String, dynamic>>> _swahiliChapters = {
    'revelation_14': [
      {'verse': 1, 'text': 'Kisha nikaona, na tazama, huyo Mwana-Kondoo amesimama juu ya mlima Sayuni, na pamoja naye watu mia na arobaini na nne elfu, wenye jina lake na jina la Baba yake limeandikwa katika vipaji vya nyuso zao.'},
      {'verse': 2, 'text': 'Nikasikia sauti kutoka mbinguni, kama sauti ya maji mengi, na kama sauti ya radi kuu; na hiyo sauti niliyoisikia ilikuwa kama sauti ya wapiga vinubi wakivipiga vinubi vyao.'},
      {'verse': 3, 'text': 'Nao waimba wimbo mpya mbele ya kile kiti cha enzi, na mbele ya wale wenye uhai wanne, na wale wazee; wala hapana mtu aliyeweza kujifunza wimbo ule, ila wale mia na arobaini na nne elfu, walionunuliwa katika nchi.'},
      {'verse': 4, 'text': 'Hawa ndio wasio kutiwa unajisi pamoja na wanawake; maana ni bikira. Hawa ndio wamfuatao Mwana-Kondoo kila aendako. Hawa wamenunuliwa katika wanadamu, malimbuko kwa Mungu na kwa Mwana-Kondoo.'},
      {'verse': 5, 'text': 'Na katika vinywa vyao haukuonekana uongo; hawana mawaa.'},
      {'verse': 6, 'text': 'Kisha nikaona malaika mwingine, akiruka katikati ya mbingu, mwenye Injili ya milele, awahubiri hao wakaao juu ya nchi, na kila taifa na kabila na lugha na jamaa.'},
      {'verse': 7, 'text': 'Akasema kwa sauti kuu, Mcheni Mungu, na kumtukuza, kwa maana saa ya hukumu yake imekuja; msujudieni yeye aliyezifanya mbingu na nchi na bahari na chemchemi za maji.'},
      {'verse': 8, 'text': 'Kisha mwingine, malaika wa pili, akafuata, akisema, Umeanguka, umeanguka Babeli, mji ule ulio mkuu, ambao uliwanywesha mataifa yote mvinyo ya ghadhabu ya uasherati wake.'},
      {'verse': 9, 'text': 'Na mwingine, malaika wa tatu, akafuata, akisema kwa sauti kuu, Mtu awaye yote akimsujudu huyo mnyama na sanamu yake, na kuipokea chapa katika kipaji cha uso wake, au katika mkono wake,'},
      {'verse': 10, 'text': 'yeye naye atakunywa katika mvinyo ya ghadhabu ya Mungu iliyotengenezwa pasipo kuchanganywa na maji, katika kikombe cha hasira yake; naye atateswa kwa moto na kiberiti mbele ya malaika watakatifu, na mbele za Mwana-Kondoo.'},
      {'verse': 11, 'text': 'Na moshi wa maumivu yao hupanda juu hata milele na milele; wala hawana raha mchana wala usiku, hao wamsujuduo huyo mnyama na sanamu yake, na kila aipokeaye chapa ya jina lake.'},
      {'verse': 12, 'text': 'Hapa ndipo penye subira ya watakatifu, hao wazishikao amri za Mungu, na imani ya Yesu.'},
    ],
    'john_3': [
      {'verse': 16, 'text': 'Kwa maana jinsi hii Mungu aliupenda ulimwengu, hata akamtoa Mwanawe pekee, ili kila mtu amwaminiye asipotee, bali awe na uzima wa milele.'},
      {'verse': 17, 'text': 'Maana Mungu hakumtuma Mwana ulimwenguni ili auhukumu ulimwengu, bali ulimwengu uokolewe katika yeye.'},
    ],
    'psalms_23': [
      {'verse': 1, 'text': 'Bwana ndiye mchungaji wangu, Sitapungukiwa na kitu.'},
      {'verse': 2, 'text': 'Katika malisho ya majani mabichi hunilaza, Kando ya maji ya utulivu huniongoza.'},
      {'verse': 3, 'text': 'Hunihuisha nafsi yangu; Huniongoza katika njia za haki kwa ajili ya jina lake.'},
      {'verse': 4, 'text': 'Naam, nijapopita kati ya bonde la uvuli wa mauti, Sitaogopa mabaya; Kwa maana Wewe upo pamoja nami, Fimbo yako na gongo lako vyanifariji.'},
      {'verse': 5, 'text': 'Waandaa meza mbele yangu, Machoni pa watesi wangu. Umenipaka mafuta kichwani pangu, Na kikombe changu kinafurika.'},
      {'verse': 6, 'text': 'Hakika wema na fadhili zitanifuata Siku zote za maisha yangu; Nami nitakaa nyumbani mwa Bwana milele.'},
    ],
    'exodus_20': [
      {'verse': 8, 'text': 'Ikumbuke siku ya Sabato uitakase.'},
      {'verse': 9, 'text': 'Siku sita fanya kazi, utende mambo yako yote;'},
      {'verse': 10, 'text': 'lakini siku ya saba ni Sabato ya Bwana, Mungu wako, siku hiyo usifanye kazi yo yote, wewe, wala mwana wako, wala binti yako, wala mtumwa wako, wala mjakazi wako, wala mnyama wako wa kufuga, wala mgeni aliye ndani ya malango yako.'},
      {'verse': 11, 'text': 'Maana, kwa siku sita Bwana alifanya mbingu, na nchi, na bahari, na vyote vilivyomo, akastarehe siku ya saba; kwa hiyo Bwana akaibarikia siku ya Sabato akaitakasa.'},
    ],
  };

  // Core translated chapters in Spanish
  static final Map<String, List<Map<String, dynamic>>> _spanishChapters = {
    'revelation_14': [
      {'verse': 6, 'text': 'Vi volar por en medio del cielo a otro ángel, que tenía el evangelio eterno para predicarlo a los moradores de la tierra, a toda nación, tribu, lengua y pueblo,'},
      {'verse': 7, 'text': 'diciendo a gran voz: Temed a Dios, y dadle gloria, porque la hora de su juicio ha llegado; y adorad a aquel que hizo el cielo y la tierra, el mar y las fuentes de las aguas.'},
      {'verse': 8, 'text': 'Otro ángel le siguió, diciendo: Ha caído, ha caído Babilonia, la gran ciudad, porque ha hecho beber a todas las naciones del vino del furor de su fornicación.'},
      {'verse': 9, 'text': 'Y el tercer ángel los siguió, diciendo a gran voz: Si alguno adora a la bestia y a su imagen, y recibe la marca en su frente o en su mano,'},
      {'verse': 12, 'text': 'Aquí está la paciencia de los santos, los que guardan los mandamientos de Dios y la fe de Jesús.'},
    ],
    'john_3': [
      {'verse': 16, 'text': 'Porque de tal manera amó Dios al mundo, que ha dado a su Hijo unigénito, para que todo aquel que en él cree, no se pierda, mas tenga vida eterna.'},
    ],
    'psalms_23': [
      {'verse': 1, 'text': 'Jehová es mi pastor; nada me faltará.'},
      {'verse': 2, 'text': 'En lugares de delicados pastos me hará descansar; Junto a aguas de reposo me pastoreará.'},
      {'verse': 3, 'text': 'Confortará mi alma; Me guiará por sendas de justicia por amor de su nombre.'},
      {'verse': 4, 'text': 'Aunque ande en valle de sombra de muerte, No temeré mal alguno, porque tú estarás conmigo; Tu vara y tu cayado me infundirán aliento.'},
      {'verse': 5, 'text': 'Aderezas mesa delante de mí en presencia de mis angustiadores; Unges mi cabeza con aceite; mi copa está rebosando.'},
      {'verse': 6, 'text': 'Ciertamente el bien y la misericordia me seguirán todos los días de mi vida, Y en la casa de Jehová moraré por largos días.'},
    ],
  };

  // Core translated chapters in French
  static final Map<String, List<Map<String, dynamic>>> _frenchChapters = {
    'revelation_14': [
      {'verse': 6, 'text': 'Je vis un autre ange qui volait au milieu du ciel, ayant un Évangile éternel, pour l\'annoncer aux habitants de la terre, à toute nation, à toute tribu, à toute langue, et à tout peuple.'},
      {'verse': 7, 'text': 'Il disait d\'une voix forte: Craignez Dieu, et donnez-lui gloire, car l\'heure de son jugement est venue; et adorez celui qui a fait le ciel, et la terre, et la mer, et les sources d\'eaux.'},
      {'verse': 8, 'text': 'Et un autre, un second ange suivit, en disant: Elle est tombée, elle est tombée, Babylone la grande, qui a abreuvé toutes les nations du vin de la fureur de son impudicité!'},
      {'verse': 12, 'text': 'C\'est ici la persévérance des saints, qui gardent les commandements de Dieu et la foi de Jésus.'},
    ],
    'john_3': [
      {'verse': 16, 'text': 'Car Dieu a tant aimé le monde qu\'il a donné son Fils unique, afin que quiconque croit en lui ne périsse point, mais qu\'il ait la vie éternelle.'},
    ],
    'psalms_23': [
      {'verse': 1, 'text': 'L\'Éternel est mon berger: je ne manquerai de rien.'},
      {'verse': 2, 'text': 'Il me fait reposer dans de verts pâturages, Il me dirige près des eaux paisibles.'},
      {'verse': 3, 'text': 'Il restaure mon âme, Il me conduit dans les sentiers de la justice, À cause de son nom.'},
      {'verse': 4, 'text': 'Quand je marche dans la vallée de l\'ombre de la mort, Je ne crains aucun mal, car tu es avec moi: Ta houlette et ton bâton me rassurent.'},
      {'verse': 5, 'text': 'Tu dresses devant moi une table, En face de mes adversaires; Tu oins d\'huile ma tête, Et ma coupe déborde.'},
      {'verse': 6, 'text': 'Oui, le bonheur et la grâce m\'accompagneront Tous les jours de ma vie, Et j\'habiterai dans la maison de l\'Éternel Jusqu\'à la fin de mes jours.'},
    ],
  };
}

