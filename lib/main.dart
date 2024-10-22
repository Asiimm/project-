import 'dart:convert';
import 'dart:io';
import 'package:capstone2/SpotifyApi/Screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:http/http.dart' as http;
import 'package:capstone2/logs/logs.dart';
import 'package:capstone2/permission/permission.dart';
import 'package:capstone2/sync/sync.dart';
import 'package:capstone2/loginSignup/screen/account.dart';
import 'package:capstone2/loginSignup/screen/login.dart';
import 'package:capstone2/loginSignup/screen/forget.dart';
import 'package:capstone2/homeScreen/home_screen.dart';
import 'package:capstone2/loginSignup/screen/email_verification.dart';
import 'package:capstone2/Services/auth_wrapper.dart';

class PostHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  HttpOverrides.global = new PostHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final String clientId = 'b54219d1e27c409782f2d68118690250';
  final String clientSecret = 'ae2ef45cd190407a8de23d42118b60d2';

  @override
  void initState() {
    super.initState();
    _handleDynamicLinks();
  }

  Future<void> _handleDynamicLinks() async {
    FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

    // Capture dynamic link when the app is already open
    dynamicLinks.onLink.listen((PendingDynamicLinkData? dynamicLinkData) {
      final Uri? deepLink = dynamicLinkData?.link;
      if (deepLink != null) {
        print('Dynamic link received: $deepLink');
        _handleDeepLink(deepLink);
      }
    }).onError((error) {
      print('Error handling dynamic link: ${error.message}');
    });

    // Capture dynamic link when the app is closed and then opened via the link
    final PendingDynamicLinkData? initialLink = await dynamicLinks.getInitialLink();
    if (initialLink != null) {
      final Uri? deepLink = initialLink.link;
      if (deepLink != null) {
        print('Initial dynamic link received: $deepLink');
        _handleDeepLink(deepLink);
      }
    }
  }

  void _handleDeepLink(Uri deepLink) {
    print('Deep link received: $deepLink');

    // Check if the path matches your expected path
    if (deepLink.path == "/fitbit") {
      // Log all query parameters
      print('Query parameters: ${deepLink.queryParameters}');

      // Extract the authorization code
      final authCode = deepLink.queryParameters['code'];

      if (authCode != null) {
        print('Spotify authentication completed with code: $authCode');
        // Now you can exchange this code for an access token
        _exchangeCodeForToken(authCode);
      } else {
        print('Authorization code not found in deep link: $deepLink');
      }
    }
  }

  Future<void> _exchangeCodeForToken(String authCode) async {
    final response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Basic ' + base64Encode(utf8.encode('$clientId:$clientSecret')),
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


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(),
      routes: {
        'account': (context) => Account(),
        'forget': (context) => ForgetPassword(),
        'home_screen': (context) => const HomeScreen(),
        'login': (context) => const Login(),
        'email_verification': (context) => EmailVerification(),
        'sync': (context) => Sync(),
        'logs': (context) => Logs(),
        'permission': (context) => Permission(),
        'screen': (context) => Spotify(),
      },
    );
  }
}
