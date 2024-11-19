class MarkerModel {
  String nameOfThePlace;
  double latitude;
  double longitude;
  String title;
  String snippet;

  MarkerModel({
    required this.nameOfThePlace,
    required this.latitude,
    required this.longitude,
    required this.title,
    required this.snippet,
  });

  /// Converts the model to a map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'nameOfThePlace': nameOfThePlace,
      'latitude': latitude,
      'longitude': longitude,
      'title': title,
      'snippet': snippet,
    };
  }

  /// Creates a model from a map (useful for reading Firestore data)
  factory MarkerModel.fromMap(Map<String, dynamic> map) {
    return MarkerModel(
      nameOfThePlace: map['nameOfThePlace'] ?? '',
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0,
      title: map['title'] ?? '',
      snippet: map['snippet'] ?? '',
    );
  }
}
