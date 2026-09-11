enum ProviderKind { hospital, clinic, ambulance, independentDoctor }

class AccessPermission {
  final String code;
  final String label;
  final String group;
  const AccessPermission(this.code, this.label, this.group);
}

class AccessRole {
  final String id;
  final String name;
  final String scope;
  final bool isCustom;
  final List<String> permissionCodes;

  const AccessRole({
    required this.id,
    required this.name,
    required this.scope,
    required this.isCustom,
    required this.permissionCodes,
  });

  AccessRole copyWith({String? name, List<String>? permissionCodes}) => AccessRole(
        id: id,
        name: name ?? this.name,
        scope: scope,
        isCustom: isCustom,
        permissionCodes: permissionCodes ?? this.permissionCodes,
      );
}

class ProviderOrganization {
  final String id;
  final String name;
  final ProviderKind kind;
  final String ownerName;
  final List<AccessRole> roles;

  const ProviderOrganization({
    required this.id,
    required this.name,
    required this.kind,
    required this.ownerName,
    required this.roles,
  });
}
