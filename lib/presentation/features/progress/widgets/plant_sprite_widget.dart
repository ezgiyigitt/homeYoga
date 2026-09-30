import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

/// Crops a single frame out of a horizontal plant spritesheet.
/// Scaled to display large, clear pots in weekly garden views.
class PlantSpriteWidget extends StatelessWidget {
  final String assetPath;
  final int frameIndex; // 0-based
  final double height;

  const PlantSpriteWidget({
    super.key,
    required this.assetPath,
    required this.frameIndex,
    this.height = 95,
  });

  // Measured directly from the source PNGs: (totalWidth / 7) / totalHeight.
  static const double _growingFrameAspect = (2116 / 7) / 743; // ≈ 0.4068
  static const double _wiltingFrameAspect = (2172 / 7) / 724; // ≈ 0.4285

  double get _frameAspect =>
      assetPath == AppConstants.plantGrowingAsset ? _growingFrameAspect : _wiltingFrameAspect;

  @override
  Widget build(BuildContext context) {
    final frameCount = AppConstants.plantSpriteFrameCount;
    final frameWidth = height * _frameAspect;
    final sheetWidth = frameWidth * frameCount;

    return SizedBox(
      width: frameWidth,
      height: height,
      child: ClipRect(
        child: OverflowBox(
          maxWidth: sheetWidth,
          minWidth: sheetWidth,
          maxHeight: height,
          minHeight: height,
          alignment: Alignment.centerLeft,
          child: Transform.translate(
            offset: Offset(-frameWidth * frameIndex, 0),
            child: Image.asset(
              assetPath,
              width: sheetWidth,
              height: height,
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
    );
  }
}
