import 'package:yaml_api_dart/databases/database.dart';
import 'package:yaml_api_dart/helpers/validation_helper.dart';
import 'package:yaml_api_dart/models/contact.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:shelf/shelf.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_writer/yaml_writer.dart';

/// Controller class for handling contact-related HTTP requests
class ContactController {
  /// Creates a new contact from YAML payload
  ///
  /// Validates input data, stores in database, and returns success/error response
  ///
  /// - [request] Shelf request object containing YAML body
  ///
  /// Returns [Response] with YAML-formatted status message
  Future<Response> createContact(Request request) async {
    final body = await request.readAsString();
    final data = loadYaml(body);

    if (data == null) {
      return Response.badRequest(
        body: YamlWriter().write({
          'status_code': 400,
          'message': 'Validation failed',
          'errors': 'No input in body',
        }),
      );
    }

    final name = data['name']?.toString() ?? '';
    final phoneNumber = data['phone_number']?.toString() ?? '';
    final email = data['email']?.toString();
    final address = data['address']?.toString();

    final errors = ValidationHelper.validateContactFields(
      name: name,
      phoneNumber: phoneNumber,
      email: email,
      address: address,
    );

    if (errors.isNotEmpty) {
      return Response.badRequest(
        body: YamlWriter().write({
          'status_code': 400,
          'message': 'Validation failed',
          'errors': errors,
        }),
      );
    }

    final database = Database();
    final connection = await database.openConnection();
    final prepare = await connection.prepare(
      'INSERT INTO contacts (name, phone_number, email, address) VALUES (?, ?, ?, ?)',
    );

    final newContact = {
      'name': data['name'],
      'phone_number': data['phone_number'],
      'email': data['email'] ?? '',
      'address': data['address'] ?? '',
    };

    await prepare.execute([
      data['name'],
      data['phone_number'],
      data['email'] ?? '',
      data['address'] ?? '',
    ]);

    await prepare.deallocate();
    await database.closeConnection();

    return Response.ok(
      YamlWriter().write({
        'status_code': 200,
        'message': 'Task ${data['name']} created successfully',
        'result': newContact,
      }),
    );
  }

  /// Retrieves filtered list of contacts with sorting capabilities
  ///
  /// Supports filtering by name/email/phone number and sorting by field
  ///
  /// - [request] Shelf request object containing query parameters
  ///
  /// Returns [Response] with list of contacts or empty result
  Future<Response> readContacts(Request request) async {
    final database = Database();
    final connection = await database.openConnection();

    final uri = request.url;
    final params = uri.queryParameters;

    final filterName = params['name']?.trim();
    final filterEmail = params['email']?.trim();
    final filterPhone = params['phone_number']?.trim();
    final sortBy = params['sort']?.toLowerCase() ?? 'name';
    final sortOrder = params['order']?.toLowerCase() == 'desc' ? 'DESC' : 'ASC';

    final whereClauses = <String>[];
    final queryParams = <dynamic>[];

    if (filterName != null && filterName.isNotEmpty) {
      whereClauses.add('name LIKE ?');
      queryParams.add('%$filterName%');
    }

    if (filterEmail != null && filterEmail.isNotEmpty) {
      whereClauses.add('email LIKE ?');
      queryParams.add('%$filterEmail%');
    }

    if (filterPhone != null && filterPhone.isNotEmpty) {
      whereClauses.add('phone_number LIKE ?');
      queryParams.add('%$filterPhone%');
    }

    String query = 'SELECT * FROM contacts';
    if (whereClauses.isNotEmpty) {
      query += " WHERE ${whereClauses.join(' AND ')}";
    }

    query += ' ORDER BY $sortBy $sortOrder';

    final prepare = await connection.prepare(query);
    final results = await prepare.execute(queryParams);

    final contacts = <Contact>[];
    for (final row in results.rows) {
      contacts.add(Contact.fromRow(row.assoc()));
    }

    await database.closeConnection();

    return Response.ok(
      YamlWriter().write({
        'status_code': 200,
        'message':
            results.rows.isEmpty
                ? 'No contacts available'
                : 'Contacts fetched successfully',
        'result': results.rows.isEmpty ? null : contacts,
      }),
    );
  }

