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
        return Consumer<RadioGlobeProvider>(
          builder: (context, provider, child) {
            if (!provider.isGlobeInitialized) {
              return const Center(
                child:
                    CupertinoActivityIndicator(color: AppColors.primaryOrange),
              );
            }
            return Center(
              child: SizedBox(
                width: diameter,
                height: diameter,
                child: Stack(
                  alignment: Alignment.center,
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
                      child: MediaQuery(
                        data: MediaQuery.of(context).copyWith(
                          size: Size.square(diameter),
                        ),
                        child: FlutterEarthGlobe(
                          controller: provider.globeController,
                          radius: radius,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
