import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/akademi_screen.dart';
import 'screens/arsip_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/write_screen.dart';
import 'theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const LibraryApp());
}

class LibraryApp extends StatelessWidget {
  const LibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MYTECHPUS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const MainNavigation(),
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  late final List<Widget> _screens = [
    HomeScreen(onActionTap: (index) => setState(() => _selectedIndex = index)),
    const AkademiScreen(),
    const WriteScreen(),
    const ArsipScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        height: 65, // Explicit height to ensure visibility
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primaryBlue,
          unselectedItemColor: const Color(0xFFCBD5E1),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 9),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 9),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded, size: 20), label: 'HOME'),
            BottomNavigationBarItem(icon: Icon(Icons.school_rounded, size: 20), label: 'AKADEMI'),
            BottomNavigationBarItem(icon: Icon(Icons.edit_note_rounded, size: 24), label: 'TULIS'),
            BottomNavigationBarItem(icon: Icon(Icons.auto_stories_rounded, size: 20), label: 'EBOOK'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded, size: 20), label: 'PROFIL'),
          ],
        ),
      ),
    );
  }
}
