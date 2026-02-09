import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/credential.dart';
import '../providers/wifi_provider.dart';

class CredentialScreen extends ConsumerWidget {
  const CredentialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wifiProvider);
    final notifier = ref.read(wifiProvider.notifier);

    return Scaffold(
      backgroundColor: NeumorphicTheme.baseColor(context),

      /// ✅ CLEAN APPBAR
      appBar: NeumorphicAppBar(
        title: const Text("Manage Credentials"),
        leading: NeumorphicButton(
          style: const NeumorphicStyle(boxShape: NeumorphicBoxShape.circle()),
          onPressed: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          /// ✅ INFO CARD
          Neumorphic(
            padding: const EdgeInsets.all(18),
            style: NeumorphicStyle(
              depth: 6,
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, size: 22),
                    SizedBox(width: 8),
                    Text(
                      "Smart Auto Login",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  "Add multiple credentials and stay online without interruptions. "
                  "The app automatically selects a working account and switches "
                  "when data or login limits are reached.",
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// ✅ EMPTY STATE
          if (state.credentials.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Column(
                children: const [
                  Icon(Icons.wifi_off, size: 60, color: Colors.grey),
                  SizedBox(height: 12),
                  Text("No credentials added", style: TextStyle(fontSize: 16)),
                  SizedBox(height: 6),
                  Text(
                    "Tap + to add login credentials",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

          /// ✅ CREDENTIAL LIST
          ...state.credentials.map((cred) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Neumorphic(
                style: NeumorphicStyle(
                  depth: cred.isActive ? 6 : -3,
                  boxShape: NeumorphicBoxShape.roundRect(
                    BorderRadius.circular(14),
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),

                  title: Text(
                    cred.username,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  subtitle: Text("Password: ${'*' * cred.password.length}"),

                  leading: Icon(
                    cred.isActive ? Icons.wifi : Icons.wifi_off,
                    color: cred.isActive ? Colors.green : Colors.grey,
                  ),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Colors.blue,
                        ),
                        onPressed: () =>
                            _showEditDialog(context, notifier, cred),
                      ),
                      NeumorphicSwitch(
                        value: cred.isActive,
                        onChanged: (_) => notifier.toggleCredentialActive(cred),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () => notifier.deleteCredential(cred.id!),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),

      /// ✅ FAB
      floatingActionButton: NeumorphicFloatingActionButton(
        style: const NeumorphicStyle(
          boxShape: NeumorphicBoxShape.circle(),
          color: Colors.deepOrange,
          shadowLightColor: Colors.deepOrange,
          shadowDarkColor: Colors.deepOrange,
        ),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddDialog(context, notifier),
      ),
    );
  }

  /// ✅ MODERN EDIT DIALOG
  void _showEditDialog(
    BuildContext context,
    WifiNotifier notifier,
    Credential cred,
  ) {
    final userController = TextEditingController(text: cred.username);
    final passController = TextEditingController(text: cred.password);

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: NeumorphicTheme.baseColor(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Edit Credential",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: userController,
                decoration: const InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  Row(
                    children: [
                      NeumorphicButton(
                        onPressed: () async {
                          final response = await notifier.performManualLogin(
                            userController.text,
                            passController.text,
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(response.message)),
                            );
                          }
                        },
                        child: const Text("Test"),
                      ),
                      const SizedBox(width: 8),
                      NeumorphicButton(
                        onPressed: () {
                          if (userController.text.isEmpty ||
                              passController.text.isEmpty) {
                            return;
                          }
                          notifier.updateCredential(
                            cred.id!,
                            userController.text,
                            passController.text,
                          );
                          Navigator.pop(context);
                        },
                        child: const Text("Save"),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ MODERN ADD DIALOG
  void _showAddDialog(BuildContext context, WifiNotifier notifier) {
    final userController = TextEditingController();
    final passController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: NeumorphicTheme.baseColor(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Add Credential",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: userController,
                decoration: const InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  Row(
                    children: [
                      NeumorphicButton(
                        onPressed: () async {
                          final response = await notifier.performManualLogin(
                            userController.text,
                            passController.text,
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(response.message)),
                            );
                          }
                        },
                        child: const Text("Test"),
                      ),
                      const SizedBox(width: 8),
                      NeumorphicButton(
                        onPressed: () {
                          if (userController.text.isEmpty ||
                              passController.text.isEmpty) {
                            return;
                          }
                          notifier.addCredential(
                            userController.text,
                            passController.text,
                          );
                          Navigator.pop(context);
                        },
                        child: const Text("Add"),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
