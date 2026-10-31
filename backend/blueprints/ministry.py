import datetime
from flask import Blueprint, request, jsonify
from google.cloud import firestore
from firebase_config import db

ministry_bp = Blueprint("ministry", __name__)

# ============================================================================
# 1. 📖 DAILY DEVOTIONALS
# ============================================================================
@ministry_bp.route("/devotionals", methods=["GET"])
def get_devotionals():
    """Retrieve daily devotionals with scripture and prayer thoughts."""
    try:
        if db is None:
            return jsonify({"success": False, "message": "Database not initialized"}), 503

        docs = db.collection("devotionals").order_by("date", direction="DESCENDING").limit(30).stream()
        data = []
        for d in docs:
            item = d.to_dict()
            item["id"] = d.id
            data.append(item)
        return jsonify({"success": True, "count": len(data), "data": data})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@ministry_bp.route("/devotionals", methods=["POST"])
def post_devotional():
    """Admin endpoint to create a daily devotional."""
    try:
        if db is None:
            return jsonify({"success": False, "message": "Database not initialized"}), 503

        body = request.get_json(silent=True) or {}
        title = body.get("title")
        scripture_ref = body.get("scriptureReference")
        scripture_text = body.get("scriptureText")
        commentary = body.get("commentary")

        if not title or not scripture_ref:
            return jsonify({"success": False, "message": "Title and scriptureReference required."}), 400

        devotional_data = {
            "title": title,
            "scriptureReference": scripture_ref,
            "scriptureText": scripture_text or "",
            "commentary": commentary or "",
            "prayerThought": body.get("prayerThought", "Lord, grant me wisdom to live by Your Word today. Amen."),
            "author": body.get("author", "Ellen G. White"),
            "date": datetime.datetime.now(datetime.timezone.utc),
        }

        update_time, doc_ref = db.collection("devotionals").add(devotional_data)
        return jsonify({"success": True, "message": "Devotional published.", "id": doc_ref.id, "data": devotional_data}), 201
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


# ============================================================================
# 2. 📚 SABBATH SCHOOL LESSONS
# ============================================================================
DEFAULT_SS_LESSONS = [
    {
        "lessonNumber": 1,
        "title": "The Cosmic Conflict and the Character of God",
        "theme": "The Great Controversy Between Christ and Satan",
        "memoryVerse": "And there was war in heaven: Michael and his angels fought against the dragon; and the dragon fought and his angels. — Revelation 12:7",
        "keyScriptures": ["Revelation 12:7-12", "Isaiah 14:12-14", "Ezekiel 28:12-17"],
        "quarter": "Quarterly Study",
        "dayStudies": [
            {"day": "Sabbath Afternoon", "topic": "Introduction to the Conflict"},
            {"day": "Sunday", "topic": "The Origin of Evil in a Perfect Universe"},
            {"day": "Monday", "topic": "Satan's Accusations Against God's Law"},
            {"day": "Tuesday", "topic": "The Cross: Vindication of God's Justice and Love"},
            {"day": "Wednesday", "topic": "The Sanctuary Truth and the Final Judgment"},
            {"day": "Thursday", "topic": "Christ's Victory Over the Powers of Darkness"},
            {"day": "Friday", "topic": "Further Study: Patriarchs and Prophets, ch. 1"}
        ]
    },
    {
        "lessonNumber": 2,
        "title": "The Seal of God and the Mark of the Beast",
        "theme": "God's Final Call in the Three Angels' Messages",
        "memoryVerse": "Hurt not the earth, neither the sea, nor the trees, till we have sealed the servants of our God in their foreheads. — Revelation 7:3",
        "keyScriptures": ["Revelation 7:1-4", "Revelation 14:6-12", "Exodus 20:8-11"],
        "quarter": "Quarterly Study",
        "dayStudies": [
            {"day": "Sabbath Afternoon", "topic": "The Final Test of Loyalty"},
            {"day": "Sunday", "topic": "The Sabbath: Sign of the Creator's Authority"},
            {"day": "Monday", "topic": "The Mark of Apostasy"},
            {"day": "Tuesday", "topic": "The Image to the Beast and Economic Coercion"},
            {"day": "Wednesday", "topic": "The Patience and Faith of the Saints"},
            {"day": "Thursday", "topic": "Standing Firm in the Time of Trouble"},
            {"day": "Friday", "topic": "Further Study: The Great Controversy, ch. 35-36"}
        ]
    },
    {
        "lessonNumber": 3,
        "title": "The Sanctuary and the Cleansing of All Sin",
        "theme": "Christ's High Priestly Ministry",
        "memoryVerse": "And he said unto me, Unto two thousand and three hundred days; then shall the sanctuary be cleansed. — Daniel 8:14",
        "keyScriptures": ["Daniel 8:14", "Hebrews 8:1-6", "Leviticus 16:1-34"],
        "quarter": "Quarterly Study",
        "dayStudies": [
            {"day": "Sabbath Afternoon", "topic": "The Heavenly Sanctuary Model"},
            {"day": "Sunday", "topic": "The Daily and Yearly Services in Shadow"},
            {"day": "Monday", "topic": "The 2300 Days Prophetic Timeline"},
            {"day": "Tuesday", "topic": "1844 and the Investigative Judgment"},
            {"day": "Wednesday", "topic": "Jesus as our Loving Advocate"},
            {"day": "Thursday", "topic": "Total Blotting Out of Sin"},
            {"day": "Friday", "topic": "Further Study: The Great Controversy, ch. 23-24"}
        ]
    }
]

