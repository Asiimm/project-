//connect.dart

import 'package:capstone2/SpotifyApi/Screen.dart';
import 'package:flutter/material.dart';
import 'spotify_auth.dart'; // Import the SpotifyAuth class
import '../loginSignup/widget/button.dart';
import 'package:capstone2/SpotifyApi/spotify_auth_handler.dart';

class SpotifyPage extends StatefulWidget {
  const SpotifyPage({super.key});

  @override
  State<SpotifyPage> createState() => _SpotifyPageState();
}

class _SpotifyPageState extends State<SpotifyPage> {
  final SpotifyAuthHandler _spotifyAuthHandler = SpotifyAuthHandler();
  final SpotifyAuth _spotifyAuth = SpotifyAuth();
  bool _isLoading = false;
  String? _errorMessage;


  Future<void> _connectToSpotify() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _spotifyAuth.authenticateSpotify();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to connect to Spotify. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF492A87),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          onPressed: () {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const Spotify(),
                ),
            );
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Spotify',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Connect your Spotify account to share your music playlist',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (_errorMessage != null) // Show error message if exists
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                ),
              ),
            ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Regbutton(
                text: _isLoading ? 'Connecting...' : 'Connect to Spotify',
                onTab: _isLoading ? () {} : _connectToSpotify, // Disable button while loading
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'By connecting your Spotify account, you consent to the collection, use, and disclosure of your data in accordance with the Privacy Policy.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
