class UserModel {
  final String userId;
  final String? displayName;   // aligned with Firebase displayName
  final String email;
  final String? phone;
  final String? location;
  final String? profilePicture;
  final DateTime? createdAt;
  final int totalProjects;

  UserModel({
    required this.userId,
    this.displayName,
    required this.email,
    this.phone,
    this.location,
    this.profilePicture,
    this.createdAt,
    this.totalProjects = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId:         json['user_id'] as String? ?? '',
      displayName:    json['display_name'] as String? ?? json['name'] as String?,
      email:          json['email'] as String? ?? '',
      phone:          json['phone'] as String?,
      location:       json['location'] as String?,
      profilePicture: json['profile_picture'] as String?,
      createdAt:      json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      totalProjects: json['total_projects'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id':        userId,
    'display_name':   displayName,
    'email':          email,
    'phone':          phone,
    'location':       location,
    'profile_picture':profilePicture,
    'created_at':     createdAt?.toIso8601String(),
    'total_projects': totalProjects,
  };

  UserModel copyWith({
    String? displayName,
    String? phone,
    String? location,
    String? profilePicture,
    int? totalProjects,
  }) => UserModel(
    userId:         userId,
    displayName:    displayName ?? this.displayName,
    email:          email,
    phone:          phone ?? this.phone,
    location:       location ?? this.location,
    profilePicture: profilePicture ?? this.profilePicture,
    createdAt:      createdAt,
    totalProjects:  totalProjects ?? this.totalProjects,
  );
}