import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ui/dashboard_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
          final size = MediaQuery.of(context).size;
          return Container(
            color: NeumorphicTheme.baseColor(context),
            child: Center(
              child: Neumorphic(
                style: const NeumorphicStyle(depth: 10),
                child: const DashboardScreen(),
              ),
            ),
          );
        },
      ),
    );
  }
}
