/// Represents a contact entity with basic information.
class Contact {
  /// Unique identifier for the contact
  final int id;

  /// Full name of the contact
  final String name;

  /// Phone number of the contact
  final String phoneNumber;

  /// Optional email address
  final String? email;

  /// Optional physical address
  final String? address;

  /// Timestamp when the contact was created
  final String? createdAt;

  /// Creates a new [Contact] instance
  Contact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.email,
    this.address,
    this.createdAt,
  });

  /// Converts the contact to JSON map
  ///
  /// Useful for serialization and JSON-based APIs
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone_number': phoneNumber,
    'email': email,
    'address': address,
    'created_at': createdAt,
  };

  /// Creates a [Contact] from a database row
  ///
  /// - [row] Map containing database fields
  factory Contact.fromRow(Map<String, dynamic> row) => Contact(
    id: int.parse(row['id']),
    name: row['name'],
    phoneNumber: row['phone_number'],
    email: row['email'] ?? '',
    address: row['address'] ?? '',
    createdAt: row['created_at'],
  );
}
