// lib/providers/encounter_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/services/encounter_service.dart';

// Provider cho service
final encounterServiceProvider = Provider.autoDispose((ref) => EncounterService());

// Provider để quản lý hành động tạo bệnh án
final encounterCreationProvider = 
    AsyncNotifierProvider.autoDispose<EncounterCreationNotifier, void>(
        EncounterCreationNotifier.new);

class EncounterCreationNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Không cần làm gì ở đây
  }

 
  Future<void> createEncounter({
    required int appointmentId,
    required String symptoms,
    required String diagnosis,
    required List<Map<String, dynamic>> prescriptionItems,
    String? prescriptionNotes,
    List<int>? serviceIds,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(encounterServiceProvider).createEncounter(
            appointmentId: appointmentId,
            symptoms: symptoms,
            diagnosis: diagnosis,
            prescriptionItems: prescriptionItems,
            prescriptionNotes: prescriptionNotes,
            serviceIds: serviceIds,
          );
    });
  }
}