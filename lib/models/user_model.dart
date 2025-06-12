class User {
  final String id;
  final String name;
  final String email;
  final String image;

  final DateTime joinedAt;
  final int version;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.image,
    required this.joinedAt,
    required this.version,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      image: json['image'],
      joinedAt: DateTime.parse(json['joinedAt']),
      version: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'image': image,
      'joinedAt': joinedAt.toIso8601String(),
      '__v': version,
    };
  }

  // Helper method to get user initials for avatar fallback
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'U';
  }

  // Helper method to get formatted join date
  String get formattedJoinDate {
    return '${joinedAt.day}/${joinedAt.month}/${joinedAt.year}';
  }

  // Helper method to get membership duration in days
  int get membershipDays {
    return DateTime.now().difference(joinedAt).inDays;
  }
}

class UserData {
  final User user;

  UserData({
    required this.user,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      user: User.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
    };
  }
}

class LoginResponse {
  final String status;
  final String token;
  final UserData data;

  LoginResponse({
    required this.status,
    required this.token,
    required this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status'],
      token: json['token'],
      data: UserData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'token': token,
      'data': data.toJson(),
    };
  }
}
