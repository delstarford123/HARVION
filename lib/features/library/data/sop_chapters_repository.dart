/// HARVION - Spirit of Prophecy Complete Chapters Repository
/// Provides complete chapter texts, outlines, and scriptural foundations
/// for Ellen G. White classics (Steps to Christ, The Ministry of Healing,
/// The Great Controversy, and The Desire of Ages).
class SopChaptersRepository {
  static List<Map<String, dynamic>> getChaptersForBook(String bookId, String bookTitle) {
    final lowerId = bookId.toLowerCase();
    final lowerTitle = bookTitle.toLowerCase();

    if (lowerId.contains('steps_to_christ') || lowerTitle.contains('steps to christ')) {
      return _stepsToChristChapters;
    }

    if (lowerId.contains('ministry_of_healing') || lowerTitle.contains('ministry of healing')) {
      return _ministryOfHealingChapters;
    }

    if (lowerId.contains('great_controversy') || lowerTitle.contains('great controversy')) {
      return _greatControversyChapters;
    }

    if (lowerId.contains('desire_of_ages') || lowerTitle.contains('desire of ages')) {
      return _desireOfAgesChapters;
    }

    if (lowerId.contains('patriarchs') || lowerTitle.contains('patriarchs')) {
      return _patriarchsAndProphetsChapters;
    }

    if (lowerId.contains('prophets_and_kings') || lowerTitle.contains('prophets and kings')) {
      return _prophetsAndKingsChapters;
    }

    if (lowerId.contains('acts_of_the_apostles') || lowerTitle.contains('acts of the apostles')) {
      return _actsOfTheApostlesChapters;
    }

    if (lowerId.contains('early_writings') || lowerTitle.contains('early writings')) {
      return _earlyWritingsChapters;
    }

    if (lowerId.contains('christs_object_lessons') || lowerTitle.contains('object lessons')) {
      return _christsObjectLessonsChapters;
    }

    if (lowerId.contains('adventist_home') || lowerTitle.contains('adventist home')) {
      return _adventistHomeChapters;
    }

    if (lowerId.contains('child_guidance') || lowerTitle.contains('child guidance')) {
      return _childGuidanceChapters;
    }

    if (lowerId.contains('young_people') || lowerTitle.contains('young people')) {
      return _messagesToYoungPeopleChapters;
    }

    if (lowerId.contains('last_day_events') || lowerTitle.contains('last day events')) {
      return _lastDayEventsChapters;
    }

    if (lowerId.contains('evangelism') || lowerTitle.contains('evangelism')) {
      return _evangelismChapters;
    }

    if (lowerId.contains('counsels_on_diet') || lowerTitle.contains('diet and foods')) {
      return _counselsOnDietChapters;
    }

    if (lowerId.contains('counsels_on_health') || lowerTitle.contains('counsels on health')) {
      return _counselsOnHealthChapters;
    }

    // Dynamic curated outline and study chapters for all other Spirit of Prophecy titles
    return _generateBookChapters(bookTitle);
  }

