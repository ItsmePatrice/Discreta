import 'package:discreta/app/src/1_Front_end/Assets/colors.dart';
import 'package:discreta/app/src/1_Front_end/lib/Screens/home_screen.dart';
import 'package:discreta/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

typedef OnNavBarTap = void Function(int index);

class DiscretaNavBar extends StatelessWidget {
  final int currentIndex;

  const DiscretaNavBar({super.key, required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return; // do nothing if already selected

    switch (index) {
      case 0:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const HomePage()));
        break;
      case 1:
        /* Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const ContactsScreen())); */
        break;
      case 2:
        /* Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const GuideScreen())); */
        break;
      case 3:
        /* Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const SettingsScreen())); */
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primaryColor,
      unselectedItemColor: Colors.grey,
      currentIndex: currentIndex,
      onTap: (index) => _onItemTapped(context, index),
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: AppLocalizations.of(context)!.home,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_add),
          label: AppLocalizations.of(context)!.contacts,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.help_outline),
          label: AppLocalizations.of(context)!.guide,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: AppLocalizations.of(context)!.profile,
        ),
      ],
    );
  }
}
