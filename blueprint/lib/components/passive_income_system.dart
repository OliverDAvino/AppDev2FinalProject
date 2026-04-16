import 'package:flame/components.dart';
import '../cookie_game.dart';

class PassiveIncomeSystem extends Component with HasGameRef<CookieGame> {
  double _accumulator = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _accumulator += dt;
    if (_accumulator >= 1.0) {
      final earned = gameRef.upgradeManager.cookiesPerSecond.floor();
      if (earned > 0) {
        gameRef.cookieNotifier.value += earned;
      }
      _accumulator = 0;
    }
  }
}