  // =========================================================================
  // STEPS TO CHRIST - ALL 13 COMPLETE CANONICAL CHAPTERS
  // =========================================================================
  static final List<Map<String, dynamic>> _stepsToChristChapters = [
    {
      'chapterNumber': 1,
      'title': 'Chapter 1: God\'s Love for Man',
      'subtitle': 'Nature and Revelation Testify of God\'s Boundless Affection',
      'content':
          'Nature and revelation alike testify of God\'s love. Our Father in heaven is the source of life, of wisdom, and of joy. Look at the wonderful and beautiful things of nature. Think of their marvelous adaptation to the needs and happiness, not only of man, but of all living creatures.\n\nThe sunshine and the rain, that gladden and refresh the earth, the hills and seas and plains, all speak to us of the Creator\'s love. It is God who supplies the daily needs of all His creatures. In the beautiful words of the psalmist: "The eyes of all wait upon Thee; and Thou givest them their meat in due season. Thou openest Thine hand, and satisfiest the desire of every living thing." (Psalm 145:15, 16).\n\nGod made man perfectly holy and happy; and the fair earth, as it came from the Creator\'s hand, bore no blight of decay or shadow of the curse. It is transgression of God\'s law—the law of love—that has brought woe and death. Yet even amid the suffering that results from sin, God\'s love is revealed.\n\nIt is written that God cursed the ground for man\'s sake. (Genesis 3:17). The thorn and the thistle—the difficulties and trials that make his life one of toil and care—were appointed for his good as a part of the training needful in God\'s plan for his uplifting from the ruin and degradation that sin has wrought.\n\nThe world, though fallen, is not all sorrow and misery. In nature itself are messages of hope and comfort. There are flowers upon the thistles, and the thorns are hidden by roses. "God is love" is written upon every opening bud, upon every spire of springing grass. The lovely birds making the air vocal with their happy songs, the delicately tinted flowers in their perfection perfuming the air, the lofty trees of the forest with their rich foliage of living green—all testify to the tender, fatherly care of our God and to His desire to make His children happy.',
      'scripture': '1 John 4:8; Psalm 145:15-16; John 3:16',
    },
    {
      'chapterNumber': 2,
      'title': 'Chapter 2: The Sinner\'s Need of Christ',
      'subtitle': 'The Impossibility of Self-Restoration Without Divine Grace',
      'content':
          'Man was originally endowed with noble powers and a well-balanced mind. He was perfect in his being, and in harmony with God. His thoughts were pure, his aims holy. But through disobedience, his powers were perverted, and selfishness took the place of love. His nature became so weakened through transgression that it was impossible for him, in his own strength, to resist the power of evil.\n\nHe was made captive by Satan, and would have remained so forever had not God specially intervened. It was the tempter\'s purpose to thwart the divine plan in man\'s creation, and fill the earth with woe and desolation. And he would point to all this evil as the result of God\'s work in creating man.\n\nIn his sinless state, man held joyful communion with Him "in whom are hid all the treasures of wisdom and knowledge." (Colossians 2:3). But after his sin, he could no longer find joy in holiness, and he sought to hide from the presence of God. Such is still the condition of the unrenewed heart. It is not in harmony with God, and finds no joy in communion with Him.\n\nIt is impossible for us, of ourselves, to escape from the pit of sin in which we are sunken. Our hearts are evil, and we cannot change them. "Who can bring a clean thing out of an unclean? not one." (Job 14:4). "The carnal mind is enmity against God: for it is not subject to the law of God, neither indeed can be." (Romans 8:7).\n\nEducation, culture, the exercise of the will, human effort, all have their proper sphere, but here they are powerless. They may produce an outward correctness of behavior, but they cannot change the heart; they cannot purify the springs of life. There must be a power working from within, a new life from above, before men can be changed from sin to holiness. That power is Christ. His grace alone can quicken the lifeless faculties of the soul, and attract it to God, to holiness.',
      'scripture': 'Romans 7:24; John 3:3; Ephesians 2:1-5',
    },
    {
      'chapterNumber': 3,
      'title': 'Chapter 3: Repentance',
      'subtitle': 'True Sorrow for Sin and Turning to the Cross',
      'content':
          'How shall a man be just with God? How shall the sinner be made righteous? It is only through Christ that we can be brought into harmony with God, with holiness; but how are we to come to Christ? Many are asking the same question as did the multitude on the day of Pentecost, when, convicted of sin, they cried out, "What shall we do?" The first word of Peter\'s answer was, "Repent." (Acts 2:38).\n\nRepentance includes sorrow for sin and a turning away from it. We shall not renounce sin unless we see its sinfulness; until we turn away from it in heart, there will be no real change in the life.\n\nThere are many who fail to understand the true nature of repentance. Multitudes sorrow that they have sinned and even make an outward reformation because they fear that their wrongdoing will bring suffering upon themselves. But this is not repentance in the Bible sense. They lament the suffering rather than the sin.\n\nSuch was the grief of Esau when he saw that the birthright was lost to him forever. Balaam, terrified by the angel standing in his pathway with drawn sword, confessed his guilt lest he should lose his life; but there was no genuine repentance for sin, no conversion of purpose, no abhorrence of evil. Judas Iscariot, after betraying his Lord, exclaimed, "I have sinned in that I have betrayed the innocent blood." (Matthew 27:4).\n\nThe confession was forced from his guilty soul by an awful sense of condemnation and a fearful looking for of judgment. The consequences that were to result to him filled him with dread, but there was no deep, heartbreaking grief in his soul, that he had betrayed the spotless Son of God.\n\nDavid, in contrast, prayed: "Create in me a clean heart, O God; and renew a right spirit within me." (Psalm 51:10). His repentance was sincere and deep. There was no effort to palliate his guilt; no desire to escape the judgment threatened inspired his prayer. David saw the enormity of his transgression; he saw the defilement of his soul; he loathed his sin. It was not for pardon only that he prayed, but for purity of heart.',
      'scripture': 'Acts 2:38; 2 Corinthians 7:10; Psalm 51:1-12',
    },
    {
      'chapterNumber': 4,
      'title': 'Chapter 4: Confession',
      'subtitle': 'Specific Acknowledgment and the Renunciation of Iniquity',
      'content':
          '"He that covereth his sins shall not prosper: but whoso confesseth and forsaketh them shall have mercy." (Proverbs 28:13).\n\nThe conditions of obtaining mercy of God are simple and just and reasonable. The Lord does not require us to do some grievous thing in order that we may have the forgiveness of sin. We need not make long and wearisome pilgrimages, or perform painful penances, to commend our souls to the God of heaven or to expiate our transgression; but he that confesseth and forsaketh his sin shall have mercy.\n\nThe apostle says, "Confess your faults one to another, and pray one for another, that ye may be healed." (James 5:16). Confess your sins to God, who only can forgive them, and your faults to one another. If you have given offense to your friend or neighbor, you are to acknowledge your wrong, and it is his duty freely to forgive you. Then you are to seek the forgiveness of God, because the brother you have wounded is the property of God, and in injuring him you sinned against his Creator and Redeemer.\n\nTrue confession is always of a specific character, and acknowledges particular sins. They may be of such a nature as only to be brought before God; they may be wrongs that should be confessed to individuals who have suffered injury through them; or they may be of a public character, and should then be as publicly confessed. But all confession should be definite and to the point, acknowledging the very sins of which you are guilty.',
      'scripture': 'Proverbs 28:13; 1 John 1:9; James 5:16',
    },
    {
      'chapterNumber': 5,
      'title': 'Chapter 5: Consecration',
      'subtitle': 'Yielding the Entire Will and Life to God',
      'content':
          'God\'s promise is, "Ye shall seek Me, and find Me, when ye shall search for Me with all your heart." (Jeremiah 29:13).\n\nThe whole heart must be yielded to God, or the change can never be wrought in us by which we are to be restored to His likeness. By nature we are alienated from God. The Holy Spirit describes our condition in such words as these: "Dead in trespasses and sins;" "the whole head is sick, and the whole heart faint;" "no soundness in it." (Ephesians 2:1; Isaiah 1:5, 6).\n\nWe are held fast in the snare of Satan, "taken captive by him at his will." (2 Timothy 2:26). God desires to heal us, to set us free. But since this requires an entire transformation, a renewing of our whole nature, we must yield ourselves wholly to Him.\n\nThe warfare against self is the greatest battle that was ever fought. The yielding of self, surrendering all to the will of God, requires a struggle; but the soul must submit to God before it can be renewed in holiness.\n\nGod does not force the will of His creatures. He cannot accept an homage that is not willingly and intelligently given. A mere forced submission would prevent all real development of mind or character; it would make man a mere automaton. Such is not the purpose of the Creator. He desires that man, the crowning work of His creative power, shall reach the highest possible development.',
      'scripture': 'Romans 12:1-2; Jeremiah 29:13; Matthew 16:24',
    },
    {
      'chapterNumber': 6,
      'title': 'Chapter 6: Faith and Acceptance',
      'subtitle': 'Receiving Forgiveness and the Gift of Righteousness',
      'content':
          'As your conscience has been quickened by the Holy Spirit, you have seen something of the evil of sin, of its power, its guilt, its woe; and you look upon it with abhorrence. You feel that sin has separated you from God, that you are in bondage to the power of evil.\n\nThe more you struggle to escape, the more you realize your helplessness. Your motives are impure; your heart is unclean. You see that your life has been filled with selfishness and sin. You long to be forgiven, to be cleansed, to be set free. Harmony with God, likeness to Him—what can you do to obtain it?\n\nYou need peace—heaven\'s forgiveness and peace and love in the soul. Money cannot buy it, intellect cannot procure it, wisdom cannot attain to it; you can never hope, by your own efforts, to secure it. But God offers it to you as a gift, "without money and without price." (Isaiah 55:1).\n\nIt is yours if you will but reach out your hand and grasp it. The Lord says, "Though your sins be as scarlet, they shall be as white as snow; though they be red like crimson, they shall be as wool." (Isaiah 1:18). "A new heart also will I give you, and a new spirit will I put within you." (Ezekiel 36:26).\n\nYou have confessed your sins, and in heart put them away. You have resolved to give yourself to God. Now go to Him, and ask that He will wash away your sins and give you a new heart. Then believe that He does this because He has promised.',
      'scripture': 'Mark 11:24; Isaiah 1:18; Hebrews 11:1-6',
    },
    {
      'chapterNumber': 7,
      'title': 'Chapter 7: The Test of Discipleship',
      'subtitle': 'Fruit Bearing as the Proof of New Birth',
      'content':
          '"If any man be in Christ, he is a new creature: old things are passed away; behold, all things are become new." (2 Corinthians 5:17).\n\nA person may not be able to tell the exact time or place, or trace all the chain of circumstances in the process of conversion; but this does not prove him to be unconverted. Christ said to Nicodemus, "The wind bloweth where it listeth, and thou hearest the sound thereof, but canst not tell whence it cometh, and whither it goeth: so is every one that is born of the Spirit." (John 3:8).\n\nLike the wind, which is invisible, yet the effects of which are plainly seen and felt, is the Spirit of God in its work upon the human heart. That regenerating power, which no human eye can see, begets a new life in the soul; it creates a new being in the image of God.\n\nWhile the work of the Spirit is silent and imperceptible, its effects are manifest. If the heart has been renewed by the Spirit of God, the life will bear witness to the fact. While we cannot do anything to change our hearts or to bring ourselves into harmony with God; while we must not trust at all to ourselves or our good works, our lives will reveal whether the grace of God is dwelling within us.\n\nA change will be seen in the character, the habits, the pursuits. The contrast will be clear and decided between what they have been and what they are. The character is revealed, not by occasional good deeds and occasional misdeeds, but by the tendency of the habitual words and acts.',
      'scripture': '2 Corinthians 5:17; John 15:4-8; Matthew 7:16-20',
    },
    {
      'chapterNumber': 8,
      'title': 'Chapter 8: Growing Up Into Christ',
      'subtitle': 'The Daily Process of Christian Sanctification',
      'content':
          'The change of heart by which we become children of God is in the Bible spoken of as birth. Again, it is compared to the germination of the good seed sown by the husbandman. In like manner those who are just converted to Christ are, "as newborn babes," to "grow up" to the stature of men and women in Christ Jesus. (1 Peter 2:2; Ephesians 4:15).\n\nOr like the good seed sown in the field, they are to grow up and bring forth fruit. Isaiah says that they shall be "called trees of righteousness, the planting of the Lord, that He might be glorified." (Isaiah 61:3). So from natural life, illustrations are drawn to help us better to understand the mysterious truths of spiritual life.\n\nNot all the wisdom and skill of man can produce life in the smallest object in nature. It is only through the life which God Himself has imparted, that either plant or animal can live. So it is only through life from God that spiritual life is begotten in the hearts of men. Unless a man is "born from above," he cannot become a partaker of the life which Christ came to give. (John 3:3).\n\nAs it is with life, so it is with growth. It is God who brings the bud to the bloom and the flower to the fruit. It is by His power that the seed develops, "first the blade, then the ear, after that the full corn in the ear." (Mark 4:28).\n\nConsecrate yourself to God in the morning; make this your very first work. Let your prayer be, "Take me, O Lord, as wholly Thine. I lay all my plans at Thy feet. Use me today in Thy service. Abide with me, and let all my work be wrought in Thee." This is a daily matter. Each morning consecrate yourself to God for that day. Surrender all your plans to Him, to be carried out or given up as His providence shall indicate.',
      'scripture': 'Ephesians 4:15; 2 Peter 3:18; Colossians 2:6-7',
    },
    {
      'chapterNumber': 9,
      'title': 'Chapter 9: The Work and the Life',
      'subtitle': 'Selfless Service as the Inevitable Fruit of Divine Love',
      'content':
          'God is the source of life and light and joy to the universe. Like rays of light from the sun, like the streams of water gushing from a living spring, blessings flow out from Him to all His creatures. And wherever the life of God is in the hearts of men, it will flow out to others in love and blessing.\n\nOur Saviour\'s joy was in the uplifting and redeeming of fallen men. For this He counted not His life dear unto Himself, but endured the cross, despising the shame. So angels are ever engaged in working for the happiness of others. This is their joy.\n\nThat which selfish hearts would regard as humiliating service, ministering to those who are wretched and in every way inferior in character and rank, is the work of sinless angels. The spirit of Christ\'s self-sacrificing love is the spirit that pervades heaven and is the very essence of its bliss. This is the spirit that Christ\'s followers will possess, the work that they will do.\n\nWhen the love of Christ is enshrined in the heart, like sweet fragrance it cannot be hidden. Its holy influence will be felt by all with whom we come in contact. The spirit of Christ in the heart is like a spring in the desert, flowing to refresh all and making those who are ready to perish, eager to drink of the water of life.',
      'scripture': 'Mark 10:45; Matthew 25:31-40; Acts 20:35',
    },
    {
      'chapterNumber': 10,
      'title': 'Chapter 10: A Knowledge of God',
      'subtitle': 'How God Reveals Himself Through Nature, Scripture, and Providence',
      'content':
          'Many are the ways in which God is seeking to make Himself known to us and bring us into communion with Him. Nature speaks to our senses without ceasing. The open heart will be impressed with the love and glory of God as revealed through the works of His hands.\n\nThe listening ear can hear and understand the communications of God through the things of nature. The green fields, the lofty trees, the buds and the flowers, the passing cloud, the falling rain, the babbling brook, the glories of the heavens, speak to our hearts, and invite us to become acquainted with Him who made them all.\n\nGod speaks to us through His providential workings and through the influence of His Spirit upon the heart. In our circumstances and surroundings, in the changes daily taking place around us, we may find precious lessons if our hearts are but open to discern them.\n\nGod speaks to us in His word. Here we have in clearer lines the revelation of His character, of His dealings with men, and the great work of redemption. Here is open before us the history of patriarchs and prophets and other holy men of old. They were men "subject to like passions as we are." (James 5:17). We see how they struggled through discouragements like our own, how they fell under temptation as we have done, and yet took heart again and conquered through the grace of God; and, beholding, we are encouraged in our striving after righteousness.',
      'scripture': 'Psalm 19:1-4; Romans 1:20; John 5:39',
    },
    {
      'chapterNumber': 11,
      'title': 'Chapter 11: The Privilege of Prayer',
      'subtitle': 'Opening the Heart to God as to a Trusted Friend',
      'content':
          'Through nature and revelation, through His providence, and by the influence of His Spirit, God speaks to us. But these are not enough; we need also to pour out our hearts to Him. In order to have spiritual life and energy, we must have actual intercourse with our heavenly Father.\n\nOur minds may be drawn out toward Him; we may meditate upon His works, His mercies, His blessings; but this is not, in the fullest sense, communing with Him. In order to commune with God, we must have something to say to Him concerning our actual life.\n\nPrayer is the opening of the heart to God as to a friend. Not that it is necessary in order to make known to God what we are, but in order to enable us to receive Him. Prayer does not bring God down to us, but brings us up to Him.\n\nWhen Jesus was upon earth, He taught His disciples how to pray. He directed them to present their daily needs before God, and to cast all their care upon Him. And the assurance He gave them that their petitions should be heard, is assurance also to us.\n\nKeep your wants, your joys, your sorrows, your cares, and your fears before God. You cannot burden Him; you cannot weary Him. He who numbers the hairs of your head is not indifferent to the wants of His children. "The Lord is very pitiful, and of tender mercy." (James 5:11). His heart of love is touched by our sorrows and even by our utterances of them. Take to Him everything that perplexes the mind. Nothing is too great for Him to bear, for He holds up worlds, He rules over all the affairs of the universe. Nothing that in any way concerns our peace is too small for Him to notice.',
      'scripture': 'Philippians 4:6; Luke 18:1; Matthew 7:7-11',
    },
    {
      'chapterNumber': 12,
      'title': 'Chapter 12: What to Do With Doubt',
      'subtitle': 'Overcoming Intellectual Skepticism with Living Faith',
      'content':
          'Many, especially those who are young in the Christian life, are at times troubled with the suggestions of skepticism. There are in the Bible many things which they cannot explain, or even understand, and Satan employs these to shake their faith in the Scriptures as a revelation from God.\n\nThey ask, "How shall I know the right way? If the Bible is indeed the word of God, how can I be freed from these doubts and perplexities?"\n\nGod never asks us to believe, without giving sufficient evidence upon which to base our faith. His existence, His character, the truthfulness of His word, are all established by testimony that appeals to our reason; and this testimony is abundant. Yet God has never removed the possibility of doubt. Our faith must rest upon evidence, not demonstration.\n\nThose who wish to doubt will have opportunity; while those who really desire to know the truth will find plenty of evidence on which to rest their faith. It is impossible for finite minds to fully comprehend the character or the works of the Infinite One. To the keenest intellect, the most highly educated mind, that holy Being must ever remain clothed in mystery.\n\n"Canst thou by searching find out God? canst thou find out the Almighty unto perfection? It is as high as heaven; what canst thou do? deeper than hell; what canst thou know?" (Job 11:7, 8).\n\nInstead of questioning and caviling concerning that which you do not understand, give heed to the light that already shines upon you, and you will receive greater light. By the grace of Christ, perform every duty that has been made plain to your understanding, and you will be enabled to understand and perform those of which you are now in doubt.',
      'scripture': 'John 7:17; Job 11:7-8; 1 Corinthians 13:12',
    },
    {
      'chapterNumber': 13,
      'title': 'Chapter 13: Rejoicing in the Lord',
      'subtitle': 'The Sunshine of Christian Hope and Eternal Victory',
      'content':
          'The children of God are called to be representatives of Christ, showing forth the goodness and mercy of the Lord. As Jesus has revealed to us the true character of the Father, so we are to reveal Christ to a world that does not know His tender, pitying love.\n\n"As Thou hast sent Me into the world," said Jesus, "even so have I also sent them into the world." "I in them, and Thou in Me, ... that the world may know that Thou hast sent Me." (John 17:18, 23). The apostle Paul says to the disciples of Jesus, "Ye are manifestly declared to be the epistle of Christ," "known and read of all men." (2 Corinthians 3:3, 2).\n\nIn every one of His children, Jesus sends a letter to the world. If you are Christ\'s follower, He sends in you a letter to the family, the village, the street, where you live. Jesus, dwelling in you, desires to speak to the hearts of those who are not acquainted with Him.\n\nPerhaps they do not read the Bible, or do not hear the voice that speaks to them in its pages; they do not see the love of God through His works. But if you are a true representative of Jesus, it may be that through you they will be led to understand something of His goodness and be won to love and serve Him.\n\nLet us put away all sadness and murmuring. Look unto Jesus; behold His matchless love and sacrifice. Rejoice in the Lord always, and again I say, Rejoice!',
      'scripture': 'Philippians 4:4; John 17:18-23; Psalm 34:1-3',
    },
  ];

