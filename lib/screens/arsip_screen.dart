import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../services/api_service.dart';
import 'book_details_screen.dart';

class ArsipScreen extends StatefulWidget {
  const ArsipScreen({super.key});

  @override
  State<ArsipScreen> createState() => _ArsipScreenState();
}

class _ArsipScreenState extends State<ArsipScreen> {
  final TextEditingController _searchController = TextEditingController();
  int? selectedGenreId;
  List<dynamic> categories = [];
  List<dynamic> books = [];
  bool isLoadingCategories = true;
  bool isLoadingBooks = true;
  String _sortOption = 'default';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadBooks();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _loadBooks();
    });
  }

  List<dynamic> _sortBooks(List<dynamic> input) {
    final sorted = List<dynamic>.from(input);
    switch (_sortOption) {
      case 'az':
        sorted.sort((a, b) => (a['title'] ?? '').toString().compareTo((b['title'] ?? '').toString()));
        break;
      case 'za':
        sorted.sort((a, b) => (b['title'] ?? '').toString().compareTo((a['title'] ?? '').toString()));
        break;
      case 'rating':
        sorted.sort((a, b) => (double.tryParse(b['rating']?.toString() ?? '0') ?? 0)
            .compareTo(double.tryParse(a['rating']?.toString() ?? '0') ?? 0));
        break;
      case 'views':
        sorted.sort((a, b) => (int.tryParse(b['views']?.toString() ?? '0') ?? 0)
            .compareTo(int.tryParse(a['views']?.toString() ?? '0') ?? 0));
        break;
      default:
        break;
    }
    return sorted;
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('URUTKAN', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.textSlate)),
              const SizedBox(height: 20),
              ...([
                ('default', 'Terbaru (Default)'),
                ('az', 'Judul A → Z'),
                ('za', 'Judul Z → A'),
                ('rating', 'Rating Tertinggi'),
                ('views', 'Paling Banyak Dilihat'),
              ].map((opt) => ListTile(
                leading: Icon(
                  _sortOption == opt.$1 ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                  color: _sortOption == opt.$1 ? AppTheme.primaryBlue : const Color(0xFFCBD5E1),
                ),
                title: Text(opt.$2, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700)),
                onTap: () {
                  setState(() => _sortOption = opt.$1);
                  Navigator.pop(ctx);
                },
              ))),
            ],
          ),
        );
      },
    );
  }

  Future<void> _loadCategories() async {
    try {
      final fetchedCategories = await ApiService.getCategories();
      setState(() {
        categories = fetchedCategories;
        isLoadingCategories = false;
      });
    } catch (e) {
      setState(() => isLoadingCategories = false);
    }
  }

  Future<void> _loadBooks() async {
    setState(() => isLoadingBooks = true);
    try {
      final query = _searchController.text.trim();
      final fetchedBooks = selectedGenreId == null
          ? await ApiService.getBooks(query: query.isEmpty ? null : query)
          : await ApiService.getBooksByGenre(selectedGenreId!);
      setState(() {
        books = fetchedBooks;
        isLoadingBooks = false;
      });
    } catch (e) {
      setState(() => isLoadingBooks = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildHeroSection(),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchAndStats(),
                const SizedBox(height: 32),
                _buildCategoryList(),
                const SizedBox(height: 40),
                _buildBookGrid(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF002E7A), AppTheme.primaryBlue],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Text(
                  'PENGETAHUAN\nTANPA BATAS.',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'TEMUKAN RIBUAN KARYA PREMIUM',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withValues(alpha: 0.6),
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndStats() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onSubmitted: (value) => _loadBooks(),
            decoration: InputDecoration(
              hintText: 'Cari judul, penulis, SKU...',
              border: InputBorder.none,
              icon: Icon(Icons.search_rounded, color: AppTheme.primaryBlue),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear_rounded),
                onPressed: () {
                  _searchController.clear();
                  _loadBooks();
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'MENAMPILKAN ${books.length} HASIL',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF94A3B8),
                letterSpacing: 1,
              ),
            ),
            InkWell(
              onTap: _showSortSheet,
              child: Row(
                children: [
                  Text(
                    'URUTKAN:',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: _sortOption != 'default' ? AppTheme.primaryBlue : const Color(0xFF94A3B8),
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    color: _sortOption != 'default' ? AppTheme.primaryBlue : const Color(0xFF94A3B8),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'KATEGORI',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: AppTheme.textSlate,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: isLoadingCategories
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length + 1,
                  itemBuilder: (context, index) {
                    final bool isAllGenre = index == 0;
                    final dynamic genre = isAllGenre ? null : categories[index - 1];
                    final bool isSelected = isAllGenre ? selectedGenreId == null : selectedGenreId == genre['id'];

                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedGenreId = isAllGenre ? null : genre['id'];
                        });
                        _loadBooks();
                      },
                      child: Container(
                        width: 140,
                        margin: const EdgeInsets.only(right: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? AppTheme.primaryBlue.withValues(alpha: 0.3) : const Color(0xFFF1F5F9),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAllGenre ? 'SEMUA GENRE' : (genre['name'] ?? '').toString().toUpperCase(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: isSelected ? AppTheme.primaryBlue : AppTheme.textSlate,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isAllGenre ? '${categories.fold<int>(0, (sum, item) => sum + (int.tryParse(item['books_count']?.toString() ?? '0') ?? 0))} BUKU' : '${int.tryParse(genre['books_count']?.toString() ?? '0') ?? 0} BUKU',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildBookGrid() {
    if (isLoadingBooks) {
      return const Center(child: CircularProgressIndicator());
    }

    final sorted = _sortBooks(books);

    if (sorted.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Text(
            'Belum ada naskah tersedia.',
            style: GoogleFonts.plusJakartaSans(color: AppTheme.textSlate),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 32,
        crossAxisSpacing: 20,
        childAspectRatio: 0.55,
      ),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final book = sorted[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookDetailsScreen(
                  id: book['id'],
                  title: book['title'] ?? '',
                  author: book['author'] ?? '',
                  genre: book['genre'],
                  coverUrl: book['cover_url'],
                  synopsis: book['synopsis'],
                  views: book['views'] ?? 0,
                  likes: book['likes'] ?? 0,
                  rating: (book['rating'] ?? 0.0).toDouble(),
                ),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        Image.network(
                          book['cover_url'] ?? 'https://via.placeholder.com/200x300',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.book, color: Colors.grey),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Builder(builder: (context) {
                            final createdAt = book['created_at'] != null
                                ? DateTime.tryParse(book['created_at'])
                                : null;
                            final isNew = createdAt != null &&
                                DateTime.now().difference(createdAt).inDays < 7;
                            if (!isNew) return const SizedBox.shrink();
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.accentBlue,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'NEW',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                (book['genre'] ?? 'UMUM').toString().toUpperCase(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primaryBlue,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                book['title'] ?? 'Tanpa Judul',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textSlate,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                book['author'] ?? 'Anonim',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
