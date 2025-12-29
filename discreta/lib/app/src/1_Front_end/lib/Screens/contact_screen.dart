import 'package:discreta/app/src/1_Front_end/Assets/enum/button_size.dart';
import 'package:discreta/app/src/1_Front_end/Assets/enum/text_size.dart';
import 'package:discreta/app/src/1_Front_end/lib/Classes/contact.dart';
import 'package:discreta/app/src/1_Front_end/lib/Components/discreta_button.dart';
import 'package:discreta/app/src/1_Front_end/lib/Components/discreta_text.dart';
import 'package:discreta/app/src/1_Front_end/lib/Components/loading_overlay.dart';
import 'package:discreta/app/src/1_Front_end/Assets/colors.dart';
import 'package:discreta/app/src/1_Front_end/lib/Services/message_service.dart';
import 'package:discreta/app/src/1_Front_end/lib/Services/user_service.dart';
import 'package:discreta/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

  @override
  void initState() {
    super.initState();
    initializePage();
  }

  @override
  void dispose() {
    _alertController.dispose();
    super.dispose();
  }

  void initializePage() async {
    _setIsLoading(true);
    try {
      final alertMessage = await UserService.instance.fetchAlertMessage();
      _alertController.text = alertMessage ?? '';
      final contacts = await UserService.instance.fetchContacts();
      setState(() {
        _contacts.addAll(contacts);
      });
    } catch (e) {
      MessageService.displayAlertDialog(
        context: context,
        title: AppLocalizations.of(context)!.unknownError,
        message: AppLocalizations.of(context)!.noInternetConnection,
      );
    } finally {
      _setIsLoading(false);
    }
  }

  void _saveAlertMessage() async {
    _setIsLoading(true);
    try {
      await UserService.instance.saveAlertMessage(_alertController.text.trim());
      MessageService.displayAlertDialog(
        context: context,
        title: AppLocalizations.of(context)!.success,
        message: AppLocalizations.of(context)!.alertMessageSaved,
      );
    } catch (e) {
      _setIsLoading(false);
      MessageService.displayAlertDialog(
        context: context,
        title: AppLocalizations.of(context)!.unknownError,
        message: AppLocalizations.of(context)!.noInternetConnection,
      );
    } finally {
      _setIsLoading(false);
    }
  }

  Future<void> _addContact() async {
    if (_contacts.length >= 10) {
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
              maxLength: 20,
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
            onPressed: () async {
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

              try {
                _setIsLoading(true);
                await UserService.instance.addContact(
                  Contact(name: name, phone: phone, id: '23'),
                );
              } catch (e) {
                _setIsLoading(false);
                MessageService.displayAlertDialog(
                  context: context,
                  title: AppLocalizations.of(context)!.unknownError,
                  message: AppLocalizations.of(context)!.noInternetConnection,
                );
              }
              final contacts = await UserService.instance.fetchContacts();
              setState(() {
                _contacts.clear();
                _contacts.addAll(contacts);
              });
              _setIsLoading(false);

              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.add),
          ),
        ],
      ),
    );
  }

  Future<void> _editContact(int index) async {
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
              maxLength: 20,
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
            onPressed: () async {
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

              _setIsLoading(true);

              await UserService.instance.updateContact(
                Contact(name: name, phone: phone, id: contact.id),
              );
              setState(() {});

              final contacts = await UserService.instance.fetchContacts();
              setState(() {
                _contacts.clear();
                _contacts.addAll(contacts);
                _isLoading = false;
              });

              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteContact(int index) async {
    try {
      _setIsLoading(true);
      await UserService.instance.deleteContact(_contacts[index].id!);
      setState(() {
        _contacts.removeAt(index);
      });
      _setIsLoading(false);
    } catch (e) {
      _setIsLoading(false);
      MessageService.displayAlertDialog(
        context: context,
        title: AppLocalizations.of(context)!.unknownError,
        message: AppLocalizations.of(context)!.noInternetConnection + '$e',
      );
    }
  }

  Future<void> _confirmContactDeletion(int index) async {
    MessageService.displayConfirmationDialog(
      context: context,
      message: AppLocalizations.of(context)!.confirmDeleteContact,
      onYesPressed: () async {
        Navigator.pop(context);
        await _deleteContact(index);
      },
    );
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
          GestureDetector(
            onTap: _dismissKeyboard,
            behavior: HitTestBehavior.translucent,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DiscretaText(
                    text: AppLocalizations.of(context)!.alertMessage,
                    fontWeight: FontWeight.bold,
                    size: TextSize.medium,
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: _alertController,
                    maxLength: 160,
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
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DiscretaButton(
                        text: AppLocalizations.of(context)!.save,
                        size: ButtonSize.medium,
                        onPressed: () async {
                          if (_alertController.text.trim().isEmpty) return;
                          FocusManager.instance.primaryFocus?.unfocus();

                          await Future.delayed(
                            const Duration(milliseconds: 50),
                          );
                          _saveAlertMessage();
                          _dismissKeyboard();
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 70.h),
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
                        icon: Icon(Icons.add),
                        size: ButtonSize.large,
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
                                onPressed: () => _confirmContactDeletion(index),
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
          ),

          if (_isLoading) const LoadingOverlay(),
        ],
      ),
    );
  }
}
