import '../../domain/entities/weekly_plan_entity.dart';
import '../../domain/repositories/i_plan_repository.dart';
import '../../core/utils/result.dart';
import '../local/local_storage.dart';

class PlanRepositoryImpl implements IPlanRepository {
  final LocalStorage _localStorage;

  PlanRepositoryImpl(this._localStorage);

  @override
  Future<Result<WeeklyPlanEntity?>> getWeeklyPlan() async {
    try {
      final jsonString = _localStorage.weeklyPlanJson;
      if (jsonString == null || jsonString.isEmpty) {
        return const Success(null);
      }
      final plan = WeeklyPlanEntity.fromJson(jsonString);
      return Success(plan);
    } catch (e) {
      return Failure('Failed to parse weekly plan: $e');
    }
  }

  @override
  Future<Result<void>> saveWeeklyPlan(WeeklyPlanEntity plan) async {
    try {
      final jsonString = plan.toJson();
      await _localStorage.saveWeeklyPlan(jsonString);
      return const Success(null);
    } catch (e) {
      return Failure('Failed to save weekly plan: $e');
    }
  }

  @override
  Future<Result<void>> clearWeeklyPlan() async {
    try {
      await _localStorage.clearWeeklyPlan();
      return const Success(null);
    } catch (e) {
      return Failure('Failed to clear weekly plan: $e');
    }
  }
}
