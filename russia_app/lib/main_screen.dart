import 'package:flutter/material.dart';
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
    final double barHeight = 90;
    final double circleSize = 92;

    return Container(
      height: 120, // Total height to accommodate the circle and shadow
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
            padding: const EdgeInsets.only(bottom: 10), // Adjust to center items vertically in bar
            child: Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Profile
                  _buildNavItem(
                    index: 0,
                    imagePath: 'lib/assets/p.png',
                    icon: Icons.person,
                    label: 'Profile',
                    isActive: currentIndex == 0,
                    activeColor: const Color(0xFF32BA7C),
                  ),
                  
                  // Empty space for the center circle
                  const SizedBox(width: 80),
                  
                  // Services
                  _buildNavItem(
                    index: 2,
                    imagePath: 'lib/assets/S.png',
                    icon: Icons.apps,
                    label: 'Services',
                    isActive: currentIndex == 2,
                    activeColor: const Color(0xFF32BA7C),
                  ),
                ],
              ),
            ),
          ),
          
          // Center Circle (Home)
          Positioned(
            top: 5,
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
                        ? const Color(0xFF32BA7C) // Green when selected
                        : const Color(0xFFE5E5E5), // Grey when not
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
                            : const Color(0xFFAAB2B9),
                        BlendMode.srcIn,
                      ),
                      child: Image.asset(
                        'lib/assets/home.png',
                        width: 64,
                        height: 64,
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -14),
                      child: Text(
                        'Home',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: currentIndex == 1 
                              ? const Color(0xFF32BA7C) // Green when selected
                              : const Color(0xFFAAB2B9),
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
    final color = isActive ? const Color(0xFF32BA7C) : const Color(0xFFAAB2B9);
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
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2.5),
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
    final color = isActive ? activeColor : const Color(0xFFAAB2B9);
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 90,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget ?? (imagePath != null 
                ? ColorFiltered(
                    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                    child: Image.asset(
                      imagePath,
                      width: 32,
                      height: 32,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        icon ?? Icons.error,
                        color: color,
                        size: 32,
                      ),
                    ),
                  )
                : Icon(
                    icon,
                    color: color,
                    size: 32,
                  )),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
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
    double cornerRadius = 24;
    double notchRadius = 58; // Half of notch width
    double centerX = size.width / 2;
    
    // Start from bottom left
    path.moveTo(0, size.height);
    path.lineTo(0, cornerRadius);
    
    // Top left corner
    path.quadraticBezierTo(0, 0, cornerRadius, 0);
    
    // Line to start of notch smoothly
    path.lineTo(centerX - notchRadius - 10, 0);
    
    // Smooth transition into the notch
    path.quadraticBezierTo(
      centerX - notchRadius, 
      0, 
      centerX - notchRadius, 
      12,
    );
    
    // The Circular Notch (The "U")
    path.arcToPoint(
      Offset(centerX + notchRadius, 12),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );
    
    // Smooth transition out of the notch
    path.quadraticBezierTo(
      centerX + notchRadius, 
      0, 
      centerX + notchRadius + 10, 
      0,
    );
    
    // Top right corner
    path.lineTo(size.width - cornerRadius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);
    
    // Bottom right
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // Subtle Shadow for the bar
    canvas.drawShadow(
      path, 
      Colors.black.withOpacity(0.1), 
      8, 
      false
    );
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
