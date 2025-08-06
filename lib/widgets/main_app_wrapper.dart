import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../core/constants.dart';
import '../pages/exercises_page.dart';
import '../pages/timer_page.dart';
import '../pages/history_page.dart';
import '../pages/settings_page.dart';
import '../models/breathing_exercise.dart';
import '../services/session_service.dart';

class MainAppWrapper extends StatefulWidget {
  const MainAppWrapper({super.key});

  @override
  State<MainAppWrapper> createState() => _MainAppWrapperState();
}

class _MainAppWrapperState extends State<MainAppWrapper> {

  // Material Design breakpoints
  static const double mobileBreakpoint = 600;
  static const double desktopBreakpoint = 1240;

  NavigationType _getNavigationType(Size screenSize) {
    if (screenSize.width < mobileBreakpoint) {
      return NavigationType.bottomNavigation;
    } else if (screenSize.width < desktopBreakpoint) {
      return NavigationType.navigationRail;
    } else {
      return NavigationType.navigationDrawer;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final NavigationType navigationType = _getNavigationType(screenSize);

    return ResponsiveHomePage(navigationType: navigationType);
  }
}

enum NavigationType {
  bottomNavigation,
  navigationRail,
  navigationDrawer,
}

class ResponsiveHomePage extends StatefulWidget {
  final NavigationType navigationType;
  
  const ResponsiveHomePage({super.key, required this.navigationType});
  
  @override
  State<ResponsiveHomePage> createState() => _ResponsiveHomePageState();
}

class _ResponsiveHomePageState extends State<ResponsiveHomePage> {
  int _currentIndex = 0;
  late PageController _pageController;
  String _version = '';

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _version = packageInfo.version;
      });
    } catch (e) {
      debugPrint('Error loading app version: $e');
      setState(() {
        _version = '0.9.0'; // Fallback to pubspec version
      });
    }
  }

  @override
  void didUpdateWidget(ResponsiveHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.navigationType != widget.navigationType) {
      // Reset page controller when navigation type changes
      _pageController.dispose();
      _pageController = PageController(initialPage: _currentIndex);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onExerciseSelected(BreathingExercise exercise) {
    // Update the session service with the selected exercise
    SessionService().setExercise(exercise);
    
    setState(() {
      _currentIndex = 1; // Navigate to Start/Timer page
    });
    _pageController.animateToPage(
      1,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.navigationType) {
      case NavigationType.bottomNavigation:
        return _buildMobileLayout();
      case NavigationType.navigationRail:
        return _buildTabletLayout();
      case NavigationType.navigationDrawer:
        return _buildDesktopLayout();
    }
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      body: _buildPageView(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.cardBackground,
        selectedItemColor: AppColors.selected,
        unselectedItemColor: AppColors.textSecondary,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: _onItemTapped,
        items: _getNavigationItems(),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _currentIndex,
            onDestinationSelected: _onItemTapped,
            backgroundColor: AppColors.cardBackground,
            selectedIconTheme: IconThemeData(color: AppColors.selected),
            unselectedIconTheme: IconThemeData(color: AppColors.textSecondary),
            selectedLabelTextStyle: TextStyle(color: AppColors.selected),
            unselectedLabelTextStyle: TextStyle(color: AppColors.textSecondary),
            labelType: NavigationRailLabelType.all,
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.list),
                label: Text('Exercises'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.timer),
                label: Text('Timer'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.history),
                label: Text('History'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          VerticalDivider(thickness: 1, width: 1, color: AppColors.textSecondary.withValues(alpha: 0.2)),
          Expanded(child: _buildPageView()),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 256,
            child: _buildNavigationDrawer(),
          ),
          VerticalDivider(thickness: 1, width: 1, color: AppColors.textSecondary.withValues(alpha: 0.2)),
          Expanded(child: _buildPageView()),
        ],
      ),
    );
  }

  Widget _buildPageView() {
    return PageView(
      key: ValueKey(widget.navigationType),
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      children: [
        ExercisesPage(
          key: ValueKey('exercises_${widget.navigationType}'),
          onExerciseSelected: _onExerciseSelected,
        ),
        TimerPage(
          key: ValueKey('timer_${widget.navigationType}'),
        ),
        HistoryPage(key: ValueKey('history_${widget.navigationType}')),
        SettingsPage(key: ValueKey('settings_${widget.navigationType}')),
      ],
    );
  }

  List<BottomNavigationBarItem> _getNavigationItems() {
    return [
      BottomNavigationBarItem(
        icon: Icon(Icons.list),
        label: 'Exercises',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.timer),
        label: 'Timer',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.history),
        label: 'History',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        label: 'Settings',
      ),
    ];
  }

  Widget _buildNavigationDrawer() {
    final user = Supabase.instance.client.auth.currentUser;
    final isLoggedIn = user != null;

    return Container(
      color: AppColors.cardBackground,
      child: Column(
        children: [
          // Header
          Container(
            height: 180,
            width: double.infinity,
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.headerBackground.withValues(alpha: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icon.png',
                  width: 48,
                  height: 48,
                ),
                SizedBox(height: 16),
                Text(
                  'Breath Training',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: AppLayout.fontSizeMedium,
                  ),
                ),
                if (_version.isNotEmpty) ...[
                  SizedBox(height: 4),
                  Text(
                    'v$_version',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: AppLayout.fontSizeSmall - 2,
                    ),
                  ),
                ],
                if (isLoggedIn) ...[
                  SizedBox(height: 8),
                  Text(
                    user.email ?? 'Unknown',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: AppLayout.fontSizeSmall,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ],
            ),
          ),
          
          // Navigation items
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildDrawerItem(
                  icon: Icons.list,
                  title: 'Exercises',
                  index: 0,
                ),
                _buildDrawerItem(
                  icon: Icons.timer,
                  title: 'Timer', 
                  index: 1,
                ),
                _buildDrawerItem(
                  icon: Icons.history,
                  title: 'History',
                  index: 2,
                ),
                _buildDrawerItem(
                  icon: Icons.settings,
                  title: 'Settings',
                  index: 3,
                ),
                
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppColors.selected : AppColors.textPrimary,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.selected : AppColors.textPrimary,
          ),
        ),
        selected: isSelected,
        selectedTileColor: AppColors.selected.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: () => _onItemTapped(index),
      ),
    );
  }
}

