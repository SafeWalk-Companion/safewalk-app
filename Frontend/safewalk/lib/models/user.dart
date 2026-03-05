// User model representing a user account in the SafeWalk application.
//
// This data class is used across the app to hold user information retrieved
// from the backend or entered during registration / login.

class User {
  /// Unique identifier assigned by the backend.
  final String id;

  /// User's display name.
  final String username;

  /// User's email address.
  final String email;

  User({required this.id, required this.username, required this.email});

  /// Constructs a [User] from a JSON map (e.g. API response).
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  /// Serialises this [User] to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {'id': id, 'username': username, 'email': email};
  }

  @override
  String toString() => 'User(id: $id, username: $username, email: $email)';
}
