import 'package:flutter/material.dart';
import 'package:phone_ai/features/home/presentation/pages/settings.dart';

import '../../../../shared/widgets/custom_bottom_nav.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Placeholder views for the tabs
  final List<Widget> _pages = [
    const Center(child: Text('Inbox View')),
    const Center(child: Text('Calls View')),
    const Center(child: Text('Dial Pad')),
    const Center(child: Text('Contacts View')),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBody: false,
      extendBodyBehindAppBar: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: theme.scaffoldBackgroundColor,
        selectedColor: theme.navigationBarTheme.indicatorColor,
        unselectedColor: Colors.grey.shade600,
      ),
    );
  }
}
