import '../entities/weekly_plan_entity.dart';
import '../../core/utils/result.dart';

abstract class IPlanRepository {
  Future<Result<WeeklyPlanEntity?>> getWeeklyPlan();
  Future<Result<void>> saveWeeklyPlan(WeeklyPlanEntity plan);
  Future<Result<void>> clearWeeklyPlan();
}
