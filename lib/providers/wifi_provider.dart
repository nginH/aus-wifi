import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/credential.dart';
import '../models/login_log.dart';
import '../services/database_helper.dart';
import '../services/network_service.dart';

class WifiState {
  final bool isMonitoring;
  final String? currentIp;
  final String status;
  final String message;
  final List<Credential> credentials;
  final List<LoginLog> logs;
  final int currentCredentialIndex;
  final String targetSubnet;
  final String loginUrl;
  final String httpMethod;
  final Map<String, String> headers;
  final int checkInterval;
  final int loginInterval;

  WifiState({
    this.isMonitoring = false,
    this.currentIp,
    this.status = 'Idle',
    this.message = 'Ready to monitor',
    this.credentials = const [],
    this.logs = const [],
    this.currentCredentialIndex = 0,
    this.targetSubnet = '172.16.56',
    this.loginUrl = 'http://172.16.1.1:8090/login.xml',
    this.httpMethod = 'POST',
    this.headers = const {'Content-Type': 'application/x-www-form-urlencoded'},
    this.checkInterval = 1,
    this.loginInterval = 30,
  });

  WifiState copyWith({
    bool? isMonitoring,
    String? currentIp,
    String? status,
    String? message,
    List<Credential>? credentials,
    List<LoginLog>? logs,
    int? currentCredentialIndex,
    String? targetSubnet,
    String? loginUrl,
    String? httpMethod,
    Map<String, String>? headers,
    int? checkInterval,
    int? loginInterval,
  }) {
    return WifiState(
      isMonitoring: isMonitoring ?? this.isMonitoring,
      currentIp: currentIp ?? this.currentIp,
      status: status ?? this.status,
      message: message ?? this.message,
      credentials: credentials ?? this.credentials,
      logs: logs ?? this.logs,
      currentCredentialIndex:
          currentCredentialIndex ?? this.currentCredentialIndex,
      targetSubnet: targetSubnet ?? this.targetSubnet,
      loginUrl: loginUrl ?? this.loginUrl,
      httpMethod: httpMethod ?? this.httpMethod,
      headers: headers ?? this.headers,
      checkInterval: checkInterval ?? this.checkInterval,
      loginInterval: loginInterval ?? this.loginInterval,
    );
  }
}

class WifiNotifier extends StateNotifier<WifiState> {
  final _networkService = NetworkService();
  final _db = DatabaseHelper();
  Timer? _timer;
  int _consecutiveFailures = 0;
  DateTime? _lastLoginTime;

