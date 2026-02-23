import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../theme.dart';
import '../services/api_service.dart';

class WriteScreen extends StatefulWidget {
  final Map<String, dynamic>? book;
  const WriteScreen({super.key, this.book});

  @override
  State<WriteScreen> createState() => _WriteScreenState();
}

class _WriteScreenState extends State<WriteScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _synopsisController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  
  List<dynamic> _genres = [];
  int? _selectedGenreId;
  String _status = 'draft';
  XFile? _selectedImage;
  bool _isLoadingGenres = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadGenres();
    if (widget.book != null) {
      _loadBookDetails();
    }
  }

  Future<void> _loadBookDetails() async {
    setState(() => _isSubmitting = true);
    try {
      final bookId = int.tryParse(widget.book!['id'].toString());
      if (bookId != null) {
        final details = await ApiService.getBookDetails(bookId);
        setState(() {
          _titleController.text = details['title'] ?? '';
          _synopsisController.text = details['synopsis'] ?? '';
          _contentController.text = details['content'] ?? '';
          _selectedGenreId = _genres.indexWhere((g) => g['name'] == details['genre']) != -1 
              ? _genres.firstWhere((g) => g['name'] == details['genre'])['id']
              : details['genre_id'];
          _status = details['status'] ?? 'draft';
          // Cover URL is not easily converted back to File, so we just show the URL preview if possible
          // or leave it as null (user can choose a new one)
        });
      }
    } catch (e) {
      debugPrint('Error loading book details: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _synopsisController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadGenres() async {
    try {
      final fetchedGenres = await ApiService.getCategories();
      setState(() {
        _genres = fetchedGenres;
        if (_genres.isNotEmpty) {
          _selectedGenreId = _genres[0]['id'];
        }
        _isLoadingGenres = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingGenres = false);
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _saveDraft() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul wajib diisi untuk menyimpan draft')),
      );
      return;
    }
    if (_selectedGenreId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih genre terlebih dahulu')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      if (widget.book != null) {
        await ApiService.updateBook(
          id: int.parse(widget.book!['id'].toString()),
          title: _titleController.text,
          genreId: _selectedGenreId!,
          synopsis: _synopsisController.text.isEmpty ? '-' : _synopsisController.text,
          content: _contentController.text.isEmpty ? '-' : _contentController.text,
          status: 'draft',
          coverPath: _selectedImage?.path,
        );
      } else {
        await ApiService.createBook(
          title: _titleController.text,
          genreId: _selectedGenreId!,
          synopsis: _synopsisController.text.isEmpty ? '-' : _synopsisController.text,
          content: _contentController.text.isEmpty ? '-' : _contentController.text,
          status: 'draft',
          coverPath: _selectedImage?.path,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Berhasil disimpan ke Draft!'),
            backgroundColor: Color(0xFF22C55E),
          ),
        );
        if (widget.book != null) {
           Navigator.pop(context);
        } else {
           _clearForm();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitBook() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGenreId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih genre terlebih dahulu')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      if (widget.book != null) {
        await ApiService.updateBook(
          id: int.parse(widget.book!['id'].toString()),
          title: _titleController.text,
          genreId: _selectedGenreId!,
          synopsis: _synopsisController.text,
          content: _contentController.text,
          status: _status,
          coverPath: _selectedImage?.path,
        );
      } else {
        await ApiService.createBook(
          title: _titleController.text,
          genreId: _selectedGenreId!,
          synopsis: _synopsisController.text,
          content: _contentController.text,
          status: _status,
          coverPath: _selectedImage?.path,
        );
      }

      if (mounted) {
        String msg = '✅ Berhasil!';
        if (widget.book != null) {
          msg = '✅ Karya berhasil diperbarui dan sedang ditinjau!';
        } else {
          msg = _status == 'published' 
              ? '🚀 Karya berhasil diajukan & menunggu moderasi!' 
              : '📝 Karya disimpan sebagai Draft!';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppTheme.primaryBlue),
        );
        if (widget.book != null) {
          Navigator.pop(context);
        } else {
          _clearForm();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _clearForm() {
    _titleController.clear();
    _synopsisController.clear();
    _contentController.clear();
    setState(() {
      _selectedImage = null;
      _status = 'draft';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundSlate,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.book != null ? 'EDIT KARYA' : 'MULAI MENULIS',
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: AppTheme.textSlate,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_isSubmitting)
            const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2)))
          else
            TextButton(
              onPressed: _saveDraft,
              child: Text(
                'SIMPAN',
                style: GoogleFonts.plusJakartaSans(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoadingGenres 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImagePicker(),
                const SizedBox(height: 32),
                _buildLabel('JUDUL KARYA'),
                _buildTextField('Masukkan judul yang menarik...', controller: _titleController, maxLines: 1),
                const SizedBox(height: 24),
                _buildLabel('GENRE / KATEGORI'),
                _buildGenreDropdown(),
                const SizedBox(height: 24),
                _buildLabel('SINOPSIS SINGKAT'),
                _buildTextField('Berikan gambaran singkat tentang ceritamu...', controller: _synopsisController, maxLines: 3),
                const SizedBox(height: 24),
                _buildLabel('ISI CERITA'),
                _buildTextField('Mulai ketikkan mahakaryamu di sini...', controller: _contentController, maxLines: 12),
                const SizedBox(height: 32),
                _buildLabel('STATUS PUBLIKASI'),
                _buildStatusPicker(),
                const SizedBox(height: 48),
                _buildSubmitButton(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF94A3B8),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, {required TextEditingController controller, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13),
          contentPadding: const EdgeInsets.all(20),
          border: InputBorder.none,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Bagian ini wajib diisi';
          return null;
        },
      ),
    );
  }

  Widget _buildImagePicker() {
    return InkWell(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          image: _selectedImage != null 
            ? DecorationImage(image: FileImage(File(_selectedImage!.path)), fit: BoxFit.cover) 
            : (widget.book?['cover_url'] != null 
                ? DecorationImage(image: NetworkImage(widget.book!['cover_url']), fit: BoxFit.cover)
                : null),
        ),
        child: _selectedImage == null && widget.book?['cover_url'] == null ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_photo_alternate_rounded, color: AppTheme.primaryBlue, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              widget.book != null ? 'GANTI SAMPUL BUKU' : 'UNGGAH SAMPUL BUKU',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: AppTheme.primaryBlue,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Rasio 2:3 direkomendasikan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ) : null,
      ),
    );
  }

  Widget _buildGenreDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedGenreId,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8)),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSlate,
          ),
          onChanged: (int? newValue) {
            setState(() {
              _selectedGenreId = newValue;
            });
          },
          items: _genres.map<DropdownMenuItem<int>>((dynamic genre) {
            return DropdownMenuItem<int>(
              value: genre['id'],
              child: Text(genre['name'] ?? 'Unknown'),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatusPicker() {
    return Row(
      children: [
        Expanded(
          child: _buildStatusCard('draft', 'DRAFT', Icons.edit_note_rounded),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatusCard('published', 'PUBLISH', Icons.rocket_launch_rounded),
        ),
      ],
    );
  }

  Widget _buildStatusCard(String value, String label, IconData icon) {
    final isSelected = _status == value;
    return InkWell(
      onTap: () => setState(() => _status = value),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.transparent : const Color(0xFFF1F5F9),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        onPressed: _isSubmitting ? null : _submitBook,
        child: Text(
          _isSubmitting 
              ? 'MEMPROSES...' 
              : widget.book != null ? 'SIMPAN PERUBAHAN' : (_status == 'published' ? 'PUBLIKASKAN KARYA' : 'SIMPAN SEBAGAI DRAFT'),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}
