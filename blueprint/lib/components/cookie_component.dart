import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import '../cookie_game.dart';

class CookieComponent extends SpriteComponent
    with TapCallbacks, HasGameRef<CookieGame> {
  CookieComponent({required Vector2 position})
      : super(size: Vector2(240, 240), anchor: Anchor.center) {
    this.position = position;
  }

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('MainFlower.png');
  }

  @override
  void onTapDown(TapDownEvent event) {
    gameRef.cookieNotifier.value += gameRef.upgradeManager.clickPower;
    _spawnParticles();
    _animateClick();
  }

  void _animateClick() {
    add(ScaleEffect.by(
      Vector2.all(1.15),
      EffectController(duration: 0.05, reverseDuration: 0.05),
    ));
  }

  void _spawnParticles() {
    final random = Random();
    gameRef.add(
      ParticleSystemComponent(
        position: absoluteCenter,
        particle: Particle.generate(
          count: 6,
          generator: (_) => AcceleratedParticle(
            acceleration: Vector2(0, 200),
            speed: Vector2(
              -80 + random.nextDouble() * 160,
              -200 + random.nextDouble() * -100,
            ),
            child: CircleParticle(
              radius: 4,
              paint: Paint()..color = Colors.brown.shade300,
            ),
          ),
        ),
      ),
    );
  }
}