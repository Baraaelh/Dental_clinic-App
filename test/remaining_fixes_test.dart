import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graduation/core/utils/helpers.dart';
import 'package:graduation/core/utils/status_labels.dart';
import 'package:graduation/features/admin/domain/repositories/admin_repository.dart';
import 'package:graduation/features/admin/presentation/controllers/admin_controller.dart';
import 'package:graduation/features/authentication/domain/models/user_model.dart';
import 'package:graduation/features/dentists/domain/models/dentist_model.dart';
import 'package:graduation/features/dentists/domain/repositories/dentist_repository.dart';
import 'package:graduation/features/dentists/presentation/controllers/dentist_controller.dart';
import 'package:graduation/l10n/app_localizations.dart';

DentistModel _dentist(String name, String spec, {List<String> days = const []}) =>
    DentistModel(
      id: name,
      name: name,
      specialization: spec,
      experience: 1,
      description: '',
      image: '',
      workingDays: days,
      workingHours: const {'start': '09:00', 'end': '17:00'},
    );

class _FakeDentists extends Fake implements DentistRepository {
  _FakeDentists(this.all);
  final List<DentistModel> all;
  int calls = 0;
  int? lastLimit;

  @override
  Future<List<DentistModel>> getDentists({
    int limit = 10,
    DentistModel? lastDentist,
    String? specialization,
    String? searchQuery,
  }) async {
    calls++;
    lastLimit = limit;
    return all.take(limit).toList();
  }
}

class _FakeAdmin extends Fake implements AdminRepository {
  _FakeAdmin(this.patients);
  final List<UserModel> patients;
  final toggled = <String, bool>{};

  @override
  Future<List<UserModel>> getAllPatients({int limit = 20, UserModel? lastUser}) async {
    final start = lastUser == null ? 0 : patients.indexOf(lastUser) + 1;
    return patients.skip(start).take(limit).toList();
  }

  @override
  Future<void> toggleUserStatus(String uid, bool isActive) async {
    toggled[uid] = isActive;
  }
}

void main() {
  group('generateTimeSlots', () {
    test('normal hours produce 30-minute slots', () {
      final slots = AppHelpers.generateTimeSlots(start: '09:00', end: '11:00');
      expect(slots, ['09:00', '09:30', '10:00', '10:30']);
    });
    test('bad or reversed hours return no slots instead of crashing', () {
      for (final pair in [
        ['', ''],
        ['9am', '5pm'],
        ['17:00', '09:00'],
        ['25:00', '26:00'],
      ]) {
        expect(AppHelpers.generateTimeSlots(start: pair[0], end: pair[1]),
            isEmpty, reason: pair.toString());
      }
      expect(AppHelpers.generateTimeSlots(start: '9:00', end: '10:00'),
          ['09:00', '09:30']);
    });
  });

  test('working days match full and 3-letter names', () {
    final d = _dentist('A', 'x', days: ['sun', 'Monday', 'TUE']);
    expect(d.isWorkingOn('Sunday'), isTrue);
    expect(d.isWorkingOn('Monday'), isTrue);
    expect(d.isWorkingOn('Tuesday'), isTrue);
    expect(d.isWorkingOn('Friday'), isFalse);
    final ar = lookupAppLocalizations(const Locale('ar'));
    expect(weekdayLabel(ar, 'sun'), ar.sunday);
  });

  group('DentistListController', () {
    test('loads all dentists once; search/filter run in memory', () async {
      final repo = _FakeDentists([
        for (var i = 0; i < 15; i++) _dentist('Dr $i', i.isEven ? 'Ortho' : 'Kids'),
      ]);
      final c = ProviderContainer(overrides: [
        dentistRepositoryProvider.overrideWithValue(repo),
      ]);
      addTearDown(c.dispose);

      final all = await c.read(dentistListProvider.future);
      expect(all.length, 15, reason: 'more than the old page size of 10');
      expect(repo.lastLimit, greaterThan(10));

      final ctrl = c.read(dentistListProvider.notifier);
      ctrl.search('dr 14');
      expect(c.read(dentistListProvider).value!.map((d) => d.name), ['Dr 14']);
      ctrl.search('');
      ctrl.filterBySpecialization('Kids');
      expect(c.read(dentistListProvider).value!.length, 7);
      expect(repo.calls, 1, reason: 'no Firestore query per keystroke');
    });
  });

  group('PatientsController', () {
    final patients = [
      for (var i = 0; i < 45; i++)
        UserModel(uid: 'u$i', name: 'P$i', phone: '', email: '', role: 'patient'),
    ];

    test('pages through all patients with loadMore', () async {
      final c = ProviderContainer(overrides: [
        adminRepositoryProvider.overrideWithValue(_FakeAdmin(patients)),
      ]);
      addTearDown(c.dispose);
      final ctrl = c.read(allPatientsProvider.notifier);

      expect((await c.read(allPatientsProvider.future)).length, 20);
      expect(ctrl.hasMore, isTrue);
      await ctrl.loadMore();
      await ctrl.loadMore();
      expect(c.read(allPatientsProvider).value!.length, 45);
      expect(ctrl.hasMore, isFalse);
    });

    test('blocking a patient keeps loaded pages and updates in place', () async {
      final repo = _FakeAdmin(patients);
      final c = ProviderContainer(overrides: [
        adminRepositoryProvider.overrideWithValue(repo),
      ]);
      addTearDown(c.dispose);
      final ctrl = c.read(allPatientsProvider.notifier);
      await c.read(allPatientsProvider.future);
      await ctrl.loadMore();

      await ctrl.toggleStatus('u30', true);
      final list = c.read(allPatientsProvider).value!;
      expect(list.length, 40);
      expect(list.firstWhere((u) => u.uid == 'u30').isActive, isFalse);
      expect(repo.toggled['u30'], isFalse);
    });
  });
}
