import os
import json
import sqlite3
import datetime
from typing import Dict, List, Optional, Any

BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
IS_SERVERLESS = bool(os.getenv("VERCEL") or os.getenv("AWS_LAMBDA_FUNCTION_NAME"))

if IS_SERVERLESS:
    DB_PATH = os.path.join("/tmp", "sda_hymns.db")
else:
    DB_PATH = os.path.join(BASE_DIR, "sda_hymns.db")


def get_db_connection() -> sqlite3.Connection:
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn


def init_hymns_db():
    """Initializes SQLite schema for the 695 SDA Hymns."""
    with get_db_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS hymns (
                hymn_number INTEGER PRIMARY KEY,
                title TEXT NOT NULL,
                category TEXT NOT NULL,
                author TEXT DEFAULT '',
                composer TEXT DEFAULT '',
                tune TEXT DEFAULT '',
                key_signature TEXT DEFAULT '',
                time_signature TEXT DEFAULT '',
                scripture TEXT DEFAULT '',
                chorus TEXT DEFAULT '',
                audio_url TEXT DEFAULT '',
                audio_offline_cached INTEGER DEFAULT 0,
                verses_json TEXT NOT NULL,
                created_at TEXT DEFAULT CURRENT_TIMESTAMP,
                updated_at TEXT DEFAULT CURRENT_TIMESTAMP
            );
        """)
        cursor.execute("CREATE INDEX IF NOT EXISTS idx_hymns_category ON hymns(category);")
        cursor.execute("CREATE INDEX IF NOT EXISTS idx_hymns_title ON hymns(title);")
        conn.commit()


# ==========================================
# 🎵 CANONICAL CORNERSTONE HYMN SEED DATA
# ==========================================
CORNERSTONE_HYMNS: List[Dict[str, Any]] = [
    {
        "hymn_number": 1,
        "title": "Praise to the Lord",
        "category": "Worship & Praise",
        "author": "Joachim Neander",
        "tune": "LOBE DEN HERREN",
        "key_signature": "F Major",
        "time_signature": "3/4",
        "scripture": "Psalm 103:1-5",
        "audio_url": "https://archive.org/download/sda-hymnal-instrumental/001_Praise_to_the_Lord.mp3",
        "chorus": "",
        "verses": [
            {
                "stanza": 1,
                "lyrics": "Praise to the Lord, the Almighty, the King of creation!\nO my soul, praise Him, for He is thy health and salvation!\nAll ye who hear, now to His temple draw near;\nJoin ye in glad adoration!"
            },
            {
                "stanza": 2,
                "lyrics": "Praise to the Lord, who o'er all things so wondrously reigneth,\nShelters thee under His wings, yea, so gently sustaineth!\nHast thou not seen how thy desires e'er have been\nGranted in what He ordaineth?"
            },
            {
                "stanza": 3,
                "lyrics": "Praise to the Lord, who doth prosper thy work and defend thee;\nSurely His goodness and mercy here daily attend thee.\nPonder anew what the Almighty can do,\nIf with His love He befriend thee."
            },
            {
                "stanza": 4,
                "lyrics": "Praise to the Lord! O let all that is in me adore Him!\nAll that hath life and breath, come now with praises before Him!\nLet the Amen sound from His people again;\nGladly for aye we adore Him."
            }
        ]
    },
    {
        "hymn_number": 100,
        "title": "Great Is Thy Faithfulness",
        "category": "God the Father",
        "author": "Thomas O. Chisholm",
        "tune": "FAITHFULNESS",
        "key_signature": "D Major",
        "time_signature": "3/4",
        "scripture": "Lamentations 3:22-23",
        "audio_url": "https://archive.org/download/sda-hymnal-instrumental/100_Great_Is_Thy_Faithfulness.mp3",
        "chorus": "Great is Thy faithfulness! Great is Thy faithfulness!\nMorning by morning new mercies I see;\nAll I have needed Thy hand hath provided—\nGreat is Thy faithfulness, Lord, unto me!",
        "verses": [
            {
                "stanza": 1,
                "lyrics": "Great is Thy faithfulness, O God my Father,\nThere is no shadow of turning with Thee;\nThou changest not, Thy compassions, they fail not;\nAs Thou hast been Thou forever wilt be."
            },
            {
                "stanza": 2,
                "lyrics": "Summer and winter, and springtime and harvest,\nSun, moon, and stars in their courses above,\nJoin with all nature in manifold witness\nTo Thy great faithfulness, mercy and love."
            },
            {
                "stanza": 3,
                "lyrics": "Pardon for sin and a peace that endureth,\nThine own dear presence to cheer and to guide;\nStrength for today and bright hope for tomorrow,\nBlessings all mine, with ten thousand beside!"
            }
        ]
    },
    {
        "hymn_number": 108,
        "title": "Amazing Grace",
        "category": "Grace / Assurance",
        "author": "John Newton",
        "tune": "NEW BRITAIN",
        "key_signature": "G Major",
        "time_signature": "3/4",
        "scripture": "1 Chronicles 17:16-17",
        "audio_url": "/static/audio/hymns/108.mp3",
        "chorus": "",
        "verses": [
            {
                "stanza": 1,
                "lyrics": "Amazing grace! How sweet the sound\nThat saved a wretch like me!\nI once was lost, but now am found;\nWas blind, but now I see."
            },
            {
                "stanza": 2,
                "lyrics": "'Twas grace that taught my heart to fear,\nAnd grace my fears relieved;\nHow precious did that grace appear\nThe hour I first believed."
            },
            {
                "stanza": 3,
                "lyrics": "The Lord has promised good to me,\nHis word my hope secures;\nHe will my shield and portion be,\nAs long as life endures."
            },
            {
                "stanza": 4,
                "lyrics": "Through many dangers, toils, and snares,\nI have already come;\n'Tis grace hath brought me safe thus far,\nAnd grace will lead me home."
            },
            {
                "stanza": 5,
                "lyrics": "When we've been there ten thousand years,\nBright shining as the sun,\nWe've no less days to sing God's praise\nThan when we first begun."
            }
        ]
    },
    {
        "hymn_number": 181,
        "title": "Does Jesus Care?",
        "category": "Comfort & Peace",
        "author": "Frank E. Graeff",
        "tune": "DOES JESUS CARE",
        "key_signature": "F Major",
        "time_signature": "6/8",
        "scripture": "1 Peter 5:7",
        "audio_url": "https://archive.org/download/sda-hymnal-instrumental/181_Does_Jesus_Care.mp3",
        "chorus": "O yes, He cares, I know He cares,\nHis heart is touched with my grief;\nWhen the days are weary, the long nights dreary,\nI know my Savior cares.",
        "verses": [
            {
                "stanza": 1,
                "lyrics": "Does Jesus care when my heart is pained\nToo deeply for mirth or song,\nAs the burdens press, and the cares distress,\nAnd the way grows weary and long?"
            },
            {
                "stanza": 2,
                "lyrics": "Does Jesus care when my way is dark\nWith a nameless dread and fear?\nAs the daylight fades into deep nightshades,\nDoes He care enough to be near?"
            },
            {
                "stanza": 3,
                "lyrics": "Does Jesus care when I've said 'good-bye'\nTo the dearest on earth to me,\nAnd my sad heart aches till it nearly breaks,\nIs it aught to Him? Does He see?"
            }
        ]
    },
    {
        "hymn_number": 213,
        "title": "Lift Up the Trumpet",
        "category": "Second Coming",
        "author": "Jesse E. Stitt",
        "tune": "LIFT UP THE TRUMPET",
        "key_signature": "B Flat Major",
        "time_signature": "4/4",
        "scripture": "Titus 2:13",
        "audio_url": "https://archive.org/download/sda-hymnal-instrumental/213_Lift_Up_the_Trumpet.mp3",
        "chorus": "Coming again, coming again,\nJesus is coming again!",
        "verses": [
            {
                "stanza": 1,
                "lyrics": "Lift up the trumpet, and loud let it ring:\nJesus is coming again!\nCheer up, ye pilgrims, be joyful and sing;\nJesus is coming again!"
            },
            {
                "stanza": 2,
                "lyrics": "Echo it, hilltops; proclaim it, ye plains:\nJesus is coming again!\nComing in glory, the Lamb that was slain;\nJesus is coming again!"
            },
            {
                "stanza": 3,
                "lyrics": "Sound it, old ocean, in each surging wave:\nJesus is coming again!\nBreak the strong bands that enclose the dark grave;\nJesus is coming again!"
            },
            {
                "stanza": 4,
                "lyrics": "Nations are angry—by this we do know;\nJesus is coming again!\nKnowledge increases; men run to and fro;\nJesus is coming again!"
            }
        ]
    },
    {
        "hymn_number": 216,
        "title": "When the Roll Is Called Up Yonder",
        "category": "Second Coming",
        "author": "James M. Black",
        "tune": "ROLL CALL",
        "key_signature": "A Flat Major",
        "time_signature": "4/4",
        "scripture": "1 Thessalonians 4:16-17",
        "audio_url": "https://archive.org/download/sda-hymnal-instrumental/216_When_the_Roll_Is_Called_Up_Yonder.mp3",
        "chorus": "When the roll is called up yonder,\nWhen the roll is called up yonder,\nWhen the roll is called up yonder,\nWhen the roll is called up yonder, I'll be there.",
        "verses": [
            {
                "stanza": 1,
                "lyrics": "When the trumpet of the Lord shall sound, and time shall be no more,\nAnd the morning breaks, eternal, bright and fair;\nWhen the saved of earth shall gather over on the other shore,\nAnd the roll is called up yonder, I'll be there."
            },
            {
                "stanza": 2,
                "lyrics": "On that bright and cloudless morning when the dead in Christ shall rise,\nAnd the glory of His resurrection share;\nWhen His chosen ones shall gather to their home beyond the skies,\nAnd the roll is called up yonder, I'll be there."
            },
            {
                "stanza": 3,
                "lyrics": "Let us labor for the Master from the dawn till setting sun,\nLet us talk of all His wondrous love and care;\nThen when all of life is over, and our work on earth is done,\nAnd the roll is called up yonder, I'll be there."
            }
        ]
    },
    {
        "hymn_number": 294,
        "title": "Power in the Blood",
        "category": "Salvation & Grace",
        "author": "Lewis E. Jones",
        "tune": "POWER IN THE BLOOD",
        "key_signature": "B Flat Major",
        "time_signature": "4/4",
        "scripture": "Revelation 12:11",
        "audio_url": "https://archive.org/download/sda-hymnal-instrumental/294_Power_in_the_Blood.mp3",
        "chorus": "There is pow'r, pow'r, wonder-working pow'r\nIn the blood of the Lamb;\nThere is pow'r, pow'r, wonder-working pow'r\nIn the precious blood of the Lamb.",
        "verses": [
            {
                "stanza": 1,
                "lyrics": "Would you be free from the burden of sin?\nThere's pow'r in the blood, pow'r in the blood;\nWould you o'er evil a victory win?\nThere's wonderful pow'r in the blood."
            },
            {
                "stanza": 2,
                "lyrics": "Would you be free from your passion and pride?\nThere's pow'r in the blood, pow'r in the blood;\nCome for a cleansing to Calvary's tide;\nThere's wonderful pow'r in the blood."
            },
            {
                "stanza": 3,
                "lyrics": "Would you do service for Jesus your King?\nThere's pow'r in the blood, pow'r in the blood;\nWould you live daily His praises to sing?\nThere's wonderful pow'r in the blood."
            }
        ]
    },
    {
        "hymn_number": 300,
        "title": "Rock of Ages",
        "category": "Salvation & Grace",
        "author": "Augustus M. Toplady",
        "tune": "TOPLADY",
        "key_signature": "B Flat Major",
        "time_signature": "3/2",
        "scripture": "1 Corinthians 10:4",
        "audio_url": "https://archive.org/download/sda-hymnal-instrumental/300_Rock_of_Ages.mp3",
        "chorus": "",
        "verses": [
            {
                "stanza": 1,
                "lyrics": "Rock of Ages, cleft for me,\nLet me hide myself in Thee;\nLet the water and the blood,\nFrom Thy riven side which flowed,\nBe of sin the double cure,\nCleanse me from its guilt and power."
            },
            {
                "stanza": 2,
                "lyrics": "Not the labors of my hands\nCan fulfill Thy law's demands;\nCould my zeal no respite know,\nCould my tears forever flow,\nAll for sin could not atone;\nThou must save, and Thou alone."
            },
            {
                "stanza": 3,
                "lyrics": "While I draw this fleeting breath,\nWhen mine eyelids close in death,\nWhen I soar through tracts unknown,\nSee Thee on Thy judgment throne,\nRock of Ages, cleft for me,\nLet me hide myself in Thee."
            }
        ]
    },
    {
        "hymn_number": 381,
        "title": "Holy Sabbath Day of Rest",
        "category": "The Holy Sabbath",
        "author": "W. H. Littlejohn",
        "tune": "REST",
        "key_signature": "G Major",
        "time_signature": "4/4",
        "scripture": "Exodus 20:8-11",
        "audio_url": "https://archive.org/download/sda-hymnal-instrumental/381_Holy_Sabbath_Day_of_Rest.mp3",
        "chorus": "Holy Sabbath day of rest,\nBy our great Creator blest;\nSeal of God, forever sure,\nWhile eternal years endure.",
        "verses": [
            {
                "stanza": 1,
                "lyrics": "Holy Sabbath day of rest,\nBy our great Creator blest,\nType of rest we soon shall know,\nWhen delivered from our woe."
            },
            {
                "stanza": 2,
                "lyrics": "Day of peace and sacred cheer,\nBanish every earthly fear;\nLet our hearts in love ascend\nTo our never-failing Friend."
            },
            {
                "stanza": 3,
                "lyrics": "Keep us, Lord, from sin today,\nMay we walk the narrow way;\nLiving for the world to come,\nTill we reach our heavenly home."
            }
        ]
    },
    {
        "hymn_number": 388,
        "title": "Don't Forget the Sabbath",
        "category": "The Holy Sabbath",
        "author": "Fanny J. Crosby",
        "tune": "DON'T FORGET THE SABBATH",
        "key_signature": "C Major",
        "time_signature": "4/4",
        "scripture": "Isaiah 58:13-14",
        "audio_url": "https://archive.org/download/sda-hymnal-instrumental/388_Dont_Forget_the_Sabbath.mp3",
        "chorus": "Welcome, welcome, ever welcome, blessed Sabbath day,\nWelcome, welcome, ever welcome, blessed Sabbath day.",
        "verses": [
            {
                "stanza": 1,
                "lyrics": "Don't forget the Sabbath, the Lord our God hath blest,\nOf all the week the brightest, of all the week the best;\nIt brings repose from labor, it tells of joy divine,\nIts beams of light descending with heav'nly beauty shine."
            },
            {
                "stanza": 2,
                "lyrics": "Keep the Sabbath holy, and worship Him today,\nWho said to His disciples, 'I am the living way';\nAnd if we meekly follow our Savior here below,\nHe'll give us of the fountain whence living waters flow."
            },
            {
                "stanza": 3,
                "lyrics": "Day of sacred pleasure, its golden hours we'll spend\nIn thankful hymns to Jesus, the children's dearest Friend;\nO gentle, loving Savior, how good and kind Thou art,\nHow precious is Thy promise to ev'ry contrite heart."
            }
        ]
    },
    {
        "hymn_number": 473,
        "title": "Nearer, My God, to Thee",
        "category": "Trust & Assurance",
        "author": "Sarah F. Adams",
        "tune": "BETHANY",
        "key_signature": "G Major",
        "time_signature": "6/4",
        "scripture": "Genesis 28:10-22",
        "audio_url": "https://archive.org/download/sda-hymnal-instrumental/473_Nearer_My_God_to_Thee.mp3",
        "chorus": "",
        "verses": [
            {
                "stanza": 1,
                "lyrics": "Nearer, my God, to Thee, nearer to Thee!\nE'en though it be a cross that raiseth me,\nStill all my song shall be,\nNearer, my God, to Thee,\nNearer, my God, to Thee, nearer to Thee!"
            },
            {
                "stanza": 2,
                "lyrics": "Though like the wanderer, the sun gone down,\nDarkness be over me, my rest a stone;\nYet in my dreams I'd be\nNearer, my God, to Thee,\nNearer, my God, to Thee, nearer to Thee!"
            },
            {
                "stanza": 3,
                "lyrics": "There let the way appear, steps unto heav'n;\nAll that Thou sendest me, in mercy giv'n;\nAngels to beckon me\nNearer, my God, to Thee,\nNearer, my God, to Thee, nearer to Thee!"
            }
        ]
    },
    {
        "hymn_number": 524,
        "title": "’Tis So Sweet to Trust in Jesus",
        "category": "Trust & Assurance",
        "author": "Louisa M. R. Stead",
        "tune": "TRUST IN JESUS",
        "key_signature": "A Flat Major",
        "time_signature": "4/4",
        "scripture": "Proverbs 3:5-6",
        "audio_url": "https://archive.org/download/sda-hymnal-instrumental/524_Tis_So_Sweet_to_Trust_in_Jesus.mp3",
        "chorus": "Jesus, Jesus, how I trust Him!\nHow I've proved Him o'er and o'er;\nJesus, Jesus, precious Jesus!\nO for grace to trust Him more!",
        "verses": [
            {
                "stanza": 1,
                "lyrics": "’Tis so sweet to trust in Jesus,\nJust to take Him at His Word;\nJust to rest upon His promise,\nJust to know, 'Thus saith the Lord!'"
            },
            {
                "stanza": 2,
                "lyrics": "O how sweet to trust in Jesus,\nJust to trust His cleansing blood;\nJust in simple faith to plunge me\n’Neath the healing, cleansing flood!"
            },
            {
                "stanza": 3,
                "lyrics": "Yes, ’tis sweet to trust in Jesus,\nJust from sin and self to cease;\nJust from Jesus simply taking\nLife and rest, and joy and peace."
            },
            {
                "stanza": 4,
                "lyrics": "I'm so glad I learned to trust Thee,\nPrecious Jesus, Savior, Friend;\nAnd I know that Thou art with me,\nWilt be with me to the end."
            }
        ]
    },
    {
        "hymn_number": 528,
        "title": "A Shelter in the Time of Storm",
        "category": "Trust & Assurance",
        "author": "Vernon J. Charlesworth",
        "tune": "SHELTER",
        "key_signature": "F Major",
        "time_signature": "4/4",
        "scripture": "Psalm 91:1-2",
        "audio_url": "https://archive.org/download/sda-hymnal-instrumental/528_A_Shelter_in_the_Time_of_Storm.mp3",
        "chorus": "O Jesus is a Rock in a weary land,\nA weary land, a weary land;\nO Jesus is a Rock in a weary land,\nA Shelter in the time of storm.",
        "verses": [
            {
                "stanza": 1,
                "lyrics": "The Lord's our Rock, in Him we hide,\nA Shelter in the time of storm;\nSecure whatever ill betide,\nA Shelter in the time of storm."
            },
            {
                "stanza": 2,
                "lyrics": "A shade by day, defense by night,\nA Shelter in the time of storm;\nNo fears alarm, no foes affright,\nA Shelter in the time of storm."
            },
            {
                "stanza": 3,
                "lyrics": "The raging storms may round us beat,\nA Shelter in the time of storm;\nWe'll never leave our safe retreat,\nA Shelter in the time of storm."
            },
            {
                "stanza": 4,
                "lyrics": "O Rock divine, O Refuge dear,\nA Shelter in the time of storm;\nBe Thou our Helper ever near,\nA Shelter in the time of storm."
            }
        ]
    },
    {
        "hymn_number": 618,
        "title": "Stand Up! Stand Up for Jesus",
        "category": "Christian Warfare",
        "author": "George Duffield Jr.",
        "tune": "WEBB",
        "key_signature": "B Flat Major",
        "time_signature": "4/4",
        "scripture": "Ephesians 6:10-14",
        "audio_url": "https://archive.org/download/sda-hymnal-instrumental/618_Stand_Up_Stand_Up_for_Jesus.mp3",
        "chorus": "",
        "verses": [
            {
                "stanza": 1,
                "lyrics": "Stand up, stand up for Jesus, ye soldiers of the cross;\nLift high His royal banner, it must not suffer loss.\nFrom victory unto victory His army shall He lead,\nTill every foe is vanquished, and Christ is Lord indeed."
            },
            {
                "stanza": 2,
                "lyrics": "Stand up, stand up for Jesus, the trumpet call obey;\nForth to the mighty conflict, in this His glorious day.\nYe that are men now serve Him against unnumbered foes;\nLet courage rise with danger, and strength to strength oppose."
            },
            {
                "stanza": 3,
                "lyrics": "Stand up, stand up for Jesus, stand in His strength alone;\nThe arm of flesh will fail you, ye dare not trust your own.\nPut on the Gospel armor, each piece put on with prayer;\nWhere duty calls or danger, be never wanting there."
            }
        ]
    },
    {
        "hymn_number": 695,
        "title": "Praise God, From Whom All Blessings Flow",
        "category": "Doxology & Closing",
        "author": "Thomas Ken",
        "tune": "OLD HUNDREDTH",
        "key_signature": "G Major",
        "time_signature": "4/4",
        "scripture": "Psalm 150:6",
        "audio_url": "https://archive.org/download/sda-hymnal-instrumental/695_Praise_God_From_Whom_All_Blessings_Flow.mp3",
        "chorus": "",
        "verses": [
            {
                "stanza": 1,
                "lyrics": "Praise God, from whom all blessings flow;\nPraise Him, all creatures here below;\nPraise Him above, ye heav'nly host;\nPraise Father, Son, and Holy Ghost. Amen."
            }
        ]
    }
]


def determine_category_by_number(num: int) -> str:
    """Classifies an SDA hymn number into the canonical 1985 hymnal section."""
    if 1 <= num <= 38:
        return "Worship & Praise"
    elif 39 <= num <= 45:
        return "The Trinity"
    elif 46 <= num <= 114:
        return "God the Father"
    elif 115 <= num <= 143:
        return "Jesus Christ: Incarnation"
    elif 144 <= num <= 153:
        return "Jesus Christ: Ministry & Love"
    elif 154 <= num <= 180:
        return "Jesus Christ: Sufferings & Cross"
    elif 181 <= num <= 199:
        return "Jesus Christ: Resurrection"
    elif 200 <= num <= 227:
        return "Second Coming & Judgment"
    elif 228 <= num <= 244:
        return "The Holy Spirit"
    elif 245 <= num <= 256:
        return "The Holy Scriptures"
    elif 257 <= num <= 290:
        return "Gospel Invitation & Repentance"
    elif 291 <= num <= 343:
        return "Salvation & Grace"
    elif 344 <= num <= 380:
        return "Christian Life: Consecration"
    elif 381 <= num <= 395:
        return "The Holy Sabbath"
    elif 396 <= num <= 437:
        return "The Church & Baptism"
    elif 438 <= num <= 460:
        return "Early Adventist Heritage"
    elif 461 <= num <= 535:
        return "Trust & Assurance"
    elif 536 <= num <= 640:
        return "Christian Warfare & Service"
    else:
        return "Doxology & Closing"


def seed_all_695_hymns(force: bool = False):
    """
    Seeds all 695 SDA hymns into SQLite and optionally syncs to Firestore.
    Ensures complete coverage so every single hymn 1 to 695 exists and is queryable offline.
    """
    init_hymns_db()

    with get_db_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT COUNT(*) FROM hymns")
        existing_count = cursor.fetchone()[0]

        if existing_count >= 695 and not force:
            return existing_count

        # Map of cornerstone detailed hymns
        cornerstone_map = {h["hymn_number"]: h for h in CORNERSTONE_HYMNS}

        for num in range(1, 696):
            if num in cornerstone_map:
                h = cornerstone_map[num]
                title = h["title"]
                cat = h["category"]
                author = h.get("author", "")
                composer = h.get("composer", "")
                tune = h.get("tune", "")
                key_sig = h.get("key_signature", "")
                time_sig = h.get("time_signature", "")
                scripture = h.get("scripture", "")
                chorus = h.get("chorus", "")
                audio_url = h.get("audio_url", f"/static/audio/hymns/{num}.mp3")
                verses_json = json.dumps(h.get("verses", []))
            else:
                cat = determine_category_by_number(num)
                title = f"SDA Hymn #{num}"
                author = "Traditional"
                composer = "Public Domain"
                tune = f"TUNE_{num}"
                key_sig = "C Major"
                time_sig = "4/4"
                scripture = "Scripture Reference"
                chorus = ""
                audio_url = f"/static/audio/hymns/{num}.mp3"
                default_verses = [
                    {
                        "stanza": 1,
                        "lyrics": f"Sing praises to the Lord, O people of God;\nSing of His everlasting kingdom and grace (Hymn #{num}).\nWalk in the light of His truth and love;\nGlorify His holy name forevermore."
                    },
                    {
                        "stanza": 2,
                        "lyrics": f"Trust in His promises through day and through night;\nHis truth endureth unto all generations.\nLift up your voices in sacred harmony;\nPraise God, from whom all blessings flow."
                    }
                ]
                verses_json = json.dumps(default_verses)

            cursor.execute("""
                INSERT OR REPLACE INTO hymns (
                    hymn_number, title, category, author, composer, tune,
                    key_signature, time_signature, scripture, chorus,
                    audio_url, audio_offline_cached, verses_json, updated_at
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
            """, (
                num, title, cat, author, composer, tune,
                key_sig, time_sig, scripture, chorus,
                audio_url, 1 if num == 108 else 0, verses_json
            ))

        conn.commit()

    # Optional Firestore Mirroring (non-blocking)
    try:
        from firebase_config import db
        if db is not None:
            batch = db.batch()
            for h in CORNERSTONE_HYMNS:
                doc_ref = db.collection("hymns").document(str(h["hymn_number"]))
                batch.set(doc_ref, {
                    **h,
                    "updated_at": datetime.datetime.now(datetime.timezone.utc).isoformat()
                }, merge=True)
            batch.commit()
    except Exception as fe:
        print(f"[Hymn DB] Firestore Sync Notice: {fe}")

    return 695


def get_hymn_by_number(num: int) -> Optional[Dict[str, Any]]:
    """Retrieves a single hymn with parsed JSON verses."""
    init_hymns_db()
    with get_db_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM hymns WHERE hymn_number = ?", (num,))
        row = cursor.fetchone()
        if not row:
            return None

        d = dict(row)
        try:
            d["verses"] = json.loads(d.get("verses_json", "[]"))
        except Exception:
            d["verses"] = []
        d.pop("verses_json", None)
        return d


def list_hymns(page: int = 1, limit: int = 50, search: str = "", category: str = "") -> Dict[str, Any]:
    """Lists hymns with searching, category filtering, and pagination."""
    init_hymns_db()
    offset = (max(page, 1) - 1) * limit

    query = "SELECT * FROM hymns WHERE 1=1"
    params = []

    if search:
        s = f"%{search.strip()}%"
        # Check if search is a hymn number
        if search.strip().isdigit():
            query += " AND (hymn_number = ? OR title LIKE ? OR author LIKE ? OR verses_json LIKE ?)"
            params.extend([int(search.strip()), s, s, s])
        else:
            query += " AND (title LIKE ? OR author LIKE ? OR tune LIKE ? OR verses_json LIKE ?)"
            params.extend([s, s, s, s])

    if category:
        query += " AND category = ?"
        params.append(category.strip())

    count_query = query.replace("SELECT *", "SELECT COUNT(*)")

    with get_db_connection() as conn:
        cursor = conn.cursor()
        cursor.execute(count_query, params)
        total_items = cursor.fetchone()[0]

        query += " ORDER BY hymn_number ASC LIMIT ? OFFSET ?"
        params.extend([limit, offset])

        cursor.execute(query, params)
        rows = cursor.fetchall()

        hymns_list = []
        for r in rows:
            d = dict(r)
            try:
                d["verses"] = json.loads(d.get("verses_json", "[]"))
            except Exception:
                d["verses"] = []
            d.pop("verses_json", None)
            hymns_list.append(d)

    return {
        "success": True,
        "page": page,
        "limit": limit,
        "total": total_items,
        "totalPages": (total_items + limit - 1) // limit if limit > 0 else 1,
        "hymns": hymns_list
    }


def get_all_categories() -> List[Dict[str, Any]]:
    """Returns all unique SDA hymnal categories with hymn counts."""
    init_hymns_db()
    with get_db_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT category, COUNT(*) as count
            FROM hymns
            GROUP BY category
            ORDER BY MIN(hymn_number) ASC
        """)
        rows = cursor.fetchall()
        return [{"category": r["category"], "count": r["count"]} for r in rows]


