import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // URL hosting kamu
  static const String baseUrl = 'https://perpus.mytech.my.id/api/mobile';
  static const String appVersion = '1.0.0'; // Versi aplikasi saat ini
  
  static Future<Map<String, dynamic>> getAppConfig() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/app-config'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Gagal memuat konfigurasi aplikasi');
    } catch (e) {
      throw Exception('Kesalahan koneksi: $e');
    }
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        body: {'email': email, 'password': password},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['token'] != null) {
          await saveToken(data['token']);
        }
        return data;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Gagal masuk');
      }
    } catch (e) {
      throw Exception('Kesalahan koneksi: $e');
    }
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        body: {'name': name, 'email': email, 'password': password},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['token'] != null) {
          await saveToken(data['token']);
        }
        return data;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Gagal mendaftar');
      }
    } catch (e) {
      throw Exception('Kesalahan koneksi: $e');
    }
  }

  static Future<Map<String, dynamic>> loginWithGoogle(
    String googleId,
    String email,
    String name,
    String? avatar,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/google'),
        body: {
          'google_id': googleId,
          'email': email,
          'name': name,
          'avatar': avatar ?? '',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['token'] != null) {
          await saveToken(data['token']);
        }
        return data;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Gagal masuk dengan Google');
      }
    } catch (e) {
      throw Exception('Kesalahan koneksi: $e');
    }
  }

  static Future<Map<String, dynamic>> getHomeData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/home'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Gagal memuat data beranda (${response.statusCode}): ${response.body.length > 200 ? response.body.substring(0, 200) : response.body}');
      }
    } catch (e) {
      throw Exception('Kesalahan koneksi: $e');
    }
  }

  static Future<List<dynamic>> getNotifications() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/notifications'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Gagal memuat notifikasi');
      }
    } catch (e) {
      throw Exception('Kesalahan koneksi: $e');
    }
  }

  static Future<List<dynamic>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/categories'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Gagal memuat kategori');
      }
    } catch (e) {
      throw Exception('Kesalahan koneksi: $e');
    }
  }

  static Future<List<dynamic>> getBooks({String? query}) async {
    try {
      final url = query != null ? '$baseUrl/books?search=$query' : '$baseUrl/books';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Gagal memuat buku');
      }
    } catch (e) {
      throw Exception('Kesalahan koneksi: $e');
    }
  }

  static Future<List<dynamic>> getBooksByGenre(int genreId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/books/genre/$genreId'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Gagal memuat buku');
      }
    } catch (e) {
      throw Exception('Kesalahan koneksi: $e');
    }
  }

  static Future<Map<String, dynamic>> getBookDetails(int bookId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/books/$bookId'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Gagal memuat detail buku');
      }
    } catch (e) {
      throw Exception('Kesalahan koneksi: $e');
    }
  }
  static Future<List<dynamic>> getUserBooks() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/my-books'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Gagal memuat karya saya');
      }
    } catch (e) {
      throw Exception('Kesalahan koneksi: $e');
    }
  }

  static Future<List<dynamic>> getVideos({String? query, int? genreId}) async {
    try {
      String url = '$baseUrl/videos';
      List<String> params = [];
      if (query != null && query.isNotEmpty) params.add('search=$query');
      if (genreId != null) params.add('genre_id=$genreId');
      
      if (params.isNotEmpty) {
        url += '?' + params.join('&');
      }

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Gagal memuat video');
      }
    } catch (e) {
      throw Exception('Kesalahan koneksi: $e');
    }
  }

  static Future<Map<String, dynamic>> createBook({
    required String title,
    required int genreId,
    required String synopsis,
    required String content,
    required String status,
    String? coverPath,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/books'));
    request.headers.addAll(await _getHeaders());

    request.fields['title'] = title;
    request.fields['genre_id'] = genreId.toString();
    request.fields['synopsis'] = synopsis;
    request.fields['content'] = content;
    request.fields['status'] = status;

    if (coverPath != null) {
      request.files.add(await http.MultipartFile.fromPath('cover_image', coverPath));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      // Try to parse JSON error, otherwise show raw response
      try {
        final errorData = json.decode(response.body);
        final msg = errorData['message'] ?? errorData['error'] ?? 'Gagal menyimpan karya';
        throw Exception('[${response.statusCode}] $msg');
      } catch (jsonError) {
        // Server returned non-JSON (e.g. HTML error page)
        final snippet = response.body.length > 300 ? response.body.substring(0, 300) : response.body;
        throw Exception('[${response.statusCode}] Server error: $snippet');
      }
    }
  }

  static Future<Map<String, dynamic>> updateBook({
    required int id,
    required String title,
    required int genreId,
    required String synopsis,
    required String content,
    required String status,
    String? coverPath,
  }) async {
    final request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/books/$id'));
    // Laravel Multipart with PUT workaround: use POST and _method=PUT
    final realRequest = http.MultipartRequest('POST', Uri.parse('$baseUrl/books/$id'));
    realRequest.headers.addAll(await _getHeaders());

    realRequest.fields['_method'] = 'PUT';
    realRequest.fields['title'] = title;
    realRequest.fields['genre_id'] = genreId.toString();
    realRequest.fields['synopsis'] = synopsis;
    realRequest.fields['content'] = content;
    realRequest.fields['status'] = status;

    if (coverPath != null && !coverPath.startsWith('http')) {
      realRequest.files.add(await http.MultipartFile.fromPath('cover_image', coverPath));
    }

    final streamedResponse = await realRequest.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      try {
        final errorData = json.decode(response.body);
        final msg = errorData['message'] ?? errorData['error'] ?? 'Gagal memperbarui karya';
        throw Exception('[${response.statusCode}] $msg');
      } catch (e) {
        throw Exception('[${response.statusCode}] Server error: ${response.body}');
      }
    }
  }

  static Future<void> deleteBook(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/books/$id'),
        headers: await _getHeaders(),
      );
      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal menghapus karya');
      }
    } catch (e) {
      throw Exception('Kesalahan koneksi: $e');
    }
  }

  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Gagal memuat profil');
      }
    } catch (e) {
      throw Exception('Kesalahan koneksi: $e');
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    String? avatarPath,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/profile/update'));
    request.headers.addAll(await _getHeaders());
    request.fields['name'] = name;
    request.fields['email'] = email;

    if (avatarPath != null) {
      request.files.add(await http.MultipartFile.fromPath('avatar', avatarPath));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Gagal memperbarui profil');
    }
  }

  static Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/profile/password'),
      headers: await _getHeaders(),
      body: json.encode({
        'old_password': oldPassword,
        'new_password': newPassword,
        'new_password_confirmation': confirmPassword,
      }),
    );

    if (response.statusCode != 200) {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Gagal mengubah kata sandi');
    }
  }

  static Future<Map<String, dynamic>> getAnalytics() async {
    final response = await http.get(
      Uri.parse('$baseUrl/analytics'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal memuat analistik');
    }
  }

  static Future<Map<String, dynamic>> getEarnings() async {
    final response = await http.get(
      Uri.parse('$baseUrl/earnings'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal memuat data penghasilan');
    }
  }

  static Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: await _getHeaders(),
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
    } catch (e) {
      // Even if API fails, clear local token
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
    }
  }
}
