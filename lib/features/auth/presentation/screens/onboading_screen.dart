import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jdonut_app/shared/theme/app_colors.dart';
import 'package:jdonut_app/shared/widgets/tnc_footer.dart';
import 'package:jdonut_app/core/router/routes.dart';

class OnboadingScreen extends StatelessWidget {
  const OnboadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.bottomTint,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: height * 0.52,
            child: Image.asset(
              'assets/images/onboading.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),

          Positioned(
            top: height * 0.34,
            left: 0,
            right: 0,
            height: height * 0.18,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00FAEEF1), AppColors.bottomTint],
                ),
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Round food for\nevery mood',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.fredoka(
                        fontSize: 32,
                        height: 1.15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 36),
                    SizedBox(
                      width: double.infinity,
                      height: 64,
                      child: ElevatedButton(
                        onPressed: () {
                          context.push(
                            Routes.phoneScreen,
                            extra: {'isNewUser': true},
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.sky,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          'LET\'S GET STARTED',
                          style: GoogleFonts.fredoka(
                            fontSize: 16,
                            height: 1.15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.background,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            color: AppColors.ink,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            context.push(
                              Routes.phoneScreen,
                              extra: {'isNewUser': false},
                            );
                          },
                          child: Text(
                            'Log In',
                            style: GoogleFonts.fredoka(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.pink,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _SocialButton(
                            type: 'Google',
                            child: Image.asset("assets/images/google.png"),
                          ),
                          SizedBox(width: 32),
                          _SocialButton(
                            type: 'Apple',
                            child: Icon(
                              Icons.apple,
                              size: 32,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 32),
                          _SocialButton(
                            type: 'Facebook',
                            child: Image.asset("assets/images/facebook.png"),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    tncFooter(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final Widget child;
  final String type;
  const _SocialButton({required this.child, required this.type});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: () {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text('$type sign-in isn’t available yet')),
          );
      },
      radius: 32,
      child: SizedBox(width: 32, height: 32, child: Center(child: child)),
    );
  }
}
