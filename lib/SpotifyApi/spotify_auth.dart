import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

class SpotifyAuth {
  final String clientId = 'b54219d1e27c409782f2d68118690250';
  final String redirectUri = 'com.example.capstone2:/callback';
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final FlutterAppAuth _appAuth = FlutterAppAuth();



  Future<void> authenticateSpotify() async {
    try {
      print('Starting authentication with redirect URI: $redirectUri');

      // Spotify authorization and token endpoints
      final AuthorizationServiceConfiguration serviceConfiguration = AuthorizationServiceConfiguration(
        authorizationEndpoint: 'https://accounts.spotify.com/authorize',
        tokenEndpoint: 'https://accounts.spotify.com/api/token',
      );

      // Create the authorization token request
      final AuthorizationTokenResponse? response = await _appAuth
          .authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          clientId,
          redirectUri,
          serviceConfiguration: serviceConfiguration,
          scopes: ['playlist-read-private', 'playlist-read-collaborative'],
        ),
      );

      if (response != null) {
        // Log the full response for better debugging
        print('Authorization successful: ${response.toString()}');

        // Store the access token securely
        await _storage.write(key: 'access_token', value: response.accessToken);
        print('Access Token: ${response.accessToken}');
      } else {
        print('Authorization failed: Response was null.');
        throw Exception('Authorization response was null.');
      }
    } catch (e) {
      print('Error during Spotify authentication: ${e.toString()}');
      throw Exception('Authentication failed: ${e.toString()}');
    }
  }

  Future<void> fetchUserPlaylists() async {
    try {
      // Retrieve the access token
      String? accessToken = await _storage.read(key: 'access_token');
      if (accessToken == null) {
        throw Exception('Access token is null. Please authenticate first.');
      }

      // Make a GET request to the Spotify API to fetch user playlists
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/me/playlists'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        // Parse the response
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        List<dynamic> playlists = jsonResponse['items'];

        // Print playlists or do something with them
        for (var playlist in playlists) {
          print('Playlist Name: ${playlist['name']}');
          print('Playlist ID: ${playlist['id']}');
        }
      } else {
        print('Failed to fetch playlists: ${response.statusCode} ${response
            .body}');
      }
    } catch (e) {
      print('Error fetching user playlists: ${e.toString()}');
      throw Exception('Failed to fetch playlists: ${e.toString()}');
    }
  }
}