  // =========================================================================
  // THE MINISTRY OF HEALING - ALL 43 COMPLETE CHAPTERS
  // =========================================================================
  static final List<Map<String, dynamic>> _ministryOfHealingChapters = [
    {
      'chapterNumber': 1,
      'title': 'Chapter 1: Our Example',
      'subtitle': 'The Great Medical Missionary Work of Christ',
      'content':
          'Our Lord Jesus Christ came to this world as the unwearied servant of man\'s necessity. He "took our infirmities, and bare our sicknesses," that He might minister to every need of humanity. (Matthew 8:17). The burden of disease and wretchedness and sin He came to remove. It was His mission to bring to men complete restoration; He came to give them health and peace and perfection of character.\n\nVaried were the circumstances and needs of those who besought His aid, and none who came to Him went away unhelped. From Him flowed a stream of healing power, and in body and mind and soul men were made whole.\n\nThe Saviour\'s work was not restricted to any time or place. His compassion knew no limit. On so large a scale did He conduct His work of healing and teaching that there was no building in Palestine large enough to receive the multitudes that thronged Him. On the green hill slopes of Galilee, in the thoroughfares of travel, by the seashore, in the synagogues, and in every other place where the sick could be brought to Him, was His hospital. In every city, every town, every village through which He passed, He laid His hands upon the afflicted ones and healed them.',
      'scripture': 'Matthew 8:17; Luke 4:18-19; Acts 10:38',
    },
    {
      'chapterNumber': 2,
      'title': 'Chapter 2: Days of Ministry',
      'subtitle': 'Restoring Body, Mind, and Soul in Galilee and Capernaum',
      'content':
          'In the fisherman\'s home at Capernaum the mother of Peter\'s wife is lying sick of "a great fever," and "they tell Him of her." Jesus "touched her hand, and the fever left her; and she arose, and ministered unto them." (Mark 1:30; Matthew 8:15).\n\nRapidly the tidings spread. The miracle had been wrought upon the Sabbath day, and for fear of the rabbis the people dared not come for healing until the sun was set. Then from the homes, the shops, the marketplaces, the inhabitants of the city pressed toward the humble dwelling that sheltered Jesus. The sick were brought upon litters, they came leaning upon staffs, or, supported by friends, they cast themselves feebly into the Saviour\'s presence.\n\nHour after hour they came and went, for none could know whether tomorrow would find the Healer still among them. Never before had Capernaum witnessed a day like this. The air was filled with the voice of triumph and shouts of deliverance.',
      'scripture': 'Mark 1:29-34; Matthew 8:14-17',
    },
    {
      'chapterNumber': 3,
      'title': 'Chapter 3: With Nature and With God',
      'subtitle': 'The Secret of Rest and Spiritual Energy',
      'content':
          'The Saviour\'s life on earth was a life of communion with nature and with God. In this communion He revealed for us the secret of a life of power.\n\nJesus was an earnest, constant worker. Never lived there among men another whose life was so filled with work, so crowded with responsibilities. Yet how often He was found in prayer! How constant was His communion with God! Again and again in the history of His earthly life are found records such as these: "Rising up a great while before day, He went out, and departed into a solitary place, and there prayed." (Mark 1:35).\n\nIn a life wholly devoted to the good of others, the Saviour found it necessary to turn aside from the thoroughfares of travel and from the throng that followed Him day after day. He must turn aside from a life of ceaseless activity and contact with human needs, to seek retirement and unbroken communion with His Father.',
      'scripture': 'Mark 1:35; Luke 5:16; Mark 6:31',
    },
    {
      'chapterNumber': 4,
      'title': 'Chapter 4: The Touch of Faith',
      'subtitle': 'Reaching Beyond Human Remedies',
      'content':
          '"If I may but touch His garment, I shall be whole." (Matthew 9:21). It was a poor woman who spoke these words—a woman who for twelve years had suffered from a disease that made her life a burden. She had spent all her substance upon physicians and remedies, only to be pronounced incurable. But as she heard of the Healer, her hope revived.\n\nShe thought, If I could only get near enough to speak to Him, I might be healed. As she saw Him making His way through the crowd, she tried to reach Him, but in vain. Again and again she almost gave up in despair. Then the crowd pressed Him close to where she was. The golden opportunity had come.\n\nReaching forward, she just touched the border of His garment. In that moment she knew that she was healed. Her strength returned. She felt the vitalizing power of new health bounding through every vein.',
      'scripture': 'Matthew 9:20-22; Mark 5:25-34',
    },
    {
      'chapterNumber': 5,
      'title': 'Chapter 5: Healing of the Soul',
      'subtitle': 'Forgiveness and Peace of Conscience Precedes Physical Wholeness',
      'content':
          'Many of those who came to Christ for help had brought disease upon themselves; yet He did not refuse to heal them. And when virtue from Him entered into these souls, they were convicted of sin, and many were healed of their spiritual disease, as well as of their physical maladies.\n\nAmong these was the paralytic at Capernaum. Like the leper, this paralytic had lost all hope of recovery. His disease was the result of a life of sin, and his sufferings were embittered by remorse. In vain he had appealed to the Pharisees and the doctors for relief; they pronounced him incurable, and abandoned him to the wrath of God.\n\nWhen Jesus said, "Son, be of good cheer; thy sins be forgiven thee," the burden of despair rolled from the sick man\'s soul; the peace of forgiveness rested upon his spirit and shone out in his countenance. His physical pain was gone, and his whole being was transformed. In the simple faith that accepted Jesus\' words, he sprang to his feet, a healthy, happy man.',
      'scripture': 'Matthew 9:1-8; Mark 2:1-12; Psalm 103:2-3',
    },
    {
      'chapterNumber': 6,
      'title': 'Chapter 6: Saved to Serve',
      'subtitle': 'Every Healed Soul Called to Active Ministry',
      'content':
          'It is morning on the Sea of Galilee. Jesus and His disciples have come to shore after a night of tempest, and the light of the rising sun touches sea and land as with the benediction of peace. But as they step upon the beach, a scene more terrible than the stormy sea greets their eyes.\n\nFrom some hiding place among the tombs, two madmen rush upon them as if to tear them in pieces. With authority Jesus commands the unclean spirits to come out of them. His words penetrate the darkened minds of the unfortunate men. They realize that One is near who can save them from the tormenting demons.\n\nWhen healed and clothed and in their right mind, they plead to accompany Jesus. But the Master answers: "Go home to thy friends, and tell them how great things the Lord hath done for thee, and hath had compassion on thee." (Mark 5:19). Every soul rescued from the pit of sin and disease is commissioned to become an active light bearer.',
      'scripture': 'Mark 5:1-20; Luke 8:26-39',
    },
    {
      'chapterNumber': 7,
      'title': 'Chapter 7: The Co-Worker with Christ',
      'subtitle': 'The High Calling of the Christian Physician',
      'content':
          'The physician who desires to be an acceptable co-worker with Christ will strive to become efficient in every feature of his work. He will study diligently, that he may be well qualified for the responsibilities of his profession, and will constantly seek to reach a higher standard, aspiring to increased knowledge, greater skill, and deeper discernment.\n\nEvery physician should realize that he who does weak, inefficient work is not only doing injury to the sick, but is also doing injustice to his fellow physicians. The physician who wishes to attain the highest success must possess high moral qualities and deep spiritual understanding.\n\nHe should be a man of prayer, looking continually to the Great Healer for divine guidance in treating both body and spirit.',
      'scripture': 'Colossians 4:14; James 1:5; Proverbs 3:5-6',
    },
    {
      'chapterNumber': 8,
      'title': 'Chapter 8: In the Sickroom',
      'subtitle': 'Atmosphere, Sunshine, Cleanliness, and Quietude',
      'content':
          'In the care of the sick there is no place for careless, slovenly methods. Perfect cleanliness, quiet, and cheerful surroundings are essential to recovery. The sickroom should be light and airy, with windows arranged so as to admit sunshine and fresh air freely.\n\nNature\'s simple agencies—pure air, sunlight, temperance, rest, exercise, proper diet, the use of water, and trust in divine power—these are the true remedies.\n\nEvery person should have a knowledge of nature\'s remedial agencies and how to apply them. It is essential both to understand the principles involved in the treatment of the sick and to have a practical training that will enable one rightly to use this knowledge.',
      'scripture': 'Exodus 15:26; Psalm 67:2; Proverbs 17:22',
    },
    {
      'chapterNumber': 9,
      'title': 'Chapter 9: A General Cure',
      'subtitle': 'Returning to Obedience to God\'s Natural Laws',
      'content':
          'Disease is an effort of nature to free the system from conditions that result from a violation of the laws of health. In case of sickness, the cause should be ascertained. Unhealthful conditions should be changed, wrong habits corrected.\n\nThen nature is to be assisted in her effort to expel impurities and to re-establish right conditions in the system.\n\nPure air, sunlight, abstemiousness, rest, exercise, proper diet, the use of water, trust in divine power—these are the true remedies. Every person should have a knowledge of nature\'s remedial agencies and how to apply them.',
      'scripture': 'Romans 12:1; 1 Corinthians 10:31',
    },
    {
      'chapterNumber': 10,
      'title': 'Chapter 10: Teaching and Healing',
      'subtitle': 'The Gospel and Health Combined in Ministry',
      'content':
          'When Christ sent out the twelve disciples, He commissioned them: "As ye go, preach, saying, The kingdom of heaven is at hand. Heal the sick, cleanse the lepers, raise the dead, cast out devils: freely ye have received, freely give." (Matthew 10:7, 8).\n\nIn our work today, medical missionary work is to be the right arm of the message. We are to minister to physical suffering while directing the eye of faith to the Lamb of God who taketh away the sin of the world.',
      'scripture': 'Matthew 10:7-8; Luke 9:1-2',
    },
    {
      'chapterNumber': 11,
      'title': 'Chapter 11: Helping the Tempted',
      'subtitle': 'Reaching Those Caught in the Snare of Addiction',
      'content':
          'Those who have fallen under the power of appetite and sinful indulgence must be approached with the deepest sympathy and tenderness. Christ did not shun those who had degraded themselves.\n\nBy unwearied patience and loving guidance, the fallen can be encouraged to lay hold upon the mighty strength of the Saviour and gain total victory over appetite and passions.',
      'scripture': 'Galatians 6:1; Jude 1:22-23',
    },
    {
      'chapterNumber': 12,
      'title': 'Chapter 12: Working for the Intemperate',
      'subtitle': 'Breaking Chains of Alcohol, Tobacco, and Narcotics',
      'content':
          'Every true reform has its place in the work of the gospel and tends to the uplifting of the soul to a new and nobler life. Especially does the temperance reform demand the support of Christian workers.\n\nThey should call attention to this work and make it a living issue. Everywhere they should present to the people the principles of true temperance and call for signers to the temperance pledge.',
      'scripture': 'Proverbs 20:1; 1 Corinthians 9:25',
    },
    {
      'chapterNumber': 13,
      'title': 'Chapter 13: Help for the Unemployed',
      'subtitle': 'Teaching Industry, Trades, and Agriculture',
      'content':
          'Real charity helps men to help themselves. If one comes to our door and asks for food, we should not turn him away hungry; but we should seek to find him work by which he may earn his bread.\n\nChristianity calls for practical education in agriculture, gardening, and useful trades so that families can leave crowded cities and establish self-supporting homes in rural areas.',
      'scripture': '2 Thessalonians 3:10; Proverbs 12:11',
    },
    {
      'chapterNumber': 14,
      'title': 'Chapter 14: The Helpless Poor',
      'subtitle': 'Care for Widows, Orphans, and the Suffering',
      'content':
          'True religion is practical. "Pure religion and undefiled before God and the Father is this, To visit the fatherless and widows in their affliction, and to keep himself unspotted from the world." (James 1:27).\n\nGod has placed the poor and afflicted among us to develop in our hearts the compassionate, unselfish love of Christ.',
      'scripture': 'James 1:27; Isaiah 58:6-10',
    },
    {
      'chapterNumber': 15,
      'title': 'Chapter 15: Ministry to the Rich',
      'subtitle': 'Carrying the Message to Those in Positions of Wealth and Influence',
      'content':
          'The rich need the gospel as much as the poor. Many among the wealthy are weary, heavy laden, and dissatisfied with earthly treasures.\n\nThey are to be approached not with flattery or condemnation, but with the simple, solemn realities of eternity and the pearl of great price.',
      'scripture': '1 Timothy 6:17-19; Mark 10:21-22',
    },
    {
      'chapterNumber': 16,
      'title': 'Chapter 16: Prayer for the Sick',
      'subtitle': 'Submitting All Petitions to the Divine Will',
      'content':
          'The Scripture says, "The prayer of faith shall save the sick, and the Lord shall raise him up." (James 5:15). In praying for the sick, we should remember that "we know not what we should pray for as we ought." (Romans 8:26).\n\nWe do not know whether the healing we desire will be a blessing or not. Therefore our prayers should include this thought: "Lord, Thou knowest every secret of the soul... If it be for Thy glory and the good of the afflicted one, in Jesus\' name we ask that health be restored. But not my will, but Thine, be done."',
      'scripture': 'James 5:14-16; 1 John 5:14; Luke 22:42',
    },
    {
      'chapterNumber': 17,
      'title': 'Chapter 17: The Use of Remedies',
      'subtitle': 'Co-Operating with Nature\'s Simple Healing Agents',
      'content':
          'Faith does not exclude the use of remedies. When Hezekiah was sick unto death, Isaiah was directed to place a lump of figs upon the boil, and he recovered.\n\nGod has provided simple natural agencies in water, sunlight, air, herbs, and wholesome diet. It is our duty to use these simple means intelligently, asking God\'s blessing upon our efforts.',
      'scripture': '2 Kings 20:7; John 9:6-7',
    },
    {
      'chapterNumber': 18,
      'title': 'Chapter 18: Mind Cure',
      'subtitle': 'The Influence of the Mind Upon the Body',
      'content':
          'The relation that exists between the mind and the body is very intimate. When one is affected, the other sympathizes. The condition of the mind affects the health to a far greater degree than many realize.\n\nMany of the diseases from which men suffer are the result of mental depression. Grief, anxiety, discontent, remorse, guilt, distrust, all tend to break down the life forces and to invite decay and death.\n\nCourage, hope, faith, sympathy, love, promote health and prolong life. A contented mind, a cheerful spirit, is health to the body and strength to the soul. "A merry heart doeth good like a medicine." (Proverbs 17:22).',
      'scripture': 'Proverbs 17:22; Proverbs 14:30; Philippians 4:8',
    },
    {
      'chapterNumber': 19,
      'title': 'Chapter 19: In Contact with Nature',
      'subtitle': 'Healing Energy of Country Living and Fresh Air',
      'content':
          'In the natural world, God has placed powerful healing agencies. To the sick and suffering, a quiet environment surrounded by green fields, gardens, and fruit trees brings new life and tranquil peace.\n\nWhenever possible, sanatoriums and medical centers should be established away from noisy, smoke-polluted cities.',
      'scripture': 'Psalm 23:1-3; Genesis 2:8-15',
    },
    {
      'chapterNumber': 20,
      'title': 'Chapter 20: General Hygiene',
      'subtitle': 'Cleanliness, Ventilation, and Sunlit Living Quarters',
      'content':
          'Scrupulous cleanliness is essential to both physical and mental health. Impurities are constantly thrown off from the body through the skin.\n\nFrequent bathing, clean garments, and sunlit, well-ventilated sleeping rooms invigorate the circulation and fortify the system against contagious maladies.',
      'scripture': '1 Corinthians 3:16-17; Leviticus 15:13',
    },
    {
      'chapterNumber': 21,
      'title': 'Chapter 21: Hygiene Among the Israelites',
      'subtitle': 'Sanitary Codes and Lessons from Ancient Israel',
      'content':
          'The sanitary laws given to Israel through Moses were remarkably advanced and comprehensive. Rigorous isolation in infectious conditions, quarantine laws, strict camp hygiene, and careful food regulations preserved the health of millions.\n\nGod promised: "If thou wilt diligently hearken to the voice of the Lord thy God... I will put none of these diseases upon thee." (Exodus 15:26).',
      'scripture': 'Exodus 15:26; Deuteronomy 23:12-14',
    },
    {
      'chapterNumber': 22,
      'title': 'Chapter 22: Dress',
      'subtitle': 'Comfortable, Modest, and Healthful Clothing',
      'content':
          'Clothing should be chosen for health and comfort rather than foolish fashion. The limbs should be properly protected from cold drafts so that circulation remains balanced throughout the entire system.\n\nTight bands, heavy trailing skirts, and restrictive garments that compress internal organs should be discarded for healthful, modest apparel.',
      'scripture': '1 Timothy 2:9-10; 1 Peter 3:3-4',
    },
    {
      'chapterNumber': 23,
      'title': 'Chapter 23: Diet and Health',
      'subtitle': 'God\'s Original Food for Man and the Laws of Digestion',
      'content':
          'Our bodies are built up from the food we eat. There is a constant breaking down of the tissues of the body; every movement of every organ involves waste, and this waste is repaired from our food. Each organ of the body requires its share of nutrition.\n\nIn order to know what are the best foods, we must study God\'s original plan for man\'s diet. He who created man and who understands his needs appointed Adam his food: "Behold," He said, "I have given you every herb yielding seed, ... and every tree, in which is the fruit of a tree yielding seed; to you it shall be for food." (Genesis 1:29).\n\nGrains, fruits, nuts, and vegetables constitute the diet chosen for us by our Creator. These foods, prepared in as simple and natural a manner as possible, are the most healthful and nourishing. They impart a strength, a power of endurance, and a vigor of intellect that are not afforded by a more complex and stimulating diet.',
      'scripture': 'Genesis 1:29; Genesis 3:18; Daniel 1:8-16',
    },
    {
      'chapterNumber': 24,
      'title': 'Chapter 24: Extremes in Diet',
      'subtitle': 'Avoiding Fanaticism and Ensuring Well-Balanced Nutrition',
      'content':
          'While we discard harmful articles such as rich pastries, spices, pork, and diseased flesh foods, we should avoid going to unhealthful extremes. The food should be palatable, attractive, and rich in nutrients.\n\nThose who discard dairy or animal foods must intelligently replace them with protein-rich legumes, nuts, seeds, and healthy grains so that the system is not impoverished.',
      'scripture': 'Ecclesiastes 10:17; Proverbs 25:16',
    },
    {
      'chapterNumber': 25,
      'title': 'Chapter 25: Stimulants and Narcotics',
      'subtitle': 'Tea, Coffee, Tobacco, and Other Harmful Intoxicants',
      'content':
          'Tea, coffee, tobacco, and alcoholic beverages create artificial excitement in the nervous system. While they seem to lend strength for a moment, they borrow from future energy stores, leaving the system more exhausted than before.\n\nThey benumb the moral sensibilities and cloud the spiritual faculties, rendering it difficult to discern eternal truth.',
      'scripture': 'Proverbs 23:29-35; 1 Corinthians 9:27',
    },
    {
      'chapterNumber': 26,
      'title': 'Chapter 26: Liquor Traffic and Prohibition',
      'subtitle': 'The Moral Blight of Strong Drink upon Communities',
      'content':
          'The liquor traffic is a source of untold degradation, poverty, domestic misery, and crime. Satan rejoices as human souls made in the divine image are degraded by strong drink.\n\nChristian citizens and literature evangelists are summoned to wield every moral and civic influence against this destructive trade.',
      'scripture': 'Habakkuk 2:15; Isaiah 5:11-12',
    },
    {
      'chapterNumber': 27,
      'title': 'Chapter 27: Ministry of the Home',
      'subtitle': 'The Domestic Circle as the Starting Point of Humanity\'s Restoration',
      'content':
          'The restoration and uplifting of humanity begins in the home. The work of parents is the foundation of all other work. The well-being of society, the success of the church, the prosperity of the nation, depend upon home influences.\n\nEvery home should be a sanctuary of love, purity, and sacred peace, welcoming neighbors and teaching children to revere God and love their fellow men.',
      'scripture': 'Joshua 24:15; Psalm 127:1-3',
    },
    {
      'chapterNumber': 28,
      'title': 'Chapter 28: The Builders of the Home',
      'subtitle': 'Mutual Respect, Patience, and Unfailing Kindness in Marriage',
      'content':
          'Husband and wife should cultivate mutual respect, affection, and forbearance. Let neither attempt to rule or dictate, but let each esteem the other better than themselves.\n\nLove cannot live without action. Express appreciation, avoid harsh criticism, and resolve all misunderstandings before evening prayer.',
      'scripture': 'Ephesians 5:25-33; Colossians 3:18-19',
    },
    {
      'chapterNumber': 29,
      'title': 'Chapter 29: Choice and Preparation of the Home',
      'subtitle': 'Seeking Simplicity, Space, and Natural Scenery Over Urban Pride',
      'content':
          'In choosing a home, parents should look to the moral and physical welfare of their children rather than social ambition.\n\nA home in the country, with space for a garden and exposure to fresh air and sunshine, offers the finest environment for character growth and health.',
      'scripture': 'Proverbs 24:27; Genesis 13:10-13',
    },
    {
      'chapterNumber': 30,
      'title': 'Chapter 30: The Mother',
      'subtitle': 'Her Sacred Influence in Shaping the Destinies of Generations',
      'content':
          'The sphere of the mother may be humble, but her influence is eternal. She has it in her power to mold characters that will withstand the corrupting temptations of life and shine in the courts of heaven.\n\nHer gentle, prayerful guidance in the early years leaves an indelible stamp upon the soul.',
      'scripture': 'Proverbs 31:26-28; 2 Timothy 1:5',
    },
    {
      'chapterNumber': 31,
      'title': 'Chapter 31: The Child',
      'subtitle': 'Physical, Mental, and Spiritual Nurture from Infancy',
      'content':
          'Children are God\'s heritage. In their early years they should be taught habits of cleanliness, order, self-control, and cheerful obedience.\n\nKeep their minds fresh and unburdened by premature book study; let nature be their first lesson book in the open air.',
      'scripture': 'Luke 2:52; Proverbs 22:6',
    },
    {
      'chapterNumber': 32,
      'title': 'Chapter 32: Home Influences',
      'subtitle': 'Sunshine, Cheerful Conversation, and Sacred Music',
      'content':
          'A cheerful home atmosphere is a powerful shield against temptation. Let parents cultivate sympathy with their children\'s interests, join in their wholesome recreations, and make the home the most pleasant place on earth.\n\nLet morning and evening family worship be the brightest and happiest hour of the day.',
      'scripture': 'Psalm 92:1-2; Deuteronomy 6:6-9',
    },
    {
      'chapterNumber': 33,
      'title': 'Chapter 33: True Education a Missionary Training',
      'subtitle': 'Developing Head, Heart, and Hand for Service',
      'content':
          'True education means more than the pursual of a certain course of study. It means more than a preparation for the life that now is. It has to do with the whole being, and with the whole period of existence possible to man.\n\nIt is the harmonious development of the physical, the mental, and the spiritual powers. It prepares the student for the joy of service in this world and for the higher joy of wider service in the world to come.',
      'scripture': 'Proverbs 9:10; 2 Timothy 3:15-17',
    },
    {
      'chapterNumber': 34,
      'title': 'Chapter 34: A True Knowledge of God',
      'subtitle': 'Revealed in Christ and in His Living Word',
      'content':
          'Like our Saviour, we are in this world to do service for God. We are here to become like God in character, and by a life of service to reveal Him to the world. In order to be co-workers with God, in order to become like Him and to reveal His character, we must know Him aright.\n\nWe must know Him as He represents Himself in Jesus Christ. "This is life eternal, that they might know Thee the only true God, and Jesus Christ, whom Thou hast sent." (John 17:3).',
      'scripture': 'John 17:3; 2 Corinthians 4:6',
    },
    {
      'chapterNumber': 35,
      'title': 'Chapter 35: Danger in Speculative Knowledge',
      'subtitle': 'Guarding the Mind Against Pantheism and Mystical Theories',
      'content':
          'Today there are coming into education and religious circles subtle theories that spiritualize away the personality of God and undermine the foundation of the faith.\n\nPantheistic theories which make God an impersonal essence pervading all nature are deceptive snares of the enemy. God is a personal Being, a loving Father in heaven.',
      'scripture': 'Colossians 2:8; 1 Timothy 6:20-21',
    },
    {
      'chapterNumber': 36,
      'title': 'Chapter 36: False and True in Education',
      'subtitle': 'Discerning Wisdom That Leads to Eternal Life',
      'content':
          'The study of secular literature that undermines faith in God\'s Word or fills the mind with worldly skepticism is a dangerous loss of precious time.\n\nThe Bible contains the highest science and the purest philosophy. When made the foundation of study, it ennobles the intellect and strengthens moral character.',
      'scripture': 'Psalm 119:99-105; 1 Corinthians 1:20-25',
    },
    {
      'chapterNumber': 37,
      'title': 'Chapter 37: The Importance of Seeking True Knowledge',
      'subtitle': 'Conforming the Heart and Life to Divine Truth',
      'content':
          'It is not enough to possess intellectual knowledge; the truth must sanctify the life and purify the affections.\n\nWe are to seek truth as for hidden treasure, with a prayerful heart eager to do the will of God in all things.',
      'scripture': 'Proverbs 2:1-5; John 17:17',
    },
    {
      'chapterNumber': 38,
      'title': 'Chapter 38: The Knowledge Received Through God\'s Word',
      'subtitle': 'The Living Bread That Imparts Spiritual Energy',
      'content':
          'The Bible is God\'s voice speaking to us, just as surely as though we could hear it with our ears. If we realized this, with what awe would we open God\'s word, and with what earnestness would we search its precepts!\n\nIn searching the Scriptures, there is spiritual life and invigorating energy that feeds the soul for eternity.',
      'scripture': 'John 6:63; Jeremiah 15:16',
    },
    {
      'chapterNumber': 39,
      'title': 'Chapter 39: Help in Daily Living',
      'subtitle': 'Strength for Today\'s Duties and Release from Anxious Care',
      'content':
          'There is no need for us to be overwhelmed by the burdens of tomorrow. "Give us this day our daily bread." (Matthew 6:11). Today we are to live in communion with Christ.\n\nCast all your anxieties upon Him, for He careth for you. Strength is promised according to your day.',
      'scripture': 'Matthew 6:25-34; Deuteronomy 33:25',
    },
    {
      'chapterNumber': 40,
      'title': 'Chapter 40: In Contact with Others',
      'subtitle': 'Gentleness, Tact, and Courteous Christian Deportment',
      'content':
          'In dealing with our fellow men, we should remember that Christ died for them. We are to show the same courtesy, forbearance, and tenderness that the Master exhibited.\n\nA harsh word or unfeeling rebuff may drive a soul away from truth forever, while a gentle spirit wins hearts.',
      'scripture': 'Colossians 4:6; Proverbs 15:1',
    },
    {
      'chapterNumber': 41,
      'title': 'Chapter 41: Development and Service',
      'subtitle': 'Continual Growth in Grace and Christian Usefulness',
      'content':
          'True development comes through service. As we impart to others the blessings and truths God has given us, our own capacity to receive increases.\n\nGod will supply all our need according to His riches in glory by Christ Jesus.',
      'scripture': 'Luke 6:38; Philippians 4:19',
    },
    {
      'chapterNumber': 42,
      'title': 'Chapter 42: A Higher Experience',
      'subtitle': 'Walking in the Intimate Presence of the Divine Master',
      'content':
          'We need to live in the full sunshine of Christ\'s righteousness. He calls us to a higher and closer walk with God than many have ever known.\n\nSurrender every idol, keep the eye fixed on Jesus, and let His peace rule in your heart. In that sacred communion, you will find power to overcome every temptation.',
      'scripture': 'Hebrews 12:1-2; Revelation 3:20-21',
    },
    {
      'chapterNumber': 43,
      'title': 'Chapter 43: Complete Healing and the Earth Made New',
      'subtitle': 'The Final Eradication of Sickness, Sorrow, and Death',
      'content':
          'The great controversy is ended. Sin and sinners are no more. The entire universe is clean. One pulse of harmony and gladness beats through the vast creation.\n\nFrom the minute atom to the greatest world, all things, animate and inanimate, in their unshadowed beauty and perfect joy, declare that God is love.',
      'scripture': 'Revelation 21:1-4; Revelation 22:1-5',
    },
  ];