  /// Gets a single contact by ID
  ///
  /// Validates ID format and existence in database
  ///
  /// - [request] Shelf request object
  /// - [id] Contact ID from URL path parameter
  ///
  /// Returns [Response] with contact data or 404 error
  Future<Response> readContactById(Request request, String id) async {
    final database = Database();
    final connection = await database.openConnection();
    final prepare = await connection.prepare(
      'SELECT * FROM contacts WHERE id = ?',
    );
    final result = await prepare.execute([id]);

    if (result.rows.isEmpty) {
      return Response.notFound(
        YamlWriter().write({
          'status_code': 404,
          'message': 'Contact with ID $id not found',
          'result': null,
        }),
      );
    }

    final contact = Contact.fromRow(result.rows.first.assoc());
    await prepare.deallocate();
    await database.closeConnection();

    return Response.ok(
      YamlWriter().write({
        'status_code': 200,
        'message': 'Contact ${contact.name} fetched successfully',
        'result': contact,
      }),
    );
  }

  /// Updates existing contact information
  ///
  /// Validates ID format, contact existence, and input data
  ///
  /// - [request] Shelf request object with YAML body
  /// - [id] Contact ID from URL path parameter
  ///
  /// Returns [Response] with updated contact or error message
  Future<Response> updateContact(Request request, String id) async {
    final body = await request.readAsString();
    final data = loadYaml(body) as Map<String, dynamic>?;

    if (data == null) {
      return Response.badRequest(
        body: YamlWriter().write({
          'status_code': 400,
          'message': 'Validation failed',
          'errors': 'No input in body',
        }),
      );
    }

    final name = data['name']?.toString() ?? '';
    final phoneNumber = data['phone_number']?.toString() ?? '';
    final email = data['email']?.toString();
    final address = data['address']?.toString();

    final errors = ValidationHelper.validateContactFields(
      name: name,
      phoneNumber: phoneNumber,
      email: email,
      address: address,
    );

    if (errors.isNotEmpty) {
      return Response.badRequest(
        body: YamlWriter().write({
          'status_code': 400,
          'message': 'Validation failed',
          'errors': errors,
        }),
      );
    }

    final database = Database();
    final connection = await database.openConnection();

    final contactId = int.tryParse(id);
    if (contactId == null) {
      return Response.badRequest(
        body: YamlWriter().write({
          'status_code': 400,
          'message': 'Invalid contact ID',
          'result': null,
        }),
      );
    }

    final exists = await _contactExists(contactId, connection);
    if (!exists) {
      return Response.notFound(
        YamlWriter().write({
          'status_code': 404,
          'message': 'Contact with ID $id not found',
          'result': null,
        }),
      );
    }

    final prepare = await connection.prepare(
      'UPDATE contacts SET name = ?, phone_number = ?, email = ?, address = ?, created_at = ? WHERE id = ?',
    );

    final updatedContact = {
      'id': data['id'],
      'name': data['name'],
      'phone_number': data['phone_number'],
      'email': data['email'] ?? '',
      'address': data['address'] ?? '',
    };

    await prepare.execute([
      data['name'],
      data['phone_number'],
      data['email'],
      data['address'],
      data['created_at'],
      data['id'],
    ]);

    await prepare.deallocate();
    await database.closeConnection();

    return Response.ok(
      YamlWriter().write({
        'status_code': 200,
        'message': 'Task ${data['name']} updated successfully',
        'result': updatedContact,
      }),
    );
  }

  /// Deletes a contact by ID
  ///
  /// Validates ID format and contact existence before deletion
  ///
  /// - [request] Shelf request object
  /// - [id] Contact ID from URL path parameter
  ///
  /// Returns [Response] with success/error message
  Future<Response> deleteContact(Request request, String id) async {
    final database = Database();
    final connection = await database.openConnection();

    final contactId = int.tryParse(id);
    if (contactId == null) {
      return Response.badRequest(
        body: YamlWriter().write({
          'status_code': 400,
          'message': 'Invalid contact ID',
          'result': null,
        }),
      );
    }

    final exists = await _contactExists(contactId, connection);
    if (!exists) {
      return Response.notFound(
        YamlWriter().write({
          'status_code': 404,
          'message': 'Contact with ID $id not found',
          'result': null,
        }),
      );
    }

    final prepare = await connection.prepare(
      'DELETE FROM contacts WHERE id = ?',
    );

    await prepare.execute([contactId]);
    await prepare.deallocate();
    await database.closeConnection();

    return Response.ok(
      YamlWriter().write({
        'status_code': 200,
        'message': 'Contact with ID $id deleted successfully',
        'result': null,
      }),
    );
  }

  /// Checks if contact exists in database
  ///
  /// - [id] Contact ID to verify
  /// - [connection] Active database connection
  ///
  /// Returns Future&lt;bool&gt; indicating existence
  Future<bool> _contactExists(int id, MySQLConnection connection) async {
    final result = await connection.execute(
      'SELECT COUNT(*) AS count FROM contacts WHERE id = ?',
    );
    final row = result.rows.first.assoc();
    return (row['count'] as int) > 0;
  }
}