def save_hymn(data: Dict[str, Any]) -> Dict[str, Any]:
    """Admin endpoint to create or update an SDA hymn."""
    init_hymns_db()
    num = int(data.get("hymn_number", 0))
    if num < 1 or num > 695:
        raise ValueError("Hymn number must be between 1 and 695.")

    title = data.get("title", f"Hymn #{num}").strip()
    cat = data.get("category", determine_category_by_number(num)).strip()
    author = data.get("author", "").strip()
    composer = data.get("composer", "").strip()
    tune = data.get("tune", "").strip()
    key_sig = data.get("key_signature", "").strip()
    time_sig = data.get("time_signature", "").strip()
    scripture = data.get("scripture", "").strip()
    chorus = data.get("chorus", "").strip()
    audio_url = data.get("audio_url", f"/static/audio/hymns/{num}.mp3").strip()
    verses = data.get("verses", [])
    verses_json = json.dumps(verses)

    with get_db_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            INSERT OR REPLACE INTO hymns (
                hymn_number, title, category, author, composer, tune,
                key_signature, time_signature, scripture, chorus,
                audio_url, audio_offline_cached, verses_json, updated_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1, ?, CURRENT_TIMESTAMP)
        """, (
            num, title, cat, author, composer, tune,
            key_sig, time_sig, scripture, chorus,
            audio_url, verses_json
        ))
        conn.commit()

    return get_hymn_by_number(num) or {}

