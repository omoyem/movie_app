import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../constants/endpoints.dart';

/// Fake backend used while [Endpoints.baseUrl] is still the placeholder.
///
/// Every HTTP request made by the app is answered here with dummy data in the
/// same shape the real API returned, so the screens work without a server.
/// Set a real `baseUrl` in `endpoints.dart` and this is switched off.
class MockBackend {
  static const _sampleBase =
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample';

  static final List<Map<String, dynamic>> _movies = [
    _movie('1', 'Big Buck Bunny', 'BigBuckBunny', '10 min', '2008-05-20', ['Animation', 'Kids', 'Family'],
        'A giant rabbit takes revenge on three bullying rodents in this playful short.'),
    _movie('2', 'Elephants Dream', 'ElephantsDream', '11 min', '2006-03-24', ['Animation', 'Documentary'],
        'Two strange characters explore a surreal, ever-shifting machine world.'),
    _movie('3', 'Sintel', 'Sintel', '15 min', '2010-09-27', ['Animation', 'Family'],
        'A lonely girl searches the world for the baby dragon she once rescued.'),
    _movie('4', 'Tears of Steel', 'TearsOfSteel', '12 min', '2012-09-26', ['Documentary', 'Educational'],
        'A group of scientists try to save the world from killer robots in Amsterdam.'),
    _movie('5', 'For Bigger Blazes', 'ForBiggerBlazes', '1 min', '2015-01-01', ['Educational'],
        'A short clip about streaming your favourite shows to a bigger screen.'),
    _movie('6', 'For Bigger Escapes', 'ForBiggerEscapes', '1 min', '2015-01-01', ['Family'],
        'A quick escape to somewhere far away, straight from your phone.'),
    _movie('7', 'For Bigger Fun', 'ForBiggerFun', '1 min', '2015-01-01', ['Kids', 'Musical'],
        'Fun on the big screen for the whole family.'),
    _movie('8', 'For Bigger Joyrides', 'ForBiggerJoyrides', '1 min', '2015-01-01', ['Family'],
        'Take the ride with you wherever you go.'),
    _movie('9', 'For Bigger Meltdowns', 'ForBiggerMeltdowns', '1 min', '2015-01-01', ['Kids'],
        'When the little ones need a distraction, fast.'),
    _movie('10', 'Subaru Outback On Street And Dirt', 'SubaruOutbackOnStreetAndDirt', '10 min', '2014-06-01',
        ['Documentary'], 'Taking a car off the road and into the dirt.'),
  ];

  static final List<Map<String, dynamic>> _categories = [
    {'id': '1', 'name': 'Animation', 'description': 'Animated films'},
    {'id': '2', 'name': 'Documentary', 'description': 'Real stories'},
    {'id': '3', 'name': 'Educational', 'description': 'Learn something new'},
    {'id': '4', 'name': 'Kids', 'description': 'For the little ones'},
    {'id': '5', 'name': 'Family', 'description': 'Watch together'},
    {'id': '6', 'name': 'Musical', 'description': 'Songs and music'},
  ];

  static final List<Map<String, dynamic>> _profiles = [
    {
      'id': '1',
      'dob': '1995-01-01',
      'user_id': 'demo@example.com',
      'name': 'Demo',
      'gender': 'other',
      'avatar': '',
      'screen_time': '120',
      'allowed_ratings': 'G,PG,PG-13',
      'calculated_age': '30',
      'current_age': '30',
      'age_group': 'adult',
      'created_at': '2025-01-01',
      'updated_at': null,
    },
  ];

  static final Set<String> _favouriteIds = {'1', '3'};

  static Map<String, dynamic> _movie(String id, String title, String file, String duration,
      String releaseDate, List<String> tags, String description) {
    return {
      'id': id,
      'title': title,
      'description': description,
      'duration': duration,
      'file_path': '$_sampleBase/$file.mp4',
      'cover_photo_path': '$_sampleBase/images/$file.jpg',
      'tags': jsonEncode(tags.map((t) => {'value': t}).toList()),
      'age_group': 'all',
      'category_id': '1',
      'release_date': releaseDate,
      'uploaded_at': '2025-01-01',
      'uploaded_by': 'demo',
      'views': '1000',
      'rating': '4.5',
    };
  }

  static http.Client client() => MockClient(_handle);

  static Future<http.Response> _handle(http.Request request) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final endpoint = request.url.pathSegments.isEmpty ? '' : request.url.pathSegments.last;
    Map<String, dynamic> body = {};
    try {
      if (request.body.isNotEmpty) body = Map<String, dynamic>.from(jsonDecode(request.body));
    } catch (_) {}

    switch (endpoint) {
      case Endpoints.login:
        final email = (body['username'] ?? 'demo@example.com').toString();
        return _ok({
          // The login response model expects the code as a string.
          'response_code': '200',
          'response_message': 'Login successful',
          'data': {
            'firstname': 'Demo',
            'lastname': 'User',
            'username': email,
            'unique_id': 'demo-user',
            'role': 'user',
            'email': email,
            'profiles': _profiles,
            'access_token': 'dummy-access-token-0123456789',
          },
        });

      case Endpoints.getMovies:
        return _ok(_success({
          'movies': _withFavourites(_movies),
          'age_group': 'all',
          'allowed_ratings': ['G', 'PG', 'PG-13'],
          'pagination': {'current_page': 1, 'per_page': _movies.length},
        }));

      case Endpoints.continueWatching:
        return _ok(_success(_movies.take(3).toList()));

      case Endpoints.getSimilarMovies:
        final id = body['movie_id']?.toString();
        return _ok(_success(_movies.where((m) => m['id'] != id).take(5).toList()));

      case Endpoints.searchMovies:
        final q = (body['q'] ?? '').toString().toLowerCase();
        return _ok(_success(_movies
            .where((m) =>
                m['title'].toString().toLowerCase().contains(q) ||
                m['description'].toString().toLowerCase().contains(q))
            .toList()));

      case Endpoints.movieCategories:
        return _ok(_success(_categories));

      case Endpoints.getFavourites:
        return _ok(_success(_movies.where((m) => _favouriteIds.contains(m['id'])).toList()));

      case Endpoints.favourite:
        final id = body['movie_id']?.toString();
        if (id != null) _favouriteIds.add(id);
        return _ok({'response_code': 201, 'response_message': 'Added to favourites'});

      case Endpoints.deleteFavourite:
        final id = body['movie_id']?.toString();
        if (id != null) _favouriteIds.remove(id);
        return _ok({'response_code': 200, 'response_message': 'Removed from favourites'});

      case Endpoints.profileSelection:
        return _ok(_success(_profiles));

      case Endpoints.profileSetup:
        _profiles.add({
          ..._profiles.first,
          'id': '${_profiles.length + 1}',
          'name': body['name'] ?? 'New profile',
          'dob': body['dob'] ?? _profiles.first['dob'],
          'gender': body['gender'] ?? 'other',
        });
        return _ok({'response_code': 201, 'response_message': 'Profile created successfully'});

      default:
        // Signup, OTP, password reset, profile update/delete, watch progress:
        // just report success.
        return _ok({'response_code': 200, 'response_message': 'Success'});
    }
  }

  static List<Map<String, dynamic>> _withFavourites(List<Map<String, dynamic>> movies) => movies
      .map((m) => {...m, 'is_favorite': _favouriteIds.contains(m['id'])})
      .toList();

  static Map<String, dynamic> _success(dynamic data) =>
      {'response_code': 200, 'response_message': 'Success', 'data': data};

  static http.Response _ok(Map<String, dynamic> json) => http.Response(
        jsonEncode(json),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
}