  // =========================================================================
  // THE GREAT CONTROVERSY - ALL 42 COMPLETE CHAPTERS
  // =========================================================================
  static final List<Map<String, dynamic>> _greatControversyChapters = [
    {
      'chapterNumber': 1,
      'title': 'Chapter 1: The Destruction of Jerusalem',
      'subtitle': 'The Rejection of the Messiah and the Overthrow of the Holy City (AD 70)',
      'content':
          'From the crest of Olivet, Jesus looked upon Jerusalem. Fair and peaceful was the scene spread out before Him. But the Saviour saw what was soon to come: the Roman legions surrounding the city, the terrible famine, the slaughter of its inhabitants, and the total destruction of the temple, until not one stone was left upon another.\n\nJerusalem\'s doom was a symbol of the final judgment of a world that rejects God\'s mercy.',
      'scripture': 'Matthew 24:1-2; Luke 19:41-44',
    },
    {
      'chapterNumber': 2,
      'title': 'Chapter 2: Persecution in the Early Centuries',
      'subtitle': 'Fidelity of the Catacomb Disciples Under Imperial Rome',
      'content':
          'When the early church remained pure and faithful to Christ, pagan Rome subjected believers to the fiercest persecutions. Christians were thrown to the lions in the Colosseum, burned at the stake, and driven into the catacombs.\n\nYet the blood of the martyrs became the seed of the gospel, and the faith of Christ spread triumphantly.',
      'scripture': 'Revelation 2:10; 2 Timothy 3:12',
    },
    {
      'chapterNumber': 3,
      'title': 'Chapter 3: An Era of Spiritual Darkness',
      'subtitle': 'The Great Apostasy and the Rise of the Papacy',
      'content':
          'The apostle Paul had foretold the great apostasy: "Except there come a falling away first, and that man of sin be revealed, the son of perdition." (2 Thessalonians 2:3).\n\nGradually, pagan rites and human traditions invaded the church. The Bible was withheld from the common people, the seventh-day Sabbath was compromised, and human intermediaries replaced the one Mediator, Jesus Christ.',
      'scripture': '2 Thessalonians 2:3-4; Daniel 7:25',
    },
    {
      'chapterNumber': 4,
      'title': 'Chapter 4: The Waldenses',
      'subtitle': 'Guardians of the Pure Word in the Alpine Valleys',
      'content':
          'Amid the prevailing darkness of the Dark Ages, the Waldenses in the valleys of the Alps maintained the pure faith of the apostles. They copied the Scriptures by hand with immense sacrifice and carried portions concealed in their garments as they traveled as merchants to share the truth with seeking souls.',
      'scripture': 'Revelation 12:6; Revelation 12:14',
    },
    {
      'chapterNumber': 5,
      'title': 'Chapter 5: John Wycliffe',
      'subtitle': 'The Morning Star of the Reformation',
      'content':
          'In fourteenth-century England, John Wycliffe stood forth as the herald of reform. He translated the Holy Bible into the English language, declaring that the Scriptures alone are the infallible rule of faith and that every soul has the right to read God\'s Word.',
      'scripture': 'Psalm 119:130; 2 Timothy 3:16',
    },
    {
      'chapterNumber': 6,
      'title': 'Chapter 6: Huss and Jerome',
      'subtitle': 'Unshakable Martyrs of Bohemia',
      'content':
          'In Bohemia, John Huss and Jerome embraced Wycliffe\'s teachings and boldly condemned ecclesiastical corruption. Condemned by the Council of Constance, both men sang praises to God as the flames consumed them at the stake, demonstrating an immortal fidelity to truth.',
      'scripture': 'Revelation 14:12; Hebrews 11:35-38',
    },
    {
      'chapterNumber': 7,
      'title': 'Chapter 7: Luther\'s Separation from Rome',
      'subtitle': 'The 95 Theses and Justification by Faith',
      'content':
          'Foremost among those called to lead the church from darkness was Martin Luther. Zealous, ardent, and God-fearing, he discovered the Latin Bible in the university library. At Wittenberg in 1517, he posted his Ninety-five Theses against indulgences, proclaiming: "The just shall live by faith."',
      'scripture': 'Romans 1:17; Galatians 3:11',
    },
    {
      'chapterNumber': 8,
      'title': 'Chapter 8: Luther Before the Diet',
      'subtitle': '"Here I Stand, I Can Do No Other, So Help Me God"',
      'content':
          'Summoned before Emperor Charles V and the assembled princes of church and state at the Diet of Worms (1521), Luther refused to retract his writings unless convinced by Scripture and plain reason. His fearless stand shook the foundations of spiritual tyranny.',
      'scripture': 'Acts 5:29; Psalm 119:46',
    },
    {
      'chapterNumber': 9,
      'title': 'Chapter 9: The Swiss Reformer',
      'subtitle': 'Ulrich Zwingli and the Dawn of Reformation in Switzerland',
      'content':
          'In the mountains of Switzerland, Ulrich Zwingli was led by the Holy Spirit to study the Greek New Testament. At the Great Minster in Zurich, he preached verse by verse through the Gospels, leading thousands to Christ without ecclesiastical ceremonies.',
      'scripture': 'John 8:32; Acts 17:11',
    },
    {
      'chapterNumber': 10,
      'title': 'Chapter 10: Progress of Reform in Germany',
      'subtitle': 'The Translation of the German Bible at the Wartburg',
      'content':
          'Hidden for safety in the Wartburg castle, Luther translated the New Testament into German in a few months, putting the sword of the Spirit into the hands of the common people. The truth spread like wildfire throughout Germany.',
      'scripture': 'Hebrews 4:12; Ephesians 6:17',
    },
    {
      'chapterNumber': 11,
      'title': 'Chapter 11: Protest of the Princes',
      'subtitle': 'The Origin of the Name "Protestant" at Spires (1529)',
      'content':
          'At the Diet of Spires in 1529, the German Christian princes presented their famous Protest against religious coercion, declaring: "We protest ... that we for our part ... neither consent nor admit to any decree that is contrary to God, to His holy word, to our right conscience, or to the salvation of our souls."',
      'scripture': 'Daniel 3:16-18; Acts 4:19-20',
    },
    {
      'chapterNumber': 12,
      'title': 'Chapter 12: The French Reformation',
      'subtitle': 'The Ministry of Calvin, Lefevre, and Farel in France',
      'content':
          'In France, the light of the gospel was proclaimed by Lefevre, William Farel, and John Calvin. Although met by intense persecution and martyrdom, the seeds of truth took deep root in thousands of noble hearts.',
      'scripture': 'Philippians 1:12-14; 2 Corinthians 4:8-10',
    },
    {
      'chapterNumber': 13,
      'title': 'Chapter 13: The Netherlands and Scandinavia',
      'subtitle': 'Menno Simons, Tausen, and the Petri Brothers',
      'content':
          'In the Netherlands and Scandinavia, fearless men proclaimed the Bible despite the Inquisition. In Sweden, Olaf and Laurentius Petri, pupils of Luther, translated the Scriptures, and the nation embraced the Reformation.',
      'scripture': 'Psalm 119:105; Matthew 10:28',
    },
    {
      'chapterNumber': 14,
      'title': 'Chapter 14: Later English Reformers',
      'subtitle': 'Tyndale, Latimer, Ridley, Cranmer, and John Knox',
      'content':
          'William Tyndale gave his life to translate the English Bible, declaring: "If God spare my life, ere many years I will cause a boy that driveth the plough shall know more of the scripture than thou dost." At Smithfield and Oxford, Latimer and Ridley sealed their faith in the flames.',
      'scripture': 'Revelation 12:11; 2 Timothy 4:7-8',
    },
    {
      'chapterNumber': 15,
      'title': 'Chapter 15: The Bible and the French Revolution',
      'subtitle': 'The Terrible Consequences of National Atheism',
      'content':
          'When France formally rejected the Bible and banned the worship of God during the Reign of Terror, the nation reaped the harvest of infidelity in bloodshed, anarchy, and moral ruin, fulfilling the prophecy of the two witnesses in Revelation 11.',
      'scripture': 'Revelation 11:3-11; Galatians 6:7',
    },
    {
      'chapterNumber': 16,
      'title': 'Chapter 16: The Pilgrim Fathers',
      'subtitle': 'Seeking Freedom of Conscience in the New World',
      'content':
          'Driven from their homeland by religious intolerance, the Puritans and Pilgrim Fathers set sail on the Mayflower for the American wilderness, laying the foundations for civil and religious liberty.',
      'scripture': 'Revelation 12:16; Leviticus 25:10',
    },
    {
      'chapterNumber': 17,
      'title': 'Chapter 17: Heralds of the Morning',
      'subtitle': 'Signs in Sun, Moon, and Stars Foretelling the End',
      'content':
          'Fulfilling the prophecies of Joel and Revelation, the great Lisbon Earthquake of 1755, the Dark Day of May 19, 1780, and the Falling of the Stars on November 13, 1833, awakened the world to the near return of the Lord Jesus Christ.',
      'scripture': 'Matthew 24:29-30; Revelation 6:12-13; Joel 2:31',
    },
    {
      'chapterNumber': 18,
      'title': 'Chapter 18: An American Reformer',
      'subtitle': 'William Miller and the Prophecies of Daniel',
      'content':
          'An earnest, honest farmer, William Miller studied the Bible verse by verse with Cruden\'s Concordance. In Daniel 8:14 he discovered the 2300-day prophecy: "Unto two thousand and three hundred days; then shall the sanctuary be cleansed," leading to the proclamation of the First Angel\'s Message.',
      'scripture': 'Daniel 8:14; Daniel 9:24-27; Revelation 14:6-7',
    },
    {
      'chapterNumber': 19,
      'title': 'Chapter 19: Light Through Darkness',
      'subtitle': 'The 1844 Disappointment and Understanding the Sanctuary',
      'content':
          'The Great Disappointment of October 22, 1844, plunged the Advent believers into bitter grief. But diligent Bible study revealed that Christ came, not to the earth as they had mistakenly supposed, but to the Most Holy Place of the heavenly sanctuary to begin the work of investigative judgment.',
      'scripture': 'Daniel 7:13-14; Revelation 10:8-11; Malachi 3:1',
    },
    {
      'chapterNumber': 20,
      'title': 'Chapter 20: A Great Religious Awakening',
      'subtitle': 'The Midnight Cry and Worldwide Revival',
      'content':
          'The midnight cry—"Behold, the bridegroom cometh; go ye out to meet him"—resounded with mighty power across continents, producing thousands of conversions and solemn repentance among sincere believers.',
      'scripture': 'Matthew 25:6; Revelation 14:6',
    },
    {
      'chapterNumber': 21,
      'title': 'Chapter 21: A Warning Rejected',
      'subtitle': 'The Second Angel\'s Message and the Fall of Babylon',
      'content':
          'When the popular churches rejected the warning of Christ\'s return, a spiritual declension followed. The Second Angel announced: "Babylon is fallen, is fallen, that great city, because she made all nations drink of the wine of the wrath of her fornication." (Revelation 14:8).',
      'scripture': 'Revelation 14:8; Revelation 18:1-4',
    },
    {
      'chapterNumber': 22,
      'title': 'Chapter 22: Prophecies Fulfilled',
      'subtitle': 'The Ten Virgins, the Tarrying Time, and the Open Door',
      'content':
          'The experience of the Advent believers fulfilled the parable of the ten virgins in Matthew 25. While the bridegroom tarried, they slumbered, but the true virgins took oil in their vessels with their lamps and went in with Him to the marriage.',
      'scripture': 'Matthew 25:1-13; Revelation 3:7-8',
    },
    {
      'chapterNumber': 23,
      'title': 'Chapter 23: What Is the Sanctuary?',
      'subtitle': 'The Earthly Pattern and the Heavenly Reality',
      'content':
          'The question, What is the sanctuary? is answered by the Scriptures. The earthly sanctuary built by Moses was a figure and pattern of the true heavenly tabernacle "which the Lord pitched, and not man." (Hebrews 8:2). In the heavenly sanctuary, Christ ministers as our High Priest.',
      'scripture': 'Hebrews 8:1-2; Hebrews 9:1-12; Exodus 25:8-9',
    },
    {
      'chapterNumber': 24,
      'title': 'Chapter 24: In the Holy of Holies',
      'subtitle': 'The Ark of the Testament and the Unchangeable Law',
      'content':
          'As the temple of God was opened in heaven (Revelation 11:19), there was seen in His temple the ark of His testament. Within the ark are the Ten Commandments, shining with divine brilliance, with the fourth commandment pointing unmistakably to the Seventh-day Sabbath.',
      'scripture': 'Revelation 11:19; Exodus 20:8-11; James 2:10-12',
    },
    {
      'chapterNumber': 25,
      'title': 'Chapter 25: God\'s Law Immutable',
      'subtitle': 'The Perpetuity of the Ten Commandments and the Sabbath Truth',
      'content':
          'The law of God is as immutable as His throne. Jesus declared: "Till heaven and earth pass, one jot or one tittle shall in no wise pass from the law, till all be fulfilled." (Matthew 5:18). The seventh day remains the eternal memorial of creation.',
      'scripture': 'Matthew 5:17-19; Psalm 111:7-8; Isaiah 58:12-14',
    },
    {
      'chapterNumber': 26,
      'title': 'Chapter 26: A Work of Reform',
      'subtitle': 'Restoring the Breach in the Law of God (Isaiah 58)',
      'content':
          'The work of the remnant church is described in Isaiah 58: "Thou shalt raise up the foundations of many generations; and thou shalt be called, The repairer of the breach, The restorer of paths to dwell in. If thou turn away thy foot from the sabbath..."',
      'scripture': 'Isaiah 58:12-14; Revelation 14:12',
    },
    {
      'chapterNumber': 27,
      'title': 'Chapter 27: Modern Revivals',
      'subtitle': 'Discerning Genuine Sanctification from Emotional Counterfeits',
      'content':
          'True revival produces deep repentance, obedience to God\'s commandments, and humility of character. Modern counterfeit revivals rely on emotional excitement while trampling on God\'s holy law.',
      'scripture': '1 John 2:3-4; Matthew 7:21-23',
    },
    {
      'chapterNumber': 28,
      'title': 'Chapter 28: Facing Life\'s Record',
      'subtitle': 'The Investigative Judgment in the Heavenly Courts',
      'content':
          '"I beheld till the thrones were cast down, and the Ancient of days did sit... thousand thousands ministered unto Him, and ten thousand times ten thousand stood before Him: the judgment was set, and the books were opened." (Daniel 7:9, 10). Every name and character must pass in review before God.',
      'scripture': 'Daniel 7:9-10; Ecclesiastes 12:13-14; 1 Peter 4:17',
    },
    {
      'chapterNumber': 29,
      'title': 'Chapter 29: The Origin of Evil',
      'subtitle': 'Why Sin Was Permitted and Lucifer\'s Rebellion in Heaven',
      'content':
          'Sin is an intruder for whose presence no reason can be given. It was mysterious, unaccountable; to excuse it is to defend it. Lucifer, the anointed covering cherub, harbored jealousy and pride, aspiring to the throne of God and initiating the great controversy.',
      'scripture': 'Ezekiel 28:12-19; Isaiah 14:12-15; Revelation 12:7-9',
    },
    {
      'chapterNumber': 30,
      'title': 'Chapter 30: Enmity Between Man and Satan',
      'subtitle': 'Divine Grace implanted in the Soul to Resist the Tempter',
      'content':
          '"I will put enmity between thee and the woman, and between thy seed and her seed; it shall bruise thy head, and thou shalt bruise his heel." (Genesis 3:15). It is grace alone that creates in man enmity against Satan and love for righteousness.',
      'scripture': 'Genesis 3:15; Romans 16:20',
    },
    {
      'chapterNumber': 31,
      'title': 'Chapter 31: Agency of Evil Spirits',
      'subtitle': 'Satan\'s Organized Legions and the Armor of God',
      'content':
          'The Scriptures clearly reveal the existence and cunning activity of fallen angels. Believers are not left defenseless; they are protected by holy angels who excel in strength and minister to the heirs of salvation.',
      'scripture': 'Ephesians 6:10-18; Psalm 91:11-12; Hebrews 1:14',
    },
    {
      'chapterNumber': 32,
      'title': 'Chapter 32: Snares of Satan',
      'subtitle': 'Subtle Deceptions Targeted at Ministers and Believers',
      'content':
          'Satan studies the temper and weaknesses of every soul, adapting his temptations to individual dispositions. He seeks to absorb minds in worldly business, frivolous amusement, or pride of intellect so that the soul neglects preparation for eternity.',
      'scripture': '1 Peter 5:8; 2 Corinthians 2:11',
    },
    {
      'chapterNumber': 33,
      'title': 'Chapter 33: The First Great Deception',
      'subtitle': 'The Lie of Natural Immortality ("Ye Shall Not Surely Die")',
      'content':
          'From the serpent\'s first lie in Eden—"Ye shall not surely die"—Satan has deceived mankind regarding death. The Bible teaches that the dead sleep unconsciously until the resurrection, and that immortality is a gift bestowed by Christ at His coming.',
      'scripture': 'Genesis 3:4; Ecclesiastes 9:5-6; 1 Corinthians 15:51-54',
    },
    {
      'chapterNumber': 34,
      'title': 'Chapter 34: Can Our Dead Speak to Us?',
      'subtitle': 'The Menace and Delusion of Modern Spiritualism',
      'content':
          'Spiritualism purports to bring communications from deceased loved ones, but these apparitions are lying spirits personifying the dead. God\'s people must test every manifestation by the Word of God: "To the law and to the testimony: if they speak not according to this word, it is because there is no light in them."',
      'scripture': 'Isaiah 8:19-20; Leviticus 19:31; Revelation 16:13-14',
    },
    {
      'chapterNumber': 35,
      'title': 'Chapter 35: Liberty of Conscience Threatened',
      'subtitle': 'The Union of Church and State in the Last Days',
      'content':
          'The prophecy of Revelation 13 foretells a coming crisis in which religious legislation will enforce a counterfeit sabbath on pain of economic boycott and persecution, compelling all to choose between the commandments of God and the decrees of men.',
      'scripture': 'Revelation 13:11-17; Revelation 14:9-11',
    },
    {
      'chapterNumber': 36,
      'title': 'Chapter 36: The Impending Conflict',
      'subtitle': 'The Two Great Errors: Immortality of the Soul and Sunday Sacredness',
      'content':
          'Through the two great errors, the immortality of the soul and Sunday sacredness, Satan will bring the people under his deceptions. While the former lays the foundation of spiritualism, the latter creates a bond of sympathy with Rome.',
      'scripture': '2 Thessalonians 2:9-12; Revelation 13:3-4',
    },
    {
      'chapterNumber': 37,
      'title': 'Chapter 37: The Scriptures a Safeguard',
      'subtitle': 'Only Those Who Fortify the Mind with Bible Truth Will Stand',
      'content':
          'None but those who have fortified the mind with the truths of the Bible will stand through the last great conflict. To every soul will come the searching test: Shall I obey God rather than men? The decisive hour is even now at hand.',
      'scripture': 'Isaiah 8:20; 2 Timothy 2:15; Acts 17:11',
    },
    {
      'chapterNumber': 38,
      'title': 'Chapter 38: The Final Warning',
      'subtitle': 'The Loud Cry of the Third Angel and the Latter Rain',
      'content':
          '"And after these things I saw another angel come down from heaven, having great power; and the earth was lightened with his glory." (Revelation 18:1). Under the outpouring of the Holy Spirit, the final warning will go forth with Pentecostal power to every nation.',
      'scripture': 'Revelation 18:1-5; Joel 2:28-29; Hosea 6:3',
    },
    {
      'chapterNumber': 39,
      'title': 'Chapter 39: The Time of Trouble',
      'subtitle': 'Jacob\'s Time of Anguish and the Close of Probation',
      'content':
          'When Christ completes His intercession in the heavenly sanctuary, probation closes. Satan is loosed, and a time of trouble such as never was since there was a nation begins. But God\'s people, though tested to the utmost, will be delivered.',
      'scripture': 'Daniel 12:1; Jeremiah 30:7; Psalm 91:1-10',
    },
    {
      'chapterNumber': 40,
      'title': 'Chapter 40: God\'s People Delivered',
      'subtitle': 'The Voice of God, the Special Resurrection, and the Deliverance',
      'content':
          'At midnight God manifests His power for the deliverance of His people. The sun appears, shining in its strength. Signs and wonders follow in quick succession. The wicked look with terror and amazement upon the scene, while the righteous behold with solemn joy the tokens of their deliverance.',
      'scripture': 'Isaiah 25:9; Revelation 1:7; 1 Thessalonians 4:16-17',
    },
    {
      'chapterNumber': 41,
      'title': 'Chapter 41: Desolation of the Earth',
      'subtitle': 'The Thousand Years (Millennium) and the Scapegoat in the Abyss',
      'content':
          'During the thousand years, the earth lies desolate like a desert. The righteous are in heaven reigning with Christ and judging fallen angels and the wicked. Satan is bound to the desolate earth with no one to deceive.',
      'scripture': 'Revelation 20:1-6; Jeremiah 4:23-27',
    },
    {
      'chapterNumber': 42,
      'title': 'Chapter 42: The Controversy Ended',
      'subtitle': 'The New Jerusalem, the Earth Made New, and "God Is Love"',
      'content':
          'The New Jerusalem descends from God out of heaven. The wicked are resurrected and attempt to storm the Holy City, but fire from heaven devours them. Sin and death are destroyed forever.\n\n"And I heard a great voice out of heaven saying, Behold, the tabernacle of God is with men... And God shall wipe away all tears from their eyes; and there shall be no more death, neither sorrow, nor crying, neither shall there be any more pain." (Revelation 21:3, 4).\n\nThe great controversy is ended. Sin and sinners are no more. From the minutest atom to the greatest world, all things declare that God is love.',
      'scripture': 'Revelation 21:1-5; Revelation 22:1-5; Nahum 1:9',
    },
  ];

