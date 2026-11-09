import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jdonut_app/features/auth/domain/validators/phone_validator.dart';
import 'package:jdonut_app/features/auth/domain/validators/validator.dart';
import 'package:jdonut_app/shared/theme/app_colors.dart';
import 'package:jdonut_app/shared/widgets/tnc_footer.dart' show tncFooter;
import 'package:jdonut_app/core/router/routes.dart';

class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({super.key, required this.isNewUser});
  final bool isNewUser;

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  static const _countryCode = '+95';
  bool _touched = false;

  String? get _national => _result.value;

  bool get _isValid => _national != null;
  Validated<String, PhoneFailure> get _result =>
      validateMyanmarPhone(_controller.text);

  String? get _errorText {
    if (!_touched) return null;
    final f = _result.failure;
    if (f == null) return null;
    return switch (f) {
      PhoneFailure.empty => 'Enter your phone number',
      PhoneFailure.invalidFormat => 'Enter a valid Myanmar mobile number',
    };
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    _focus.addListener(() {
      if (!_focus.hasFocus && !_touched) setState(() => _touched = true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onContinue() {
    FocusScope.of(context).unfocus();
    context.push(
      Routes.verifyOtpScreen,
      extra: {'phoneNumber': _controller.text, 'isNewUser': widget.isNewUser},
    );
  }

  @override
  Widget build(BuildContext context) {
    final errorText = _errorText;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.fadeEnd, Color(0xFFFDF3F6), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => Navigator.of(context).maybePop(),
                        child: const SizedBox(
                          width: 56,
                          height: 56,
                          child: Icon(
                            Icons.arrow_back,
                            size: 28,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  'Enter your phone\nnumber',
                  style: GoogleFonts.fredoka(
                    fontSize: 32,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 36),
                Container(
                  height: 77,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _countryCode,
                        style: GoogleFonts.nunito(
                          fontSize: 20,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          focusNode: _focus,
                          autofocus: true,
                          onSubmitted: (_) {
                            setState(() => _touched = true);
                            FocusScope.of(context).unfocus();
                          },
                          keyboardType: const TextInputType.numberWithOptions(
                            signed: true,
                          ),
                          textInputAction: TextInputAction.done,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9 \-]'),
                            ),
                            LengthLimitingTextInputFormatter(10),
                          ],
                          cursorColor: AppColors.pink,
                          style: GoogleFonts.nunito(
                            fontSize: 20,
                            color: AppColors.ink,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Phone number',
                            hintStyle: TextStyle(color: Color(0xFFC4C4CC)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (errorText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12, left: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.error_outline,
                            size: 18,
                            color: AppColors.pink,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            errorText,
                            style: GoogleFonts.nunito(
                              fontSize: 15,
                              height: 1.4,
                              color: AppColors.pink,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isValid ? _onContinue : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.sky,
                      disabledBackgroundColor: AppColors.sky.withValues(
                        alpha: 0.7,
                      ),
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white,
                      elevation: 0,
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      'CONTINUE',
                      style: GoogleFonts.fredoka(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 45),
                Center(child: tncFooter()),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
