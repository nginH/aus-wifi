import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'ui/dashboard_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        // Many platforms still allow launching even if canLaunchUrl returns false
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return NeumorphicApp(
      debugShowCheckedModeBanner: false,
      title: 'AUS WIFI Monitor',
      themeMode: ThemeMode.light,
      theme: NeumorphicThemeData(
        baseColor: const Color(0xFFE0E5EC),
        lightSource: LightSource.topLeft,
        depth: 10,
        accentColor: const Color(0xFF2D5AF0),
        variantColor: const Color(0xFF6B7280),
        textTheme: GoogleFonts.outfitTextTheme(),
      ),
      darkTheme: NeumorphicThemeData(
        baseColor: const Color(0xFF292D32),
        lightSource: LightSource.topLeft,
        depth: 6,
        accentColor: const Color(0xFF2D5AF0),
        variantColor: const Color(0xFF6B7280),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      ),
      home: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: NeumorphicTheme.baseColor(context),
            body: Center(
              child: Neumorphic(
                style: const NeumorphicStyle(depth: 10),
                child: const DashboardScreen(),
              ),
            ),

            bottomNavigationBar: Neumorphic(
              style: const NeumorphicStyle(
                depth: -5,
                boxShape: NeumorphicBoxShape.rect(),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Text(
                      "Build by Harsh Anand",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: NeumorphicTheme.variantColor(context),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        color: Colors.white,
                      ),
                      child: IconButton(
                        onPressed: () async {
                          await _launchURL(
                            "https://www.instagram.com/harsh_.anand/",
                          );
                        },
                        icon: Image.asset(
                          "assets/images/insta.png",
                          width: 30,
                          height: 30,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        color: Colors.white,
                      ),
                      child: IconButton(
                        onPressed: () async {
                          await _launchURL("https://github.com/nginH/aus-wifi");
                        },
                        icon: Image.asset(
                          "assets/images/git.png",
                          width: 24,
                          height: 24,
                          colorBlendMode: BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        color: Colors.white,
                      ),
                      child: IconButton(
                        onPressed: () async {
                          await _launchURL(
                            "https://github.com/nginH/aus-wifi/releases",
                          );
                        },
                        icon: Icon(Icons.share),
                      ),
                    ),

                    const Spacer(),
                    Text(
                      "Version 1.0.0",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: NeumorphicTheme.variantColor(context),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