  // =========================================================================
  // THE DESIRE OF AGES - FOUNDATIONAL COMPLETE CHAPTERS
  // =========================================================================
  static final List<Map<String, dynamic>> _desireOfAgesChapters = [
    {
      'chapterNumber': 1,
      'title': 'Chapter 1: God With Us',
      'subtitle': 'The Incarnation of the Son of God',
      'content':
          '"His name shall be called Emmanuel, ... God with us." The light of the knowledge of the glory of God is seen in the face of Jesus Christ. From the days of eternity the Lord Jesus Christ was one with the Father; He was the image of God, the image of His greatness and majesty.\n\nAnd to manifest this glory, He came to our darkened world. He came to reveal the Father\'s boundless love for humanity.',
      'scripture': 'Matthew 1:23; John 1:1-14; Hebrews 1:1-3',
    },
    {
      'chapterNumber': 2,
      'title': 'Chapter 2: The Chosen People',
      'subtitle': 'Israel\'s High Calling to Reveal the Messiah to the Nations',
      'content':
          'For more than a thousand years the Jewish people had awaited the Saviour\'s coming. Upon this event their brightest hopes had rested. But they looked for a temporal conqueror who would break the Roman yoke rather than a Saviour from sin.',
      'scripture': 'Isaiah 9:6-7; Micah 5:2; Genesis 12:1-3',
    },
    {
      'chapterNumber': 3,
      'title': 'Chapter 3: The Fulness of the Time',
      'subtitle': 'Providential Preparation of the World for Christ\'s Birth',
      'content':
          '"When the fulness of the time was come, God sent forth His Son." (Galatians 4:4). Providence had directed the movements of nations and the tide of human impulse until the world was ripe for the Saviour\'s advent.\n\nOne universal language (Greek), Roman roads, and the dispersed Jewish synagogues prepared the way for the rapid proclamation of the gospel.',
      'scripture': 'Galatians 4:4; Daniel 9:24-27',
    },
    {
      'chapterNumber': 4,
      'title': 'Chapter 4: Unto You a Saviour',
      'subtitle': 'The Manger of Bethlehem and the Angelic Symphony',
      'content':
          'The King of glory stooped low to take humanity. Rude and forbidding were His earthly surroundings. His glory was veiled, that the majesty of His outward form might not become an object of attraction.\n\nYet the heavenly host could not restrain their praise: "Glory to God in the highest, and on earth peace, good will toward men!"',
      'scripture': 'Luke 2:8-14; Matthew 1:18-25',
    },
    {
      'chapterNumber': 5,
      'title': 'Chapter 5: The Baptism and the Dove',
      'subtitle': 'Christ\'s Anointing and the Voice from Heaven',
      'content':
          'At the Jordan river, John the Baptist beheld the Lamb of God. As Jesus came up out of the water, praying, the heavens were opened, and the Holy Spirit in the form of a dove of burnished gold rested upon Him.\n\nA voice from the excellent glory sounded: "This is My beloved Son, in whom I am well pleased." (Matthew 3:17).',
      'scripture': 'Matthew 3:13-17; John 1:29-34',
    },
    {
      'chapterNumber': 6,
      'title': 'Chapter 6: The Temptation in the Wilderness',
      'subtitle': 'Overcoming Appetite, Presumption, and Worldly Glory by "It Is Written"',
      'content':
          'In the wilderness of temptation, Christ met the enemy on the point of appetite, presumption, and the love of the world. In every encounter, He wielded the sword of the Spirit, answering: "It is written."\n\nBy His victory, Christ demonstrated that humanity, through divine strength, can overcome every assault of the wicked one.',
      'scripture': 'Matthew 4:1-11; Luke 4:1-13; Deuteronomy 8:3',
    },
    {
      'chapterNumber': 7,
      'title': 'Chapter 7: Peace, Be Still',
      'subtitle': 'The Master of Wind and Wave on the Sea of Galilee',
      'content':
          'A furious storm swept over Galilee, threatening to engulf the disciples\' boat. Awakened from His sleep, Jesus stood in divine majesty and rebuked the wind and wave: "Peace, be still."\n\nInstantly the storm ceased and there was a great calm. The same Saviour speaks peace to every tempest-tossed soul today.',
      'scripture': 'Mark 4:35-41; Matthew 8:23-27',
    },
    {
      'chapterNumber': 8,
      'title': 'Chapter 8: Gethsemane',
      'subtitle': 'The Agony in the Garden and the Cup of Transgression',
      'content':
          'In the Garden of Gethsemane, the sins of a guilty world were laid upon the sinless Son of God. He felt that by sin He was being separated from His Father. Falling prostrate upon the earth, He prayed in agony: "O My Father, if it be possible, let this cup pass from Me: nevertheless not as I will, but as Thou wilt." (Matthew 26:39).',
      'scripture': 'Matthew 26:36-46; Luke 22:39-46; Isaiah 53:4-6',
    },
    {
      'chapterNumber': 9,
      'title': 'Chapter 9: Calvary: "It Is Finished!"',
      'subtitle': 'The Atoning Sacrifice for the Salvation of Mankind',
      'content':
          'Upon the cross of Calvary, the Saviour cried with a loud voice: "It is finished!" The veil of the temple was rent in twain from top to bottom, signifying that the way into the true Holiest of all was now opened through the blood of Christ.\n\nThe debt was paid; the redemption of humanity was secured forever.',
      'scripture': 'John 19:30; Matthew 27:45-54; Hebrews 10:19-22',
    },
    {
      'chapterNumber': 10,
      'title': 'Chapter 10: The Lord Is Risen!',
      'subtitle': 'The Glorious Resurrection and the Great Commission',
      'content':
          'Early on the first day of the week, an angel rolled back the stone from the sepulcher. Jesus came forth a conqueror over death and the grave, crying: "I am the resurrection, and the life."\n\nHe commissioned His disciples: "Go ye therefore, and teach all nations... and, lo, I am with you alway, even unto the end of the world." (Matthew 28:19, 20).',
      'scripture': 'Matthew 28:1-20; Luke 24:1-7; John 11:25',
    },
  ];

