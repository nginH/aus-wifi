import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/wifi_provider.dart';

class LogScreen extends ConsumerWidget {
  const LogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wifiProvider);
    final notifier = ref.read(wifiProvider.notifier);

    return Scaffold(
      backgroundColor: NeumorphicTheme.baseColor(context),
      appBar: NeumorphicAppBar(
        title: const Text("Login History"),
        actions: [
          NeumorphicButton(
            child: const Icon(Icons.delete_sweep_rounded),
            onPressed: () => notifier.clearLogs(),
            style: const NeumorphicStyle(boxShape: NeumorphicBoxShape.circle()),
          ),
        ],
      ),
      body: state.logs.isEmpty
          ? Center(
              child: Text(
                "No logs yet",
                style: TextStyle(color: NeumorphicTheme.variantColor(context)),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: state.logs.length,
              itemBuilder: (context, index) {
                final log = state.logs[index];
                bool isSuccess = log.status == 'LIVE';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Neumorphic(
                    padding: const EdgeInsets.all(16),
                    style: const NeumorphicStyle(depth: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat(
                                'MMM dd, HH:mm:ss',
                              ).format(log.timestamp),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isSuccess
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                log.status,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isSuccess ? Colors.green : Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "User: ${log.username}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          log.message,
                          style: TextStyle(
                            fontSize: 13,
                            color: NeumorphicTheme.variantColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
