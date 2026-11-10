import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../../dentists/presentation/controllers/dentist_controller.dart';
import '../controllers/appointment_controller.dart';
import '../widgets/time_slot_widget.dart';
import 'payment_screen.dart';
import '../../../../core/errors/error_messages.dart';

class BookAppointmentScreen extends ConsumerStatefulWidget {
  const BookAppointmentScreen({super.key, required this.dentistId});
  final String dentistId;

  @override
  ConsumerState<BookAppointmentScreen> createState() =>
      _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends ConsumerState<BookAppointmentScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  String? _selectedTime;
  bool _initialDayChosen = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dentistAsync = ref.watch(dentistDetailProvider(widget.dentistId));

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(l10n.bookAppointment),
      ),
      body: dentistAsync.when(
        data: (dentist) {
          // Start on the first day the dentist actually works.
          if (!_initialDayChosen) {
            _initialDayChosen = true;
            if (dentist.workingDays.isNotEmpty) {
              var day = DateTime.now();
              for (var i = 0; i < 7; i++) {
                if (dentist.isWorkingOn(_getDayName(day.weekday))) break;
                day = day.add(const Duration(days: 1));
              }
              _selectedDay = day;
              _focusedDay = day;
            }
          }
          final bookedSlotsAsync = ref.watch(
            bookedSlotsProvider((
              dentistId: widget.dentistId,
              date: _selectedDay,
            )),
          );

          final allSlots = AppHelpers.generateTimeSlots(
            start: dentist.workStartTime,
            end: dentist.workEndTime,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DentistInfoCard(
                  name: dentist.name,
                  specialization: dentist.specialization,
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.selectDate,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Card(
                  child: TableCalendar(
                    locale: Localizations.localeOf(context).languageCode,
                    firstDay: DateTime.now(),
                    lastDay: DateTime.now().add(const Duration(days: 90)),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
                    enabledDayPredicate: dentist.workingDays.isEmpty
                        ? null
                        : (day) {
                            final dayName = _getDayName(day.weekday);
                            return dentist.isWorkingOn(dayName);
                          },
                    onDaySelected: (selected, focused) {
                      setState(() {
                        _selectedDay = selected;
                        _focusedDay = focused;
                        _selectedTime = null;
                      });
                    },
                    calendarStyle: const CalendarStyle(
                      selectedDecoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      disabledTextStyle: TextStyle(color: AppColors.textHint),
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.selectTime,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                bookedSlotsAsync.when(
                  data: (bookedSlots) {
                    if (allSlots.isEmpty) {
                      return Text(l10n.noSlotsAvailable);
                    }
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 2.2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: allSlots.length,
                      itemBuilder: (context, index) {
                        final slot = allSlots[index];
                        return TimeSlotWidget(
                          time: slot,
                          isBooked: bookedSlots.contains(slot) ||
                              _isPast(_selectedDay, slot),
                          isSelected: _selectedTime == slot,
                          onTap: () =>
                              setState(() => _selectedTime = slot),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => Text(l10n.somethingWentWrong),
                ),
                const SizedBox(height: 32),
                AppButton(
                  label: l10n.confirmBooking,
                  onPressed: _selectedTime != null
                      ? () {
                          final user = ref.read(currentUserProvider);
                          if (user == null) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PaymentScreen(
                                dentistId: widget.dentistId,
                                dentistName: dentist.name,
                                date: _selectedDay,
                                time: _selectedTime!,
                                patientId: user.uid,
                                patientName: user.name,
                              ),
                            ),
                          );
                        }
                      : null,
                  icon: Icons.check,
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (e, _) => AppErrorWidget(
          message: context.errorMessage(e),
          onRetry: () =>
              ref.refresh(dentistDetailProvider(widget.dentistId)),
        ),
      ),
    );
  }

  /// Today's slots that have already started can't be booked.
  bool _isPast(DateTime day, String slot) {
    final now = DateTime.now();
    if (!isSameDay(day, now)) return false;
    final parts = slot.split(':');
    final slotTime = DateTime(now.year, now.month, now.day,
        int.parse(parts[0]), int.parse(parts[1]));
    return !slotTime.isAfter(now);
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }
}

class _DentistInfoCard extends StatelessWidget {
  const _DentistInfoCard({
    required this.name,
    required this.specialization,
  });
  final String name;
  final String specialization;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.gradient1, AppColors.gradient2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                specialization,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

