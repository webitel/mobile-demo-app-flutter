import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'CallPage.dart';
import 'ChatPage.dart';

// Webitel (Client: Portal App) token issued
const String PORTAL_CLIENT = "M8Sk4cjAW0uftPlKfTZ786o7";
// Webitel Customer Portal service host address
const String ADDRESS = "grpcs://demo.webitel.com:443";

void main() {
  const app = MyApp();

  runApp(const CupertinoApp(
    title: 'Webitel',
    home: app,
  ));

  app._initLibrary();
  app._setUser();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const channel = MethodChannel("webitel.com/portal");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildNavigationBar(context),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => const CallPage()),
                    );
                  },
                  child: const Text("Calls")),
              const SizedBox(height: 23),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => const ChatPage()),
                    );
                  },
                  child: const Text("Chats")),
            ],
          ),
        ));
  }

  CupertinoNavigationBar buildNavigationBar(BuildContext context) {
    return const CupertinoNavigationBar(backgroundColor: Colors.grey);
  }


  _initLibrary()  {
    channel.invokeMethod("init", <String, String> {
      'app_token': PORTAL_CLIENT, // REQUIRED.
      'address': ADDRESS, // REQUIRED.
    });
  }


  void _setUser() {
    /**
     * REQUIRED. Issuer Identifier for the Issuer of the response.
     * The iss value is a case sensitive URL using the https scheme that contains scheme,
     *  host, and optionally, port number and path components and no query or fragment components.
     */
    const String iss = "https://example.org/users";

    /**
     * Subject Identifier.
     * A locally unique and never reassigned identifier within the Issuer for the End-User,
     * which is intended to be consumed by the Client, e.g., 24400320
     * or AItOawmwtWwcT0k51BayewNvutrJUqsvl6qs7A4. It MUST NOT exceed 255 ASCII characters in length.
     * The sub value is a case sensitive string.
     */
    const String sub = "fsjdfsdfsdff";

    /**
     * End-User's full name in displayable form including all name parts,
     * possibly including titles and suffixes,
     * ordered according to the End-User's locale and preferences.
     */
    const String name = "John McClane";

    /**
     * End-User's locale, represented as a BCP47 RFC5646 language tag.
     * This is typically an ISO 639-1 Alpha-2 ISO639‑1 language code in lowercase
     * and an ISO 3166-1 Alpha-2 ISO3166‑1 country code in uppercase, separated by a dash.
     * For example, en-US or uk-UA.
     */
    const String locale = "uk-UA";

    channel.invokeMethod("setUser", <String, String>{
      'iss': iss, // REQUIRED.
      'sub': sub, // REQUIRED.
      'name': name, // REQUIRED.

      'locale': locale, // OPTIONAL.
      'email': "jmc@simple.com", // OPTIONAL.
      'emailVerified': "true", // OPTIONAL.
      'phoneNumber': "1332", // OPTIONAL.
      'phoneNumberVerified': "true", // OPTIONAL.
    });
  }
}
