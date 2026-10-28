import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../services/firebase_storage_service.dart';

class RequestSellBookScreen extends StatefulWidget {
  const RequestSellBookScreen({super.key});

  @override
  State<RequestSellBookScreen> createState() => _RequestSellBookScreenState();
}

class _RequestSellBookScreenState extends State<RequestSellBookScreen> {
  final _formKey = GlobalKey<FormState>();

  // Seller details
  final _sellerNameController = TextEditingController();
  final _sellerPhoneController = TextEditingController();
  final _sellerEmailController = TextEditingController();
  final _conferenceController = TextEditingController(text: 'Central Kenya Conference');

  // Book details
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _priceController = TextEditingController();
  final _softCopyPriceController = TextEditingController();
  final _softCopyUrlController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pageCountController = TextEditingController(text: '250');
  final _isbnController = TextEditingController();

  String _selectedCategory = AppConstants.bookstoreCategories.first;
  bool _hasHardCopy = true;
  bool _hasSoftCopy = false;

  // Image Upload state
  PlatformFile? _coverImageFile;
  List<PlatformFile> _previewImageFiles = [];
  bool _isSubmitting = false;
  String _uploadStatus = '';

  @override
  void dispose() {
    _sellerNameController.dispose();
    _sellerPhoneController.dispose();
    _sellerEmailController.dispose();
    _conferenceController.dispose();
    _titleController.dispose();
    _authorController.dispose();
    _priceController.dispose();
    _softCopyPriceController.dispose();
    _softCopyUrlController.dispose();
    _descriptionController.dispose();
    _pageCountController.dispose();
    _isbnController.dispose();
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
        _coverImageFile = result.files.first;
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
        _previewImageFiles = result.files;
      });
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_coverImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a cover image for the book.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _uploadStatus = 'Uploading book cover to Firebase Storage bucket...';
    });

    try {
      final storageService = FirebaseStorageService();

      // 1. Upload Cover Image to gs://vine-3e4ab.firebasestorage.app
      String coverUrl = '';
      if (kIsWeb || _coverImageFile!.bytes != null) {
        coverUrl = await storageService.uploadSellerBookImage(
          bytes: _coverImageFile!.bytes,
          fileName: 'cover_${_coverImageFile!.name}',
        );
      } else if (_coverImageFile!.path != null) {
        coverUrl = await storageService.uploadSellerBookImage(
          file: File(_coverImageFile!.path!),
          fileName: 'cover_${_coverImageFile!.name}',
        );
      }

      // 2. Upload Preview Images
      List<String> previewUrls = [];
      for (int i = 0; i < _previewImageFiles.length; i++) {
        setState(() {
          _uploadStatus = 'Uploading preview image ${i + 1} of ${_previewImageFiles.length}...';
        });
        final file = _previewImageFiles[i];
        String previewUrl = '';
        if (kIsWeb || file.bytes != null) {
          previewUrl = await storageService.uploadSellerBookImage(
            bytes: file.bytes,
            fileName: 'preview_${i}_${file.name}',
          );
        } else if (file.path != null) {
          previewUrl = await storageService.uploadSellerBookImage(
            file: File(file.path!),
            fileName: 'preview_${i}_${file.name}',
          );
        }
        if (previewUrl.isNotEmpty) previewUrls.add(previewUrl);
      }

      // 3. Save Book Seller Request to Firestore
      setState(() {
        _uploadStatus = 'Submitting request for Admin approval...';
      });

      final docRef = await FirebaseFirestore.instance.collection('book_seller_requests').add({
        'sellerName': _sellerNameController.text.trim(),
        'sellerPhone': _sellerPhoneController.text.trim(),
        'sellerEmail': _sellerEmailController.text.trim(),
        'conference': _conferenceController.text.trim(),
        'bookTitle': _titleController.text.trim(),
        'author': _authorController.text.trim(),
        'category': _selectedCategory,
        'description': _descriptionController.text.trim(),
        'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'originalPrice': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'hasHardCopy': _hasHardCopy,
        'hasSoftCopy': _hasSoftCopy,
        'softCopyPrice': _hasSoftCopy ? double.tryParse(_softCopyPriceController.text.trim()) : null,
        'softCopyUrl': _hasSoftCopy ? _softCopyUrlController.text.trim() : null,
        'pageCount': int.tryParse(_pageCountController.text.trim()) ?? 250,
        'isbn': _isbnController.text.trim(),
        'coverImageUrl': coverUrl,
        'previewImages': previewUrls,
        'status': 'pending', // pending, approved, rejected
        'submittedAt': FieldValue.serverTimestamp(),
      });

      // 4. Create Notification for Admin
      await FirebaseFirestore.instance.collection('admin_notifications').add({
        'title': 'New Literature Evangelist Book Request',
        'message': '${_sellerNameController.text.trim()} submitted "${_titleController.text.trim()}" for review.',
        'requestId': docRef.id,
        'type': 'seller_request',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 28),
              SizedBox(width: 8),
              Text('Application Submitted!'),
            ],
          ),
          content: const Text(
            'Your request to sell this Literature Evangelism book has been successfully received.\n\n'
            'The ministry administrator has been notified and will verify the theological accuracy and publishing credentials before approving it to appear on the official Harvion Bookstore.',
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(ctx); // Close dialog
                Navigator.pop(context); // Close screen
              },
              child: const Text('DONE'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _uploadStatus = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Request to Sell Books', style: TextStyle(fontWeight: FontWeight.bold)),
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
              // Info Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.volunteer_activism, color: AppTheme.primaryBlue, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Literature Evangelists and SDA book authors can apply to distribute spiritually enriching books through Harvion. All books are reviewed and approved by the administrator.',
                        style: TextStyle(fontSize: 12, height: 1.4, color: AppTheme.primaryBlue),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // SECTION 1: Seller Info
              _buildSectionHeader('1. Colporteur / Seller Information'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sellerNameController,
                decoration: const InputDecoration(labelText: 'Full Name *', prefixIcon: Icon(Icons.person_outline)),
                validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sellerPhoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone Number (M-Pesa enabled) *', prefixIcon: Icon(Icons.phone_outlined)),
                validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sellerEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _conferenceController,
                decoration: const InputDecoration(labelText: 'SDA Conference / Field / Church', prefixIcon: Icon(Icons.church_outlined)),
              ),
              const SizedBox(height: 28),

              // SECTION 2: Book Details
              _buildSectionHeader('2. Literature Evangelism Book Details'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Book Title *', prefixIcon: Icon(Icons.book_outlined)),
                validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(labelText: 'Author Name *', prefixIcon: Icon(Icons.create_outlined)),
                validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Ministry Category', prefixIcon: Icon(Icons.category_outlined)),
                items: AppConstants.bookstoreCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Synopsis & Spiritual Mission *',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _pageCountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Page Count', prefixIcon: Icon(Icons.numbers)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _isbnController,
                      decoration: const InputDecoration(labelText: 'ISBN (Optional)', prefixIcon: Icon(Icons.qr_code)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // SECTION 3: Format & Pricing
              _buildSectionHeader('3. Format & Availability'),
              const SizedBox(height: 8),
              CheckboxListTile(
                title: const Text('Sell Hard Copy (Physical Deliveries)'),
                subtitle: const Text('Printed books sold at church depots or shipped'),
                value: _hasHardCopy,
                activeColor: AppTheme.primaryBlue,
                onChanged: (val) => setState(() => _hasHardCopy = val ?? true),
              ),
              if (_hasHardCopy) ...[
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Hard Copy Price (Ksh) *', prefixIcon: Icon(Icons.money)),
                  validator: (val) => _hasHardCopy && (val == null || val.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
              ],

              CheckboxListTile(
                title: const Text('Sell Soft Copy (Digital PDF / eBook)'),
                subtitle: const Text('Instant reading and digital evangelism access'),
                value: _hasSoftCopy,
                activeColor: AppTheme.primaryGreen,
                onChanged: (val) => setState(() => _hasSoftCopy = val ?? false),
              ),
              if (_hasSoftCopy) ...[
                TextFormField(
                  controller: _softCopyPriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Soft Copy Price (Ksh)', prefixIcon: Icon(Icons.attach_money)),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _softCopyUrlController,
                  decoration: const InputDecoration(labelText: 'Digital Link (Google Drive / EGW Writings / PDF URL)', prefixIcon: Icon(Icons.link)),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 24),

              // SECTION 4: Image Uploads to Firebase Storage Bucket
              _buildSectionHeader('4. Upload Book Cover & Images (Storage Bucket: gs://vine-3e4ab.firebasestorage.app)'),
              const SizedBox(height: 10),

              // Cover Image Button
              InkWell(
                onTap: _pickCoverImage,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _coverImageFile != null ? AppTheme.primaryGreen : Colors.grey.shade300, width: 2),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _coverImageFile != null ? Icons.check_circle : Icons.add_photo_alternate_outlined,
                        color: _coverImageFile != null ? AppTheme.primaryGreen : AppTheme.primaryBlue,
                        size: 32,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _coverImageFile != null ? 'Cover: ${_coverImageFile!.name}' : 'Select Front Cover Image *',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              _coverImageFile != null ? '${(_coverImageFile!.size / 1024).toStringAsFixed(1)} KB' : 'JPG, PNG or WebP',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Preview Images Button
              InkWell(
                onTap: _pickPreviewImages,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.collections_outlined, color: AppTheme.sacredGold, size: 32),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _previewImageFiles.isNotEmpty
                                  ? '${_previewImageFiles.length} preview images selected'
                                  : 'Select Sample Pages & Interior Images (Optional)',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              'Helps buyers examine contents before purchasing',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              if (_isSubmitting) ...[
                Center(
                  child: Column(
                    children: [
                      const CircularProgressIndicator(color: AppTheme.primaryGreen),
                      const SizedBox(height: 12),
                      Text(
                        _uploadStatus,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                        textAlign: TextAlign.center,
                      ),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _submitRequest,
                    child: const Text('SUBMIT BOOK FOR ADMIN APPROVAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
    );
  }
}