@ministry_bp.route("/sabbath-school", methods=["GET"])
def get_sabbath_school_lessons():
    """Retrieve Sabbath School lessons. Falls back to core study series if collection is unseeded."""
    try:
        if db is None:
            return jsonify({"success": True, "count": len(DEFAULT_SS_LESSONS), "data": DEFAULT_SS_LESSONS})

        docs = list(db.collection("sabbath_school_lessons").order_by("lessonNumber", direction="ASCENDING").stream())
        if not docs:
            return jsonify({"success": True, "count": len(DEFAULT_SS_LESSONS), "data": DEFAULT_SS_LESSONS, "isFallback": True})

        data = []
        for d in docs:
            item = d.to_dict()
            item["id"] = d.id
            data.append(item)
        return jsonify({"success": True, "count": len(data), "data": data})
    except Exception as e:
        return jsonify({"success": True, "count": len(DEFAULT_SS_LESSONS), "data": DEFAULT_SS_LESSONS, "error_fallback": str(e)})


@ministry_bp.route("/sabbath-school", methods=["POST"])
def post_sabbath_school_lesson():
    """Admin endpoint to create or update a Sabbath School lesson."""
    try:
        if db is None:
            return jsonify({"success": False, "message": "Database not initialized"}), 503

        body = request.get_json(silent=True) or {}
        title = body.get("title")
        lesson_num = body.get("lessonNumber")

        if not title or lesson_num is None:
            return jsonify({"success": False, "message": "Title and lessonNumber are required."}), 400

        lesson_data = {
            "lessonNumber": int(lesson_num),
            "title": title,
            "theme": body.get("theme", "Sabbath School Lesson"),
            "memoryVerse": body.get("memoryVerse", ""),
            "keyScriptures": body.get("keyScriptures", []),
            "quarter": body.get("quarter", "Current Quarter"),
            "dayStudies": body.get("dayStudies", []),
            "updatedAt": datetime.datetime.now(datetime.timezone.utc),
        }

        update_time, doc_ref = db.collection("sabbath_school_lessons").add(lesson_data)
        return jsonify({"success": True, "message": "Lesson added successfully.", "id": doc_ref.id}), 201
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


# ============================================================================
# 3. 🙏 PRAYER WALL & INTERCESSION
# ============================================================================
@ministry_bp.route("/prayers", methods=["GET"])
def get_prayers():
    """Retrieve prayer requests with optional category filter."""
    try:
        if db is None:
            return jsonify({"success": False, "message": "Database not initialized"}), 503

        category = request.args.get("category")
        query = db.collection("prayer_requests")
        if category and category != "All":
            query = query.where("category", "==", category)

        docs = query.order_by("datePosted", direction="DESCENDING").limit(50).stream()
        data = []
        for d in docs:
            item = d.to_dict()
            item["id"] = d.id
            data.append(item)
        return jsonify({"success": True, "count": len(data), "data": data})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@ministry_bp.route("/prayers", methods=["POST"])
