import os
from flask import Blueprint, request, jsonify, render_template

sop_bp = Blueprint("sop", __name__)

# Complete catalog of all 50 Spirit of Prophecy masterworks by Ellen G. White
SOP_BOOKS = [
    # 🌟 Conflict of the Ages Series (5 Volumes)
    {
        "id": "sop_patriarchs_and_prophets",
        "title": "Patriarchs and Prophets",
        "author": "Ellen G. White",
        "category": "Spirit of Prophecy",
        "series": "Conflict of the Ages",
        "onlineUrl": "https://m.egwwritings.org/en/book/84.2",
        "description": "From creation and the fall of Lucifer to the reign of King David, tracing the great conflict between good and evil.",
    },
    {
        "id": "sop_prophets_and_kings",
        "title": "Prophets and Kings",
        "author": "Ellen G. White",
        "category": "Spirit of Prophecy",
        "series": "Conflict of the Ages",
        "onlineUrl": "https://m.egwwritings.org/en/book/86.2",
        "description": "From the division of Solomon's kingdom, the ministries of Elijah and Jeremiah, to the coming Messiah.",
    },
    {
        "id": "sop_desire_of_ages",
        "title": "The Desire of Ages",
        "author": "Ellen G. White",
        "category": "Spirit of Prophecy",
        "series": "Conflict of the Ages",
        "onlineUrl": "https://m.egwwritings.org/en/book/130.2",
        "description": "The supreme biography of Jesus Christ, His matchless love, earthly ministry, and ultimate cross sacrifice.",
    },
    {
        "id": "sop_acts_of_the_apostles",
        "title": "The Acts of the Apostles",
        "author": "Ellen G. White",
        "category": "Spirit of Prophecy",
        "series": "Conflict of the Ages",
        "onlineUrl": "https://m.egwwritings.org/en/book/127.2",
        "description": "The early Christian church, Pentecost power, apostolic missionary journeys, and spreading the Gospel worldwide.",
    },
    {
        "id": "sop_great_controversy",
        "title": "The Great Controversy",
        "author": "Ellen G. White",
        "category": "Spirit of Prophecy",
        "series": "Conflict of the Ages",
        "onlineUrl": "https://m.egwwritings.org/en/book/132.2",
        "description": "The cosmic drama from the destruction of Jerusalem, the Dark Ages, Reformation, to the glorious Earth Made New.",
    },

    # ✝️ Christian Living & Salvation
    {
        "id": "sop_steps_to_christ",
        "title": "Steps to Christ",
        "author": "Ellen G. White",
        "category": "Spirit of Prophecy",
        "series": "Christian Living & Salvation",
        "onlineUrl": "https://m.egwwritings.org/en/book/138.2",
        "description": "The timeless masterpiece guiding sinners through repentance, confession, faith, and joy in Christ.",
    },
    {
        "id": "sop_christs_object_lessons",
        "title": "Christ's Object Lessons",
        "author": "Ellen G. White",
        "category": "Spirit of Prophecy",
        "series": "Christian Living & Salvation",
        "onlineUrl": "https://m.egwwritings.org/en/book/15.2",
        "description": "Profound spiritual insights drawn from Christ's parables of the kingdom, seed, and harvest.",
    },
    {
        "id": "sop_mount_of_blessing",
        "title": "Thoughts from the Mount of Blessing",
        "author": "Ellen G. White",
        "category": "Spirit of Prophecy",
        "series": "Christian Living & Salvation",
        "onlineUrl": "https://m.egwwritings.org/en/book/140.2",
        "description": "Deep study into the Beatitudes, the Lord's Prayer, and Jesus' divine Sermon on the Mount.",
    },
    {
        "id": "sop_prayer",
        "title": "Prayer",
        "author": "Ellen G. White",
        "category": "Spirit of Prophecy",
        "series": "Christian Living & Salvation",
        "onlineUrl": "https://m.egwwritings.org/en/book/85.2",
        "description": "Encouragement and principles for prevailing, transformative personal and intercessory prayer.",
    },
    {
        "id": "sop_sanctified_life",
        "title": "The Sanctified Life",
        "author": "Ellen G. White",
        "category": "Spirit of Prophecy",
        "series": "Christian Living & Salvation",
        "onlineUrl": "https://m.egwwritings.org/en/book/136.2",
        "description": "Biblical holiness exemplified through the lives of Daniel, John, and the character of Christ.",
    },
    {
        "id": "sop_sons_and_daughters",
        "title": "Sons and Daughters of God",
        "author": "Ellen G. White",
        "category": "Spirit of Prophecy",
        "series": "Christian Living & Salvation",
        "onlineUrl": "https://m.egwwritings.org/en/book/137.2",
        "description": "Inspiring daily devotionals centering on adoption into the heavenly royal family.",
    },
    {
        "id": "sop_our_high_calling",
        "title": "Our High Calling",
        "author": "Ellen G. White",
        "category": "Spirit of Prophecy",
        "series": "Christian Living & Salvation",
        "onlineUrl": "https://m.egwwritings.org/en/book/75.2",
        "description": "Daily spiritual counsel urging believers toward higher Christian standards and divine communion.",
    },
    {
        "id": "sop_faith_i_live_by",
        "title": "The Faith I Live By",
        "author": "Ellen G. White",
        "category": "Spirit of Prophecy",
        "series": "Christian Living & Salvation",
        "onlineUrl": "https://m.egwwritings.org/en/book/131.2",
        "description": "Exposition of fundamental Adventist doctrines and Christian faith practical applications.",
    },

    # 🌿 Health & Temperance
    {
        "id": "sop_ministry_of_healing",
        "title": "The Ministry of Healing",
        "author": "Ellen G. White",
        "category": "Health & Temperance",
        "series": "Health & Temperance",
        "onlineUrl": "https://m.egwwritings.org/en/book/150.2",
        "description": "God's natural remedies, pure air, water, nutrition, mental peace, and practical medical missionary service.",
    },
    {
        "id": "sop_counsels_on_diet_and_foods",
        "title": "Counsels on Diet and Foods",
        "author": "Ellen G. White",
        "category": "Health & Temperance",
        "series": "Health & Temperance",
        "onlineUrl": "https://m.egwwritings.org/en/book/24.2",
        "description": "Comprehensive dietary counsels, plant-based principles, and physiological health laws.",
    },
    {
        "id": "sop_temperance",
        "title": "Temperance",
        "author": "Ellen G. White",
        "category": "Health & Temperance",
        "series": "Health & Temperance",
        "onlineUrl": "https://m.egwwritings.org/en/book/139.2",
        "description": "Overcoming addictions, tobacco, alcohol, and intemperance through divine grace and self-control.",
    },
    {
        "id": "sop_medical_ministry",
        "title": "Medical Ministry",
        "author": "Ellen G. White",
        "category": "Health & Temperance",
        "series": "Health & Temperance",
        "onlineUrl": "https://m.egwwritings.org/en/book/57.2",
        "description": "Manual for physicians, nurses, sanitariums, and gospel health workers in the closing work.",
    },
    {
        "id": "sop_call_to_medical_evangelism",
        "title": "A Call to Medical Evangelism",
        "author": "Ellen G. White",
        "category": "Health & Temperance",
        "series": "Health & Temperance",
        "onlineUrl": "https://m.egwwritings.org/en/book/13.2",
        "description": "How the health work serves as the entering wedge for the Three Angels' Messages.",
    },

    # 👨‍👩‍👧‍👦 Family Life, Youth & Home
    {
        "id": "sop_the_adventist_home",
        "title": "The Adventist Home",
        "author": "Ellen G. White",
        "category": "Christian Living & Family",
        "series": "Family Life, Youth & Home",
        "onlineUrl": "https://m.egwwritings.org/en/book/32.2",
        "description": "Principles for creating a peaceful, Christ-centered marriage and home that reflects heaven.",
    },
    {
        "id": "sop_child_guidance",
        "title": "Child Guidance",
        "author": "Ellen G. White",
        "category": "Christian Living & Family",
        "series": "Family Life, Youth & Home",
        "onlineUrl": "https://m.egwwritings.org/en/book/14.2",
        "description": "Essential principles for parenting, early habit training, and spiritual character building in youth.",
    },
    {
        "id": "sop_messages_to_young_people",
        "title": "Messages to Young People",
        "author": "Ellen G. White",
        "category": "Youth & Education",
        "series": "Family Life, Youth & Home",
        "onlineUrl": "https://m.egwwritings.org/en/book/58.2",
        "description": "Heartfelt appeals to Adventist youth regarding purity, courtship, mission, and life goals.",
    },
    {
        "id": "sop_education",
        "title": "Education",
        "author": "Ellen G. White",
        "category": "Youth & Education",
        "series": "Family Life, Youth & Home",
        "onlineUrl": "https://m.egwwritings.org/en/book/29.2",
        "description": "The true nature of education — harmonious development of physical, mental, and spiritual powers.",
    },
    {
        "id": "sop_counsels_to_parents",
        "title": "Counsels to Parents, Teachers, and Students",
        "author": "Ellen G. White",
        "category": "Youth & Education",
        "series": "Family Life, Youth & Home",
        "onlineUrl": "https://m.egwwritings.org/en/book/27.2",
        "description": "Christian school guidance, moral discipline, manual training, and academic standards.",
    },

    # 💼 Evangelism & Church Ministry
    {
        "id": "sop_colporteur_ministry",
        "title": "Colporteur Ministry",
        "author": "Ellen G. White",
        "category": "Evangelism & Prophecy",
        "series": "Evangelism & Church Ministry",
        "onlineUrl": "https://m.egwwritings.org/en/book/20.2",
        "description": "The definitive guide for literature evangelists distributing physical truth-filled books door-to-door.",
    },
    {
        "id": "sop_evangelism",
        "title": "Evangelism",
        "author": "Ellen G. White",
        "category": "Evangelism & Prophecy",
        "series": "Evangelism & Church Ministry",
        "onlineUrl": "https://m.egwwritings.org/en/book/35.2",
        "description": "Comprehensive reference manual for public campaigns, city missions, and personal soul-winning.",
    },
    {
        "id": "sop_gospel_workers",
        "title": "Gospel Workers",
        "author": "Ellen G. White",
        "category": "Evangelism & Prophecy",
        "series": "Evangelism & Church Ministry",
        "onlineUrl": "https://m.egwwritings.org/en/book/44.2",
        "description": "Instruction and qualifications for ministers, elders, and leaders in church administration.",
    },
    {
        "id": "sop_christian_service",
        "title": "Christian Service",
        "author": "Ellen G. White",
        "category": "Evangelism & Prophecy",
        "series": "Evangelism & Church Ministry",
        "onlineUrl": "https://m.egwwritings.org/en/book/17.2",
        "description": "Mobilizing every lay member of the Seventh-day Adventist church for personal missionary work.",
    },
    {
        "id": "sop_testimonies_to_ministers",
        "title": "Testimonies to Ministers",
        "author": "Ellen G. White",
        "category": "Evangelism & Prophecy",
        "series": "Evangelism & Church Ministry",
        "onlineUrl": "https://m.egwwritings.org/en/book/142.2",
        "description": "Solemn appeals warning against ecclesiastical domination and lifting up righteousness by faith.",
    },
    {
        "id": "sop_welfare_ministry",
        "title": "Welfare Ministry",
        "author": "Ellen G. White",
        "category": "Evangelism & Prophecy",
        "series": "Evangelism & Church Ministry",
        "onlineUrl": "https://m.egwwritings.org/en/book/146.2",
        "description": "Ministering to the poor, sick, widows, and vulnerable as Christ's loving hands.",
    },
    {
        "id": "sop_pastoral_ministry",
        "title": "Pastoral Ministry",
        "author": "Ellen G. White",
        "category": "Evangelism & Prophecy",
        "series": "Evangelism & Church Ministry",
        "onlineUrl": "https://m.egwwritings.org/en/book/83.2",
        "description": "Counsel for pastors in church governance, visitation, pulpit ministry, and soul winning.",
    },
    {
        "id": "sop_publishing_ministry",
        "title": "The Publishing Ministry",
        "author": "Ellen G. White",
        "category": "Evangelism & Prophecy",
        "series": "Evangelism & Church Ministry",
        "onlineUrl": "https://m.egwwritings.org/en/book/88.2",
        "description": "History, divine purpose, and worldwide reach of Adventist publishing houses and literature.",
    },

    # 📜 Testimonies for the Church (Vols 1 - 9)
    {
        "id": "sop_testimonies_vol1",
        "title": "Testimonies for the Church, Vol. 1",
        "author": "Ellen G. White",
        "category": "Testimonies",
        "series": "Evangelism & Church Ministry",
        "onlineUrl": "https://m.egwwritings.org/en/book/118.2",
        "description": "Early experiences, vision reports, and foundational church development (1855-1868).",
    },
    {
        "id": "sop_testimonies_vol2",
        "title": "Testimonies for the Church, Vol. 2",
        "author": "Ellen G. White",
        "category": "Testimonies",
        "series": "Evangelism & Church Ministry",
        "onlineUrl": "https://m.egwwritings.org/en/book/119.2",
        "description": "Counsels on health reform, sanctification, family duties, and church order (1868-1871).",
    },
    {
        "id": "sop_testimonies_vol3",
        "title": "Testimonies for the Church, Vol. 3",
        "author": "Ellen G. White",
        "category": "Testimonies",
        "series": "Evangelism & Church Ministry",
        "onlineUrl": "https://m.egwwritings.org/en/book/120.2",
        "description": "Christian leadership, institutional integrity, and personal godliness (1872-1875).",
    },
    {
        "id": "sop_testimonies_vol4",
        "title": "Testimonies for the Church, Vol. 4",
        "author": "Ellen G. White",
        "category": "Testimonies",
        "series": "Evangelism & Church Ministry",
        "onlineUrl": "https://m.egwwritings.org/en/book/121.2",
        "description": "Self-denial, sacrificial giving, and missionary enterprises (1876-1881).",
    },
    {
        "id": "sop_testimonies_vol5",
        "title": "Testimonies for the Church, Vol. 5",
        "author": "Ellen G. White",
        "category": "Testimonies",
        "series": "Evangelism & Church Ministry",
        "onlineUrl": "https://m.egwwritings.org/en/book/122.2",
        "description": "The coming crisis, Sunday laws, shaking in the church, and divine guidance (1882-1889).",
    },
    {
        "id": "sop_testimonies_vol6",
        "title": "Testimonies for the Church, Vol. 6",
        "author": "Ellen G. White",
        "category": "Testimonies",
        "series": "Evangelism & Church Ministry",
        "onlineUrl": "https://m.egwwritings.org/en/book/123.2",
        "description": "Christian education, camp meetings, medical evangelism, and tithe fidelity (1900).",
    },
    {
        "id": "sop_testimonies_vol7",
        "title": "Testimonies for the Church, Vol. 7",
        "author": "Ellen G. White",
        "category": "Testimonies",
        "series": "Evangelism & Church Ministry",
        "onlineUrl": "https://m.egwwritings.org/en/book/124.2",
        "description": "Sanitarium establishment, publishing houses, and decentralized organization (1902).",
    },
    {
        "id": "sop_testimonies_vol8",
        "title": "Testimonies for the Church, Vol. 8",
        "author": "Ellen G. White",
        "category": "Testimonies",
        "series": "Evangelism & Church Ministry",
        "onlineUrl": "https://m.egwwritings.org/en/book/125.2",
        "description": "Warning against pantheism, crisis in Battle Creek, and God's essential nature (1904).",
    },
    {
        "id": "sop_testimonies_vol9",
        "title": "Testimonies for the Church, Vol. 9",
        "author": "Ellen G. White",
        "category": "Testimonies",
        "series": "Evangelism & Church Ministry",
        "onlineUrl": "https://m.egwwritings.org/en/book/126.2",
        "description": "The final crisis, city evangelism, health food work, and the triumph of God's church (1909).",
    },

    # ⏳ Prophecy & Historical
    {
        "id": "sop_early_writings",
        "title": "Early Writings",
        "author": "Ellen G. White",
        "category": "Spirit of Prophecy",
        "series": "Prophecy & Historical",
        "onlineUrl": "https://m.egwwritings.org/en/book/50.2",
        "description": "First visions of the heavenly sanctuary, the midnight cry, and the 1858 Great Controversy vision.",
    },
    {
        "id": "sop_last_day_events",
        "title": "Last Day Events",
        "author": "Ellen G. White",
        "category": "Evangelism & Prophecy",
        "series": "Prophecy & Historical",
        "onlineUrl": "https://m.egwwritings.org/en/book/135.2",
        "description": "Compilations outlining the national Sunday law, loud cry, seven last plagues, and Second Coming.",
    },
    {
        "id": "sop_maranatha",
        "title": "Maranatha — The Lord Is Coming",
        "author": "Ellen G. White",
        "category": "Evangelism & Prophecy",
        "series": "Prophecy & Historical",
        "onlineUrl": "https://m.egwwritings.org/en/book/56.2",
        "description": "Devotional insights on closing events, character perfection, and Jesus' soon return.",
    },
    {
        "id": "sop_selected_messages_1",
        "title": "Selected Messages, Book 1",
        "author": "Ellen G. White",
        "category": "Spirit of Prophecy",
        "series": "Prophecy & Historical",
        "onlineUrl": "https://m.egwwritings.org/en/book/90.2",
        "description": "Inspiration of prophets, Christ's human nature, and justification by faith.",
    },
    {
        "id": "sop_selected_messages_2",
        "title": "Selected Messages, Book 2",
        "author": "Ellen G. White",
        "category": "Spirit of Prophecy",
        "series": "Prophecy & Historical",
        "onlineUrl": "https://m.egwwritings.org/en/book/91.2",
        "description": "Spiritualism warnings, faith healing counterfeits, and true revival.",
    },
    {
        "id": "sop_selected_messages_3",
        "title": "Selected Messages, Book 3",
        "author": "Ellen G. White",
        "category": "Spirit of Prophecy",
        "series": "Prophecy & Historical",
        "onlineUrl": "https://m.egwwritings.org/en/book/92.2",
        "description": "Church governance, historical clarifications, and guidance for Christian life.",
    },
    {
        "id": "sop_spiritual_gifts_vol1",
        "title": "Spiritual Gifts, Vol. 1",
        "author": "Ellen G. White",
        "category": "Spirit of Prophecy",
        "series": "Prophecy & Historical",
        "onlineUrl": "https://m.egwwritings.org/en/book/105.2",
        "description": "The original 1858 vision accounts of the great controversy between Christ and Satan.",
    },
    {
        "id": "sop_life_sketches",
        "title": "Life Sketches of Ellen G. White",
        "author": "Ellen G. White",
        "category": "Biographies",
        "series": "Prophecy & Historical",
        "onlineUrl": "https://m.egwwritings.org/en/book/55.2",
        "description": "Her childhood, 1844 disappointment, missionary travels in America, Europe, and Australia.",
    },
]

@sop_bp.route("/books", methods=["GET"])
@sop_bp.route("/", methods=["GET"])
def get_sop_catalog():
    format_arg = request.args.get("format", "").lower()
    accept_header = request.headers.get("Accept", "")
    
    # 🌐 If accessed directly in a web browser without ?format=json, serve the rich HTML page!
    if ("text/html" in accept_header or request.accept_mimetypes.accept_html) and format_arg != "json":
        try:
            return render_template("books.html")
        except Exception:
            pass

    # ⚡ JSON API response for mobile app / Flutter / external APIs
    series = request.args.get("series")
    search = request.args.get("search")

    books = list(SOP_BOOKS)
    if series and series != "All Series":
        books = [b for b in books if b.get("series") == series]

    if search:
        q = search.lower()
        books = [
            b for b in books
            if q in b["title"].lower() or q in b.get("description", "").lower() or q in b.get("series", "").lower()
        ]

    return jsonify({"success": True, "count": len(books), "data": books})
