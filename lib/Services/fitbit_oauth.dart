import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

// Your OAuth 2.0 Client ID and Secret
const String clientId = '23PTY6';
const String clientSecret = 'c0bed81c7969098a27d425f81ac421ab';
const String redirectUri = 'https://fitbitscreen.page.link/fitbitScreen/callback';
const String authUri = 'https://www.fitbit.com/oauth2/authorize';
const String tokenUri = 'https://api.fitbit.com/oauth2/token';

// Function to launch the Fitbit OAuth flow
Future<void> launchFitbitOAuth() async {
  final Uri uri = Uri.parse(
    '$authUri?response_type=code&client_id=$clientId&redirect_uri=$redirectUri&scope=activity heartrate nutrition sleep',
  );
  await launch(uri.toString());
}

// Function to exchange the authorization code for an access token
Future<String?> exchangeCodeForToken(String code) async {
  final response = await http.post(
    Uri.parse(tokenUri),
    headers: {
      'Authorization': 'Basic ' + base64Encode(utf8.encode('$clientId:$clientSecret')),
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: {
      'client_id': clientId,
      'grant_type': 'authorization_code',
      'redirect_uri': redirectUri,
      'code': code,
    },
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> body = jsonDecode(response.body);
    return body['access_token']; // Return the access token
  } else {
    print('Failed to exchange code for token: ${response.body}');
    return null; // Handle error appropriately
  }
}

// Function to fetch Fitbit data using the access token
Future<Map<String, dynamic>?> fetchFitbitData(String accessToken) async {
  final response = await http.get(
    Uri.parse('https://api.fitbit.com/1/user/-/activities/date/today.json'),
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = jsonDecode(response.body);
    return data; // Return the fetched data
  } else {
    print('Failed to fetch Fitbit data: ${response.body}');
    return null; // Handle error appropriately
  }
}
