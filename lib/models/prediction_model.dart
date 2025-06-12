class Prediction {
  final String id;
  final String title;
  final String city;
  final String propertyType;
  final String furnished;
  final String deliveryTerm;
  final int bedrooms;
  final int bathrooms;
  final double area;
  final int level;
  final double price;
  final double pricePerSqm;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  Prediction({
    required this.id,
    required this.title,
    required this.city,
    required this.propertyType,
    required this.furnished,
    required this.deliveryTerm,
    required this.bedrooms,
    required this.bathrooms,
    required this.area,
    required this.level,
    required this.price,
    required this.pricePerSqm,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      id: json['_id'],
      title: json['title'],
      city: json['city'],
      propertyType: json['propertyType'],
      furnished: json['furnished'],
      deliveryTerm: json['deliveryTerm'],
      bedrooms: json['bedrooms'],
      bathrooms: json['bathrooms'],
      area: json['area'].toDouble(),
      level: json['level'],
      price: json['price'].toDouble(),
      pricePerSqm: json['pricePerSqm'].toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      version: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'city': city,
      'propertyType': propertyType,
      'furnished': furnished,
      'deliveryTerm': deliveryTerm,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'area': area,
      'level': level,
      'price': price,
      'pricePerSqm': pricePerSqm,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
    };
  }

  // Helper method to get formatted price
  String get formattedPrice {
    return '\$${price.toStringAsFixed(0)}';
  }

  // Helper method to get formatted price per square meter
  String get formattedPricePerSqm {
    return '\$${pricePerSqm.toStringAsFixed(2)}/sqm';
  }

  // Helper method to get formatted area
  String get formattedArea {
    return '${area.toStringAsFixed(0)} sqm';
  }

  // Helper method to get room summary
  String get roomSummary {
    return '$bedrooms bed • $bathrooms bath';
  }

  // Helper method to check if furnished
  bool get isFurnished {
    return furnished.toLowerCase() == 'yes';
  }

  // Helper method to check if finished
  bool get isFinished {
    return deliveryTerm.toLowerCase() == 'finished';
  }
}

class PredictionResponse {
  final String status;
  final PredictionData data;

  PredictionResponse({
    required this.status,
    required this.data,
  });

  factory PredictionResponse.fromJson(Map<String, dynamic> json) {
    return PredictionResponse(
      status: json['status'],
      data: PredictionData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.toJson(),
    };
  }
}

class PredictionData {
  final Prediction prediction;

  PredictionData({
    required this.prediction,
  });

  factory PredictionData.fromJson(Map<String, dynamic> json) {
    return PredictionData(
      prediction: Prediction.fromJson(json['prediction']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prediction': prediction.toJson(),
    };
  }
}

// For handling multiple predictions
class PredictionListResponse {
  final String status;
  final List<Prediction> predictions;

  PredictionListResponse({
    required this.status,
    required this.predictions,
  });

  factory PredictionListResponse.fromJson(Map<String, dynamic> json) {
    return PredictionListResponse(
      status: json['status'],
      predictions: List<Prediction>.from(
        json['predictions'].map((x) => Prediction.fromJson(x)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'predictions': predictions.map((x) => x.toJson()).toList(),
    };
  }
}
