import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../services/api_service.dart';
import 'book_details_screen.dart';
import 'write_screen.dart';

class UserBooksScreen extends StatelessWidget {
  const UserBooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundSlate,
      appBar: AppBar(
        title: Text(
          'KARYA SAYA',
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: AppTheme.textSlate,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textSlate, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: ApiService.getUserBooks(),
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
                  Text(snapshot.error.toString(), style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey)),
                ],
              ),
            );
          }

          final books = snapshot.data ?? [];

          if (books.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Container(
                     width: 100,
                     height: 100,
                     decoration: BoxDecoration(
                       color: Colors.white,
                       shape: BoxShape.circle,
                       boxShadow: [
                         BoxShadow(
                           color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                           blurRadius: 20,
                         ),
                       ],
                     ),
                     child: const Icon(
                       Icons.auto_stories_rounded,
                       color: AppTheme.primaryBlue,
                       size: 60,
                     ),
                   ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum Ada Karya',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSlate,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mulai menulis dan publikasikan karyamu!',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return _buildBookItem(context, book);
            },
          );
        },
      ),
    );
  }

  Widget _buildBookItem(BuildContext context, Map<String, dynamic> book) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFF1F5F9),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: book['cover_url'] != null
                  ? Image.network(book['cover_url'], fit: BoxFit.cover)
                  : const Icon(Icons.book_rounded, color: Color(0xFF94A3B8)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        book['genre']?.toString().toUpperCase() ?? 'KARYA',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      if (book['status'] != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          book['status'].toString().toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: book['status'] == 'published' ? const Color(0xFF22C55E) : const Color(0xFFF59E0B),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  book['title'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textSlate,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStat(Icons.visibility_rounded, book['views'].toString()),
                    const SizedBox(width: 16),
                    _buildStat(Icons.favorite_rounded, book['likes'].toString()),
                    const SizedBox(width: 16),
                    _buildStat(Icons.star_rounded, book['rating'].toString()),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WriteScreen(book: book),
                    ),
                  );
                },
                icon: const Icon(Icons.edit_note_rounded, color: AppTheme.primaryBlue, size: 22),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),
              IconButton(
                onPressed: () => _confirmDelete(context, book),
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookDetailsScreen(
                        id: int.tryParse(book['id']?.toString() ?? ''),
                        title: book['title'] ?? '',
                        author: book['author'] ?? '',
                        coverUrl: book['cover_url'],
                        synopsis: book['synopsis'],
                        genre: book['genre'],
                        views: int.tryParse(book['views'].toString()) ?? 0,
                        likes: int.tryParse(book['likes'].toString()) ?? 0,
                        rating: double.tryParse(book['rating'].toString()) ?? 0.0,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Map<String, dynamic> book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Karya?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        content: Text('Apakah kamu yakin ingin menghapus karya "${book['title']}"? Tindakan ini tidak bisa dibatalkan.',
            style: GoogleFonts.plusJakartaSans(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('BATAL', style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ApiService.deleteBook(int.parse(book['id'].toString()));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Karya berhasil dihapus'), backgroundColor: Colors.red),
                  );
                  // Refresh the screen (this approach is simple for stateless, but a stateful wrapper would be better)
                  // For now, we pop or just tell the user to refresh.
                  // Ideally, UserBooksScreen should be StatefulWidget.
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (context) => const UserBooksScreen()));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal menghapus: $e')),
                  );
                }
              }
            },
            child: Text('HAPUS', style: GoogleFonts.plusJakartaSans(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 4),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }
}