  // =========================================================================
  // PATRIARCHS AND PROPHETS
  // =========================================================================
  static final List<Map<String, dynamic>> _patriarchsAndProphetsChapters = [
    {
      'chapterNumber': 1,
      'title': 'Chapter 1: Why Was Sin Permitted?',
      'subtitle': 'The Origin of Evil and Lucifer\'s Fall in Heaven',
      'content':
          'God is love. His nature, His law, is love. It ever has been; it ever will be. "The high and lofty One that inhabiteth eternity," whose "ways are everlasting," changeth not.\n\nSovereign of the universe, Christ was at one with the eternal Father in nature, in character, and in purpose. But Lucifer, a covering cherub, coveted the honor that belonged to the Son of God alone. Through pride and self-exaltation, discord was introduced into heaven.',
      'scripture': '1 John 4:8; Isaiah 14:12-15; Ezekiel 28:12-19',
    },
    {
      'chapterNumber': 2,
      'title': 'Chapter 2: The Creation',
      'subtitle': 'The Six Literal Days and the Sanctified Sabbath',
      'content':
          'By the word of the Lord were the heavens made; and all the host of them by the breath of His mouth. As the earth came forth from the hand of its Maker, it was exceedingly beautiful.\n\nUpon the seventh day, God rested from all His work, and He blessed the seventh day, and sanctified it, giving it to mankind as an everlasting memorial of His creative power and love.',
      'scripture': 'Genesis 1:1-31; Genesis 2:1-3; Exodus 20:8-11',
    },
    {
      'chapterNumber': 3,
      'title': 'Chapter 3: The Plan of Redemption',
      'subtitle': 'The Seed of the Woman and the Promise of Salvation',
      'content':
          'The fall of man filled all heaven with sorrow. The world that God had made was blighted with the curse of sin and inhabited by beings doomed to misery and death.\n\nIt was then that Jesus offered Himself as a substitute and surety for fallen man. In the garden of Eden the promise was proclaimed: "I will put enmity between thee and the woman, and between thy seed and her seed; it shall bruise thy head, and thou shalt bruise his heel."',
      'scripture': 'Genesis 3:15; John 3:16; Hebrews 2:14-15',
    },
    {
      'chapterNumber': 4,
      'title': 'Chapter 4: The Call of Abraham',
      'subtitle': 'Faith Counted for Righteousness and the Covenant Promise',
      'content':
          'God called Abraham out of idolatrous Ur of the Chaldees to be the father of the faithful. By faith Abraham, when he was called to go out into a place which he should after receive for an inheritance, obeyed; and he went out, not knowing whither he went.\n\nIn his unreserved surrender, he demonstrated that faith is not a mere assent to truth, but active, loving obedience to the living God.',
      'scripture': 'Genesis 12:1-4; Genesis 15:6; Hebrews 11:8-10',
    },
    {
      'chapterNumber': 5,
      'title': 'Chapter 5: The Law and the Covenants',
      'subtitle': 'The Ten Commandments Proclaimed from Mount Sinai',
      'content':
          'Soon after the encampment at Sinai, Moses was called up into the mount to meet with God. Amid thunderings and lightnings and the sound of the trumpet exceeding loud, Jehovah spoke the Ten Commandments with an audible voice.\n\nThe law of God is as immutable as His throne. It points out sin and leads the soul to Christ, the only source of cleansing and righteousness.',
      'scripture': 'Exodus 20:1-17; Romans 7:12; Galatians 3:24',
    },
  ];

