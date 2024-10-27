part of '../../search_map.dart';


class ApiService {
  final String apiKey;
  String _sessionToken = '';

  ApiService(this.apiKey);

  // Generate a new session token
  void _generateNewSessionToken() {
    _sessionToken = const Uuid().v4();
  }

  // Reset the session token, typically after a session ends or when a new search starts
  void refreshSessionToken() {
    _sessionToken = '';
    _generateNewSessionToken();
  }

  Future<Either<Exception, List<PlaceDetails>>> getAutocompletePredictions(String input) async {
    try {
      if (_sessionToken.isEmpty) {
        _generateNewSessionToken();
      }
      final url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey&components=country:sa&sessiontoken=$_sessionToken';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List predictions = data['predictions'];
        return Right(predictions.map((p) => PlaceDetails.fromJson(p)).toList());
      } else {
        return Left(Exception('Failed to load predictions'));
      }
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  Future<Either<Exception, PlaceDetails>> getPlaceDetails(String placeId) async {
    try {
      final url =
          'https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeId&key=$apiKey&sessiontoken=$_sessionToken';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Right(PlaceDetails.fromJson(data['result']));
      } else {
        return Left(Exception('Failed to load place details'));
      }
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }
}
