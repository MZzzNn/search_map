part of '../../search_map.dart';


class PlaceDetails {
  final String? description;
  final String? placeId;
  final String? name;
  final String? formattedAddress;
  final double? latitude;
  final double? longitude;

  PlaceDetails({
    this.placeId,
    this.description,
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
      latitude:json['geometry'] !=null ? json['geometry']['location']['lat'] : null,
      longitude:json['geometry'] !=null ? json['geometry']['location']['lng'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'formatted_address': formattedAddress,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'place_id': placeId,
    };
  }
  PlaceDetails copyWith({
    String? description,
    String? placeId,
    String? name,
    String? formattedAddress,
    double? latitude,
    double? longitude,
  }) {
    return PlaceDetails(
      description: description ?? this.description,
      placeId: placeId ?? this.placeId,
      name: name ?? this.name,
      formattedAddress: formattedAddress ?? this.formattedAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
