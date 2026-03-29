import 'package:team_flow/core/helpers/cache_helper.dart';

class SaveOnboardingStatusUseCase {
  final CacheHelper _cacheHelper;

  SaveOnboardingStatusUseCase(this._cacheHelper);

  Future<bool> call() async {
    return await _cacheHelper.saveData(
      key: CacheKeys.hasSeenOnboarding,
      value: true,
    );
  }
}
