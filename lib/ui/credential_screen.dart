import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/wifi_provider.dart';

class CredentialScreen extends ConsumerWidget {
  const CredentialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wifiProvider);
    final notifier = ref.read(wifiProvider.notifier);

    return Scaffold(
      backgroundColor: NeumorphicTheme.baseColor(context),
      appBar: NeumorphicAppBar(
        title: const Text("Manage Credentials"),
        leading: NeumorphicButton(
          child: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          style: const NeumorphicStyle(boxShape: NeumorphicBoxShape.circle()),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: state.credentials.length,
        itemBuilder: (context, index) {
          final cred = state.credentials[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Neumorphic(
              style: NeumorphicStyle(depth: cred.isActive ? 5 : -2),
              child: ListTile(
                title: Text(
                  cred.username,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("Password: ${'*' * cred.password.length}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    NeumorphicSwitch(
                      value: cred.isActive,
                      onChanged: (val) => notifier.toggleCredentialActive(cred),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => notifier.deleteCredential(cred.id!),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: NeumorphicFloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showAddDialog(context, notifier),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WifiNotifier notifier) {
    final userController = TextEditingController();
    final passController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: NeumorphicTheme.baseColor(context),
          title: const Text("Add Credential"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: userController,
                decoration: const InputDecoration(labelText: "Username"),
              ),
              TextField(
                controller: passController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            NeumorphicButton(
              onPressed: () {
                if (userController.text.isNotEmpty &&
                    passController.text.isNotEmpty) {
                  notifier.addCredential(
                    userController.text,
                    passController.text,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }
}
