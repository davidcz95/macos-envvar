import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macos_envvar/features/dashboard/dashboard.dart';

void main() {
  group('CounterCubit', () {
    test('initial state is 0', () {
      expect(DashboardCubit().state, equals(0));
    });

    blocTest<DashboardCubit, int>(
      'emits [1] when increment is called',
      build: DashboardCubit.new,
      act: (cubit) => cubit.increment(),
      expect: () => [equals(1)],
    );

    blocTest<DashboardCubit, int>(
      'emits [-1] when decrement is called',
      build: DashboardCubit.new,
      act: (cubit) => cubit.decrement(),
      expect: () => [equals(-1)],
    );
  });
}
