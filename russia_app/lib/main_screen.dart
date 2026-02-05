import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/services_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late PageController _pageController;
  int _currentIndex = 1; // Default to Home (Center)

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const ProfileScreen(),
      HomeScreen(key: HomeScreen.globalKey),
      const ServicesScreen(),
    ];
    _pageController = PageController(initialPage: _currentIndex);
  }



  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool _isManualTransition = false;

  @override
  Widget build(BuildContext context) {
    // Set system navigation bar color to white
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              if (!_isManualTransition) {
                setState(() {
                  _currentIndex = index;
                });
              }
            },
            physics: const BouncingScrollPhysics(),
            children: _screens,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomBottomNavBar(
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    if (_currentIndex == index) {
                      // If already on home, trigger refresh
                      if (index == 1) {
                        HomeScreen.globalKey.currentState?.triggerRefresh();
                      }
                      return;
                    }
                    
                    setState(() {
                      _currentIndex = index;
                      _isManualTransition = true;
                    });
                    
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOutCubic,
                    ).then((_) {
                      _isManualTransition = false;
                    });
                  },
                ),
                // Solid background for the bottom safe area (home indicator area)
                Container(
                  height: MediaQuery.of(context).padding.bottom,
                  color: Colors.white,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double barHeight = 75;
    final double circleSize = 78;

    return Container(
      height: 110, // Sufficient for 78x78 circle
      width: double.infinity,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // The White Bar with Notch
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, barHeight),
            painter: NotchPainter(),
          ),
          
          // Navigation Items
          Container(
            height: barHeight,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Profile
                  _buildNavItem(
                    index: 0,
                    imagePath: 'lib/assets/p.png',
                    icon: Icons.person,
                    label: 'profile'.tr(),
                    isActive: currentIndex == 0,
                    activeColor: const Color(0xFF02C739),
                  ),
                  
                  // Empty space for the center circle
                  const SizedBox(width: 60),
                  
                  // Services
                  _buildNavItem(
                    index: 2,
                    imagePath: 'lib/assets/ser.png',
                    icon: Icons.apps,
                    label: 'services'.tr(),
                    isActive: currentIndex == 2,
                    activeColor: const Color(0xFF02C739),
                  ),
                ],
              ),
            ),
          
          // Center Circle (Home)
          Positioned(
            top: 10,
            child: GestureDetector(
              onTap: () => onTap(1),
              child: Container(
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF02C739),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF02C739).withOpacity(0.12),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    currentIndex == 1 
                        ? Opacity(
                            opacity: 0.5,
                            child: ColorFiltered(
                              colorFilter: const ColorFilter.mode(
                                Color(0xFF01C636),
                                BlendMode.srcIn,
                              ),
                            child: Image.asset(
                                'lib/assets/homy.png',
                                width: 24,
                                height: 24,
                              ),
                              ),
                          )
                        : Image.asset(
                            'lib/assets/homy.png',
                            width: 24,
                            height: 24,
                          ),
                    const SizedBox(height: 4),
                    Text(
                      'home'.tr(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesIcon(bool isActive) {
    final color = isActive ? const Color(0xFF32BA7C) : Color(0xFF3C4451).withOpacity(0.8);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dot(color),
            const SizedBox(width: 3),
            _dot(color),
          ],
        ),
        const SizedBox(height: 3),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dot(color),
            const SizedBox(width: 3),
            _dot(color),
          ],
        ),
      ],
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(1.5),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    String? imagePath,
    IconData? icon,
    Widget? iconWidget,
    required String label,
    required bool isActive,
    required Color activeColor,
  }) {
    final color = isActive ? activeColor : const Color(0xFF3C4451);
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            iconWidget ?? (imagePath != null 
                ? Opacity(
                    opacity: isActive ? 0.5 : 1.0,
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                      child: Image.asset(
                        imagePath,
                        width: 17,
                        height: 17,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          icon ?? Icons.error,
                          color: color,
                          size: 17,
                        ),
                      ),
                    ),
                  )
                : Icon(
                    icon,
                    color: color,
                    size: 17,
                  )),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    Path path = Path();
    double centerX = size.width / 2;
    double cornerRadius = 30.0; // Rounded top corners
    
    // Start from bottom left
    path.moveTo(0, size.height);
    path.lineTo(0, cornerRadius); // Go up to start of corner
    
    // Top Left Corner
    path.quadraticBezierTo(0, 0, cornerRadius, 0);
    
    // Calculate intersection of notch circle with top edge
    // We assume the circle center is at (centerX, 15) to maintain bottom depth
    double notchCenterY = 15.0; // Aligned with the circle's center at top: 10
    double notchRadius = 41.5; // Adjusted for a 78x78 circle (radius 39) with a small gap
    double intersectionX = sqrt(notchRadius * notchRadius - notchCenterY * notchCenterY);

    // Line to start of notch (curved in)
    path.lineTo(centerX - intersectionX, 0);
    
    // The Circular Notch (Full Circle wrap)
    path.arcToPoint(
      Offset(centerX + intersectionX, 0),
      radius: Radius.circular(notchRadius),
      clockwise: false,
      largeArc: true,
    );
    
    // Line to start of right corner
    path.lineTo(size.width - cornerRadius, 0);
    
    // Top Right Corner
    path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);
    
    // Bottom right
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // Subtle Shadow for the bar
    canvas.drawShadow(
      path, 
      Colors.black.withOpacity(0.08), 
      10, 
      false
    );
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
