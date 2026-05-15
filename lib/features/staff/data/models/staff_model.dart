class StaffPermission {
  final String id;
  final String name;
  final String description;

  StaffPermission({
    required this.id,
    required this.name,
    required this.description,
  });

  factory StaffPermission.fromJson(Map<String, dynamic> json) {
    return StaffPermission(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class StaffRole {
  final String id;
  final String name;
  final List<StaffPermission> permissions;

  StaffRole({
    required this.id,
    required this.name,
    this.permissions = const [],
  });

  factory StaffRole.fromJson(Map<String, dynamic> json) {
    return StaffRole(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      permissions: (json['permissions'] as List?)
              ?.map((p) => StaffPermission.fromJson(p))
              .toList() ??
          [],
    );
  }
}

class StaffMember {
  final String id;
  final String name;
  final String email;
  final String roleId;
  final String? roleName;

  StaffMember({
    required this.id,
    required this.name,
    required this.email,
    required this.roleId,
    this.roleName,
  });

  factory StaffMember.fromJson(Map<String, dynamic> json) {
    return StaffMember(
      id: json['id'] ?? json['ID'] ?? '',
      name: json['name'] ?? json['Name'] ?? '',
      email: json['email'] ?? json['Email'] ?? '',
      roleId: json['staff_role_id'] ?? json['StaffRoleID'] ?? '',
      roleName: json['role_name'] ?? json['RoleName'],
    );
  }
}
