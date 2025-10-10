// Stub: non-web platforms will use the normal http.Client implementation.
import 'package:http/http.dart' as http;

http.Client createBrowserClient() => http.Client();
