import 'package:flutter/material.dart';
import 'login_screen.dart';


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
          HomeBackground(
            imagePath: _currentView == HomeViewType.home 
                ? 'lib/assets/homebg.png' 
                : 'lib/assets/ground.png',
          ),
          
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: HomeHeader(
              onProfileTap: () {
                _showStoryOverlay();
              },
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
          ),
          const SizedBox(height: 25),
          
          // Status Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                _buildGeolocationCard(),
                const SizedBox(height: 12),
                _buildAuthenticationCard(),
                const SizedBox(height: 12),
                _buildRegistrationCard(),
                const SizedBox(height: 12),
                _buildPlaceOfStayCard(),
                const SizedBox(height: 12),
                _buildPhoneNumberCard(),
              ],
            ),
          ),
          
          // Extra padding for bottom nav
          const SizedBox(height: 120),
        ],
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
                'Настройки',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3C4451),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          
          // Change Language
          _buildSettingsItem(
            imagePath: 'lib/assets/cl.png',
            title: 'Сменить язык',
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
                  const Text('Русский', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // About the App
          _buildSettingsItem(
            imagePath: 'lib/assets/ab.png',
            title: 'О приложении',
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          ),
          
          const SizedBox(height: 8),
          
          // Technical Support
          _buildSettingsItem(
            imagePath: 'lib/assets/tech.png',
            title: 'Техническая поддержка',
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          ),
          
          const SizedBox(height: 8),
          
          // Log Out
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Выйти'),
                    content: const Text('Вы уверены, что хотите выйти из аккаунта?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Отмена',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                            (route) => false,
                          );
                        },
                        child: const Text(
                          'Выйти',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            child: _buildSettingsItem(
              imagePath: 'lib/assets/log.png',
              title: 'Выйти',
              titleColor: Colors.red,
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            ),
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
                'Уведомления',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3C4451),
                ),
              ),
            ],
          ),
          
          Expanded(
            child: Center(
              child: Text(
                'У вас нет уведомлений',
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
    required String imagePath,
    required String title,
    Widget? trailing,
    Color titleColor = const Color(0xFF3C4451),
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
            Image.asset(imagePath, width: 38, height: 38, fit: BoxFit.contain),
            const SizedBox(width: 16),
            Expanded(
            child: Text(
                title,
                style: TextStyle(
                fontSize: 14,
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
      imagePath: 'lib/assets/location.png',
      title: 'Геолокация',
      description: 'Геолокация передана',
      showBadge: true,
      badgeText: 'Передана: 31.01.2026 15:19',
      isCompleted: true,
    );
  }

  Widget _buildAuthenticationCard() {
    return const StatusCard(
      imagePath: 'lib/assets/authen.png',
      title: 'Аутентификация',
      description: 'Проверка пройдена. Открыт доступ к личным данным и документам',
      isCompleted: true,
    );
  }

  Widget _buildRegistrationCard() {
    return const StatusCard(
      imagePath: 'lib/assets/diar.png',
      title: 'Постановка на учет',
      description: 'Вы состоите на учете',
      isCompleted: true,
    );
  }

  Widget _buildPlaceOfStayCard() {
    return StatusCard(
      imagePath: 'lib/assets/locat.png',
      title: 'Место сна и отдыха',
      descriptionWidget: RichText(
        text: const TextSpan(
          style: TextStyle(color: Colors.black54, fontSize: 11, height: 1.3),
          children: [
            TextSpan(text: 'Населенный пункт:\n'),
            TextSpan(text: 'г. Москва,\n', style: TextStyle(color: Color(0xFF3C4451), fontWeight: FontWeight.normal)),
            TextSpan(text: 'проезд Электролитный, 3с7\n', style: TextStyle(color: Color(0xFF3C4451), fontWeight: FontWeight.normal)),
            TextSpan(text: 'Улица: ', style: TextStyle(color: Colors.black54)),
            TextSpan(text: 'проезд Электролитный\n', style: TextStyle(color: Color(0xFF3C4451), fontWeight: FontWeight.w600)),
            TextSpan(text: 'Дом: ', style: TextStyle(color: Colors.black54)),
            TextSpan(text: '3с7   ', style: TextStyle(color: Color(0xFF3C4451), fontWeight: FontWeight.w600)),
            TextSpan(text: 'Квартира: ', style: TextStyle(color: Colors.black54)),
            TextSpan(text: '321', style: TextStyle(color: Color(0xFF3C4451), fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      isCompleted: true,
    );
  }

  Widget _buildPhoneNumberCard() {
    return const StatusCard(
      imagePath: 'lib/assets/call.png',
      title: 'Номер телефона',
      description: '+790998933489',
      isCompleted: true,
    );
  }

  void _showStoryOverlay() {
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (context, animation, secondaryAnimation) {
          return const _StoryOverlay();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}

class _StoryItem {
  final String title;
  final String imagePath;

  _StoryItem({
    required this.title,
    required this.imagePath,
  });
}

class _StoryOverlay extends StatefulWidget {
  const _StoryOverlay();

  @override
  State<_StoryOverlay> createState() => _StoryOverlayState();
}

class _StoryOverlayState extends State<_StoryOverlay> {
  int _currentIndex = 0;
  final List<_StoryItem> _stories = [
    _StoryItem(
      title: 'Выключайте VPN-сервисы \nпри использовании приложения  ',
      imagePath: 'lib/assets/s11.png',
    ),
    _StoryItem(
      title: 'Проверьте настройки телефона,\nчтобы разрешить передачу геолокации',
      imagePath: 'lib/assets/ssss.png',
    ),
    _StoryItem(
      title: 'Заходите в \nприложение каждый день',
      imagePath: 'lib/assets/ss2.png',
    ),
    _StoryItem( 
      title: 'Зарегистрируйте свои документы',
      imagePath: 'lib/assets/sss2.png',
    ),
    _StoryItem(
      title: "Не отключайте \nPUSH-уведомления",
      imagePath: 'lib/assets/ssss2.png',
    ),
  ];

  void _nextStory() {
    if (_currentIndex < _stories.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      Navigator.pop(context);
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final story = _stories[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF2C3440),
      body: SizedBox.expand(
        child: Stack(
          children: [
            // Centered image - ensuring it shows fully without being cut
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Image.asset(
                  story.imagePath,
                  fit: BoxFit.contain,
                ),
              ),
            ),
  
            // Text overlay layer - centered on full screen
            Positioned.fill(
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 120),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        story.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Invisible Gesture Areas for Navigation
          // Close button area (top right)
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 80,
                  height: 80,
                  color: Colors.transparent,
                ),
              ),
            ),
          ),

          // Back button area (bottom left)
          if (_currentIndex > 0)
            Positioned(
              bottom: 42,
              left: 20,
              child: GestureDetector(
                onTap: _previousStory,
                child: Container(
                  width: 55,
                  height: 55,
                  color: Colors.transparent,
                ),
              ),
            ),

          // Next/Finish button area (bottom right)
          Positioned(
            bottom: 66,
            right: 10,
            child: GestureDetector(
              onTap: _nextStory,
              child: Container(
                width: _currentIndex == 0 ? MediaQuery.of(context).size.width - 40 : MediaQuery.of(context).size.width - 100,
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(
                    _currentIndex == _stories.length - 1 ? 'Завершить' : 'Далее',
                    style: const TextStyle(
                      color: Color(0xFF2C3440),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Tap anywhere on right half to go next
          Positioned(
            top: 80,
            bottom: 100,
            right: 0,
            width: MediaQuery.of(context).size.width / 2,
            child: GestureDetector(
              onTap: _nextStory,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          
          // Tap anywhere on left half to go back
          Positioned(
            top: 80,
            bottom: 100,
            left: 0,
            width: MediaQuery.of(context).size.width / 2,
            child: GestureDetector(
              onTap: _previousStory,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}

class HomeHeader extends StatelessWidget {
  final VoidCallback? onSettingsTap;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onProfileTap;
  const HomeHeader({super.key, this.onSettingsTap, this.onNotificationsTap, this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Profile Picture with Badge
        GestureDetector(
          onTap: onProfileTap,
          child: Stack(
            children: [
              Container(
                width: 65,
                height: 65,
                // decoration: BoxDecoration(
                //   shape: BoxShape.circle,
                //   border: Border.all(color: Colors.black12, width: 1),
                //   color: Colors.white,
                // ),
                child: Center(
                  child: Image.asset('lib/assets/st1.png', width: 65  , height: 65),
                ),
              ),
              Positioned(
                right: 10,
                top: 0,
                child: Container(
                  // padding: const EdgeInsets.all(4),
                  // decoration: const BoxDecoration(
                  //   color: Colors.white,
                  //   shape: BoxShape.circle,
                  //   boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  // ),
                  // child: const Text(
                  //   '5',
                  //   style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  // ),
                ),
              ),
            ],
          ),
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
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Color(0xFF3C4451),
                ),
              ),
              Text(
                'УРОЗАЛИ',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF3C4451),
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
            child: const Icon(Icons.notifications_none_outlined, size: 24),
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
            child: const Icon(Icons.settings_outlined, size: 24),
          ),
        ),
      ],
    );
  }
}

class StatusCard extends StatelessWidget {
  final IconData? icon;
  final String? imagePath;
  final String title;
  final String? description;
  final Widget? descriptionWidget;
  final bool showBadge;
  final String? badgeText;
  final bool isCompleted;

  const StatusCard({
    super.key,
    this.icon,
    this.imagePath,
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (imagePath != null)
                      Opacity(
                        opacity: 0.6,
                        child: Image.asset(imagePath!, width: 22, height: 22, fit: BoxFit.contain),
                      )
                    else if (icon != null)
                      Opacity(
                        opacity: 0.6,
                        child: Icon(icon, color: Color(0xFF3C4451), size: 22),
                      ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF3C4451),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // No gap between title row and description for maximum compactness
                const SizedBox(height: 2),
                descriptionWidget ??
                    (description != null
                        ? Text(
                            description!,
                            style: const TextStyle(
                              color: Color(0xFF3C4451),
                              fontSize: 11,
                              height: 1.2,
                            ),
                          )
                        : const SizedBox.shrink()),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (showBadge && badgeText != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF32BA7C).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badgeText!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF32BA7C),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.check, size: 12, color: Colors.white),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomeBackground extends StatelessWidget {
  final String imagePath;
  const HomeBackground({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Image.asset(
        imagePath,
        fit: BoxFit.cover,
      ),
    );
  }
}
