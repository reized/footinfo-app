import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import '../models/team.dart';

class LBSService {
  // Country mapping for location to country code
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

  static const String _apiKey = '86ab1cfe67a66269855aa7f7d32ce1e7';
  static const String _apiHost = 'v3.football.api-sports.io';

  /// Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check and request location permissions
  static Future<LocationPermission> checkAndRequestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    return permission;
  }

  /// Get current position with error handling
  static Future<Position?> getCurrentPosition() async {
    try {
      // Check if location service is enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Check permissions
      LocationPermission permission = await checkAndRequestPermission();
      
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get position with platform-specific settings
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

  /// Convert coordinates to location name (simplified geocoding)
  static String getLocationNameFromCoordinates(double latitude, double longitude) {
    // Indonesia
    if (latitude >= -11.0 && latitude <= 6.0 && longitude >= 95.0 && longitude <= 141.0) {
      return 'Indonesia';
    }
    // England/UK
    else if (latitude >= 49.9 && latitude <= 60.8 && longitude >= -8.2 && longitude <= 1.8) {
      return 'England';
    }
    // Spain
    else if (latitude >= 36.0 && latitude <= 43.8 && longitude >= -9.3 && longitude <= 3.3) {
      return 'Spain';
    }
    // Germany
    else if (latitude >= 47.3 && latitude <= 55.1 && longitude >= 5.9 && longitude <= 15.0) {
      return 'Germany';
    }
    // France
    else if (latitude >= 41.3 && latitude <= 51.1 && longitude >= -5.1 && longitude <= 9.6) {
      return 'France';
    }
    // Italy
    else if (latitude >= 35.5 && latitude <= 47.1 && longitude >= 6.6 && longitude <= 18.5) {
      return 'Italy';
    }
    // Brazil
    else if (latitude >= -33.7 && latitude <= 5.3 && longitude >= -73.9 && longitude <= -34.8) {
      return 'Brazil';
    }
    // USA
    else if (latitude >= 24.4 && latitude <= 49.4 && longitude >= -125.0 && longitude <= -66.9) {
      return 'United States';
    }
    // Malaysia
    else if (latitude >= 0.9 && latitude <= 7.4 && longitude >= 99.6 && longitude <= 119.3) {
      return 'Malaysia';
    }
    // Singapore
    else if (latitude >= 1.16 && latitude <= 1.47 && longitude >= 103.6 && longitude <= 104.0) {
      return 'Singapore';
    }
    // Thailand
    else if (latitude >= 5.6 && latitude <= 20.5 && longitude >= 97.3 && longitude <= 105.6) {
      return 'Thailand';
    }
    // Netherlands
    else if (latitude >= 50.7 && latitude <= 53.7 && longitude >= 3.4 && longitude <= 7.2) {
      return 'Netherlands';
    }
    // Portugal
    else if (latitude >= 36.9 && latitude <= 42.2 && longitude >= -9.5 && longitude <= -6.2) {
      return 'Portugal';
    }
    // Argentina
    else if (latitude >= -55.1 && latitude <= -21.8 && longitude >= -73.6 && longitude <= -53.6) {
      return 'Argentina';
    }
    
    return 'Unknown';
  }

  /// Get current location name
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

  /// Fetch teams by country
  static Future<List<Team>> fetchTeamsByCountry(String country, {int limit = 10}) async {
    try {
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

  /// Get nearby teams based on current location
  static Future<List<Team>> getNearbyTeams({int limit = 6}) async {
    try {
      String locationName = await getCurrentLocationName();
      
      if (locationName == 'Unknown') {
        // Fallback to a default country or return empty list
        return [];
      }

      return await fetchTeamsByCountry(locationName, limit: limit);
    } catch (e) {
      print('Error getting nearby teams: $e');
      return [];
    }
  }

  /// Calculate distance between two points (in kilometers)
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
    ) / 1000; // Convert to kilometers
  }

  /// Get location permission status as readable string
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

  /// Open location settings
  static Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app settings
  static Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Get detailed address from coordinates
  static Future<String> getDetailedAddress(Position position) async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return 'Location services are disabled';
      }

      // Check location permissions
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

      // Get address details
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        // Build address string, only including non-empty components
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

  /// Get detailed location info
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