  WifiNotifier() : super(WifiState()) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final credentials = await _db.getCredentials();
    final logs = await _db.getLogs();
    state = state.copyWith(credentials: credentials, logs: logs);
  }

  void toggleMonitoring() {
    if (state.isMonitoring) {
      _stopMonitoring();
    } else {
      _startMonitoring();
    }
  }

  void _startMonitoring() {
    state = state.copyWith(
      isMonitoring: true,
      status: 'Monitoring',
      message: 'Checking network...',
    );
    _timer = Timer.periodic(Duration(seconds: state.checkInterval), (timer) {
      _checkAndLogin();
    });
  }

  void _stopMonitoring() {
    _timer?.cancel();
    state = state.copyWith(
      isMonitoring: false,
      status: 'Idle',
      message: 'Monitoring stopped',
    );
  }

  Future<void> _checkAndLogin() async {
    final ip = await _networkService.getIPAddress();
    state = state.copyWith(currentIp: ip);

    if (!_networkService.isTargetSubnet(ip, state.targetSubnet)) {
      state = state.copyWith(
        status: 'Wrong Connection',
        message:
            'The device is not connected to the required subnet: ${state.targetSubnet}.',
      );
      return;
    }

    // Check if we need to login
    if (_lastLoginTime != null &&
        DateTime.now().difference(_lastLoginTime!) <
            Duration(seconds: state.loginInterval)) {
      // Still within login interval, just keep monitoring
      return;
    }

    final activeCreds = state.credentials.where((c) => c.isActive).toList();
    if (activeCreds.isEmpty) {
      state = state.copyWith(status: 'Error', message: 'No active credentials');
      _stopMonitoring();
      return;
    }

    final currentCred =
        activeCreds[state.currentCredentialIndex % activeCreds.length];
    state = state.copyWith(
      status: 'Logging in',
      message: 'Attempting with ${currentCred.username}',
    );

    final response = await _networkService.performLogin(
      currentCred,
      state.loginUrl,
      method: state.httpMethod,
      headers: state.headers,
    );
    _lastLoginTime = DateTime.now();

    if (response.isSuccess) {
      _consecutiveFailures = 0;
      state = state.copyWith(status: 'Connected', message: response.message);
    } else {
      _consecutiveFailures++;
      state = state.copyWith(status: 'Login Failed', message: response.message);

      // Same logic as bash script: switch if invalid credentials or data limit exceeded, or max failures reached
      bool switchNeeded =
          response.status == 'LOGIN' &&
          (response.message.contains('Invalid user name/password') ||
              response.message.contains('data transfer has been exceeded'));

      if (switchNeeded || _consecutiveFailures >= 3) {
        _consecutiveFailures = 0;
        state = state.copyWith(
          currentCredentialIndex:
              (state.currentCredentialIndex + 1) % activeCreds.length,
          message: 'Switching to next credential...',
        );
        _lastLoginTime = null; // Trigger immediate retry with next cred
      }
    }

    // Refresh logs
    final logs = await _db.getLogs();
    state = state.copyWith(logs: logs);
  }

  Future<void> addCredential(String username, String password) async {
    await _db.insertCredential(
      Credential(username: username, password: password),
    );
    await _loadInitialData();
  }

  Future<void> deleteCredential(int id) async {
    await _db.deleteCredential(id);
    await _loadInitialData();
  }

  Future<void> toggleCredentialActive(Credential cred) async {
    await _db.updateCredential(cred.copyWith(isActive: !cred.isActive));
    await _loadInitialData();
  }

  Future<void> updateCredential(
    int id,
    String username,
    String password,
  ) async {
    final cred = state.credentials.firstWhere((c) => c.id == id);
    await _db.updateCredential(
      cred.copyWith(username: username, password: password),
    );
    await _loadInitialData();
  }

  Future<LoginResponse> performManualLogin(
    String username,
    String password,
  ) async {
    state = state.copyWith(
      status: 'Logging in',
      message: 'Manual attempt for $username',
    );

    final response = await _networkService.performLoginWithDetails(
      username,
      password,
      state.loginUrl,
      method: state.httpMethod,
      headers: state.headers,
    );

    if (response.isSuccess) {
      state = state.copyWith(status: 'Connected', message: response.message);
    } else {
      state = state.copyWith(status: 'Login Failed', message: response.message);
    }

    // Refresh logs
    final logs = await _db.getLogs();
    state = state.copyWith(logs: logs);

    return response;
  }

  void updateTargetSubnet(String subnet) {
    state = state.copyWith(targetSubnet: subnet);
  }

  void updateLoginUrl(String url) {
    state = state.copyWith(loginUrl: url);
  }

  void updateHttpMethod(String method) {
    state = state.copyWith(httpMethod: method);
  }

  void updateHeaders(Map<String, String> headers) {
    state = state.copyWith(headers: headers);
  }

  Future<void> clearLogs() async {
    await _db.clearLogs();
    final logs = await _db.getLogs();
    state = state.copyWith(logs: logs);
  }

  void updateLoginInterval(int interval) {
    state = state.copyWith(loginInterval: interval);
  }
}

final wifiProvider = StateNotifierProvider<WifiNotifier, WifiState>((ref) {
  return WifiNotifier();
});
