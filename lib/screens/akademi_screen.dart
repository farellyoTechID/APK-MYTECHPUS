import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../services/api_service.dart';
import 'video_details_screen.dart';

class AkademiScreen extends StatefulWidget {
  const AkademiScreen({super.key});

  @override
  State<AkademiScreen> createState() => _AkademiScreenState();
}

class _AkademiScreenState extends State<AkademiScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _genres = [];
  List<dynamic> _videos = [];
  int? _selectedGenreId;
  bool _isLoading = true;
  String _sortOption = 'default'; // 'default', 'az', 'za', 'beginner', 'advanced'
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadData();
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
      _loadData();
    });
  }

  List<dynamic> _sortVideos(List<dynamic> videos) {
    final sorted = List<dynamic>.from(videos);
    switch (_sortOption) {
      case 'az':
        sorted.sort((a, b) => (a['title'] ?? '').toString().compareTo((b['title'] ?? '').toString()));
        break;
      case 'za':
        sorted.sort((a, b) => (b['title'] ?? '').toString().compareTo((a['title'] ?? '').toString()));
        break;
      case 'beginner':
        const order = ['beginner', 'intermediate', 'advanced'];
        sorted.sort((a, b) => order.indexOf((a['level'] ?? '').toString().toLowerCase())
            .compareTo(order.indexOf((b['level'] ?? '').toString().toLowerCase())));
        break;
      case 'advanced':
        const order = ['advanced', 'intermediate', 'beginner'];
        sorted.sort((a, b) => order.indexOf((a['level'] ?? '').toString().toLowerCase())
            .compareTo(order.indexOf((b['level'] ?? '').toString().toLowerCase())));
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
                ('beginner', 'Level: Beginner Dulu'),
                ('advanced', 'Level: Advanced Dulu'),
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

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      if (_genres.isEmpty) {
        _genres = await ApiService.getCategories();
      }
      _videos = await ApiService.getVideos(
        query: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
        genreId: _selectedGenreId,
      );
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading && _genres.isEmpty
        ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue))
        : CustomScrollView(
            slivers: [
              _buildHeroSection(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchAndFilter(),
                      const SizedBox(height: 32),
                      _buildGenreChips(),
                      const SizedBox(height: 40),
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator())
                      else
                        _buildVideoGrid(context, _videos),
                    ],
                  ),
                ),
              ),
            ],
          );
  }

  Widget _buildHeroSection() {
    return SliverAppBar(
      expandedHeight: 200,
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Text(
                  'AKADEMI VIDEO',
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'KUASAI KETERAMPILAN BARU DENGAN PELAJARAN PREMIUM',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withValues(alpha: 0.6),
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          child: Container(
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
              onSubmitted: (value) => _loadData(),
              decoration: InputDecoration(
                hintText: 'Cari pelajaran...',
                border: InputBorder.none,
                icon: const Icon(Icons.search_rounded, color: AppTheme.primaryBlue),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    _searchController.clear();
                    _loadData();
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        InkWell(
          onTap: _showSortSheet,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _sortOption != 'default' ? AppTheme.primaryBlue : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Icon(
              Icons.tune_rounded,
              color: _sortOption != 'default' ? Colors.white : AppTheme.textSlate,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenreChips() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _genres.length + 1,
        itemBuilder: (context, index) {
          final isAll = index == 0;
          final genre = isAll ? null : _genres[index - 1];
          final genreName = isAll ? 'SEMUA' : (genre['name'] as String).toUpperCase();
          final genreId = isAll ? null : genre['id'];
          final isSelected = _selectedGenreId == genreId;

          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: ChoiceChip(
              label: Text(
                genreName,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                ),
              ),
              selected: isSelected,
              selectedColor: AppTheme.primaryBlue,
              backgroundColor: Colors.white,
              onSelected: (val) {
                if (val) {
                  setState(() {
                    _selectedGenreId = genreId;
                  });
                  _loadData();
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoGrid(BuildContext context, List videos) {
    final sorted = _sortVideos(videos);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Result count + sort label
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MENAMPILKAN ${sorted.length} HASIL',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
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
                      'URUTKAN: ',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF94A3B8)),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (sorted.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Text('Belum ada video tersedia', style: GoogleFonts.plusJakartaSans(color: Colors.grey)),
            ),
          )
        else
          _buildGrid(context, sorted),
      ],
    );
  }

  Widget _buildGrid(BuildContext context, List videos) {

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisSpacing: 24,
        childAspectRatio: 1.2,
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoDetailsScreen(
                  title: video['title'] ?? 'Masterclass',
                  author: video['author'] ?? 'Sins & Logic',
                  videoId: video['youtube_id'] ?? 'dQw4w9WgXcQ',
                  description: video['description'],
                  level: video['level'] ?? 'ADVANCED',
                  genre: video['genre'] ?? 'TEKNOLOGI',
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                          image: DecorationImage(
                            image: NetworkImage('https://img.youtube.com/vi/${video['youtube_id']}/hqdefault.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 48),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              (video['genre'] ?? 'TEKNOLOGI').toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.primaryBlue,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'PREMIUM CLASS',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        video['title'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textSlate,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person_rounded, size: 14, color: AppTheme.primaryBlue),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            (video['author'] ?? 'ARIS THORNE').toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              (video['level'] ?? 'ADVANCED').toUpperCase(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
