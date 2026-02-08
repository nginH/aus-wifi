import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:network_info_plus/network_info_plus.dart';
import '../models/credential.dart';
import 'database_helper.dart';
import '../models/login_log.dart';

class LoginResponse {
  final String status;
  final String message;
  final bool isSuccess;

  LoginResponse({
    required this.status,
    required this.message,
    required this.isSuccess,
  });
}

class NetworkService {
  final _networkInfo = NetworkInfo();
  final _db = DatabaseHelper();

  Future<String?> getIPAddress() async {
    return await _networkInfo.getWifiIP();
  }

  bool isTargetSubnet(String? ip, String targetSubnet) {
    if (ip == null) return false;
    return ip.startsWith(targetSubnet);
  }

  Future<LoginResponse> performLogin(Credential credential) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final url = Uri.parse('http://172.16.1.1:8090/login.xml');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: {
              'mode': '191',
              'username': credential.username,
              'password': credential.password,
              'a': timestamp,
              'producttype': '0',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return _parseLoginResponse(response.body, credential.username);
      } else {
        return LoginResponse(
          status: 'ERROR',
          message: 'HTTP ${response.statusCode}',
          isSuccess: false,
        );
      }
    } catch (e) {
      return LoginResponse(
        status: 'CONN_ERROR',
        message: e.toString(),
        isSuccess: false,
      );
    }
  }

  LoginResponse _parseLoginResponse(String xmlBody, String username) {
    try {
      final document = xml.XmlDocument.parse(xmlBody);
      final status = _cleanCData(
        document.findAllElements('status').first.innerText,
      );
      final message = _cleanCData(
        document.findAllElements('message').first.innerText,
      );

      bool success = status == 'LIVE';

      // Log to database
      _db.insertLog(
        LoginLog(
          timestamp: DateTime.now(),
          username: username,
          status: status,
          message: message,
        ),
      );

      return LoginResponse(
        status: status,
        message: message,
        isSuccess: success,
      );
    } catch (e) {
      return LoginResponse(
        status: 'PARSE_ERROR',
        message: 'Failed to parse response',
        isSuccess: false,
      );
    }
  }

  String _cleanCData(String text) {
    return text.replaceAll('<![CDATA[', '').replaceAll(']]>', '').trim();
  }
}
