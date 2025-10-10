// Web implementation that returns package:http's BrowserClient.
import 'package:http/browser_client.dart' as browser;
import 'package:http/http.dart' as http;

http.Client createBrowserClient() => browser.BrowserClient();
