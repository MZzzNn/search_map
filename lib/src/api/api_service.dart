part of '../../search_map.dart';


class ApiService {
  final String apiKey;
  String _sessionToken = '';

  ApiService(this.apiKey);

  void _generateSessionToken() {
    _sessionToken = const Uuid().v4();
  }

  Future<Either<Exception, List<PlaceDetails>>> getAutocompletePredictions(String input) async {
    try {
      _generateSessionTokenIfNeeded();
      final response = await http.get(_buildAutocompleteUrl(input));
      return _handleAutocompleteResponse(response);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  Future<Either<Exception, PlaceDetails>> getPlaceDetails(String placeId) async {
    try {
      final response = await http.get(_buildPlaceDetailsUrl(placeId));
      return _handlePlaceDetailsResponse(response);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  void _generateSessionTokenIfNeeded() {
    if (_sessionToken.isEmpty) _generateSessionToken();
  }

  Uri _buildAutocompleteUrl(String input) {
    return Uri.parse('https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey&sessiontoken=$_sessionToken');
  }

  Uri _buildPlaceDetailsUrl(String placeId) {
    return Uri.parse('https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeId&key=$apiKey&sessiontoken=$_sessionToken');
  }

  Either<Exception, List<PlaceDetails>> _handleAutocompleteResponse(http.Response response) {
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final predictions = (data['predictions'] as List)
          .map((e) => PlaceDetails.fromJson(e))
          .toList();
      return Right(predictions);
    } else {
      return Left(Exception('Failed to load predictions'));
    }
  }

  Either<Exception, PlaceDetails> _handlePlaceDetailsResponse(http.Response response) {
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Right(PlaceDetails.fromJson(data['result']));
    } else {
      return Left(Exception('Failed to load place details'));
    }
  }
}
