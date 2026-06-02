import 'package:flutter/material.dart';
 
import 'home_screen.dart';
import 'profile_screen.dart';
import 'analyze_text_screen.dart';
import 'daily_tip_screen.dart';
 
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});
 
  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}
 
class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int currentIndex = 0;
 
  final screens = const [
    HomeScreen(),
    AnalyzeTextScreen(),
    DailyTipScreen(),
    ProfileScreen(),
  ];
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: screens[currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF141826),
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.06), width: 1),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                _navItem(0, Icons.home_rounded, 'Início'),
                _navItem(1, Icons.shield_rounded, 'Scanner'),
                _navItem(2, Icons.school_rounded, 'Educação'),
                _navItem(3, Icons.person_rounded, 'Perfil'),
              ],
            ),
          ),
        ),
      ),
    );
  }
 
  Widget _navItem(int index, IconData icon, String label) {
    final isActive = currentIndex == index;
 
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => currentIndex = index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF00C853).withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: isActive ? const Color(0xFF00C853) : Colors.white38,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? const Color(0xFF00C853) : Colors.white38,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}