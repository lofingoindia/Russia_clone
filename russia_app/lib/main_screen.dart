import 'package:flutter/material.dart';
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
  int _currentIndex = 1; // Default to Home (Center)

  final List<Widget> _screens = [
    const ProfileScreen(),
    const HomeScreen(),
    const ServicesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          _screens[_currentIndex],
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              bottom: true,
              child: CustomBottomNavBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
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
    final double circleSize = 75;

    return Container(
      height: 100, // Total height to accommodate the circle and shadow
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
          Padding(
            padding: const EdgeInsets.only(bottom: 8), // Adjust to center items vertically in bar
            child: Container(
              height: 60,
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
                    activeColor: const Color(0xFF32BA7C),
                  ),
                  
                  // Empty space for the center circle
                  const SizedBox(width: 60),
                  
                  // Services
                  _buildNavItem(
                    index: 2,
                    imagePath: 'lib/assets/S.png',
                    icon: Icons.apps,
                    label: 'services'.tr(),
                    isActive: currentIndex == 2,
                    activeColor: const Color(0xFF32BA7C),
                  ),
                ],
              ),
            ),
          ),
          
          // Center Circle (Home)
          Positioned(
            top: 8,
            child: GestureDetector(
              onTap: () => onTap(1),
              child: Container(
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: currentIndex == 1 
                        ? const Color(0xFF32BA7C)
                        : const Color(0xFFE5E5E5),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF32BA7C).withOpacity(0.12),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        currentIndex == 1 
                            ? const Color(0xFF32BA7C)
                            : Color(0xFF3C4451).withOpacity(0.8),
                        BlendMode.srcIn,
                      ),
                      child: Image.asset(
                        'lib/assets/home.png',
                        width: 32,
                        height: 32,
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -10),
                      child: Text(
                        'home'.tr(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: currentIndex == 1 
                              ? const Color(0xFF32BA7C) // Green when selected
                              : Color(0xFF3C4451).withOpacity(0.8),
                        ),
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
    final color = isActive ? activeColor : Color(0xFF3C4451).withOpacity(0.8);
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 70,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget ?? (imagePath != null 
                ? ColorFiltered(
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
                  )
                : Icon(
                    icon,
                    color: color,
                    size: 17,
                  )),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: color,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
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
    double notchRadius = 41;
    double centerX = size.width / 2;
    double cornerRadius = 30.0; // Rounded top corners
    
    // Start from bottom left
    path.moveTo(0, size.height);
    path.lineTo(0, cornerRadius); // Go up to start of corner
    
    // Top Left Corner
    path.quadraticBezierTo(0, 0, cornerRadius, 0);
    
    // Line to start of notch (Sharp edge)
    path.lineTo(centerX - notchRadius, 0);
    
    // Vertical line down (Deep and Sharp)
    path.lineTo(centerX - notchRadius, 20);
    
    // The Circular Notch (The "U")
    path.arcToPoint(
      Offset(centerX + notchRadius, 20),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );
    
    // Vertical line up (Sharp exit)
    path.lineTo(centerX + notchRadius, 0);
    
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
