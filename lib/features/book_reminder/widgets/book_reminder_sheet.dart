import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/services/reading_reminder_service.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../data/models/book_model.dart';
import '../../../data/models/book_reminder_model.dart';
import '../reminder_ui_sync.dart';

class BookReminderSheet extends StatefulWidget {
  const BookReminderSheet({super.key, required this.book});

  final BookModel book;

  static Future<bool?> show(BookModel book) async {
    final result = await AppBottomSheet.show<bool>(
      title: 'تذكير القراءة',
      child: BookReminderSheet(book: book),
    );
    if (result == true) {
      await ReminderUiSync.refresh();
    }
    return result;
  }

  @override
  State<BookReminderSheet> createState() => _BookReminderSheetState();
}

class _BookReminderSheetState extends State<BookReminderSheet> {
  final _service = Get.find<ReadingReminderService>();

  bool _loading = true;
  bool _saving = false;
  bool _enabled = true;
  int _hour = 20;
  int _minute = 0;
  ReminderGoalPeriod _period = ReminderGoalPeriod.daily;
  int _goalMinutes = 20;
  bool _exists = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final reminder = await _service.getForBook(widget.book.id);
      if (!mounted) return;
      if (reminder != null) {
        setState(() {
          _exists = true;
          _enabled = reminder.enabled;
          _hour = reminder.hour;
          _minute = reminder.minute;
          _period = reminder.goalPeriod;
          _goalMinutes = reminder.goalMinutes;
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      AppSnackbar.error('خطأ', e.message);
    }
  }

  List<int> get _goalOptions => _period == ReminderGoalPeriod.daily
      ? AppConstants.dailyGoalMinuteOptions
      : AppConstants.weeklyGoalMinuteOptions;

  String get _timeLabel {
    final h = _hour.toString().padLeft(2, '0');
    final m = _minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _hour, minute: _minute),
      helpText: 'وقت التذكير اليومي',
      cancelText: 'إلغاء',
      confirmText: 'اختيار',
    );
    if (selected == null) return;
    setState(() {
      _hour = selected.hour;
      _minute = selected.minute;
    });
  }

  void _onPeriodChanged(ReminderGoalPeriod period) {
    setState(() {
      _period = period;
      final options = period == ReminderGoalPeriod.daily
          ? AppConstants.dailyGoalMinuteOptions
          : AppConstants.weeklyGoalMinuteOptions;
      if (!options.contains(_goalMinutes)) {
        _goalMinutes = options.contains(20)
            ? 20
            : options.contains(120)
                ? 120
                : options.first;
      }
    });
  }

  /// Close the sheet first — showing a GetX snackbar before pop can swallow
  /// the back navigation and leave the sheet open.
  void _closeSuccess(String title, String message) {
    if (!mounted) return;
    Navigator.of(context).pop(true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppSnackbar.success(title, message);
    });
  }

  Future<void> _save() async {
    try {
      setState(() => _saving = true);
      await _service.saveReminder(
        bookId: widget.book.id,
        enabled: _enabled,
        hour: _hour,
        minute: _minute,
        goalMinutes: _goalMinutes,
        goalPeriod: _period,
      );
      _closeSuccess(
        'تم',
        _enabled ? 'تم حفظ تذكير «${widget.book.title}»' : 'تم إيقاف التذكير',
      );
    } on AppException catch (e) {
      if (mounted) setState(() => _saving = false);
      AppSnackbar.error('خطأ', e.message);
    }
  }

  Future<void> _delete() async {
    try {
      setState(() => _saving = true);
      await _service.deleteReminder(widget.book.id);
      _closeSuccess('تم', 'تم حذف التذكير');
    } on AppException catch (e) {
      if (mounted) setState(() => _saving = false);
      AppSnackbar.error('خطأ', e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 32.h),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.book.title,
            style: AppTextStyles.subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Text(
            'إشعار يومي مع هدف مدة للقراءة',
            style: AppTextStyles.caption,
          ),
          SizedBox(height: 12.h),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('تفعيل التذكير'),
            value: _enabled,
            onChanged: _saving
                ? null
                : (value) => setState(() => _enabled = value),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.access_time_rounded),
            title: const Text('وقت التذكير'),
            subtitle: Text(_timeLabel),
            enabled: !_saving,
            onTap: _pickTime,
          ),
          SizedBox(height: 8.h),
          Text('نوع الهدف', style: AppTextStyles.caption),
          SizedBox(height: 8.h),
          SegmentedButton<ReminderGoalPeriod>(
            segments: const [
              ButtonSegment(
                value: ReminderGoalPeriod.daily,
                label: Text('يومي'),
                icon: Icon(Icons.today_rounded),
              ),
              ButtonSegment(
                value: ReminderGoalPeriod.weekly,
                label: Text('أسبوعي'),
                icon: Icon(Icons.date_range_rounded),
              ),
            ],
            selected: {_period},
            onSelectionChanged: _saving
                ? null
                : (values) {
                    if (values.isEmpty) return;
                    _onPeriodChanged(values.first);
                  },
          ),
          SizedBox(height: 16.h),
          Text(
            _period == ReminderGoalPeriod.daily
                ? 'مدة الهدف يومياً'
                : 'مدة الهدف أسبوعياً',
            style: AppTextStyles.caption,
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _goalOptions.map((minutes) {
              final selected = _goalMinutes == minutes;
              final label = minutes >= 60 && minutes % 60 == 0
                  ? '${minutes ~/ 60} ساعة'
                  : '$minutes د';
              return ChoiceChip(
                label: Text(label),
                selected: selected,
                onSelected: _saving
                    ? null
                    : (_) => setState(() => _goalMinutes = minutes),
              );
            }).toList(),
          ),
          SizedBox(height: 20.h),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('حفظ'),
          ),
          if (_exists) ...[
            SizedBox(height: 8.h),
            TextButton(
              onPressed: _saving ? null : _delete,
              child: const Text('حذف التذكير'),
            ),
          ],
        ],
      ),
    );
  }
}