def post_prayer():
    """Submit a prayer request to the prayer wall."""
    try:
        if db is None:
            return jsonify({"success": False, "message": "Database not initialized"}), 503

        body = request.get_json(silent=True) or {}
        title = body.get("title")
        description = body.get("description")

        if not title or not description:
            return jsonify({"success": False, "message": "Title and description required."}), 400

        is_anon = bool(body.get("isAnonymous", False))
        new_prayer = {
            "authorName": "A Fellow Believer" if is_anon else body.get("authorName", "Anonymous"),
            "isAnonymous": is_anon,
            "title": title,
            "description": description,
            "category": body.get("category", "General"),
            "datePosted": datetime.datetime.now(datetime.timezone.utc),
            "prayerCount": 1,
            "isAnswered": False,
        }

        update_time, doc_ref = db.collection("prayer_requests").add(new_prayer)
        return jsonify({"success": True, "message": "Prayer request submitted.", "id": doc_ref.id, "data": new_prayer}), 201
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@ministry_bp.route("/prayers/<prayer_id>/pray", methods=["POST"])
def increment_prayer_count(prayer_id):
    """Atomically increment the prayer count when a believer intercedes."""
    try:
        if db is None:
            return jsonify({"success": False, "message": "Database not initialized"}), 503

        doc_ref = db.collection("prayer_requests").document(prayer_id)
        doc = doc_ref.get()
        if not doc.exists:
            return jsonify({"success": False, "message": "Prayer request not found"}), 404

        # Atomic increment
        doc_ref.update({"prayerCount": firestore.Increment(1)})
        updated_doc = doc_ref.get()
        new_count = updated_doc.to_dict().get("prayerCount", 1)

        return jsonify({"success": True, "message": "Prayer recorded. God bless your intercession.", "prayerCount": new_count})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


# ============================================================================
# 4. 🔴 LIVESTREAMS (YouTube, TikTok Live, Facebook Live, Sermons)
# ============================================================================
@ministry_bp.route("/livestreams", methods=["GET"])
def get_livestreams():
    """Retrieve active and upcoming livestreams with language and code of conduct."""
    try:
        if db is None:
            return jsonify({"success": False, "message": "Database not initialized"}), 503

        status_filter = request.args.get("status") # 'live', 'scheduled', 'all'
        query = db.collection("livestreams")
        if status_filter and status_filter != "all":
            query = query.where("status", "==", status_filter)

        docs = query.order_by("startTime", direction="DESCENDING").limit(30).stream()
        data = []
        for d in docs:
            item = d.to_dict()
            item["id"] = d.id
            data.append(item)
        return jsonify({"success": True, "count": len(data), "data": data})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@ministry_bp.route("/livestreams", methods=["POST"])
