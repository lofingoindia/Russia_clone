import 'package:flutter/material.dart';


enum HomeViewType { home, settings, notifications }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeViewType _currentView = HomeViewType.home;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background components
          const HomeBackground(),
          
          // Foreground content
          SafeArea(
            child: _buildCurrentView(),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_currentView) {
      case HomeViewType.settings:
        return _buildSettingsView();
      case HomeViewType.notifications:
        return _buildNotificationsView();
      case HomeViewType.home:
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            HomeHeader(
              onSettingsTap: () {
                setState(() {
                  _currentView = HomeViewType.settings;
                });
              },
              onNotificationsTap: () {
                setState(() {
                  _currentView = HomeViewType.notifications;
                });
              },
            ),
            const SizedBox(height: 50),
            
            // Status Cards
            _buildGeolocationCard(),
            const SizedBox(height: 10),
            _buildAuthenticationCard(),
            const SizedBox(height: 10),
            _buildRegistrationCard(),
            const SizedBox(height: 10),
            _buildPlaceOfStayCard(),
            const SizedBox(height: 10),
            _buildPhoneNumberCard(),
            
            // Extra padding for bottom nav
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 10),
          // Header
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _currentView = HomeViewType.home;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black87),
                ),
              ),
              const SizedBox(width: 20),
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          
          // Change Language
          _buildSettingsItem(
            icon: Icons.translate,
            title: 'Change Language',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Text('🇷🇺', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  const Text('Russian', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // About the App
          _buildSettingsItem(
            icon: Icons.error_outline,
            title: 'About the App',
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          ),
          
          const SizedBox(height: 16),
          
          // Technical Support
          _buildSettingsItem(
            icon: Icons.phone_outlined,
            title: 'Technical Support',
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          ),
          
          const SizedBox(height: 16),
          
          // Log Out
          _buildSettingsItem(
            icon: Icons.logout,
            title: 'Log Out',
            titleColor: Colors.red,
            iconColor: Colors.red,
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 10),
          // Header
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _currentView = HomeViewType.home;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black87),
                ),
              ),
              const SizedBox(width: 20),
              const Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          
          Expanded(
            child: Center(
              child: Text(
                'You have no notifications',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    Color titleColor = Colors.black87,
    Color iconColor = Colors.black87,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
            BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
            child: Text(
                title,
                style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: titleColor,
                ),
            ),
            ),
            if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildGeolocationCard() {
    return const StatusCard(
      icon: Icons.location_on_outlined,
      title: 'Geolocation',
      description: 'Geolocation transmitted',
      showBadge: true,
      badgeText: 'Transmitted: 30.01.2026 14:40',
      isCompleted: true,
    );
  }

  Widget _buildAuthenticationCard() {
    return const StatusCard(
      icon: Icons.person_outline,
      title: 'Authentication',
      description: 'Verification completed. Access to personal data and documents is granted',
      isCompleted: true,
    );
  }

  Widget _buildRegistrationCard() {
    return const StatusCard(
      icon: Icons.assignment_outlined,
      title: 'Registration Status',
      description: 'You are registered',
      isCompleted: true,
    );
  }

  Widget _buildPlaceOfStayCard() {
    return StatusCard(
      icon: Icons.map_outlined,
      title: 'Place of Stay',
      descriptionWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black54, fontSize: 15, height: 1.4),
              children: [
                TextSpan(text: 'City: '),
                TextSpan(text: 'Moscow,\n', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
                TextSpan(text: 'Elektrolitny Drive, 3, Building 7\n'),
                TextSpan(text: 'Street: '),
                TextSpan(text: 'Elektrolitny Drive\n', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
                TextSpan(text: 'Building: '),
                TextSpan(text: '3, Block 7\n', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
                TextSpan(text: 'Apartment: '),
                TextSpan(text: '321', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
      isCompleted: true,
    );
  }

  Widget _buildPhoneNumberCard() {
    return const StatusCard(
      icon: Icons.phone_outlined,
      title: 'Phone Number',
      description: '+790998933489',
      isCompleted: true,
    );
  }
}

class HomeHeader extends StatelessWidget {
  final VoidCallback? onSettingsTap;
  final VoidCallback? onNotificationsTap;
  const HomeHeader({super.key, this.onSettingsTap, this.onNotificationsTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Profile Picture with Badge
        Stack(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black12, width: 1),
                color: Colors.white,
              ),
              child: const Center(
                child: Icon(Icons.person, size: 35, color: Colors.grey),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                child: const Text(
                  '5',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        // User Info
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'КИГ: AA1484021',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'УРОЗАЛИ',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
        // Action Buttons
        GestureDetector(
          onTap: onNotificationsTap,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none_outlined, size: 28),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: onSettingsTap,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.settings_outlined, size: 28),
          ),
        ),
      ],
    );
  }
}

class StatusCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final Widget? descriptionWidget;
  final bool showBadge;
  final String? badgeText;
  final bool isCompleted;

  const StatusCard({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.descriptionWidget,
    this.showBadge = false,
    this.badgeText,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.black87),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (showBadge && badgeText != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF32BA7C).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badgeText!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Color(0xFF32BA7C),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 14, color: Colors.white),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (descriptionWidget != null)
            descriptionWidget!
          else if (description != null)
            Text(
              description!,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 15,
                height: 1.4,
              ),
            ),
        ],
      ),
    );
  }
}

class HomeBackground extends StatelessWidget {
  const HomeBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Image.asset(
        'lib/assets/back.png',
        fit: BoxFit.fill,
      ),
    );
  }
}
