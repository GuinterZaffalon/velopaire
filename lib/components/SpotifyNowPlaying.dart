import 'package:flutter/material.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:spotify_sdk/models/player_state.dart';

class SpotifyNowPlayingScreen extends StatefulWidget {
  const SpotifyNowPlayingScreen({super.key});

  @override
  State<SpotifyNowPlayingScreen> createState() =>
      _SpotifyNowPlayingScreenState();
}

class _SpotifyNowPlayingScreenState extends State<SpotifyNowPlayingScreen> {
  bool _connected = false;

  Future<void> _connectToSpotify() async {
    try {
      // 1. Solicite o token (isso abre o login do Spotify se necessário)
      final token = await SpotifySdk.getAccessToken(
          clientId: '3da8f5d70dd843e193694a1beb837b5e',
          redirectUrl: 'myapp://callback',
          scope:
              "app-remote-control,user-modify-playback-state,playlist-read-private");

      // 2. Agora conecte ao Spotify Remote
      bool result = await SpotifySdk.connectToSpotifyRemote(
          clientId: '3da8f5d70dd843e193694a1beb837b5e',
          redirectUrl: 'myapp://callback',
          accessToken: token);

      setState(() {
        _connected = result;
      });
    } catch (e, stack) {
      debugPrint('Erro ao conectar ao Spotify: $e');
      debugPrintStack(stackTrace: stack);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao conectar: $e')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _connectToSpotify();
  }

  @override
  Widget build(BuildContext context) {
    return _connected
        ? StreamBuilder<PlayerState>(
            stream: SpotifySdk.subscribePlayerState(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data?.track == null) {
                return const Center(
                    child: Text('Nada está tocando no momento.'));
              }
              final track = snapshot.data!.track!;
              return Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (track.imageUri.raw != null)
                          Image.network(
                            'https://i.scdn.co/image/${track.imageUri.raw.split(":").last}',
                            width: 100,
                            height: 200,
                          ),
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  track.name,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  textAlign: TextAlign.left,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  track.artist.name ?? '',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  textAlign: TextAlign.left,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  track.album.name ?? '',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ));
            },
          )
        : const Center(child: CircularProgressIndicator());
  }
}
