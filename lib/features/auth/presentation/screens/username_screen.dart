import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jdonut_app/features/auth/domain/validators/username_validator.dart';
import 'package:jdonut_app/features/auth/domain/validators/validator.dart';
import 'package:jdonut_app/shared/theme/app_colors.dart';
import 'package:jdonut_app/shared/widgets/tnc_footer.dart';
import 'package:jdonut_app/core/router/routes.dart';

class UsernameScreen extends StatefulWidget {
  const UsernameScreen({super.key});

  @override
  State<UsernameScreen> createState() => _UsernameScreenState();
}

class _UsernameScreenState extends State<UsernameScreen> {
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _firstFocus = FocusNode();
  final _lastFocus = FocusNode();

  bool _firstTouched = false;
  bool _lastTouched = false;

  Validated<String, NameFailure> get _firstResult =>
      validateFirstName(_first.text);
  Validated<String, NameFailure> get _lastResult =>
      validateLastName(_last.text);

  String _message(NameFailure f, String label) => switch (f) {
    NameFailure.required => '$label is required',
    NameFailure.containsDigits => "$label can't contain digits",
    NameFailure.invalidCharacters =>
      '$label can only contain letters and spaces',
    NameFailure.tooLong => '$label must be $kNameMaxLength characters or fewer',
  };

  String? get _firstError {
    final f = _firstResult.failure;
    return f == null ? null : _message(f, 'First name');
  }

  String? get _lastError {
    final f = _lastResult.failure;
    return f == null ? null : _message(f, 'Last name');
  }

  bool get _isValid => _firstResult.value != null && _lastResult.value != null;

  @override
  void initState() {
    super.initState();
    _first.addListener(
      () => setState(() {
        if (_first.text.isNotEmpty) _firstTouched = true;
      }),
    );
    _last.addListener(
      () => setState(() {
        if (_last.text.isNotEmpty) _lastTouched = true;
      }),
    );
    _firstFocus.addListener(() {
      if (!_firstFocus.hasFocus) setState(() => _firstTouched = true);
    });
    _lastFocus.addListener(() {
      if (!_lastFocus.hasFocus) setState(() => _lastTouched = true);
    });
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _firstFocus.dispose();
    _lastFocus.dispose();
    super.dispose();
  }

  void _onContinue() {
    final first = _firstResult.value;
    final last = _lastResult.value;

    if (first == null || last == null) {
      setState(() {
        _firstTouched = true;
        _lastTouched = true;
      });
      return;
    }

    FocusScope.of(context).unfocus();
    debugPrint('Name: $first $last');

    context.push(Routes.dobScreen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.65, 1.0],
            colors: [AppColors.fadeEnd, AppColors.fadeStart, AppColors.fadeEnd],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    // const SizedBox(
                    //   width: 44,
                    //   height: 44,
                    //   child: CustomPaint(
                    //     painter: _StepRingPainter(progress: 0.75),
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  'What\'s your\nname?',
                  style: GoogleFonts.fredoka(
                    fontSize: 32,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 36),
                _NameField(
                  controller: _first,
                  hint: 'First Name',
                  focusNode: _firstFocus,
                  autofocus: true,
                  errorText: _firstTouched ? _firstError : null,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _lastFocus.requestFocus(),
                ),
                const SizedBox(height: 16),
                _NameField(
                  controller: _last,
                  hint: 'Last Name',
                  focusNode: _lastFocus,
                  errorText: _lastTouched ? _lastError : null,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _onContinue(),
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

                const SizedBox(height: 28),
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

class _NameField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? errorText;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  const _NameField({
    required this.controller,
    required this.hint,
    required this.textInputAction,
    this.errorText,
    this.focusNode,
    this.autofocus = false,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 28),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasError ? AppColors.pink : Colors.transparent,
              width: 2,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: autofocus,
            textCapitalization: TextCapitalization.words,
            textInputAction: textInputAction,
            onSubmitted: onSubmitted,
            autofillHints: const [AutofillHints.name],
            cursorColor: AppColors.pink,
            style: GoogleFonts.nunito(fontSize: 22, color: AppColors.ink),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: GoogleFonts.nunito(
                fontSize: 22,
                color: const Color(0xFF7B8794),
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topLeft,
          child: hasError
              ? Padding(
                  padding: const EdgeInsets.only(top: 8, left: 4),
                  child: Text(
                    errorText!,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: AppColors.pink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
