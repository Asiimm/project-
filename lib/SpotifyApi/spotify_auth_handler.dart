import 'package:flutter/services.dart';
import 'dart:convert'; // For json decoding
import 'package:http/http.dart' as http;

class SpotifyAuthHandler {
  static const MethodChannel _channel = MethodChannel('auth');
  final String clientId = 'b54219d1e27c409782f2d68118690250';
  final String clientSecret = 'ae2ef45cd190407a8de23d42118b60d2';
  final String redirectUri = 'com.example.capstone2:/callback';

  SpotifyAuthHandler() {
    // Listen for the authorization code from native Android
    _channel.setMethodCallHandler(_handleAuthCode);
  }

  // Handle the authorization code from the native side
  Future<void> _handleAuthCode(MethodCall call) async {
    if (call.method == 'onAuthCode') {
      final String authCode = call.arguments;
      print('Received authorization code: $authCode');
      // Now exchange the auth code for an access token
    } else {
      print('Unexpected method call: ${call.method}');
    }
  }

  // Exchange the authorization code for an access token
  Future<void> _exchangeCodeForToken(String authCode) async {
    final response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Basic ' + base64Encode(utf8.encode('$clientId:YOUR_CLIENT_SECRET')),
      },
      body: {
        'grant_type': 'authorization_code',
        'code': authCode,
        'redirect_uri': 'https://firebasefitbitlink.page.link/fitbit',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      String accessToken = responseData['access_token'];
      String refreshToken = responseData['refresh_token'];

      print('Access Token: $accessToken');
      print('Refresh Token: $refreshToken');
      // Save the tokens securely for later use
    } else {
      print('Failed to exchange code for token: ${response.body}');
    }



  }
}
