import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock_care_repository.dart';
import '../models/care_models.dart';

final careRepositoryProvider = Provider<MockCareRepository>((ref) => MockCareRepository());

class CareState {
  final List<CareTask> tasks;
  const CareState(this.tasks);
}

class CareNotifier extends Notifier<CareState> {
  @override
  CareState build() => CareState(ref.read(careRepositoryProvider).tasks);

  Future<void> toggleTask(String id) async {
    await ref.read(careRepositoryProvider).toggleTask(id);
    state = CareState(ref.read(careRepositoryProvider).tasks);
  }
}

final careProvider = NotifierProvider<CareNotifier, CareState>(CareNotifier.new);
