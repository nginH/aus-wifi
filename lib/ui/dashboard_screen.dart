import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/wifi_provider.dart';
import 'credential_screen.dart';
import 'log_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wifiProvider);
    final notifier = ref.read(wifiProvider.notifier);

    return Scaffold(
      backgroundColor: NeumorphicTheme.baseColor(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 40),
              _buildStatusCard(context, state),
              const Spacer(),
              _buildMonitorButton(context, state, notifier),
              const Spacer(),
              _buildNavigationGrid(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "AUS WIFI",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: NeumorphicTheme.accentColor(context),
          ),
        ),
        Text(
          "Network Monitor",
          style: TextStyle(
            fontSize: 16,
            color: NeumorphicTheme.variantColor(context),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(BuildContext context, WifiState state) {
    bool isConnected = state.status == 'Connected';
    bool isError =
        state.status == 'Error' ||
        state.status == 'Login Failed' ||
        state.status == 'Wrong Network';

    return Neumorphic(
      padding: const EdgeInsets.all(24),
      style: NeumorphicStyle(
        depth: -5,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Status",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: state.isMonitoring
                      ? (isConnected
                            ? Colors.green
                            : (isError ? Colors.red : Colors.orange))
                      : Colors.grey,
                  boxShadow: [
                    if (state.isMonitoring)
                      BoxShadow(
                        color:
                            (isConnected
                                    ? Colors.green
                                    : (isError ? Colors.red : Colors.orange))
                                .withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            state.status,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            state.message,
            textAlign: TextAlign.center,
            style: TextStyle(color: NeumorphicTheme.variantColor(context)),
          ),
          const SizedBox(height: 16),
          _buildInfoRow("Internal IP", state.currentIp ?? "None"),
          _buildInfoRow("Subnet", state.targetSubnet),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildMonitorButton(
    BuildContext context,
    WifiState state,
    WifiNotifier notifier,
  ) {
    return Center(
      child: NeumorphicButton(
        onPressed: notifier.toggleMonitoring,
        style: NeumorphicStyle(
          shape: state.isMonitoring
              ? NeumorphicShape.concave
              : NeumorphicShape.convex,
          boxShape: const NeumorphicBoxShape.circle(),
          depth: state.isMonitoring ? -10 : 10,
          color: state.isMonitoring
              ? NeumorphicTheme.accentColor(context)
              : null,
        ),
        padding: const EdgeInsets.all(50),
        child: Icon(
          state.isMonitoring ? Icons.stop_rounded : Icons.play_arrow_rounded,
          size: 60,
          color: state.isMonitoring
              ? Colors.white
              : NeumorphicTheme.accentColor(context),
        ),
      ),
    );
  }

  Widget _buildNavigationGrid(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildNavButton(
            context,
            "Credentials",
            Icons.vpn_key_rounded,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CredentialScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _buildNavButton(context, "Logs", Icons.history_rounded, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LogScreen()),
            );
          }),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _buildNavButton(
            context,
            "Settings",
            Icons.settings_rounded,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNavButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return NeumorphicButton(
      onPressed: onTap,
      padding: const EdgeInsets.symmetric(vertical: 16),
      style: NeumorphicStyle(
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: NeumorphicTheme.accentColor(context)),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
