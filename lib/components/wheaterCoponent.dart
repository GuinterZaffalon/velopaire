import 'package:weather/weather.dart';
import 'package:flutter/material.dart';

class WeatherComponent extends StatefulWidget {
  final double lat;
  final double long;
  const WeatherComponent({super.key, required this.lat, required this.long});

  @override
  State<WeatherComponent> createState() => _WeatherComponentState();
}

class _WeatherComponentState extends State<WeatherComponent> {
  late final WeatherFactory wf;
  Weather? _weather;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    wf = WeatherFactory(
      "95fca6d3796cc010b75d4f6e0820272a",
      language: Language.PORTUGUESE_BRAZIL,
    );
    _fetchWeather();
  }

  String _getWeatherIcon(String? condition) {
    if (condition == null) return '🌍';
    condition = condition.toLowerCase();
    
    if (condition.contains('clear')) return '☀️';
    if (condition.contains('cloud')) return '☁️';
    if (condition.contains('rain')) return '🌧️';
    if (condition.contains('snow')) return '❄️';
    if (condition.contains('thunderstorm')) return '⛈️';
    if (condition.contains('drizzle')) return '🌦️';
    if (condition.contains('mist') || condition.contains('fog')) return '🌫️';
    
    return '🌍';
  }

  Future<void> _fetchWeather() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final weather = await wf.currentWeatherByLocation(widget.lat, widget.long);
      setState(() {
        _weather = weather;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao buscar clima: $e';
        _loading = false;
      });
    }
  }

  Widget _buildWeatherInfo(String emoji, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    if (_weather == null) {
      return const Center(child: Text('Nenhum dado de clima disponível.'));
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade700,
            Colors.blue.shade500,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Text(
                _getWeatherIcon(_weather!.weatherDescription),
                style: const TextStyle(fontSize: 100),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _weather!.areaName ?? 'Local desconhecido',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _weather!.weatherDescription ?? '',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildWeatherInfo(
                        '🌡️',
                        '${_weather!.temperature?.celsius?.toStringAsFixed(1)}°C',
                        'Temperatura',
                      ),
                      _buildWeatherInfo(
                        '💧',
                        '${_weather!.humidity?.toStringAsFixed(0)}%',
                        'Umidade',
                      ),
                      _buildWeatherInfo(
                        '💨',
                        '${_weather!.windSpeed?.toStringAsFixed(1)} km/h',
                        'Vento',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton.icon(
                      onPressed: _fetchWeather,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text(
                        'Atualizar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
