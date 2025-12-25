import 'package:discreta/app/src/1_Front_end/Assets/enum/text_size.dart';
import 'package:discreta/app/src/1_Front_end/lib/Classes/contact.dart';
import 'package:discreta/app/src/1_Front_end/lib/Components/discreta_button.dart';
import 'package:discreta/app/src/1_Front_end/lib/Components/discreta_text.dart';
import 'package:discreta/app/src/1_Front_end/lib/Components/loading_overlay.dart';
import 'package:discreta/app/src/1_Front_end/Assets/colors.dart';
import 'package:discreta/app/src/1_Front_end/lib/Components/Layout/discreta_nav_bar.dart';
import 'package:discreta/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});
  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  bool _isLoading = false;
  final TextEditingController _alertController = TextEditingController();
  final List<Contact> _contacts = [];

  void _setIsLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  void _addContact() {
    if (_contacts.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.maxContactMessage),
        ),
      );
      return;
    }

    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.addContact),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.name,
              ),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.phoneNumber,
                hintText: 'ex: 5241234567',
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              var phone = phoneController.text.trim();
              if (name.isEmpty || phone.isEmpty) return;
              phone = phone.replaceAll(RegExp(r'\D'), '');

              // Ensure it's 10 digits
              if (phone.length != 10) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context)!.invalidPhoneNumberMessage,
                    ),
                  ),
                );
                return;
              }

              // Auto-prepend +1
              phone = '+1$phone';

              setState(() {
                _contacts.add(Contact(name: name, phone: phone));
              });

              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.add),
          ),
        ],
      ),
    );
  }

  void _editContact(int index) {
    final contact = _contacts[index];
    final nameController = TextEditingController(text: contact.name);
    final phoneController = TextEditingController(
      text: contact.phone.replaceFirst('+1', ''),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.editContact),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.name,
              ),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.phoneNumber,
                hintText: '5241234567',
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              var phone = phoneController.text.trim();
              if (name.isEmpty || phone.isEmpty) return;

              // Remove non-digit characters
              phone = phone.replaceAll(RegExp(r'\D'), '');
              if (phone.length != 10) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context)!.invalidPhoneNumberMessage,
                    ),
                  ),
                );
                return;
              }

              phone = '+1$phone';

              setState(() {
                _contacts[index] = Contact(name: name, phone: phone);
              });

              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }

  void _deleteContact(int index) {
    setState(() {
      _contacts.removeAt(index);
    });
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
          text: AppLocalizations.of(context)!.contactsAndAlert,
          fontWeight: FontWeight.bold,
          size: TextSize.medium,
          color: Colors.white,
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DiscretaText(
                  text: AppLocalizations.of(context)!.alertMessage,
                  fontWeight: FontWeight.bold,
                  size: TextSize.medium,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _alertController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    hintText: AppLocalizations.of(
                      context,
                    )!.alertMessagePlaceholder,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DiscretaText(
                      text: AppLocalizations.of(context)!.contacts,
                      fontWeight: FontWeight.bold,
                      size: TextSize.medium,
                    ),
                    DiscretaButton(
                      onPressed: _addContact,
                      text: AppLocalizations.of(context)!.addContact,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _contacts.length,
                  itemBuilder: (context, index) {
                    final contact = _contacts[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text(contact.name),
                        subtitle: Text(contact.phone),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: AppColors.primaryColor,
                              ),
                              onPressed: () => _editContact(index),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: AppColors.red,
                              ),
                              onPressed: () => _deleteContact(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          if (_isLoading) const LoadingOverlay(),
        ],
      ),
      bottomNavigationBar: const DiscretaNavBar(currentIndex: 1),
    );
  }
}
