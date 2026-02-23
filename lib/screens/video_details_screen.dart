import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../theme.dart';
import '../services/api_service.dart';

class VideoDetailsScreen extends StatefulWidget {
  final String title;
  final String author;
  final String videoId;
  final String? description;
  final String level;
  final String genre;

  const VideoDetailsScreen({
    super.key,
    required this.title,
    required this.author,
    required this.videoId,
    this.description,
    this.level = 'ADVANCED',
    this.genre = 'TEKNOLOGI',
  });

  @override
  State<VideoDetailsScreen> createState() => _VideoDetailsScreenState();
}

class _VideoDetailsScreenState extends State<VideoDetailsScreen> {
  late final WebViewController _controller;
  List<dynamic> _relatedVideos = [];
  bool _loadingRelated = true;

  @override
  void initState() {
    super.initState();
    _initPlayer();
    _loadRelated();
  }

  void _initPlayer() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 12; Pixel 6) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/112.0.0.0 Mobile Safari/537.36',
      )
      ..loadRequest(
        Uri.parse('https://m.youtube.com/watch?v=${widget.videoId}'),
      );
  }

  Future<void> _loadRelated() async {
    setState(() => _loadingRelated = true);
    try {
      final videos = await ApiService.getVideos(genreId: null);
      // Exclude the current video from related
      final filtered = videos.where((v) => v['youtube_id'] != widget.videoId).take(5).toList();
      setState(() {
        _relatedVideos = filtered;
        _loadingRelated = false;
      });
    } catch (_) {
      setState(() => _loadingRelated = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundSlate,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textSlate, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'AKADEMI VIDEO',
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: AppTheme.textSlate,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // YouTube Player
            AspectRatio(
              aspectRatio: 16 / 9,
              child: WebViewWidget(controller: _controller),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildVideoInfo(),
                  const SizedBox(height: 32),
                  const Divider(color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 32),
                  _buildRelatedSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                widget.level.toUpperCase(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF22C55E),
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                widget.genre.toUpperCase(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF64748B),
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          widget.title,
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: AppTheme.textSlate,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const CircleAvatar(radius: 12, child: Icon(Icons.person, size: 14)),
            const SizedBox(width: 8),
            Text(
              widget.author,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppTheme.textSlate,
              ),
            ),
            const Spacer(),
            Text(
              'PREMIUM CONTENT',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
        if (widget.description != null && widget.description!.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            widget.description!,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: const Color(0xFF64748B),
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRelatedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MASTERCLASS TERKAIT',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: AppTheme.textSlate,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        if (_loadingRelated)
          const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue))
        else if (_relatedVideos.isEmpty)
          Text(
            'Tidak ada video terkait.',
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF94A3B8)),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _relatedVideos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final video = _relatedVideos[index];
              final youtubeId = video['youtube_id'] ?? '';
              return InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoDetailsScreen(
                        title: video['title'] ?? '',
                        author: video['author'] ?? '',
                        videoId: youtubeId,
                        description: video['description'],
                        level: video['level'] ?? 'BEGINNER',
                        genre: video['genre'] ?? '',
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: youtubeId.isNotEmpty
                            ? Image.network(
                                'https://img.youtube.com/vi/$youtubeId/mqdefault.jpg',
                                width: 100,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, stack) => Container(
                                  width: 100,
                                  height: 60,
                                  color: Colors.black,
                                  child: const Icon(Icons.play_circle_outline_rounded, color: Colors.white30, size: 24),
                                ),
                              )
                            : Container(
                                width: 100,
                                height: 60,
                                color: Colors.black,
                                child: const Icon(Icons.play_circle_outline_rounded, color: Colors.white30, size: 24),
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (video['title'] ?? '').toString().toUpperCase(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.textSlate,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'MENTOR: ${(video['author'] ?? 'ELITE EXPERT').toString().toUpperCase()}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.play_circle_fill_rounded, color: AppTheme.primaryBlue, size: 32),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