def create_livestream():
    """Add a new live stream (supports TikTok Live, YouTube, Facebook Live, Custom RTMP/HLS).
    Ensures language, presenter, code of conduct, and stream details are specified.
    """
    try:
        if db is None:
            return jsonify({"success": False, "message": "Database not initialized"}), 503

        body = request.get_json(silent=True) or {}
        title = body.get("title")
        stream_url = body.get("streamUrl") or body.get("url")
        speaker = body.get("speaker") or body.get("presenter") or "Gospel Minister"

        if not title or not stream_url:
            return jsonify({"success": False, "message": "Title and streamUrl (or url) are required."}), 400

        platform = body.get("platform", "YouTube")  # YouTube, TikTok Live, Facebook Live, Zoom, Custom
        language = body.get("language", "English")
        code_of_conduct = body.get("codeOfConduct", "Christ-centered Adventist fellowship, reverence, no profanity or spam.")

        livestream_data = {
            "title": title,
            "streamUrl": stream_url,
            "speaker": speaker,
            "platform": platform,
            "language": language,
            "codeOfConduct": code_of_conduct,
            "description": body.get("description", "Join us live for an inspiring sermon and spiritual discussion."),
            "series": body.get("series", "General Ministry"),
            "status": body.get("status", "live"),  # 'live', 'scheduled', 'ended'
            "isLiveStream": True,
            "viewerCount": int(body.get("viewerCount", 0)),
            "thumbnailUrl": body.get("thumbnailUrl", "https://images.unsplash.com/photo-1438232992991-995b7058bbb3?w=800"),
            "startTime": datetime.datetime.now(datetime.timezone.utc),
            "addedBy": body.get("addedBy", "Evangelist / Admin"),
        }

        update_time, doc_ref = db.collection("livestreams").add(livestream_data)
        return jsonify({
            "success": True,
            "message": "Livestream registered successfully. Believers can now join.",
            "id": doc_ref.id,
            "data": livestream_data
        }), 201
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@ministry_bp.route("/livestreams/<stream_id>", methods=["PUT"])
def update_livestream(stream_id):
    """Update livestream details or change status (e.g. mark as ended or live)."""
    try:
        if db is None:
            return jsonify({"success": False, "message": "Database not initialized"}), 503

        doc_ref = db.collection("livestreams").document(stream_id)
        doc = doc_ref.get()
        if not doc.exists:
            return jsonify({"success": False, "message": "Livestream not found"}), 404

        body = request.get_json(silent=True) or {}
        allowed_fields = ["title", "streamUrl", "speaker", "platform", "language", "codeOfConduct", "description", "status", "viewerCount", "thumbnailUrl"]
        updates = {k: v for k, v in body.items() if k in allowed_fields}
        updates["updatedAt"] = datetime.datetime.now(datetime.timezone.utc)

        doc_ref.update(updates)
        return jsonify({"success": True, "message": "Livestream updated successfully.", "id": stream_id})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@ministry_bp.route("/livestreams/<stream_id>", methods=["DELETE"])
def delete_livestream(stream_id):
    """Remove a finished or cancelled livestream."""
    try:
        if db is None:
            return jsonify({"success": False, "message": "Database not initialized"}), 503

        doc_ref = db.collection("livestreams").document(stream_id)
        doc_ref.delete()
        return jsonify({"success": True, "message": "Livestream removed."})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


# ============================================================================
# 5. 🎥 SERMONS & VIDEO ARCHIVE
# ============================================================================
@ministry_bp.route("/sermons", methods=["GET"])
def get_sermons():
    """Retrieve recorded sermons and video series."""
    try:
        if db is None:
            return jsonify({"success": False, "message": "Database not initialized"}), 503

        series = request.args.get("series")
        query = db.collection("sermons")
        if series and series != "All":
            query = query.where("series", "==", series)

        docs = query.order_by("publishedDate", direction="DESCENDING").limit(50).stream()
        data = []
        for d in docs:
            item = d.to_dict()
            item["id"] = d.id
            data.append(item)
        return jsonify({"success": True, "count": len(data), "data": data})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@ministry_bp.route("/sermons", methods=["POST"])
def post_sermon():
    """Publish a recorded sermon, YouTube link, or Google Drive video."""
    try:
        if db is None:
            return jsonify({"success": False, "message": "Database not initialized"}), 503

        body = request.get_json(silent=True) or {}
        title = body.get("title")
        video_url = body.get("videoUrl") or body.get("url")

        if not title or not video_url:
            return jsonify({"success": False, "message": "Title and videoUrl are required."}), 400

        sermon_data = {
            "title": title,
            "videoUrl": video_url,
            "speaker": body.get("speaker", "SDA Minister"),
            "series": body.get("series", "General Sermons"),
            "description": body.get("description", ""),
            "duration": body.get("duration", "45 mins"),
            "publishedDate": datetime.datetime.now(datetime.timezone.utc),
            "mediaType": body.get("mediaType", "video"),
            "isLiveStream": False,
            "thumbnailUrl": body.get("thumbnailUrl", "https://images.unsplash.com/photo-1519791883288-dc8bd696e667?w=800"),
        }

        update_time, doc_ref = db.collection("sermons").add(sermon_data)
        return jsonify({"success": True, "message": "Sermon published successfully.", "id": doc_ref.id, "data": sermon_data}), 201
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


