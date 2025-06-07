import 'dart:convert';
import 'package:footinfo_app/config/api_config.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import '../models/team.dart';

class LBSService {
  
  static const Map<String, String> _countryMapping = {
    'Indonesia': 'Indonesia',
    'Malaysia': 'Malaysia',
    'Singapore': 'Singapore',
    'Thailand': 'Thailand',
    'Philippines': 'Philippines',
    'Vietnam': 'Vietnam',
    'England': 'England',
    'Spain': 'Spain',
    'Germany': 'Germany',
    'France': 'France',
    'Italy': 'Italy',
    'Netherlands': 'Netherlands',
    'Portugal': 'Portugal',
    'Brazil': 'Brazil',
    'Argentina': 'Argentina',
    'United States': 'USA',
  };

  
  static String get _apiKey => ApiConfig.footballApiKey;
  static String get _apiHost => ApiConfig.footballApiHost;

  
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  
  static Future<LocationPermission> checkAndRequestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    return permission;
  }

  
  static Future<Position?> getCurrentPosition() async {
    try {
      
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      
      LocationPermission permission = await checkAndRequestPermission();
      
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      
      final LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        timeLimit: const Duration(seconds: 10),
      );

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      return position;
    } catch (e) {
      print('Error getting position: $e');
      return null;
    }
  }

  
  static String getLocationNameFromCoordinates(double latitude, double longitude) {
    
    if (latitude >= -11.0 && latitude <= 6.0 && longitude >= 95.0 && longitude <= 141.0) {
      return 'Indonesia';
    }
    
    else if (latitude >= 49.9 && latitude <= 60.8 && longitude >= -8.2 && longitude <= 1.8) {
      return 'England';
    }
    
    else if (latitude >= 36.0 && latitude <= 43.8 && longitude >= -9.3 && longitude <= 3.3) {
      return 'Spain';
    }
    
    else if (latitude >= 47.3 && latitude <= 55.1 && longitude >= 5.9 && longitude <= 15.0) {
      return 'Germany';
    }
    
    else if (latitude >= 41.3 && latitude <= 51.1 && longitude >= -5.1 && longitude <= 9.6) {
      return 'France';
    }
    
    else if (latitude >= 35.5 && latitude <= 47.1 && longitude >= 6.6 && longitude <= 18.5) {
      return 'Italy';
    }
    
    else if (latitude >= -33.7 && latitude <= 5.3 && longitude >= -73.9 && longitude <= -34.8) {
      return 'Brazil';
    }
    
    else if (latitude >= 24.4 && latitude <= 49.4 && longitude >= -125.0 && longitude <= -66.9) {
      return 'United States';
    }
    
    else if (latitude >= 0.9 && latitude <= 7.4 && longitude >= 99.6 && longitude <= 119.3) {
      return 'Malaysia';
    }
    
    else if (latitude >= 1.16 && latitude <= 1.47 && longitude >= 103.6 && longitude <= 104.0) {
      return 'Singapore';
    }
    
    else if (latitude >= 5.6 && latitude <= 20.5 && longitude >= 97.3 && longitude <= 105.6) {
      return 'Thailand';
    }
    
    else if (latitude >= 50.7 && latitude <= 53.7 && longitude >= 3.4 && longitude <= 7.2) {
      return 'Netherlands';
    }
    
    else if (latitude >= 36.9 && latitude <= 42.2 && longitude >= -9.5 && longitude <= -6.2) {
      return 'Portugal';
    }
    
    else if (latitude >= -55.1 && latitude <= -21.8 && longitude >= -73.6 && longitude <= -53.6) {
      return 'Argentina';
    }
    
    return 'Unknown';
  }

  
  static Future<String> getCurrentLocationName() async {
    try {
      Position? position = await getCurrentPosition();
      
      if (position == null) {
        return 'Unknown';
      }

      String locationName = getLocationNameFromCoordinates(
        position.latitude, 
        position.longitude
      );

      return locationName;
    } catch (e) {
      print('Error getting location name: $e');
      return 'Unknown';
    }
  }

  
  static Future<List<Team>> fetchTeamsByCountry(String country, {int limit = 10}) async {
    try {
      
      if (!ApiConfig.validateConfig()) {
        throw Exception('API configuration is incomplete. Please check your .env file.');
      }

      String mappedCountry = _countryMapping[country] ?? country;
      
      final response = await http.get(
        Uri.parse('https://$_apiHost/teams?country=$mappedCountry'),
        headers: {
          'x-apisports-host': _apiHost,
          'x-apisports-key': _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['response'] as List;
        
        return results
            .take(limit)
            .map((e) => Team.fromJson(e))
            .toList();
      } else {
        throw Exception('Failed to fetch teams: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching teams by country: $e');
      return [];
    }
  }

  
  static Future<List<Team>> getNearbyTeams({int limit = 6}) async {
    try {
      String locationName = await getCurrentLocationName();
      
      if (locationName == 'Unknown') {
        
        return [];
      }

      return await fetchTeamsByCountry(locationName, limit: limit);
    } catch (e) {
      print('Error getting nearby teams: $e');
      return [];
    }
  }

  
  static double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    ) / 1000; 
  }

  
  static String getPermissionStatusText(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.always:
        return 'Always allowed';
      case LocationPermission.whileInUse:
        return 'While in use';
      case LocationPermission.denied:
        return 'Denied';
      case LocationPermission.deniedForever:
        return 'Permanently denied';
      case LocationPermission.unableToDetermine:
        return 'Unable to determine';
    }
  }

  
  static Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  
  static Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  
  static Future<String> getDetailedAddress(Position position) async {
    try {
      
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return 'Location services are disabled';
      }

      
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return 'Location permissions are denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return 'Location permissions are permanently denied';
      }

      
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        
        List<String> addressParts = [
          place.subLocality ?? '',
          place.locality ?? '',
          place.subAdministrativeArea ?? '',
          place.administrativeArea ?? '',
          place.country ?? ''
        ].where((part) => part.isNotEmpty).toList();

        return addressParts.join(', ');
      }
      return 'Address not found';
    } catch (e) {
      print('Error getting detailed address: $e');
      return 'Error getting address: ${e.toString()}';
    }
  }

  
  static Future<Map<String, dynamic>> getLocationInfo() async {
    try {
      Position? position = await getCurrentPosition();
      
      if (position == null) {
        return {
          'status': 'error',
          'message': 'Unable to get location',
          'latitude': null,
          'longitude': null,
          'accuracy': null,
          'locationName': 'Unknown',
          'detailedAddress': 'Unknown',
        };
      }

      String locationName = getLocationNameFromCoordinates(
        position.latitude, 
        position.longitude
      );

      String detailedAddress = await getDetailedAddress(position);

      return {
        'status': 'success',
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'locationName': locationName,
        'detailedAddress': detailedAddress,
        'timestamp': position.timestamp,
      };
    } catch (e) {
      return {
        'status': 'error',
        'message': e.toString(),
        'latitude': null,
        'longitude': null,
        'accuracy': null,
        'locationName': 'Unknown',
        'detailedAddress': 'Unknown',
      };
    }
  }
}