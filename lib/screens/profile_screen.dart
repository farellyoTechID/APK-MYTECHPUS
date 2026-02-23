import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../services/api_service.dart';
import 'edit_profile_screen.dart';
import 'security_screen.dart';
import 'notification_screen.dart';
import 'user_books_screen.dart';
import 'analytics_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getProfile();
      setState(() {
        _profileData = data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat profil: $e')),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      await ApiService.logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal keluar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)));
    }

    final user = _profileData?['user'] ?? {};
    final stats = _profileData?['stats'] ?? {};

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildHeader(user, stats),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildStats(stats),
                  const SizedBox(height: 40),
                  _buildMenuSection('PENGATURAN AKUN', [
                    {'title': 'Edit Profil', 'icon': Icons.person_outline_rounded},
                    {'title': 'Keamanan & Sandi', 'icon': Icons.lock_outline_rounded},
                    {'title': 'Notifikasi', 'icon': Icons.notifications_none_rounded},
                  ]),
                  const SizedBox(height: 24),
                  _buildMenuSection('DASHBOARD PENULIS', [
                    {'title': 'Karya Saya', 'icon': Icons.auto_stories_rounded},
                    {'title': 'Analistik', 'icon': Icons.bar_chart_rounded},
                  ]),
                  const SizedBox(height: 40),
                  _buildLogoutButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Map user, Map stats) {
    return SliverAppBar(
      expandedHeight: 220,
      backgroundColor: AppTheme.primaryBlue,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF002E7A), AppTheme.primaryBlue],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: user['avatar_url'] != null 
                    ? NetworkImage(user['avatar_url']) 
                    : const NetworkImage('https://via.placeholder.com/80'),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                (user['name'] ?? 'PENGGUNA').toString().toUpperCase(),
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
              Text(
                (stats['level'] ?? 'NOVICE WRITER').toString().toUpperCase(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withValues(alpha: 0.6),
                  letterSpacing: 2.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStats(Map stats) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const SizedBox(width: 16),
            _buildStatItem(stats['books_count']?.toString() ?? '0', 'BUKU'),
            const SizedBox(width: 32),
            Container(width: 1, height: 40, color: const Color(0xFFF1F5F9)),
            const SizedBox(width: 32),
            _buildStatItem(stats['received_ratings_count']?.toString() ?? '0', 'PEMBACA'),
            const SizedBox(width: 32),
            Container(width: 1, height: 40, color: const Color(0xFFF1F5F9)),
            const SizedBox(width: 32),
            _buildStatItem(stats['received_ratings_avg']?.toString() ?? '0.0', 'RATING'),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppTheme.primaryBlue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF94A3B8),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(String title, List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 16),
          child: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF94A3B8),
              letterSpacing: 1.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Column(
            children: items.where((item) {
              if (item['title'] == 'Keamanan & Sandi') {
                final user = _profileData?['user'] ?? {};
                return user['is_google_user'] != true;
              }
              return true;
            }).map((item) {
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item['icon'] as IconData, color: AppTheme.textSlate, size: 20),
                ),
                title: Text(
                  item['title'] as String,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSlate,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
                onTap: () async {
                  Widget? targetScreen;
                  final userData = _profileData?['user'] ?? {};
                  switch (item['title']) {
                    case 'Edit Profil':
                      targetScreen = EditProfileScreen(userData: {
                        'name': userData['name'],
                        'email': userData['email'],
                        'avatar_url': userData['avatar_url'],
                      });
                      break;
                    case 'Keamanan & Sandi':
                      targetScreen = const SecurityScreen();
                      break;
                    case 'Notifikasi':
                      targetScreen = const NotificationScreen();
                      break;
                    case 'Karya Saya':
                      targetScreen = const UserBooksScreen();
                      break;
                    case 'Analistik':
                      targetScreen = const AnalyticsScreen();
                      break;
                  }

                  if (targetScreen != null) {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => targetScreen!),
                    );
                    if (result == true) {
                      _loadProfile();
                    }
                  }
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: _handleLogout,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
          backgroundColor: const Color(0xFFFEF2F2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          'KELUAR DARI AKUN',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFFEF4444),
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}
