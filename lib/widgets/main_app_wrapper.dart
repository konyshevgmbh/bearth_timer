import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../core/constants.dart';
import '../i18n/translations.g.dart';
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
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
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
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
            selectedIconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
            unselectedIconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurfaceVariant),
            selectedLabelTextStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
            unselectedLabelTextStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            labelType: NavigationRailLabelType.all,
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.list),
                label: Text(t.navigation.exercises),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.timer),
                label: Text(t.navigation.timer),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.history),
                label: Text(t.navigation.history),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text(t.navigation.settings),
              ),
            ],
          ),
          VerticalDivider(thickness: 1, width: 1, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.2)),
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
          VerticalDivider(thickness: 1, width: 1, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.2)),
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
        label: t.navigation.exercises,
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.timer),
        label: t.navigation.timer,
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.history),
        label: t.navigation.history,
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        label: t.navigation.settings,
      ),
    ];
  }

  Widget _buildNavigationDrawer() {
    final user = Supabase.instance.client.auth.currentUser;
    final isLoggedIn = user != null;

    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Column(
        children: [
          // Header
          Container(
            height: 180,
            width: double.infinity,
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
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
                  t.navigation.breathTraining,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: AppLayout.fontSizeMedium,
                  ),
                ),

                if (isLoggedIn) ...[
                  SizedBox(height: 8),
                  Text(
                    user.email ?? t.app.unknown,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                  title: t.navigation.exercises,
                  index: 0,
                ),
                _buildDrawerItem(
                  icon: Icons.timer,
                  title: t.navigation.timer, 
                  index: 1,
                ),
                _buildDrawerItem(
                  icon: Icons.history,
                  title: t.navigation.history,
                  index: 2,
                ),
                _buildDrawerItem(
                  icon: Icons.settings,
                  title: t.navigation.settings,
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
          color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        selected: isSelected,
        selectedTileColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: () => _onItemTapped(index),
      ),
    );
  }
}

