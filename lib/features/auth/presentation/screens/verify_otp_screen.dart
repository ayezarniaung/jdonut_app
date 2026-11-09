import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jdonut_app/features/auth/presentation/providers/verify_otp_notifier.dart';
import 'package:jdonut_app/features/auth/domain/validators/otp_validator.dart';
import 'package:jdonut_app/shared/theme/app_colors.dart';
import 'package:jdonut_app/core/utils/app_logger.dart';
import 'package:jdonut_app/shared/widgets/tnc_footer.dart';
import 'package:jdonut_app/core/router/routes.dart';

class VerifyOtpScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  final bool isNewUser;
  const VerifyOtpScreen({
    super.key,
    required this.phoneNumber,
    required this.isNewUser,
  });

  @override
  ConsumerState<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends ConsumerState<VerifyOtpScreen>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  late final _provider = verifyOtpProvider((
    phone: widget.phoneNumber,
    isNewUser: widget.isNewUser,
  ));

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _shake.dispose();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged() {
    setState(() {}); // repaint the boxes
    final notifier = ref.read(_provider.notifier);
    final s = ref.read(_provider);

    if (s.checking || s.locked) return;
    if (_controller.text.isNotEmpty) notifier.clearError();
    if (_controller.text.length != kOtpLength) return;

    notifier.submit(_controller.text);
  }

  Future<void> _onWrongCode() async {
    HapticFeedback.mediumImpact();
    await _shake.forward(from: 0);
    if (!mounted) return;
    _controller.clear();
    if (ref.read(_provider).locked) FocusScope.of(context).unfocus();
  }

  Future<void> _resend() async {
    final sent = await ref.read(_provider.notifier).resend();
    if (!mounted || !sent) return;
    _controller.clear();
    _focus.requestFocus();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('New code sent to ${widget.phoneNumber}')),
      );
  }

  String _timeText(int secondsLeft) {
    final m = secondsLeft ~/ 60;
    final s = (secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(_provider);

    ref.listen(_provider, (prev, next) {
      logger.w("verify status :${next.status}");
      if (next.status == OtpStatus.verified) {
        FocusScope.of(context).unfocus();
        if (widget.isNewUser) {
          context.go(Routes.usernameScreen);
        } else {
          context.go(Routes.welcomeScreen);
        }
      }

      if (prev != null && next.shakeCount != prev.shakeCount) {
        _onWrongCode();
      }

      if (next.error != null &&
          next.error != prev?.error &&
          next.shakeCount == prev?.shakeCount &&
          next.status == OtpStatus.idle &&
          next.attemptsLeft == prev?.attemptsLeft) {}
    });

    final bodyStyle = GoogleFonts.nunito(fontSize: 14, color: AppColors.ink);
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
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ... back button + _StepRingPainter row: unchanged ...
                const SizedBox(height: 32),

                Text(
                  'Verify your number',
                  style: GoogleFonts.fredoka(
                    fontSize: 32,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'We\'ve sent $kOtpLength digit OTP to ${widget.phoneNumber}',
                  style: bodyStyle,
                ),
                const SizedBox(height: 36),

                AnimatedBuilder(
                  animation: _shake,
                  builder: (context, child) {
                    final t = _shake.value;
                    final dx = math.sin(t * math.pi * 6) * 12 * (1 - t);
                    return Transform.translate(
                      offset: Offset(dx, 0),
                      child: child,
                    );
                  },
                  child: _OtpBoxes(
                    controller: _controller,
                    focusNode: _focus,
                    length: kOtpLength,
                    enabled: !s.locked,
                    hasError: s.error != null,
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  alignment: Alignment.topLeft,
                  child: s.error == null
                      ? const SizedBox(width: double.infinity)
                      : Padding(
                          padding: const EdgeInsets.only(top: 12),
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
                                  s.error!,
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
                ),

                const SizedBox(height: 24),

                Text('Didn’t receive the code?', style: bodyStyle),
                const SizedBox(height: 6),
                if (!s.canResend)
                  Text.rich(
                    TextSpan(
                      style: bodyStyle,
                      children: [
                        const TextSpan(text: 'resend in '),
                        TextSpan(
                          text: _timeText(s.resendIn),
                          style: const TextStyle(color: AppColors.pink),
                        ),
                        const TextSpan(text: ' min'),
                      ],
                    ),
                  )
                else
                  GestureDetector(
                    onTap: _resend,
                    child: Text(
                      'Resend code',
                      style: bodyStyle.copyWith(
                        color: AppColors.pink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                const Spacer(),
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

class _OtpBoxes extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final int length;
  final bool enabled;
  final bool hasError;

  const _OtpBoxes({
    required this.controller,
    required this.focusNode,
    required this.length,
    this.enabled = true,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    final text = controller.text;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (enabled) focusNode.requestFocus();
      },
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(length, (i) {
              final filled = i < text.length;
              final active =
                  enabled &&
                  focusNode.hasFocus &&
                  i == math.min(text.length, length - 1);
              return Container(
                width: 50,
                height: 70,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: hasError
                        ? AppColors.pink
                        : active
                        ? AppColors.sky
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Text(
                  filled ? text[i] : '',
                  style: GoogleFonts.fredoka(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink,
                  ),
                ),
              );
            }),
          ),
          // Hidden input
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                autofocus: true,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(length),
                ],
                showCursor: false,
                enableInteractiveSelection: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepRingPainter extends CustomPainter {
  final double progress;
  const _StepRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.22;
    final arcRect = (Offset.zero & size).deflate(stroke / 2);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = const Color(0xFFB7E0F5);
    final fill = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = AppColors.pink;

    canvas.drawArc(arcRect, 0, math.pi * 2, false, track);
    canvas.drawArc(arcRect, -math.pi / 2, math.pi * 2 * progress, false, fill);
  }

  @override
  bool shouldRepaint(covariant _StepRingPainter old) =>
      old.progress != progress;
}
