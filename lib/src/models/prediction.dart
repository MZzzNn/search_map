part of '../../search_map.dart';


class PlaceDetails {
  final String? description;
  final String? placeId;
  final String? name;
  final String? formattedAddress;
  final double? latitude;
  final double? longitude;

  PlaceDetails({
    this.description,
    this.placeId,
    this.name,
    this.formattedAddress,
    this.latitude,
    this.longitude,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    return PlaceDetails(
      placeId: json['place_id'],
      description: json['description'],
      name: json['name'],
      formattedAddress: json['formatted_address'],
      latitude: json['geometry']?['location']?['lat'],
      longitude: json['geometry']?['location']?['lng'],
    );
  }

  Map<String, dynamic> toJson() => {
    'description': description,
    'place_id': placeId,
    'name': name,
    'formatted_address': formattedAddress,
    'latitude': latitude,
    'longitude': longitude,
  };
}
