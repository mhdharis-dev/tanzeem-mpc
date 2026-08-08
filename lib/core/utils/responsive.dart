import 'package:flutter/material.dart';

enum DeviceType { mobile, tablet, laptop, desktop, tv }

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? laptop;
  final Widget desktop;
  final Widget? tv;

  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    this.laptop,
    required this.desktop,
    this.tv,
  });

  static bool isCompactMobile(BuildContext context) => MediaQuery.of(context).size.width < 420;
  static bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 600;
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1024;
  static bool isLaptop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024 && MediaQuery.of(context).size.width < 1440;
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1440 && MediaQuery.of(context).size.width < 2560;
  static bool isTV(BuildContext context) => MediaQuery.of(context).size.width >= 2560;

  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return DeviceType.mobile;
    if (width < 1024) return DeviceType.tablet;
    if (width < 1440) return DeviceType.laptop;
    if (width < 2560) return DeviceType.desktop;
    return DeviceType.tv;
  }

  static double getPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 420) return 10.0; // 390px - 412px compact mobile
    if (width < 600) return 14.0; // 480px mobile
    if (width < 1024) return 18.0; // 600px - 800px tablet
    if (width < 1440) return 24.0; // 1280px - 1366px laptop
    if (width < 2560) return 28.0; // 1600px - 1920px desktop
    return 36.0; // 2560px - 3840px 4K TV
  }

  static double getFontSizeScale(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 420) return 0.85; // 390px - 412px compact mobile
    if (width < 600) return 0.90; // 480px mobile
    if (width < 1024) return 0.95; // 600px - 800px tablet
    if (width < 1440) return 1.0; // 1280px - 1366px laptop
    if (width < 2560) return 1.08; // 1600px - 1920px desktop
    return 1.25; // 2560px - 3840px 4K TV
  }

  static int getGridColumns(
    BuildContext context, {
    int mobile = 1,
    int tablet = 2,
    int laptop = 3,
    int desktop = 4,
    int tv = 4,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width < 700) return mobile;
    if (width < 1024) return tablet;
    if (width < 1440) return laptop;
    if (width < 1920) return desktop;
    return tv;
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    if (width >= 1920 && tv != null) return tv!;
    if (width >= 1440) return desktop;
    if (width >= 1024 && laptop != null) return laptop!;
    if (width >= 700 && tablet != null) return tablet!;
    return mobile;
  }
}

class TVContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const TVContainer({
    super.key,
    required this.child,
    this.maxWidth = 1920,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1920) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      );
    }
    return child;
  }
}
