import 'dart:ui';

import 'package:flutter/material.dart';
import 'crop_rect.dart';

/// Crop Grid with invisible border, for better touch detection.
class CropGrid extends StatelessWidget {
  final Rect crop;
  final Color gridColor;
  final Color gridInnerColor;
  final Color gridCornerColor;
  final double paddingSize;
  final double cornerSize;
  final bool showCorners;
  final double thinWidth;
  final double thickWidth;
  final Color scrimColor;
  final bool alwaysShowThirdLines;
  final bool isMoving;
  final ValueChanged<Size> onSize;
  final double zoom;

  const CropGrid({
    super.key,
    required this.crop,
    required this.gridColor,
    required this.gridInnerColor,
    required this.gridCornerColor,
    required this.paddingSize,
    required this.cornerSize,
    required this.thinWidth,
    required this.thickWidth,
    required this.scrimColor,
    required this.showCorners,
    required this.alwaysShowThirdLines,
    required this.isMoving,
    required this.onSize,
    required this.zoom,
  });

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(foregroundPainter: _CropGridPainter(this)),
  );
}

class _CropGridPainter extends CustomPainter {
  final CropGrid grid;

  _CropGridPainter(this.grid);

  @override
  void paint(Canvas canvas, Size size) {
    final Size imageSize = Size(
      size.width - 2 * grid.paddingSize,
      size.height - 2 * grid.paddingSize,
    );
    final Rect full = Offset(grid.paddingSize, grid.paddingSize) & imageSize;
    final Rect bounds = grid.crop.multiply(imageSize).translate(grid.paddingSize, grid.paddingSize);
    grid.onSize(imageSize);

    // Calculate zoomed dimensions
    final zoomedWidth = imageSize.width * grid.zoom;
    final zoomedHeight = imageSize.height * grid.zoom;

    // Calculate zoom offsets
    final zoomOffsetX = (zoomedWidth - imageSize.width) / 2;
    final zoomOffsetY = (zoomedHeight - imageSize.height) / 2;

    // Create zoomed full rect
    final zoomedFull = Rect.fromLTWH(
      grid.paddingSize - zoomOffsetX,
      grid.paddingSize - zoomOffsetY,
      zoomedWidth,
      zoomedHeight,
    );

    // Add back the overlay/scrim with zoom consideration
    canvas.save();
    canvas.clipRect(bounds, clipOp: ClipOp.difference);
    canvas.drawRect(
        zoomedFull,
        Paint()
          ..color = grid.scrimColor
          ..style = PaintingStyle.fill
          ..isAntiAlias = true
    );
    canvas.restore();

    // Draw corner lines for crop customization
    if (grid.showCorners) {
      final cornerPaint = Paint()
        ..color = grid.gridCornerColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = grid.thickWidth
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true;

      // // Add corner borders
      // final borderPaint = Paint()
      //   ..color = grid.gridCornerColor
      //   ..style = PaintingStyle.stroke
      //   ..strokeWidth = 2.0  // Thin border
      //   ..isAntiAlias = true;

      // // Calculate corner border size based on cornerSize
      // final borderSize = grid.cornerSize * 1.2;  // Slightly larger than corner markers

      // // Draw corner borders
      // void drawCornerBorder(Offset corner) {
      //   canvas.drawRect(
      //     Rect.fromCenter(
      //       center: corner,
      //       width: borderSize,
      //       height: borderSize,
      //     ),
      //     borderPaint,
      //   );
      // }

      // Draw the original corner lines
      canvas.drawLine(
        bounds.topLeft,
        bounds.topLeft.translate(grid.cornerSize, 0),
        cornerPaint,
      );
      canvas.drawLine(
        bounds.topLeft,
        bounds.topLeft.translate(0, grid.cornerSize),
        cornerPaint,
      );

      canvas.drawLine(
        bounds.topRight,
        bounds.topRight.translate(-grid.cornerSize, 0),
        cornerPaint,
      );
      canvas.drawLine(
        bounds.topRight,
        bounds.topRight.translate(0, grid.cornerSize),
        cornerPaint,
      );

      canvas.drawLine(
        bounds.bottomLeft,
        bounds.bottomLeft.translate(grid.cornerSize, 0),
        cornerPaint,
      );
      canvas.drawLine(
        bounds.bottomLeft,
        bounds.bottomLeft.translate(0, -grid.cornerSize),
        cornerPaint,
      );

      canvas.drawLine(
        bounds.bottomRight,
        bounds.bottomRight.translate(-grid.cornerSize, 0),
        cornerPaint,
      );
      canvas.drawLine(
        bounds.bottomRight,
        bounds.bottomRight.translate(0, -grid.cornerSize),
        cornerPaint,
      );

      // Add the corner borders
      // drawCornerBorder(bounds.topLeft);
      // drawCornerBorder(bounds.topRight);
      // drawCornerBorder(bounds.bottomLeft);
      // drawCornerBorder(bounds.bottomRight);
    }

    // Draw thin grid lines
    final gridPaint = Paint()
      ..color = grid.gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = grid.thinWidth
      ..strokeCap = StrokeCap.butt
      ..isAntiAlias = true;

    // Draw border lines
    canvas.drawRect(bounds, gridPaint);

    // Draw third lines if needed
    if (grid.isMoving || grid.alwaysShowThirdLines) {
      final thirdHeight = bounds.height / 3.0;
      final thirdWidth = bounds.width / 3.0;

      // Horizontal third lines
      canvas.drawLine(
        Offset(bounds.left, bounds.top + thirdHeight),
        Offset(bounds.right, bounds.top + thirdHeight),
        gridPaint,
      );
      canvas.drawLine(
        Offset(bounds.left, bounds.bottom - thirdHeight),
        Offset(bounds.right, bounds.bottom - thirdHeight),
        gridPaint,
      );

      // Vertical third lines
      canvas.drawLine(
        Offset(bounds.left + thirdWidth, bounds.top),
        Offset(bounds.left + thirdWidth, bounds.bottom),
        gridPaint,
      );
      canvas.drawLine(
        Offset(bounds.right - thirdWidth, bounds.top),
        Offset(bounds.right - thirdWidth, bounds.bottom),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_CropGridPainter oldDelegate) =>
      oldDelegate.grid.crop != grid.crop ||
          oldDelegate.grid.isMoving != grid.isMoving ||
          oldDelegate.grid.cornerSize != grid.cornerSize ||
          oldDelegate.grid.gridColor != grid.gridColor ||
          oldDelegate.grid.gridCornerColor != grid.gridCornerColor ||
          oldDelegate.grid.gridInnerColor != grid.gridInnerColor ||
          oldDelegate.grid.zoom != grid.zoom;

  @override
  bool hitTest(Offset position) => true;
}