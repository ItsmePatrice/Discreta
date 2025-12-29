import 'package:discreta/app/src/1_Front_end/Assets/colors.dart';
import 'package:discreta/app/src/1_Front_end/Assets/enum/text_size.dart';
import 'package:discreta/app/src/1_Front_end/lib/Components/discreta_text.dart';
import 'package:discreta/app/src/1_Front_end/lib/Services/message_service.dart';
import 'package:discreta/app/src/1_Front_end/lib/Services/user_service.dart';
import 'package:discreta/l10n/app_localizations.dart';
import 'package:discreta/main.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late String _selectedLanguage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedLanguage = Localizations.localeOf(context).languageCode;
  }

  Future<void> _changeLanguage(String languageCode) async {
    try {
      await UserService.instance.setLanguagePreference(languageCode);
      setState(() {
        _selectedLanguage = languageCode;
      });

      myAppKey.currentState?.setLocale(Locale(languageCode));
    } catch (e) {
      MessageService.displayAlertDialog(
        context: context,
        title: AppLocalizations.of(context)!.unknownError,
        message: AppLocalizations.of(context)!.noInternetConnection,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: DiscretaText(
          text: AppLocalizations.of(context)!.settings,
          size: TextSize.medium,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DiscretaText(
              text: AppLocalizations.of(context)!.language,
              size: TextSize.medium,
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(height: 16),

            /// Français
            RadioListTile<String>(
              value: 'fr',
              groupValue: _selectedLanguage,
              activeColor: AppColors.primaryColor,
              title: const Text('Français'),
              onChanged: (value) {
                if (value != null) _changeLanguage(value);
              },
            ),

            /// English
            RadioListTile<String>(
              value: 'en',
              groupValue: _selectedLanguage,
              activeColor: AppColors.primaryColor,
              title: const Text('English'),
              onChanged: (value) {
                if (value != null) _changeLanguage(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
