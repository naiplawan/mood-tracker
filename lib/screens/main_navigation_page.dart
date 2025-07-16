import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'mood_home_page.dart';
import 'analytics_page.dart';
import 'calendar_page.dart';
import 'settings_page.dart';
import '../viewmodels/view_models.dart';
import '../utils/animations.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  @override
  void initState() {
    super.initState();
    // Initialize navigation view model
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NavigationViewModel>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F172A),
            const Color(0xFF1E293B),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Consumer<NavigationViewModel>(
          builder: (context, navigationViewModel, child) {
            final moodViewModel = navigationViewModel.moodViewModel;
            
            if (moodViewModel.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              );
            }

            return IndexedStack(
              index: navigationViewModel.selectedIndex,
              children: [
                const MoodHomePage(),
                const CalendarPage(),
                const AnalyticsPage(),
                SettingsPage(moodEntries: moodViewModel.moodEntries),
              ],
            );
          },
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Consumer<NavigationViewModel>(
      builder: (context, navigationViewModel, child) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: BottomNavigationBar(
                currentIndex: navigationViewModel.selectedIndex,
                onTap: (index) => navigationViewModel.setSelectedIndex(index),
                backgroundColor: Colors.transparent,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.white.withOpacity(0.5),
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
                items: [
                  _buildNavItem(Icons.home_outlined, Icons.home, 'Home'),
                  _buildNavItem(Icons.calendar_today_outlined, Icons.calendar_today, 'Calendar'),
                  _buildNavItem(Icons.analytics_outlined, Icons.analytics, 'Analytics'),
                  _buildNavItem(Icons.settings_outlined, Icons.settings, 'Settings'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, IconData activeIcon, String label) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      activeIcon: SlideTransitionAnimation(
        child: GlowAnimation(
          glowColor: Theme.of(context).primaryColor.withOpacity(0.3),
          child: Icon(activeIcon),
        ),
      ),
      label: label,
    );
  }
}