# ============================================================================
# 6. 🥗 ADVENTIST HEALTH & WELLNESS RECIPES
# ============================================================================
DEFAULT_RECIPES = [
    {
        "title": "Hearty Lentil & Root Vegetable Stew",
        "category": "Main Dishes",
        "prepTime": "15 mins",
        "cookTime": "35 mins",
        "servings": 6,
        "ingredients": ["Brown lentils", "Carrots", "Sweet potatoes", "Celery", "Garlic", "Thyme", "Vegetable broth"],
        "instructions": "Simmer lentils and diced vegetables in herb-infused vegetable broth until tender and fragrant. Serve with brown rice.",
        "benefits": "Rich in plant protein, dietary fiber, and immune-supporting antioxidants."
    },
    {
        "title": "High-Fiber Millet & Flax Seed Porridge",
        "category": "Breakfast",
        "prepTime": "5 mins",
        "cookTime": "20 mins",
        "servings": 4,
        "ingredients": ["Whole hulled millet", "Ground flaxseed", "Almond milk", "Pure cinnamon", "Ripe bananas"],
        "instructions": "Toast millet lightly, simmer with almond milk until creamy. Fold in flaxseed and serve warm with sliced fruit.",
        "benefits": "Optimal for sustained morning energy, digestion, and cardiovascular health."
    },
    {
        "title": "Lemon, Fresh Ginger & Garlic Natural Tonic",
        "category": "Natural Remedies",
        "prepTime": "10 mins",
        "cookTime": "10 mins",
        "servings": 2,
        "ingredients": ["Fresh lemon juice", "Grated ginger root", "Crushed garlic clove", "Raw honey", "Warm spring water"],
        "instructions": "Steep grated ginger and garlic in warm water for 10 minutes. Strain, add lemon juice and raw honey. Drink warm.",
        "benefits": "Potent natural antimicrobial support for seasonal respiratory wellness."
    }
]

@ministry_bp.route("/recipes", methods=["GET"])
def get_recipes():
    """Retrieve healthy vegetarian and whole-food recipes."""
    try:
        if db is None:
            return jsonify({"success": True, "count": len(DEFAULT_RECIPES), "data": DEFAULT_RECIPES})

        category = request.args.get("category")
        query = db.collection("healthy_recipes")
        if category and category != "All":
            query = query.where("category", "==", category)

        docs = list(query.stream())
        if not docs:
            return jsonify({"success": True, "count": len(DEFAULT_RECIPES), "data": DEFAULT_RECIPES, "isFallback": True})

        data = []
        for d in docs:
            item = d.to_dict()
            item["id"] = d.id
            data.append(item)
        return jsonify({"success": True, "count": len(data), "data": data})
    except Exception as e:
        return jsonify({"success": True, "count": len(DEFAULT_RECIPES), "data": DEFAULT_RECIPES, "error_fallback": str(e)})


# ============================================================================
# 7. 🏛️ CHURCH DIRECTORY
# ============================================================================
@ministry_bp.route("/churches", methods=["GET"])
def get_churches():
    """Retrieve Seventh-day Adventist churches by city or conference."""
    try:
        if db is None:
            return jsonify({"success": False, "message": "Database not initialized"}), 503

        city = request.args.get("city")
        query = db.collection("churches_directory")
        if city and city != "All":
            query = query.where("city", "==", city)

        docs = query.stream()
        data = []
        for d in docs:
            item = d.to_dict()
            item["id"] = d.id
            data.append(item)
        return jsonify({"success": True, "count": len(data), "data": data})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


