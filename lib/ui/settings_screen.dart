import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
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

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        // Many platforms still allow launching even if canLaunchUrl returns false
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

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
                      labelText:
                          "Target Subnet is preconfigured. Change it only if you’re a CS student who passed networking and CIDR Classes without crying.",
                      hintText: "e.g. 172.16.56",
                      border: InputBorder.none,
                    ),
                    onSubmitted: (val) => notifier.updateTargetSubnet(val),
                  ),
                  const Divider(),
                  TextField(
                    controller: _intervalController,
                    decoration: const InputDecoration(
                      labelText:
                          "Login Interval (Recommended: 30) Reduce if you still get disconnected (value is in seconds)",
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
            const SizedBox(height: 24),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Build by Harsh Anand",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: NeumorphicTheme.variantColor(context),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      color: Colors.white,
                    ),
                    child: IconButton(
                      onPressed: () async {
                        await _launchURL(
                          "https://www.instagram.com/harsh_.anand/",
                        );
                      },
                      icon: Image.asset(
                        "assets/images/insta.png",
                        width: 30,
                        height: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      color: Colors.white,
                    ),
                    child: IconButton(
                      onPressed: () async {
                        await _launchURL("https://github.com/nginH/aus-wifi");
                      },
                      icon: Image.asset(
                        "assets/images/git.png",
                        width: 24,
                        height: 24,
                        colorBlendMode: BlendMode.srcIn,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await _launchURL(
                        "https://github.com/nginH/aus-wifi/releases",
                      );
                    },
                    icon: Icon(Icons.share),
                  ),
                ],
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
