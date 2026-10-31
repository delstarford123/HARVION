import datetime
from flask import Blueprint, request, jsonify
from firebase_config import db

books_bp = Blueprint("books", __name__)
COLLECTION = "bookstore_items"

@books_bp.route("", methods=["GET"])
@books_bp.route("/", methods=["GET"])
def get_books():
    try:
        category = request.args.get("category")
        language = request.args.get("language")
        format_param = request.args.get("format")
        search = request.args.get("search")
        max_price = request.args.get("maxPrice")

        if db is None:
            return jsonify({"success": False, "message": "Database not initialized"}), 503

        query = db.collection(COLLECTION)

        if category and category != "All Categories":
            query = query.where("category", "==", category)
        if language:
            query = query.where("language", "==", language)
        if format_param:
            query = query.where("format", "==", format_param)

        docs = query.stream()
        books = []
        for doc in docs:
            b_data = doc.to_dict()
            b_data["id"] = doc.id
            books.append(b_data)

        if search:
            q = search.lower()
            books = [
                b for b in books
                if (b.get("title") and q in b["title"].lower())
                or (b.get("author") and q in b["author"].lower())
                or (b.get("description") and q in b["description"].lower())
            ]

        if max_price:
            try:
                mp = float(max_price)
                books = [b for b in books if b.get("price", 0) <= mp]
            except ValueError:
                pass

        return jsonify({"success": True, "count": len(books), "data": books})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@books_bp.route("/<book_id>", methods=["GET"])
def get_book_by_id(book_id):
    try:
        if db is None:
            return jsonify({"success": False, "message": "Database not initialized"}), 503

        doc = db.collection(COLLECTION).document(book_id).get()
        if not doc.exists:
            return jsonify({"success": False, "message": "Book not found"}), 404

        data = doc.to_dict()
        data["id"] = doc.id
        return jsonify({"success": True, "data": data})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@books_bp.route("", methods=["POST"])
@books_bp.route("/", methods=["POST"])
def add_book():
    try:
        if db is None:
            return jsonify({"success": False, "message": "Database not initialized"}), 503

        body = request.get_json(silent=True) or {}
        title = body.get("title")
        price = body.get("price")

        if not title or price is None:
            return jsonify({"success": False, "message": "Title and price are required."}), 400

        new_book = {
            "title": title,
            "author": body.get("author", "Ellen G. White"),
            "category": body.get("category", "Spirit of Prophecy"),
            "description": body.get("description", ""),
            "price": float(price),
            "originalPrice": float(body.get("originalPrice", price)),
            "format": body.get("format", "Paperback"),
            "language": body.get("language", "English"),
            "coverImageUrl": body.get("coverImageUrl", ""),
            "inStock": bool(body.get("inStock", True)),
            "pageCount": int(body.get("pageCount", 300)),
            "rating": float(body.get("rating", 5.0)),
            "isbn": body.get("isbn", ""),
            "isFeatured": bool(body.get("isFeatured", False)),
            "colporteurCommissionNote": body.get("colporteurCommissionNote"),
            "createdAt": datetime.datetime.now(datetime.timezone.utc),
        }

        update_time, doc_ref = db.collection(COLLECTION).add(new_book)
        new_book["id"] = doc_ref.id
        new_book["createdAt"] = new_book["createdAt"].isoformat()

        return jsonify({"success": True, "id": doc_ref.id, "data": new_book}), 201
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@books_bp.route("/<book_id>", methods=["PUT"])
def update_book(book_id):
    try:
        if db is None:
            return jsonify({"success": False, "message": "Database not initialized"}), 503

        body = request.get_json(silent=True) or {}
        doc_ref = db.collection(COLLECTION).document(book_id)
        doc = doc_ref.get()

        if not doc.exists:
            return jsonify({"success": False, "message": "Book not found"}), 404

        update_data = {}
        for k in ["title", "author", "category", "description", "price", "originalPrice", "format", "language", "coverImageUrl", "inStock", "pageCount", "rating", "isbn", "isFeatured"]:
            if k in body:
                update_data[k] = body[k]

        update_data["updatedAt"] = datetime.datetime.now(datetime.timezone.utc)
        doc_ref.update(update_data)

        return jsonify({"success": True, "message": "Book updated successfully."})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@books_bp.route("/<book_id>", methods=["DELETE"])
def delete_book(book_id):
    try:
        if db is None:
            return jsonify({"success": False, "message": "Database not initialized"}), 503

        db.collection(COLLECTION).document(book_id).delete()
        return jsonify({"success": True, "message": "Book deleted successfully."})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