# ============================================================================
# 8. 📜 DIGITAL MISSIONARY TRACTS
# ============================================================================
DEFAULT_TRACTS = [
    {
        "title": "The Final Crisis and the Seal of God",
        "category": "Prophecy",
        "summary": "Discover the prophetic significance of the Three Angels' Messages and how God prepares His people for the final events.",
        "author": "HARVION Publishing",
        "readTime": "6 mins",
        "downloadUrl": "https://harvion.org/tracts/final_crisis.pdf"
    },
    {
        "title": "Why the Seventh-day Sabbath Matters Today",
        "category": "Doctrine",
        "summary": "A Biblical journey exploring why the Sabbath is God's eternal memorial of Creation and Redemption from Eden to Eternity.",
        "author": "HARVION Publishing",
        "readTime": "8 mins",
        "downloadUrl": "https://harvion.org/tracts/seventh_day_sabbath.pdf"
    },
    {
        "title": "Steps to Spiritual Peace and Victory",
        "category": "Christian Living",
        "summary": "How to experience real forgiveness, overcoming power in Jesus, and daily communion through the Holy Spirit.",
        "author": "HARVION Publishing",
        "readTime": "5 mins",
        "downloadUrl": "https://harvion.org/tracts/spiritual_peace.pdf"
    }
]

@ministry_bp.route("/tracts", methods=["GET"])
def get_tracts():
    """Retrieve digital missionary sharing tracts."""
    try:
        if db is None:
            return jsonify({"success": True, "count": len(DEFAULT_TRACTS), "data": DEFAULT_TRACTS})

        docs = list(db.collection("digital_tracts").stream())
        if not docs:
            return jsonify({"success": True, "count": len(DEFAULT_TRACTS), "data": DEFAULT_TRACTS, "isFallback": True})

        data = []
        for d in docs:
            item = d.to_dict()
            item["id"] = d.id
            data.append(item)
        return jsonify({"success": True, "count": len(data), "data": data})
    except Exception as e:
        return jsonify({"success": True, "count": len(DEFAULT_TRACTS), "data": DEFAULT_TRACTS, "error_fallback": str(e)})


# ============================================================================
# 9. 🏡 8 PILLARS OF THE ADVENTIST HOME
# ============================================================================
DEFAULT_FAMILY_PILLARS = [
    {"orderIndex": 1, "title": "Christ-Centered Marriage", "description": "Founded upon selfless agape love, mutual respect, and lifelong sacred covenant."},
    {"orderIndex": 2, "title": "The Family Altar & Worship", "description": "Daily morning and evening prayer, thanksgiving, and study of God's Word in the home circle."},
    {"orderIndex": 3, "title": "Sabbath Sanctification", "description": "Welcoming the sacred Sabbath hours as a delightful family memorial of God's creation and rest."},
    {"orderIndex": 4, "title": "Health Reform & Temperance", "description": "Pure plant-based nutrition, pure water, fresh air, physical activity, and total temperance."},
    {"orderIndex": 5, "title": "Christian Education & Character", "description": "Training the youth for high calling and service in the kingdom of God."},
    {"orderIndex": 6, "title": "Stewardship & Simple Living", "description": "Faithful tithes, offerings, debt-free living, and generous support of the gospel."},
    {"orderIndex": 7, "title": "Modesty & Moral Purity", "description": "Pure language, guard of the avenues of the soul, modesty in dress and lifestyle."},
    {"orderIndex": 8, "title": "Mission & Evangelism from Home", "description": "The Christian family shining as an evangelistic lighthouse to the neighborhood."}
]

@ministry_bp.route("/family-pillars", methods=["GET"])
def get_family_pillars():
    """Retrieve the 8 Pillars of the Adventist Home."""
    try:
        if db is None:
            return jsonify({"success": True, "count": len(DEFAULT_FAMILY_PILLARS), "data": DEFAULT_FAMILY_PILLARS})

        docs = list(db.collection("family_pillars").order_by("orderIndex").stream())
        if not docs:
            return jsonify({"success": True, "count": len(DEFAULT_FAMILY_PILLARS), "data": DEFAULT_FAMILY_PILLARS, "isFallback": True})

        data = []
        for d in docs:
            item = d.to_dict()
            item["id"] = d.id
            data.append(item)
        return jsonify({"success": True, "count": len(data), "data": data})
    except Exception as e:
        return jsonify({"success": True, "count": len(DEFAULT_FAMILY_PILLARS), "data": DEFAULT_FAMILY_PILLARS, "error_fallback": str(e)})
