import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jdonut_app/shared/theme/app_colors.dart';
import 'package:jdonut_app/core/router/routes.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _onExplore(BuildContext context) {
    context.push(Routes.bottomNavScreen);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.fadeStart,
      body: LayoutBuilder(
        builder: (context, c) {
          return Stack(
            children: [
              // Fade from transparent into the pink background
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: height * 0.76,
                child: Image.asset(
                  'assets/images/welcome.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),

              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: height * 0.42,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.35, 1.0],
                        colors: [
                          AppColors.fadeEnd.withValues(alpha: 0),
                          AppColors.fadeEnd.withValues(alpha: 0.92),
                          AppColors.fadeEnd,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Title + button
              Positioned(
                left: 24,
                right: 24,
                bottom: 0,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Welcome to the\nworld of J’donuts',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.fredoka(
                            fontSize: 32,
                            height: 1.2,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () => _onExplore(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.sky,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: const StadiumBorder(),
                            ),
                            child: Text(
                              'LET\'S EXPLORE',
                              style: GoogleFonts.fredoka(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
