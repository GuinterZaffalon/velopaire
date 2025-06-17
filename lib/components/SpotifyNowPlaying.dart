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
    // 1. Solicite o token com os scopes necessários
    await SpotifySdk.getAccessToken(
      clientId: '3da8f5d70dd843e193694a1beb837b5e',
      redirectUrl: 'myapp://callback',
      scope: 'app-remote-control,user-read-playback-state,user-modify-playback-state,user-read-currently-playing',
    );

    // 2. Só depois tente conectar
    bool result = await SpotifySdk.connectToSpotifyRemote(
      clientId: '3da8f5d70dd843e193694a1beb837b5e',
      redirectUrl: 'myapp://callback',
    );

    setState(() {
      _connected = result;
    });
  } catch (e, stack) {
    debugPrint('Erro ao conectar ao Spotify: $e');
    debugPrintStack(stackTrace: stack);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao conectar: $e')),
    );
  }
}


  @override
  void initState() {
    super.initState();
    _connectToSpotify();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _connected
          ? StreamBuilder<PlayerState>(
              stream: SpotifySdk.subscribePlayerState(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data?.track == null) {
                  return const Center(
                      child: Text('Nada está tocando no momento.'));
                }
                final track = snapshot.data!.track!;
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (track.imageUri.raw != null)
                        Image.network(
                          // O SDK retorna apenas o URI, você pode usar o Web API para buscar a imagem real se quiser
                          'https://i.scdn.co/image/${track.imageUri.raw.split(":").last}',
                          width: 200,
                          height: 200,
                        ),
                      const SizedBox(height: 24),
                      Text(
                        track.name,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        track.artist.name!,
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        track.album.name!,
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
