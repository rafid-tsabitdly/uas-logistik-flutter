import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class MapDirectionScreen extends StatefulWidget {
  const MapDirectionScreen({super.key});

  @override
  State<MapDirectionScreen> createState() => _MapDirectionScreenState();
}

class _MapDirectionScreenState extends State<MapDirectionScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  bool _isLoading = true;
  List<LatLng> _routePoints = [];

  // Titik Gudang Pusat / Stasiun Serpong
  final LatLng _warehousePosition = const LatLng(-6.3218, 106.6661);

  // --- VARIABEL IOT: KONDISI KARGO (Distribusi Keluar) ---
  Timer? _iotTimer;
  double _cargoTemperature = 22.5;
  String _sensorStatus = "Optimal";
  Color _statusColor = Colors.green;

  // --- VARIABEL IOT: SMART BIN E-WASTE (Logistik Balik) ---
  double _smartBinCapacity = 78.5; // Persentase awal kapasitas
  String _binStatus = "Kapasitas Aman";
  Color _binColor = Colors.green;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _startIoTSimulation();
  }

  @override
  void dispose() {
    _iotTimer?.cancel();
    super.dispose();
  }

  // Menjalankan simulasi fluktuasi dua sensor IoT secara bersamaan
  void _startIoTSimulation() {
    _iotTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          // 1. Logika Sensor Suhu Kargo
          _cargoTemperature += (Random().nextDouble() - 0.5) * 0.8;
          if (_cargoTemperature > 25.0) {
            _sensorStatus = "Suhu Tinggi!";
            _statusColor = Colors.red;
          } else if (_cargoTemperature < 20.0) {
            _sensorStatus = "Suhu Rendah!";
            _statusColor = Colors.orange;
          } else {
            _sensorStatus = "Suhu Optimal";
            _statusColor = Colors.green;
          }

          // 2. Logika Sensor Smart Bin (Kapasitas Limbah)
          // Mensimulasikan pembuangan limbah elektronik perlahan-lahan
          _smartBinCapacity += (Random().nextDouble() * 0.6);
          if (_smartBinCapacity >= 100.0) {
            _smartBinCapacity = 100.0;
            _binStatus = "Penuh! Siap Angkut";
            _binColor = Colors.red;
          } else if (_smartBinCapacity >= 85.0) {
            _binStatus = "Hampir Penuh";
            _binColor = Colors.orange;
          } else {
            _binStatus = "Kapasitas Aman";
            _binColor = Colors.green;
          }
        });
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    if (mounted) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
      await _getRoadRoute();
    }
  }

  Future<void> _getRoadRoute() async {
    if (_currentPosition == null) return;
    final url =
        'https://router.project-osrm.org/route/v1/driving/'
        '${_warehousePosition.longitude},${_warehousePosition.latitude};'
        '${_currentPosition!.longitude},${_currentPosition!.latitude}'
        '?geometries=geojson';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List coordinates = data['routes'][0]['geometry']['coordinates'];

        setState(() {
          _routePoints = coordinates.map((c) => LatLng(c[1], c[0])).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _routePoints = [_warehousePosition, _currentPosition!];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rute Distribusi Logistik'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // 1. LAPISAN PETA
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentPosition ?? _warehousePosition,
                    initialZoom: 12.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.uas.logistik',
                    ),
                    MarkerLayer(
                      markers: [
                        if (_currentPosition != null)
                          Marker(
                            point: _currentPosition!,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.local_shipping,
                              color: Colors.blue,
                              size: 40,
                            ),
                          ),
                        Marker(
                          point: _warehousePosition,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.warehouse,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                    if (_routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routePoints,
                            color: Colors.green,
                            strokeWidth: 4.5,
                          ),
                        ],
                      ),
                  ],
                ),

                // 2. PANEL IOT DI ATAS PETA
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // PANEL KIRI: SUHU KARGO
                      Expanded(
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.thermostat,
                                      color: Colors.blue,
                                      size: 18,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Suhu Kargo',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(),
                                Text(
                                  '${_cargoTemperature.toStringAsFixed(1)} °C',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: _statusColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _sensorStatus,
                                  style: TextStyle(
                                    color: _statusColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // PANEL KANAN: SMART BIN (E-Waste)
                      Expanded(
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.delete_outline,
                                      color: Colors.grey,
                                      size: 18,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Smart Bin E-Waste',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(),
                                Text(
                                  '${_smartBinCapacity.toStringAsFixed(1)} %',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: _binColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _binStatus,
                                  style: TextStyle(
                                    color: _binColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        child: const Icon(Icons.center_focus_strong),
        onPressed: () {
          if (_currentPosition != null) {
            _mapController.move(_currentPosition!, 15.0);
          }
        },
      ),
    );
  }
}
