import 'package:discreta/app/src/1_Front_end/lib/Screens/Guide_screen.dart';
import 'package:flutter/material.dart';
import 'package:discreta/app/src/1_Front_end/lib/Components/Layout/discreta_nav_bar.dart';
import 'package:discreta/app/src/1_Front_end/lib/Screens/contact_screen.dart';
import 'package:discreta/app/src/1_Front_end/lib/Screens/home_screen.dart';
import 'package:discreta/app/src/1_Front_end/lib/Screens/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    ContactsPage(),
    GuidePage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: DiscretaNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}
