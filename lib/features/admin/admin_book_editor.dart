import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../services/firebase_storage_service.dart';
import '../bookstore/models/physical_book_model.dart';

class AdminBookEditorScreen extends StatefulWidget {
  final PhysicalBook? bookToEdit;

  const AdminBookEditorScreen({super.key, this.bookToEdit});

  @override
  State<AdminBookEditorScreen> createState() => _AdminBookEditorScreenState();
}

class _AdminBookEditorScreenState extends State<AdminBookEditorScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _priceController;
  late TextEditingController _originalPriceController;
  late TextEditingController _softCopyPriceController;
  late TextEditingController _softCopyUrlController;
  late TextEditingController _descriptionController;
  late TextEditingController _pageCountController;
  late TextEditingController _isbnController;
  late TextEditingController _commissionNoteController;

  late String _selectedCategory;
  late String _selectedLanguage;
  late String _selectedFormat;
  late bool _hasHardCopy;
  late bool _hasSoftCopy;
  late bool _inStock;
  late bool _isFeatured;

  String _coverImageUrl = '';
  List<String> _previewImages = [];

  PlatformFile? _newCoverFile;
  List<PlatformFile> _newPreviewFiles = [];
  bool _isUploading = false;
  String _uploadStatus = '';

  @override
  void initState() {
    super.initState();
    final b = widget.bookToEdit;

    _titleController = TextEditingController(text: b?.title ?? '');
    _authorController = TextEditingController(text: b?.author ?? 'Ellen G. White');
    _priceController = TextEditingController(text: b != null ? b.price.toInt().toString() : '850');
    _originalPriceController = TextEditingController(text: b != null ? b.originalPrice.toInt().toString() : '1000');
    _softCopyPriceController = TextEditingController(text: b?.softCopyPrice != null ? b!.softCopyPrice!.toInt().toString() : '350');
    _softCopyUrlController = TextEditingController(text: b?.softCopyUrl ?? '');
    _descriptionController = TextEditingController(text: b?.description ?? '');
    _pageCountController = TextEditingController(text: b != null ? b.pageCount.toString() : '350');
    _isbnController = TextEditingController(text: b?.isbn ?? '978-1-58325-102-1');
    _commissionNoteController = TextEditingController(text: b?.colporteurCommissionNote ?? 'Earn 25% commission');

    _selectedCategory = b?.category ?? AppConstants.bookstoreCategories.first;
    _selectedLanguage = b?.language ?? 'English';
    _selectedFormat = b?.format ?? 'Paperback & Soft Copy';
    _hasHardCopy = b?.hasHardCopy ?? true;
    _hasSoftCopy = b?.hasSoftCopy ?? true;
    _inStock = b?.inStock ?? true;
    _isFeatured = b?.isFeatured ?? false;
    _coverImageUrl = b?.coverImageUrl ?? '';
    _previewImages = b?.previewImages != null ? List.from(b!.previewImages) : [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _softCopyPriceController.dispose();
    _softCopyUrlController.dispose();
    _descriptionController.dispose();
    _pageCountController.dispose();
    _isbnController.dispose();
    _commissionNoteController.dispose();
    super.dispose();
  }

  Future<void> _pickCoverImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _newCoverFile = result.files.first;
      });
    }
  }

  Future<void> _pickPreviewImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
      allowMultiple: true,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _newPreviewFiles.addAll(result.files);
      });
    }
  }

  Future<void> _saveBook() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUploading = true;
      _uploadStatus = 'Saving book to literature catalog...';
    });

    try {
      final storage = FirebaseStorageService();

      // 1. Upload new cover if picked
      if (_newCoverFile != null) {
        setState(() => _uploadStatus = 'Uploading book cover to Firebase Storage bucket...');
        if (kIsWeb || _newCoverFile!.bytes != null) {
          _coverImageUrl = await storage.uploadBookCover(
            bytes: _newCoverFile!.bytes,
            fileName: _newCoverFile!.name,
          );
        } else if (_newCoverFile!.path != null) {
          _coverImageUrl = await storage.uploadBookCover(
            file: File(_newCoverFile!.path!),
            fileName: _newCoverFile!.name,
          );
        }
      }

      // 2. Upload new preview images if picked
      for (int i = 0; i < _newPreviewFiles.length; i++) {
        setState(() => _uploadStatus = 'Uploading preview page ${i + 1} of ${_newPreviewFiles.length}...');
        final file = _newPreviewFiles[i];
        String previewUrl = '';
        if (kIsWeb || file.bytes != null) {
          previewUrl = await storage.uploadBookPreviewImage(
            bytes: file.bytes,
            fileName: file.name,
          );
        } else if (file.path != null) {
          previewUrl = await storage.uploadBookPreviewImage(
            file: File(file.path!),
            fileName: file.name,
          );
        }
        if (previewUrl.isNotEmpty) _previewImages.add(previewUrl);
      }

      // 3. Prepare book data
      final bookData = {
        'title': _titleController.text.trim(),
        'author': _authorController.text.trim(),
        'category': _selectedCategory,
        'description': _descriptionController.text.trim(),
        'price': double.tryParse(_priceController.text.trim()) ?? 850.0,
        'originalPrice': double.tryParse(_originalPriceController.text.trim()) ?? 1000.0,
        'format': _selectedFormat,
        'language': _selectedLanguage,
        'coverImageUrl': _coverImageUrl,
        'previewImages': _previewImages,
        'inStock': _inStock,
        'pageCount': int.tryParse(_pageCountController.text.trim()) ?? 350,
        'rating': 5.0,
        'isbn': _isbnController.text.trim(),
        'isFeatured': _isFeatured,
        'colporteurCommissionNote': _commissionNoteController.text.trim(),
        'hasHardCopy': _hasHardCopy,
        'hasSoftCopy': _hasSoftCopy,
        'softCopyPrice': _hasSoftCopy ? double.tryParse(_softCopyPriceController.text.trim()) : null,
        'softCopyUrl': _hasSoftCopy ? _softCopyUrlController.text.trim() : null,
        'isApproved': true,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (widget.bookToEdit != null) {
        await FirebaseFirestore.instance
            .collection('bookstore_items')
            .doc(widget.bookToEdit!.id)
            .update(bookData);
      } else {
        bookData['createdAt'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance.collection('bookstore_items').add(bookData);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.bookToEdit != null ? 'Book updated successfully!' : 'New book published to catalog!'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadStatus = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.bookToEdit != null;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Literature Evangelism Book' : 'Add New Book',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title & Author
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Book Title *', prefixIcon: Icon(Icons.book)),
                validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(labelText: 'Author Name *', prefixIcon: Icon(Icons.person)),
                validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              // Category & Language
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: AppConstants.bookstoreCategories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12)))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCategory = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedLanguage,
                      decoration: const InputDecoration(labelText: 'Language'),
                      items: AppConstants.bookLanguages.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedLanguage = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description / Mission *', alignLabelWithHint: true),
                validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Hard Copy Options
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Hard Copy Available', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Printed physical copies distributed to buyers'),
                value: _hasHardCopy,
                activeColor: AppTheme.primaryBlue,
                onChanged: (val) => setState(() => _hasHardCopy = val ?? true),
              ),
              if (_hasHardCopy) ...[
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Price (Ksh) *'),
                        validator: (val) => _hasHardCopy && (val == null || val.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _originalPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Original Price (for discount)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Soft Copy Options
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Soft Copy (Digital PDF / eBook)', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Immediate reading access and downloadable PDF'),
                value: _hasSoftCopy,
                activeColor: AppTheme.primaryGreen,
                onChanged: (val) => setState(() => _hasSoftCopy = val ?? false),
              ),
              if (_hasSoftCopy) ...[
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _softCopyPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Soft Copy Price (Ksh)'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _softCopyUrlController,
                        decoration: const InputDecoration(labelText: 'PDF / EGW Writings Link'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Colporteur Commission & Stock
              TextFormField(
                controller: _commissionNoteController,
                decoration: const InputDecoration(labelText: 'Colporteur Commission Note (e.g. Earn Ksh 200 per copy)'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('In Stock'),
                      value: _inStock,
                      activeColor: AppTheme.primaryGreen,
                      onChanged: (val) => setState(() => _inStock = val ?? true),
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Featured Book'),
                      value: _isFeatured,
                      activeColor: AppTheme.sacredGold,
                      onChanged: (val) => setState(() => _isFeatured = val ?? false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Firebase Storage Upload Section
              const Text(
                'Book Images & Cover (gs://vine-3e4ab.firebasestorage.app)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryBlue),
              ),
              const SizedBox(height: 8),

              // Cover Image Button
              InkWell(
                onTap: _pickCoverImage,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _newCoverFile != null ? AppTheme.primaryGreen : Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _newCoverFile != null || _coverImageUrl.isNotEmpty ? Icons.check_circle : Icons.image,
                        color: _newCoverFile != null || _coverImageUrl.isNotEmpty ? AppTheme.primaryGreen : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _newCoverFile != null
                              ? 'New Cover: ${_newCoverFile!.name}'
                              : (_coverImageUrl.isNotEmpty ? 'Current Cover Image Set' : 'Select Book Cover Image'),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Text('Change', style: TextStyle(color: AppTheme.primaryBlue, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Preview Images Button
              InkWell(
                onTap: _pickPreviewImages,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.collections, color: AppTheme.sacredGold),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${_previewImages.length + _newPreviewFiles.length} Preview / Inside Page Images',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Text('Add More', style: TextStyle(color: AppTheme.primaryBlue, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Save Button
              if (_isUploading) ...[
                Center(
                  child: Column(
                    children: [
                      const CircularProgressIndicator(color: AppTheme.primaryGreen),
                      const SizedBox(height: 10),
                      Text(_uploadStatus, style: const TextStyle(fontSize: 12, color: AppTheme.primaryBlue)),
                    ],
                  ),
                ),
              ] else
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _saveBook,
                    child: Text(
                      isEditing ? 'UPDATE BOOK DETAILS' : 'SAVE & PUBLISH BOOK',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
