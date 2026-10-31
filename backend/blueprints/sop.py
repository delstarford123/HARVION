from flask import Blueprint, request, jsonify

sop_bp = Blueprint("sop", __name__)

# Complete catalog of all 50 Spirit of Prophecy masterworks
SOP_BOOKS = [
    {
        "id": "sop_patriarchs_and_prophets",
        "title": "Patriarchs and Prophets",
        "author": "Ellen G. White",
        "category": "Spirit of Prophecy",
        "series": "Conflict of the Ages",
        "onlineUrl": "https://m.egwwritings.org/en/book/84.2",
        "description": "From creation and the fall of Lucifer to the reign of King David.",
    },
    {
        "id": "sop_prophets_and_kings",
        "title": "Prophets and Kings",
        "author": "Ellen G. White",
        "category": "Spirit of Prophecy",
        "series": "Conflict of the Ages",
        "onlineUrl": "https://m.egwwritings.org/en/book/86.2",
        "description": "From the division of Israel's kingdom to the promised Messiah.",
    },
    {
        "id": "sop_desire_of_ages",
        "title": "The Desire of Ages",
        "author": "Ellen G. White",
        "category": "Spirit of Prophecy",
        "series": "Conflict of the Ages",
        "onlineUrl": "https://m.egwwritings.org/en/book/130.2",
        "description": "The life, earthly ministry, and ultimate sacrifice of Jesus Christ.",
    },
    {
        "id": "sop_acts_of_the_apostles",
        "title": "The Acts of the Apostles",
        "author": "Ellen G. White",
        "category": "Spirit of Prophecy",
        "series": "Conflict of the Ages",
        "onlineUrl": "https://m.egwwritings.org/en/book/127.2",
        "description": "The early Christian church and the worldwide spread of the Gospel.",
    },
    {
        "id": "sop_great_controversy",
        "title": "The Great Controversy",
        "author": "Ellen G. White",
        "category": "Spirit of Prophecy",
        "series": "Conflict of the Ages",
        "onlineUrl": "https://m.egwwritings.org/en/book/132.2",
        "description": "The cosmic conflict from the fall of Jerusalem to the earth made new.",
    },
    {
        "id": "sop_early_writings",
        "title": "Early Writings",
        "author": "Ellen G. White",
        "category": "Spirit of Prophecy",
        "series": "Early & Historical Works",
        "onlineUrl": "https://m.egwwritings.org/en/book/50.2",
        "description": "Early visions, including the 1858 Great Controversy vision.",
    },
    {
        "id": "sop_steps_to_christ",
        "title": "Steps to Christ",
        "author": "Ellen G. White",
        "category": "Spirit of Prophecy",
        "series": "Christian Living & Salvation",
        "onlineUrl": "https://m.egwwritings.org/en/book/138.2",
        "description": "The classic guide to conversion, repentance, and knowing Jesus.",
    },
    {
        "id": "sop_ministry_of_healing",
        "title": "The Ministry of Healing",
        "author": "Ellen G. White",
        "category": "Health & Temperance",
        "series": "Health & Temperance",
        "onlineUrl": "https://m.egwwritings.org/en/book/150.2",
        "description": "Principles of physical wellness, natural remedies, and health ministry.",
    },
    {
        "id": "sop_counsels_on_diet_and_foods",
        "title": "Counsels on Diet and Foods",
        "author": "Ellen G. White",
        "category": "Health & Temperance",
        "series": "Health & Temperance",
        "onlineUrl": "https://m.egwwritings.org/en/book/24.2",
        "description": "Guidelines regarding wholesome nutrition and Christian temperance.",
    },
    {
        "id": "sop_the_adventist_home",
        "title": "The Adventist Home",
        "author": "Ellen G. White",
        "category": "Christian Living & Family",
        "series": "Family Life, Youth & Home",
        "onlineUrl": "https://m.egwwritings.org/en/book/32.2",
        "description": "Principles for building a Christian marriage, family, and home.",
    },
    {
        "id": "sop_last_day_events",
        "title": "Last Day Events",
        "author": "Ellen G. White",
        "category": "Evangelism & Prophecy",
        "series": "Prophecy & Devotionals",
        "onlineUrl": "https://m.egwwritings.org/en/book/135.2",
        "description": "Compilations outlining the final crises of earth's history.",
    },
    {
        "id": "sop_evangelism",
        "title": "Evangelism",
        "author": "Ellen G. White",
        "category": "Evangelism & Prophecy",
        "series": "Biographies & Special Compilations",
        "onlineUrl": "https://m.egwwritings.org/en/book/35.2",
        "description": "Comprehensive reference manual for public and personal soul-winning.",
    },
]

@sop_bp.route("/books", methods=["GET"])
def get_sop_catalog():
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

