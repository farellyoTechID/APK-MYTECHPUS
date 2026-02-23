import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../theme.dart';
import '../services/api_service.dart';
import 'category_list_screen.dart';
import 'book_details_screen.dart';
import 'video_details_screen.dart';
import 'user_books_screen.dart';
import 'notification_screen.dart';

class HomeScreen extends StatelessWidget {
  final Function(int)? onActionTap;
  const HomeScreen({super.key, this.onActionTap});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: ApiService.getHomeData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue));
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Gagal memuat data', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () => (context as Element).markNeedsBuild(),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        final data = snapshot.data!;
        final user = data['user'];
        final trendingBooks = data['trending_books'] as List;
        final categories = data['categories'] as List;
        final recentVideos = data['recent_videos'] as List;

        return Material(
          color: AppTheme.backgroundSlate,
          child: CustomScrollView(
            slivers: [
              _buildHeroSection(context, user),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24.0, bottom: 40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildQuickActions(context, categories),
                      const SizedBox(height: 48),
                      _buildSectionHeader('PILIHAN MYTECHPUS', 'KARYA PILIHAN PENULIS DIGITAL TERBAIK'),
                      const SizedBox(height: 24),
                      _buildTrendingCarousel(context, trendingBooks),
                      const SizedBox(height: 48),
                      _buildSectionHeader('KELAS TERBARU', 'AKSES MATERI INTELEKTUAL TINGKAT LANJUT'),
                      const SizedBox(height: 24),
                      _buildHorizontalBookList(context, recentVideos),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeroSection(BuildContext context, Map<String, dynamic>? user) {
    return SliverAppBar(
      expandedHeight: 340,
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
          child: Stack(
            children: [
              Positioned(
                right: -50,
                top: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 12, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // User Profile Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD1D5FE),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.person_rounded, color: AppTheme.primaryBlue, size: 30),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  Text(
                                    'HALLO, ${user?['name'] ?? 'PENGGUNA'}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    user?['role'] ?? 'MEMBER',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white.withValues(alpha: 0.5),
                                      letterSpacing: 1,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen()));
                          },
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                const Icon(Icons.notifications_rounded, color: Colors.white, size: 24),
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppTheme.primaryBlue, width: 2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'KUASAI GARIS DEPAN DIGITAL',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -1,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'SUMBER DAYA ELIT UNTUK INTELEKTUAL TINGKAT LANJUT',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Colors.white.withValues(alpha: 0.6),
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 25,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'Cari naskah atau kelas elit...',
                          hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                          border: InputBorder.none,
                          suffixIcon: Icon(Icons.search_rounded, color: AppTheme.primaryBlue, size: 22),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, List categories) {
    final List<Map<String, dynamic>> actions = [
      {'title': 'KELAS', 'icon': Icons.school_rounded, 'index': 1},
      {'title': 'KATEGORI', 'icon': Icons.grid_view_rounded, 'index': 3, 'isCategory': true},
      {'title': 'EBOOK', 'icon': Icons.menu_book_rounded, 'index': 3},
      {'title': 'ARSIP', 'icon': Icons.inventory_2_rounded, 'isUserBooks': true},
      {'title': 'BELAJAR', 'icon': Icons.psychology_rounded, 'index': 1},
    ];

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final action = actions[index];
          return InkWell(
            onTap: () {
              if (action['isCategory'] == true) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryListScreen()));
              } else if (action['isUserBooks'] == true) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const UserBooksScreen()));
              } else if (onActionTap != null) {
                onActionTap!(action['index'] as int);
              }
            },
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: 90,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(action['icon'] as IconData, color: AppTheme.primaryBlue, size: 28),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    action['title'] as String,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                title.split(' ')[0],
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textSlate,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title.split(' ').sublist(1).join(' '),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primaryBlue,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF94A3B8),
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingCarousel(BuildContext context, List books) {
    if (books.isEmpty) {
      return Center(child: Text('Tidak ada buku terbaru', style: GoogleFonts.plusJakartaSans(fontSize: 12)));
    }

    return CarouselSlider(
      options: CarouselOptions(
        height: 280,
        viewportFraction: 0.6,
        enlargeCenterPage: true,
        enableInfiniteScroll: books.length > 1,
      ),
      items: books.map((book) {
        return _buildBookCard(context, book);
      }).toList(),
    );
  }

  Widget _buildBookCard(BuildContext context, Map<String, dynamic> book) {
    final title = book['title'] ?? 'Tanpa Judul';
    final author = book['author'] ?? 'Penulis Anonim';
    final coverUrl = book['cover_url'];

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailsScreen(
              id: int.tryParse(book['id']?.toString() ?? ''),
              title: title,
              author: author,
              coverUrl: coverUrl,
              synopsis: book['synopsis'],
              genre: book['genre'],
              views: int.tryParse(book['views'].toString()) ?? 0,
              likes: int.tryParse(book['likes'].toString()) ?? 0,
              rating: double.tryParse(book['rating'].toString()) ?? 0.0,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(8),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: coverUrl != null
                      ? Image.network(
                          coverUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(child: Icon(Icons.broken_image_rounded, color: Color(0xFF94A3B8), size: 40)),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                                color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                              ),
                            );
                          },
                        )
                      : const Center(child: Icon(Icons.book_rounded, color: Color(0xFF94A3B8), size: 40)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                   Text(
                    author.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalBookList(BuildContext context, List videos) {
    if (videos.isEmpty) {
      return Center(child: Text('Tidak ada kelas terbaru', style: GoogleFonts.plusJakartaSans(fontSize: 12)));
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
              width: 140,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          'https://img.youtube.com/vi/${video['youtube_id']}/hqdefault.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(child: Icon(Icons.play_circle_fill_rounded, color: AppTheme.primaryBlue, size: 40)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    video['title'] ?? 'Masterclass',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900),
                  ),
                  Text(
                    (video['author'] ?? 'Sins & Logic').toString().toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(fontSize: 8, fontWeight: FontWeight.w700, color: const Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
