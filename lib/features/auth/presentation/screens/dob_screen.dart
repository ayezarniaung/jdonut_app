import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jdonut_app/features/auth/domain/validators/dob_validator.dart';
import 'package:jdonut_app/features/auth/domain/validators/validator.dart';
import 'package:jdonut_app/shared/theme/app_colors.dart';
import 'package:jdonut_app/shared/widgets/tnc_footer.dart';
import 'package:jdonut_app/core/router/routes.dart';

class DobScreen extends StatefulWidget {
  const DobScreen({super.key});

  @override
  State<DobScreen> createState() => _DobScreenState();
}

class _DobScreenState extends State<DobScreen> {
  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  int? _month; // 1-12
  int? _day;
  int? _year;

  final int _maxYear = DateTime.now().year;

  Validated<DateTime, DobFailure> get _result => validateDateOfBirth(
    year: _year,
    month: _month,
    day: _day,
    now: DateTime.now(),
  );

  bool get _isValid => _result.value != null;

  String? get _errorText {
    final f = _result.failure;
    if (f == null || f == DobFailure.incomplete) return null;
    return _dobMessage(f);
  }

  String _dobMessage(DobFailure f) => switch (f) {
    DobFailure.incomplete => 'Select your full date of birth',
    DobFailure.invalidDate => "That date doesn't exist",
    DobFailure.beforeMinYear => 'Year must be $kMinBirthYear or later',
    DobFailure.inFuture => "Date of birth can't be in the future",
  };

  int _daysIn(int month, int year) => DateTime(year, month + 1, 0).day;

  void _fixDay() {
    if (_month != null && _day != null) {
      final max = _daysIn(_month!, _year ?? 2000);
      if (_day! > max) _day = max;
    }
  }

  Future<void> _pickMonth() async {
    final i = await _showPicker(items: _months, initial: (_month ?? 1) - 1);
    if (i != null) {
      setState(() {
        _month = i + 1;
        _fixDay();
      });
    }
  }

  Future<void> _pickDay() async {
    final max = _month == null ? 31 : _daysIn(_month!, _year ?? 2000);
    final i = await _showPicker(
      items: List.generate(max, (i) => '${i + 1}'),
      initial: (_day ?? 1) - 1,
    );
    if (i != null) setState(() => _day = i + 1);
  }

  Future<void> _pickYear() async {
    final years = [for (var y = _maxYear; y >= kMinBirthYear; y--) y];
    final i = await _showPicker(
      items: years.map((y) => '$y').toList(),
      initial: _year == null ? 0 : years.indexOf(_year!),
    );
    if (i != null) {
      setState(() {
        _year = years[i];
        _fixDay();
      });
    }
  }

  Future<int?> _showPicker({
    required List<String> items,
    required int initial,
  }) {
    var selected = initial.clamp(0, items.length - 1);
    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SizedBox(
        height: 320,
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(ctx, selected),
                child: Text(
                  'Done',
                  style: GoogleFonts.fredoka(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.pink,
                  ),
                ),
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 44,
                scrollController: FixedExtentScrollController(
                  initialItem: selected,
                ),
                onSelectedItemChanged: (i) => selected = i,
                children: [
                  for (final t in items)
                    Center(
                      child: Text(
                        t,
                        style: GoogleFonts.nunito(
                          fontSize: 22,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onContinue() {
    final dob = _result.value;
    if (dob == null) return;

    context.push(Routes.welcomeScreen);

    debugPrint('DOB: $dob');
  }

  @override
  Widget build(BuildContext context) {
    final errorText = _errorText;
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
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppColors.pink,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  'What\'s your\ndate of birth?',
                  style: GoogleFonts.fredoka(
                    fontSize: 32,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),

                const SizedBox(height: 36),
                _PickerField(
                  hint: 'Month',
                  value: _month == null ? null : _months[_month! - 1],
                  onTap: _pickMonth,
                ),
                const SizedBox(height: 16),
                _PickerField(
                  hint: 'Day',
                  value: _day?.toString(),
                  onTap: _pickDay,
                ),
                const SizedBox(height: 16),
                _PickerField(
                  hint: 'Year',
                  value: _year?.toString(),
                  onTap: _pickYear,
                ),
                if (errorText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12, left: 8),
                    child: Text(
                      errorText,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.error,
                      ),
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

class _PickerField extends StatelessWidget {
  final String hint;
  final String? value;
  final VoidCallback onTap;

  const _PickerField({
    required this.hint,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 28),
          alignment: Alignment.centerLeft,
          child: Text(
            value ?? hint,
            style: GoogleFonts.nunito(
              fontSize: 18,
              color: value == null ? const Color(0xFF7B8794) : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}