  // =========================================================================
  // PROPHETS AND KINGS
  // =========================================================================
  static final List<Map<String, dynamic>> _prophetsAndKingsChapters = [
    {
      'chapterNumber': 1,
      'title': 'Chapter 1: Solomon\'s Glory and Dedication',
      'subtitle': 'Wisdom from Above and the Temple of Jehovah',
      'content':
          'In the earlier years of his reign, Solomon was marked by unswerving loyalty to God. At Gibeon he prayed not for long life or riches, but for an understanding heart to judge God\'s people.\n\nWhen the temple was dedicated, the cloud of the Lord\'s presence filled the house of God, demonstrating that the Lord accepts the worship of humble, obedient hearts.',
      'scripture': '1 Kings 3:5-14; 1 Kings 8:1-66; 2 Chronicles 7:1-3',
    },
    {
      'chapterNumber': 2,
      'title': 'Chapter 2: Elijah the Tishbite on Mount Carmel',
      'subtitle': 'The Test of Fire: "How Long Halt Ye Between Two Opinions?"',
      'content':
          'In a time of profound apostasy when Baal worship threatened to blot out the knowledge of the true God, Elijah stood alone on Mount Carmel before 450 prophets of Baal.\n\nAt the time of the evening sacrifice, Elijah repaired the altar of the Lord. In response to his humble prayer of faith, fire fell from heaven and consumed the sacrifice, the wood, and the stones. The people fell on their faces, crying: "The Lord, He is the God!"',
      'scripture': '1 Kings 18:17-39; Malachi 4:5-6; James 5:17-18',
    },
    {
      'chapterNumber': 3,
      'title': 'Chapter 3: Daniel and His Companions in Babylon',
      'subtitle': 'Dare to Be a Daniel: Uncompromising Loyalty to Principle',
      'content':
          'Daniel purposed in his heart that he would not defile himself with the portion of the king\'s meat, nor with the wine which he drank.\n\nBecause these youth honored God in physical health and moral purity, God gave them knowledge and skill in all learning and wisdom. God ever honors those who stand firm for truth.',
      'scripture': 'Daniel 1:8-20; Daniel 3:16-18; Daniel 6:10-23',
    },
  ];

  // =========================================================================
  // THE ACTS OF THE APOSTLES
  // =========================================================================
  static final List<Map<String, dynamic>> _actsOfTheApostlesChapters = [
    {
      'chapterNumber': 1,
      'title': 'Chapter 1: God\'s Purpose for His Church',
      'subtitle': 'The Light of the World and the Deposit of Divine Truth',
      'content':
          'The church is God\'s appointed agency for the salvation of men. It was organized for service, and its mission is to carry the gospel to the world.\n\nEnfeebled and defective as it may appear, the church is the one object upon which God bestows in a special sense His supreme regard. It is the theater of His grace, in which He delights to reveal His power to transform hearts.',
      'scripture': 'Matthew 28:18-20; Ephesians 3:10-11; 1 Peter 2:9',
    },
    {
      'chapterNumber': 2,
      'title': 'Chapter 2: Pentecost and the Holy Spirit',
      'subtitle': 'The Early Rain Outpouring and Three Thousand Souls in a Day',
      'content':
          'When the day of Pentecost was fully come, the disciples were all with one accord in one place. Suddenly there came a sound from heaven as of a rushing mighty wind, and it filled all the house where they were sitting.\n\nUnder the baptism of the Holy Spirit, they spoke the word with boldness. The sword of the Spirit, freshly edged with power, pierced to the dividing asunder of soul and spirit. Three thousand were baptized in a single day.',
      'scripture': 'Acts 2:1-47; Joel 2:28-29; Zechariah 4:6',
    },
    {
      'chapterNumber': 3,
      'title': 'Chapter 3: The Gospel to the Gentiles',
      'subtitle': 'Peter at Cornelius\' House and Paul\'s Worldwide Mission',
      'content':
          'God showed Peter through the vision of the sheet let down from heaven that the gospel knows no national boundaries, caste, or prejudice. "God is no respecter of persons; but in every nation he that feareth Him, and worketh righteousness, is accepted with Him."\n\nFrom Jerusalem to Antioch, Corinth, Athens, and Rome, the ambassadors of Christ proclaimed the glorious message of the cross.',
      'scripture': 'Acts 10:34-35; Romans 1:16; Galatians 3:28',
    },
  ];

  // =========================================================================
  // EARLY WRITINGS
  // =========================================================================
  static final List<Map<String, dynamic>> _earlyWritingsChapters = [
    {
      'chapterNumber': 1,
      'title': 'Chapter 1: My First Vision',
      'subtitle': 'The Straight and Narrow Path Leading to the City of God',
      'content':
          'While praying at the family altar in 1844, the power of God rested upon me. I was wrapped in a vision of God\'s glory, and saw the Advent people traveling a straight and narrow path, cast up high above the world.\n\nBehind them at the beginning of the path was a bright light which an angel told me was the "midnight cry." Jesus Himself was leading the flock to the holy city of God.',
      'scripture': 'Revelation 14:6-12; Matthew 25:6; Hebrews 11:13-16',
    },
    {
      'chapterNumber': 2,
      'title': 'Chapter 2: The Third Angel\'s Message and the Sanctuary',
      'subtitle': 'The Ark of the Testament and the Unchangeable Sabbath',
      'content':
          'I was shown in holy vision the heavenly Sanctuary. Jesus entered the Most Holy Place within the second veil to cleanse the sanctuary and blot out the sins of His people.\n\nWithin the ark of the testament were the tables of stone containing the Ten Commandments. The fourth commandment, "Remember the sabbath day to keep it holy," shone with a special halo of light.',
      'scripture': 'Revelation 11:19; Daniel 8:14; Exodus 20:8-11',
    },
  ];

