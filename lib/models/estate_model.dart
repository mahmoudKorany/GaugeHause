class Location {
  final List<double> coordinates;
  final String type;

  Location({
    required this.coordinates,
    required this.type,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      coordinates:
          List<double>.from(json['coordinates'].map((x) => x.toDouble())),
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coordinates': coordinates,
      'type': type,
    };
  }
}

class Estate {
  final Location location;
  final String id;
  final String title;
  final String propertyType;
  final double price;
  final String description;
  final int bedrooms;
  final int bathrooms;
  final int livingrooms;
  final int kitchen;
  final double area;
  final String compoundName;
  final bool furnished;
  final DateTime deliveryDate;
  final String owner;
  final String ownerName;
  final String ownerImage;
  final int likes;
  final List<String> images;
  final int version;

  Estate({
    required this.location,
    required this.id,
    required this.title,
    this.propertyType = '',
    this.price = 0.0,
    this.description = '',
    this.bedrooms = 0,
    this.bathrooms = 0,
    this.livingrooms = 0,
    this.kitchen = 0,
    required this.area,
    this.compoundName = '',
    this.furnished = false,
    DateTime? deliveryDate,
    this.owner = '',
    this.ownerName = '',
    this.ownerImage = '',
    this.likes = 0,
    this.images = const [],
    this.version = 0,
  }) : deliveryDate = deliveryDate ?? DateTime.now();

  factory Estate.fromJson(Map<String, dynamic> json) {
    return Estate(
      location: Location.fromJson(json['location'] ??
          {
            'coordinates': [0.0, 0.0],
            'type': 'Point'
          }),
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      propertyType: json['propertyType'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      bedrooms: json['bedrooms'] ?? 0,
      bathrooms: json['bathrooms'] ?? 0,
      livingrooms: json['livingrooms'] ?? 0,
      kitchen: json['kitchen'] ?? 0,
      area: (json['area'] ?? 0).toDouble(),
      compoundName: json['compoundName'] ?? '',
      furnished: json['furnished'] ?? false,
      deliveryDate: json['deliveryDate'] != null
          ? DateTime.parse(json['deliveryDate'])
          : DateTime.now(),
      owner: json['owner'] ?? '',
      ownerName: json['ownerName'] ?? '',
      ownerImage: json['ownerImage'] ?? '',
      likes: json['likes'] ?? 0,
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      version: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location.toJson(),
      '_id': id,
      'title': title,
      'propertyType': propertyType,
      'price': price,
      'description': description,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'livingrooms': livingrooms,
      'kitchen': kitchen,
      'area': area,
      'compoundName': compoundName,
      'furnished': furnished,
      'deliveryDate': deliveryDate.toIso8601String(),
      'owner': owner,
      'ownerName': ownerName,
      'ownerImage': ownerImage,
      'likes': likes,
      'images': images,
      '__v': version,
    };
  }

  // Helper method to get formatted price
  String get formattedPrice {
    return '\$${price.toStringAsFixed(0)}';
  }

  // Helper method to get room summary
  String get roomSummary {
    return '$bedrooms bed • $bathrooms bath • $livingrooms living';
  }

  // Helper method to get formatted area
  String get formattedArea {
    return '${area.toStringAsFixed(0)} sqft';
  }

  // Helper method to check if delivery is upcoming
  bool get isUpcomingDelivery {
    return deliveryDate.isAfter(DateTime.now());
  }
}

class EstateResponse {
  final String status;
  final EstateData data;

  EstateResponse({
    required this.status,
    required this.data,
  });

  factory EstateResponse.fromJson(Map<String, dynamic> json) {
    return EstateResponse(
      status: json['status'],
      data: EstateData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.toJson(),
    };
  }
}

class EstateData {
  final Estate estate;

  EstateData({
    required this.estate,
  });

  factory EstateData.fromJson(Map<String, dynamic> json) {
    return EstateData(
      estate: Estate.fromJson(json['estate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'estate': estate.toJson(),
    };
  }
}
