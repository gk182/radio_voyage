import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter_earth_globe/flutter_earth_globe.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../providers/radio_globe_provider.dart';

/// The package-backed globe is kept fully interactive; this widget only
/// supplies reference-driven sizing and the restrained physical shadow.
class Globe3dViewport extends StatelessWidget {
  const Globe3dViewport({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final diameter =
            math.min(constraints.maxWidth * .92, constraints.maxHeight * .97);
        final radius = diameter / 2.16;
        return Selector<RadioGlobeProvider, bool>(
          selector: (_, provider) => provider.isGlobeInitialized,
          builder: (context, isInitialized, child) {
            if (!isInitialized) {
              return const Center(
                child:
                    CupertinoActivityIndicator(color: AppColors.primaryOrange),
              );
            }
            final provider = context.read<RadioGlobeProvider>();
            // flutter_earth_globe enlarges the painted sphere by 2^zoom. Give
            // its rasterizer enough room for maxZoom so the enlarged sphere is
            // never clipped to the package widget's rectangular bounds.
            final zoomRange = provider.globeController.maxZoom -
                provider.globeController.minZoom;
            final renderSize =
                (diameter * math.pow(2, zoomRange) + 16).toDouble();
            return RepaintBoundary(
              child: Center(
                child: SizedBox(
                  width: diameter,
                  height: diameter,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Transform.translate(
                        offset: Offset(0, diameter * .43),
                        child: Container(
                          width: diameter * .67,
                          height: diameter * .13,
                          decoration: const BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.elliptical(180, 30)),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x33476B87),
                                blurRadius: 24,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: OverflowBox(
                          maxWidth: renderSize,
                          maxHeight: renderSize,
                          child: SizedBox.square(
                            dimension: renderSize,
                            child: MediaQuery(
                              data: MediaQuery.of(context).copyWith(
                                size: Size.square(renderSize),
                              ),
                              child: FlutterEarthGlobe(
                                controller: provider.globeController,
                                radius: radius,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