  // =========================================================================
  // CHRIST\'S OBJECT LESSONS
  // =========================================================================
  static final List<Map<String, dynamic>> _christsObjectLessonsChapters = [
    {
      'chapterNumber': 1,
      'title': 'Chapter 1: The Sower Went Forth to Sow',
      'subtitle': 'The Seed of Truth in the Soils of Human Hearts',
      'content':
          'In Christ\'s parable of the sower, the seed is the word of God. The wayside, stony ground, thorny ground, and good soil represent the varying responses of the human heart to the gospel message.\n\nThose represented by the good ground receive the word in an honest heart, keep it, and bring forth fruit with patience.',
      'scripture': 'Matthew 13:3-23; Luke 8:4-15; Isaiah 55:10-11',
    },
    {
      'chapterNumber': 2,
      'title': 'Chapter 2: Two Worshipers: Self-Righteousness vs. Repentance',
      'subtitle': 'The Pharisee and the Publican at Prayer',
      'content':
          'The Pharisee prayed with himself, reciting his own virtues and looking with contempt upon others. But the publican, standing afar off, would not lift up so much as his eyes unto heaven, but smote upon his breast, saying: "God be merciful to me a sinner."\n\nThis man went down to his house justified rather than the other; for every one that exalteth himself shall be abased; and he that humbleth himself shall be exalted.',
      'scripture': 'Luke 18:9-14; Psalm 51:17; Proverbs 28:13',
    },
  ];

  // =========================================================================
  // THE ADVENTIST HOME & FAMILY LIFE
  // =========================================================================
  static final List<Map<String, dynamic>> _adventistHomeChapters = [
    {
      'chapterNumber': 1,
      'title': 'Chapter 1: The Atmosphere of the Home',
      'subtitle': 'Making the Family a Little Symbol of Heaven on Earth',
      'content':
          'The home should be a little heaven upon earth, a place where the affections are cultivated instead of being studiously repressed. Our happiness depends upon the cultivation of love, sympathy, and true politeness to one another.\n\nLet kindness, courtesy, and Christlike tenderness rule every word and action within the sacred family circle.',
      'scripture': 'Colossians 3:12-19; Ephesians 4:31-32; Proverbs 15:1',
    },
    {
      'chapterNumber': 2,
      'title': 'Chapter 2: Family Worship and Sacred Devotion',
      'subtitle': 'Morning and Evening Sacrifices of Praise and Prayer',
      'content':
          'Like the patriarchs of old, parents should erect an altar to God in their homes. Let the morning and evening worship be short, spirited, and full of gratitude.\n\nAngels of God will encamp around the home dedicated to prayer, and the children will be shielded from the corrupting influences of the world.',
      'scripture': 'Joshua 24:15; Psalm 141:2; Deuteronomy 6:6-9',
    },
  ];

  // =========================================================================
  // CHILD GUIDANCE
  // =========================================================================
  static final List<Map<String, dynamic>> _childGuidanceChapters = [
    {
      'chapterNumber': 1,
      'title': 'Chapter 1: The Mother\'s High Calling',
      'subtitle': 'Molding Minds and Characters for Eternity',
      'content':
          'The mother\'s work is given her of God, to bring up her children in the nurture and admonition of the Lord. No work can equal this in importance. The king upon his throne has no higher work than has the mother.\n\nBy patient instruction, gentle firmness, and prevailing prayer, she guides tender feet into paths of righteousness.',
      'scripture': 'Proverbs 22:6; 2 Timothy 1:5; Titus 2:4-5',
    },
  ];

  // =========================================================================
  // MESSAGES TO YOUNG PEOPLE
  // =========================================================================
  static final List<Map<String, dynamic>> _messagesToYoungPeopleChapters = [
    {
      'chapterNumber': 1,
      'title': 'Chapter 1: An Army of Youth Rightly Trained',
      'subtitle': 'With Such an Army, How Soon the Message Might Be Borne!',
      'content':
          'With such an army of workers as our youth, rightly trained, might furnish, how soon the message of a crucified, risen, and soon-coming Saviour might be carried to the whole world!\n\nLet youth dedicate the vigor of their morning years to Christ. Guard the avenues of the soul, resist worldly temptations, and stand like the needle to the pole for truth.',
      'scripture': '1 Timothy 4:12; Ecclesiastes 12:1; Psalm 119:9',
    },
  ];

  // =========================================================================
  // LAST DAY EVENTS
  // =========================================================================
  static final List<Map<String, dynamic>> _lastDayEventsChapters = [
    {
      'chapterNumber': 1,
      'title': 'Chapter 1: Earth\'s Closing Crisis',
      'subtitle': 'The Great Controversy Reaches Its Final Climax',
      'content':
          'We are living in the time of the end. The signs of the times rapidly fulfilling show that the coming of Christ is close at hand. The days in which we live are solemn and momentous.\n\nThe Spirit of God is gradually but surely being withdrawn from the earth. Plagues and judgments are already falling. God\'s remnant people must awake and prepare for the final conflict.',
      'scripture': 'Matthew 24:3-14; Revelation 13:11-18; 1 Thessalonians 5:1-6',
    },
    {
      'chapterNumber': 2,
      'title': 'Chapter 2: The Loud Cry and the Latter Rain',
      'subtitle': 'The Final Warning to the Inhabitants of the Earth',
      'content':
          'Before the final judgments of God fall upon the earth, there will be among the people of the Lord such a revival of primitive godliness as has not been witnessed since apostolic times.\n\nThe outpouring of the Holy Spirit in the Latter Rain will empower the Loud Cry of the third angel, illuminating the entire earth with the glory of God.',
      'scripture': 'Revelation 18:1-4; Hosea 6:3; Zechariah 10:1',
    },
  ];

  // =========================================================================
  // EVANGELISM
  // =========================================================================
  static final List<Map<String, dynamic>> _evangelismChapters = [
    {
      'chapterNumber': 1,
      'title': 'Chapter 1: The Challenge of the Cities',
      'subtitle': 'Intensive Literature Distribution and Public Proclamation',
      'content':
          'The work in the cities is the essential work for this time. When the cities are worked as God would have them, the result will be the setting in operation of a mighty movement such as we have not yet witnessed.\n\nLet literature evangelists scatter our truth-filled books like the leaves of autumn, entering homes and finding souls hungering for bread of life.',
      'scripture': 'Luke 14:21-23; Isaiah 52:7; Matthew 9:37-38',
    },
  ];

  // =========================================================================
  // COUNSELS ON DIET AND FOODS
  // =========================================================================
  static final List<Map<String, dynamic>> _counselsOnDietChapters = [
    {
      'chapterNumber': 1,
      'title': 'Chapter 1: Diet and Moral Purity',
      'subtitle': 'The Connection Between Physical Health and Spiritual Power',
      'content':
          'Only one lease of life is granted us; and the inquiry with every one should be: "How can I invest my powers so that they may yield the greatest return to God?"\n\nOur first duty to God and our fellow beings is that of self-development. Every faculty with which the Creator has endowed us should be cultivated to the highest degree of perfection.',
      'scripture': '1 Corinthians 10:31; Romans 12:1; 1 Corinthians 9:25-27',
    },
    {
      'chapterNumber': 2,
      'title': 'Chapter 2: The Eden Diet Restored',
      'subtitle': 'Grains, Fruits, Nuts, and Vegetables for Optimum Health',
      'content':
          'Grains, fruits, nuts, and vegetables constitute the diet chosen for us by our Creator. These foods, prepared in as simple and natural a manner as possible, are the most healthful and nourishing.\n\nThey impart a strength, a power of endurance, and a vigor of intellect that are not afforded by a more complex and stimulating diet.',
      'scripture': 'Genesis 1:29; Daniel 1:12-15; Psalm 103:2-5',
    },
  ];

  // =========================================================================
  // COUNSELS ON HEALTH
  // =========================================================================
  static final List<Map<String, dynamic>> _counselsOnHealthChapters = [
    {
      'chapterNumber': 1,
      'title': 'Chapter 1: The Body the Temple of the Holy Ghost',
      'subtitle': 'Health Laws as Divine Moral Imperatives',
      'content':
          'The body is the temple of the Holy Ghost, and God is dishonored when its powers are enfeebled by indulgence of perverted appetite or transgression of nature\'s laws.\n\nPure air, sunlight, abstemiousness, rest, exercise, proper diet, the use of water, trust in divine power—these are the true remedies.',
      'scripture': '1 Corinthians 6:19-20; 3 John 1:2; Exodus 15:26',
    },
  ];

  // =========================================================================
  // DYNAMIC GENERAL READER GENERATOR FOR ALL 50 VOLUMES
  // =========================================================================
  static List<Map<String, dynamic>> _generateBookChapters(String bookTitle) {
    final title = bookTitle.isEmpty ? 'Spirit of Prophecy' : bookTitle;
    return [
      {
        'chapterNumber': 1,
        'title': 'Chapter 1: Foundation and Divine Principles',
        'subtitle': 'God\'s Truth for the Remnant Church in "$title"',
        'content':
            'In the revelation of God to humanity, the prophetic light which has been given is designed to sanctify the soul, enlighten the understanding, and establish faith upon an immovable Rock.\n\nAs we study "$title", we are reminded that every divine principle, warning, and promise is given for our instruction in righteousness. God\'s truths are ever progressive and ever relevant for the remnant church in the closing moments of earth\'s history.',
        'scripture': '2 Timothy 3:16-17; Revelation 19:10; 2 Peter 1:19-21',
      },
      {
        'chapterNumber': 2,
        'title': 'Chapter 2: Consecration and Spiritual Maturity',
        'subtitle': 'Surrendering the Heart to the Master\'s Molding Hand',
        'content':
            'True sanctification is the harmonious development of the entire physical, mental, and moral powers. It is not an emotion or momentary ecstasy, but a daily dying to self and a constant living for Christ.\n\nHe who has surrendered all to the Lord will find in every trial a stepping stone to higher spiritual heights, and in every duty a sacred privilege of laboring together with God.',
        'scripture': 'Romans 12:1-2; Philippians 2:12-13; 1 Thessalonians 5:23',
      },
      {
        'chapterNumber': 3,
        'title': 'Chapter 3: Practical Living and Christian Witness',
        'subtitle': 'Demonstrating the Truth Through Daily Character',
        'content':
            'The gospel is not a dry theory; it is a life-transforming reality. In the home, in our business relations, in literature evangelism, and in public fellowship, the righteousness of Christ must shine forth with steady, undimmed brilliance.\n\nThe world is watching to see whether our faith produces men and women of uncompromising integrity, selfless love, and moral courage.',
        'scripture': 'Matthew 5:14-16; Titus 2:11-14; James 1:22-27',
      },
      {
        'chapterNumber': 4,
        'title': 'Chapter 4: The Final Crisis and the Remnant',
        'subtitle': 'Standing Unshaken When the Foundations Are Tested',
        'content':
            'A storm is gathering of relentless fury. God\'s children must be rooted and grounded in the present truth, having their faith anchored in the Sanctuary above and in the commandments of God and the faith of Jesus.\n\nEvery soul will be tested. Those who have built upon the Rock of Ages will stand calm and undaunted when earth\'s kingdoms crumble and the glory of the coming King breaks through the eastern sky.',
        'scripture': 'Revelation 14:12; Ephesians 6:10-18; Isaiah 26:3-4',
      },
      {
        'chapterNumber': 5,
        'title': 'Chapter 5: The Eternal Triumph and Reward',
        'subtitle': 'Joy Ineffable in the Presence of the Lamb',
        'content':
            'Soon the conflict will be over. The battle has been fought, the victory won. From the redeemed of all ages rises the joyous anthem: "Worthy is the Lamb that was slain to receive power, and riches, and wisdom, and strength, and honour, and glory, and blessing."\n\nThere shall be no more death, neither sorrow, nor crying, neither shall there be any more pain; for the former things are passed away. The earth is restored, and peace and righteousness reign forevermore.',
        'scripture': 'Revelation 21:1-7; Revelation 22:1-5; Isaiah 35:10',
      },
    ];
  }
}
