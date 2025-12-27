import 'package:discreta/app/src/1_Front_end/Assets/colors.dart';
import 'package:discreta/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class DiscretaNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const DiscretaNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primaryColor,
      unselectedItemColor: Colors.grey,
      currentIndex: currentIndex,
      onTap: onTap,
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
