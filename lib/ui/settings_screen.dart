import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/wifi_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _subnetController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(wifiProvider);
    _subnetController = TextEditingController(text: state.targetSubnet);
    _intervalController = TextEditingController(
      text: state.loginInterval.toString(),
    );
  }

  late TextEditingController _intervalController;

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(wifiProvider.notifier);

    return Scaffold(
      backgroundColor: NeumorphicTheme.baseColor(context),
      appBar: NeumorphicAppBar(title: const Text("Settings")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Network Configuration"),
            const SizedBox(height: 16),
            Neumorphic(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _subnetController,
                    decoration: const InputDecoration(
                      labelText: "Target Subnet",
                      hintText: "e.g. 172.16.56",
                      border: InputBorder.none,
                    ),
                    onSubmitted: (val) => notifier.updateTargetSubnet(val),
                  ),
                  const Divider(),
                  TextField(
                    controller: _intervalController,
                    decoration: const InputDecoration(
                      labelText: "Login Interval (seconds)",
                      hintText: "e.g. 30",
                      border: InputBorder.none,
                    ),
                    keyboardType: TextInputType.number,
                    onSubmitted: (val) {
                      final interval = int.tryParse(val);
                      if (interval != null) {
                        notifier.updateLoginInterval(interval);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle("Maintenance"),
            const SizedBox(height: 16),
            NeumorphicButton(
              onPressed: () => notifier.clearLogs(),
              padding: const EdgeInsets.all(16),
              child: const Row(
                children: [
                  Icon(Icons.cleaning_services_rounded, color: Colors.orange),
                  SizedBox(width: 12),
                  Text("Clear All Logs"),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                "Version 1.0.0",
                style: TextStyle(
                  color: NeumorphicTheme.variantColor(context),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }
}
