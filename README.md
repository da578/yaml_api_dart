# Dart REST API with YAML Format

A simple RESTful API built with [Dart](https://dart.dev) using the [`shelf`](https://pub.dev/packages/shelf) framework, MySQL database, and **YAML as the default format for both input and output** — not JSON.

> ⚠️ This project demonstrates that **YAML can be a modern alternative to JSON in API communication**, offering better readability and structure for human developers.

## 📌 Description

This project implements a basic Contact Management System (CRUD) API with the following features:

- Accepts YAML-formatted requests
- Returns YAML-formatted responses
- Uses:
  - [`shelf`](https://pub.dev/packages/shelf): For lightweight HTTP server
  - [`mysql_client`](https://pub.dev/packages/mysql_client): To connect to MySQL
  - [`yaml`](https://pub.dev/packages/yaml): To parse YAML input
  - [`yaml_writer`](https://pub.dev/packages/yaml_writer): To serialize objects into YAML

All endpoints return standardized YAML responses using the `YamlHelper.generateResponse()` utility.

## 🧠 Why YAML?

While most APIs use JSON by default, this project chooses **YAML over JSON** for several reasons:

| Feature | Advantage |
|--------|-----------|
| Human-readable formatting | Easier to read and write manually |
| Supports complex structures | Great for nested or hierarchical data |
| Widely used in DevOps | Aligns well with infrastructure-as-code workflows |

This makes it ideal for APIs consumed by both humans (e.g., CLI tools, documentation) and services.

## 📦 Features

- ✅ **CRUD Contacts**: Create, Read, Update, Delete
- ✅ **Input Validation**: Name, phone number, email, address
- ✅ **Filtering**: By name, email, phone number
- ✅ **Sorting**: By field (`name`, `email`, etc.)
- ✅ **Standardized Responses**: All outputs are returned in consistent YAML format
- ✅ **Self-documented Code**: Clear comments across all files
- ✅ **Open Source (BSD License)**

## 🛠️ Technologies Used

- **Language**: [Dart](https://dart.dev)
- **HTTP Framework**: [Shelf](https://pub.dev/packages/shelf)
- **Database**: MySQL
- **Data Formats**:
  - Request Body: YAML
  - Response Body: YAML
- **YAML Processing**: [`yaml`](https://pub.dev/packages/yaml), [`yaml_writer`](https://pub.dev/packages/yaml_writer)

## 📦 Installation

### 1. Clone Repository

```bash
git clone https://github.com/<your_username>/dart-yaml-api.git
cd dart-yaml-api
```

### 2. Install Dependencies

```bash
dart pub get
```

### 3. Setup Database

Make sure you have MySQL running and create the database:

```sql
CREATE DATABASE contacts_db;

USE contacts_db;

CREATE TABLE contacts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  phone_number VARCHAR(20) NOT NULL,
  email VARCHAR(255),
  address TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 4. Run Server

```bash
dart run bin/server.dart
```

The server will run at: `http://localhost:8080/api/contacts`

## 🛰️ Base URL

```
http://localhost:8080/api/contacts
```

## 📋 Standard Response Format

Success response:

```yaml
status_code: 200
message: Task John Doe created successfully
result:
  name: John Doe
  phone_number: "+628123456789"
```

Error response:

```yaml
status_code: 400
message: Validation failed
errors:
  name: Must be at least 2 characters
  phone_number: Invalid phone number format
```

## 📦 Endpoints

| Method | Path              | Description                     |
|--------|-------------------|---------------------------------|
| POST   | `/create`         | Create new contact from YAML body |
| GET    | `/`               | Get list of contacts (with filtering/sorting support) |
| GET    | `/{id}`          | Get single contact by ID        |
| PUT    | `/{id}/update`   | Update contact by ID            |
| DELETE | `/{id}/delete`   | Delete contact by ID            |

### 📥 Example Request Body (YAML)

```yaml
name: John Doe
phone_number: "+628123456789"
email: john@example.com
address: Jakarta, Indonesia
```

### 📤 Example Response Body (YAML)

```yaml
status_code: 200
message: Task John Doe created successfully
result:
  name: John Doe
  phone_number: "+628123456789"
  email: john@example.com
  address: Jakarta, Indonesia
```

### ❌ Example Error Response

```yaml
status_code: 400
message: Validation failed
errors:
  name: Must be at least 2 characters
  phone_number: Invalid phone number format
```

## 🔐 Input Validation

Each contact must meet the following requirements:

- `name`: Minimum 2 characters
- `phone_number`: Valid international phone number format
- `email`: If provided, must match standard email pattern
- `address`: Optional, max 255 characters

If validation fails, the API returns:

```yaml
status_code: 400
message: Validation failed
errors:
  name: Must be at least 2 characters
  phone_number: Invalid phone number format
```

## 🧱 Architecture (MVC Pattern)

This project uses a **Model-View-Controller (MVC)** architecture:

| Folder             | Contents                         |
|--------------------|----------------------------------|
| `lib/models/`      | Data models (`Contact`)          |
| `lib/controllers/` | Business logic and route handlers |
| `lib/routes/`      | Route definitions                |
| `lib/helpers/`     | Utility classes (`ValidationHelper`, `YamlHelper`) |
| `bin/`             | Main server entry point           |

## 📄 License

This project is released under the **BSD 2-Clause License** – see the [LICENSE](LICENSE) file for details.

## 🫱🏼‍🫲🏼 Contributing

Contributions are welcome!

1. Fork the repo
2. Create a new branch: `git checkout -b feature/yaml-enhancement`
3. Commit your changes: `git commit -m 'Add YAML-based endpoint'`
4. Push to the branch: `git push origin feature/yaml-enhancement`
5. Submit a pull request

## 📬 Support

For help or questions:
- **Telegram:** [@da578](https://t.me/dzul578)
- **LinkedIn:** [Dzulkifli Anwar](www.linkedin.com/in/dzulkifli-anwar)
- GitHub Issues: Open an issue on the repository

## ❤️ Thanks

Thank you for checking out this project! I hope it inspires more developers to consider **YAML as a structured and readable alternative to JSON** in future API designs.