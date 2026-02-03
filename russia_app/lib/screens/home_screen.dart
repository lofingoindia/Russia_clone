import 'package:flutter/material.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'login_screen.dart';


enum HomeViewType { home, settings, notifications }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeViewType _currentView = HomeViewType.home;
  bool _isLanguageExpanded = false;
  bool _refreshingSuccess = false;

  final List<Map<String, dynamic>> _languages = [
    {'name': 'Русский', 'sub': 'Russian', 'flag': '🇷🇺', 'locale': const Locale('ru')},
    {'name': "O'zbek", 'sub': 'Uzbek', 'flag': '🇺🇿', 'locale': const Locale('uz')},
    {'name': 'Кыргызча', 'sub': 'Kyrgyz', 'flag': '🇰🇬', 'locale': const Locale('ky')},
    {'name': 'English', 'sub': 'English', 'flag': '🇬🇧', 'locale': const Locale('en')},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background components
          HomeBackground(
            imagePath: _currentView == HomeViewType.home 
                ? 'lib/assets/neww.png' 
                : 'lib/assets/backy.png',
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
    return Column(
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
        
        Expanded(
          child: CustomRefreshIndicator(
            onRefresh: _onRefresh,
            builder: (context, child, controller) {
              return Stack(
                children: [
                  // Content with displacement
                   AnimatedBuilder(
                      animation: controller,
                      builder: (context, _) {
                        return Transform.translate(
                          offset: Offset(0, 100.0 * controller.value),
                          child: child,
                        );
                      }
                   ),
                   
                   // Indicator - Positioned at the top of this Expanded area (below header)
                   Positioned(
                     top: 10,
                     left: 0,
                     right: 0,
                     child: AnimatedBuilder(
                       animation: controller,
                       builder: (context, _) {
                         final double value = controller.value;
                         final bool isLoading = controller.isLoading;

                          Widget content;
                          if (isLoading) {
                             if (_refreshingSuccess) {
                               content = Row(
                                 mainAxisAlignment: MainAxisAlignment.center,
                                 children: [
                                   const Icon(Icons.check, color: Color(0xFF909499), size: 24),
                                   const SizedBox(width: 10),
                                   const Text("Обновление завершено", style: TextStyle(color: Color(0xFF909499), fontSize: 13, fontWeight: FontWeight.w500)),
                                 ],
                               );
                             } else {
                               content = Row(
                                 mainAxisAlignment: MainAxisAlignment.center,
                                 children: [
                                   const SizedBox(
                                     width: 20, 
                                     height: 20, 
                                     child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFEB5757))
                                   ),
                                   const SizedBox(width: 10),
                                   const Text("Обновление...", style: TextStyle(color: Color(0xFF909499), fontSize: 13, fontWeight: FontWeight.w500)), 
                                 ],
                               );
                             }
                          } else if (value >= 1.0) { 
                             content = Row(
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 const Icon(Icons.refresh, color: Color(0xFF909499), size: 20),
                                 const SizedBox(width: 10),
                                 const Text("Отпустите, чтобы обновить", style: TextStyle(color: Color(0xFF909499), fontSize: 13, fontWeight: FontWeight.w500)),
                               ],
                             );
                          } else {
                             content = Row(
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 const Icon(Icons.arrow_downward, color: Color(0xFF909499), size: 20),
                                 const SizedBox(width: 10),
                                 const Text("Потяните, чтобы обновить", style: TextStyle(color: Color(0xFF909499), fontSize: 13, fontWeight: FontWeight.w500)),
                               ],
                             );
                          }
                          
                          return SizedBox(
                            height: 60,
                            child: Center(
                              child: Opacity(
                                opacity: value.clamp(0.0, 1.0),
                                child: content,
                              ),
                            ),
                          );
                       }, 
                     ),
                   ),
                ],
              );
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Column(
                  children: [
                    const SizedBox(height: 40), // Gap between Header and first card
                    _buildGeolocationCard(),
                    const SizedBox(height: 12),
                    _buildAuthenticationCard(),
                    const SizedBox(height: 12),
                    _buildRegistrationCard(),
                    const SizedBox(height: 12),
                    _buildPlaceOfStayCard(),
                    const SizedBox(height: 12),
                    _buildPhoneNumberCard(),
                    
                    // Extra padding for bottom nav
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _onRefresh() async {
    // Start Loading
    setState(() {
      _refreshingSuccess = false;
    });
    
    // Simulate network request
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
       // Show Success State
       setState(() {
         _refreshingSuccess = true;
       });
       
       // Keep success message visible for a moment
       await Future.delayed(const Duration(seconds: 1));
       
       // Note: Indicator will hide after this future completes
    }
  }

  Widget _buildSettingsView() {
    final currentLangData = _languages.firstWhere(
      (l) => l['locale'] == context.locale,
      orElse: () => _languages[0],
    );

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
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
                      _isLanguageExpanded = false; // Reset expansion when leaving settings
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF3C4451)),
                  ),
                ),
                const SizedBox(width: 20),
                Text(
                  'settings'.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3C4451),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            
            // Change Language
            GestureDetector(
              onTap: () {
                setState(() {
                  _isLanguageExpanded = !_isLanguageExpanded;
                });
              },
              child: _buildSettingsItem(
                imagePath: 'lib/assets/cl.png',
                title: 'change_language'.tr(),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Text(currentLangData['flag']!, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(
                        currentLangData['name']!, 
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF3C4451))
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _isLanguageExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, 
                        size: 18, 
                        color: Colors.grey
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Expanded Language List
            if (_isLanguageExpanded)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(vertical: 8),
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
                child: Column(
                  children: _languages.map((lang) {
                    final isSelected = lang['locale'] == context.locale;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          context.setLocale(lang['locale']);
                          _isLanguageExpanded = false; // Close after selection
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        color: Colors.transparent,
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              alignment: Alignment.center,
                              child: Text(lang['flag']!, style: const TextStyle(fontSize: 24)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lang['name']!,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF3C4451),
                                    ),
                                  ),
                                  Text(
                                    lang['sub']!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFEB5757),
                                    width: 5,
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.grey[400]!,
                                    width: 1,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            
            const SizedBox(height: 8),
            
            // About the App
            _buildSettingsItem(
              imagePath: 'lib/assets/ab.png',
              title: 'about_app'.tr(),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            ),
            
            const SizedBox(height: 8),
            
            // Technical Support
            _buildSettingsItem(
              imagePath: 'lib/assets/tech.png',
              title: 'tech_support'.tr(),
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
                      title: Text('logout_confirmation_title'.tr()),
                      content: Text('logout_confirmation'.tr()),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'cancel'.tr(),
                            style: const TextStyle(color: Color(0xFF3C4451)),
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
                          child: Text(
                            'logout'.tr(),
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              child: _buildSettingsItem(
                imagePath: 'lib/assets/log.png',
                title: 'logout'.tr(),
                titleColor: Colors.red,
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              ),
            ),
            
            // Extra padding at bottom
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showLanguageBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.55,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                             Image.asset('lib/assets/cl.png', width: 24, height: 24),
                             const SizedBox(width: 12),
                             Text(
                              'change_language_title'.tr(), 
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3C4451),
                              ),
                            ),
                          ],
                        ),
                        
                        // Selected Language Chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                            child: Row(
                            children: [
                              Text(
                                _languages.firstWhere((l) => l['locale'] == context.locale)['flag']!, 
                                style: const TextStyle(fontSize: 16)
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _languages.firstWhere((l) => l['locale'] == context.locale)['sub']!, 
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF3C4451))
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 20),
                  
                  // List
                  Expanded(
                    child: ListView.builder(
                      itemCount: _languages.length,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemBuilder: (context, index) {
                        final lang = _languages[index];
                        final isSelected = lang['locale'] == context.locale;
                        return GestureDetector(
                            onTap: () {
                                setState(() {
                                    context.setLocale(lang['locale']);
                                });
                                setModalState(() {}); // Update modal UI if needed
                                Future.delayed(const Duration(milliseconds: 150), () {
                                  Navigator.pop(context);
                                });
                            },
                            child: Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                color: Colors.transparent, 
                                child: Row(
                                    children: [
                                        Container(
                                            width: 32,
                                            height: 32,
                                            alignment: Alignment.center,
                                            child: Text(lang['flag']!, style: const TextStyle(fontSize: 24)),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                            child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                    Text(
                                                        lang['name']!,
                                                        style: const TextStyle(
                                                            fontSize: 15,
                                                            fontWeight: FontWeight.w500,
                                                            color: Color(0xFF3C4451),
                                                        ),
                                                    ),
                                                    Text(
                                                        lang['sub']!,
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.grey[500],
                                                        ),
                                                    ),
                                                ],
                                            ),
                                        ),
                                        Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: isSelected ? const Color(0xFFEB5757) : Colors.grey[400]!, // Red accent from image
                                                    width: isSelected ? 5 : 1,
                                                ),
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
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
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF3C4451)),
                ),
              ),
              const SizedBox(width: 20),
              const SizedBox(width: 20),
               Text(
                'notifications'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3C4451),
                ),
              ),
            ],
          ),
          
          Expanded(
            child: Center(
              child: Text(
                'no_notifications'.tr(),
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
    return StatusCard(
      imagePath: 'lib/assets/location.png',
      title: 'geolocation'.tr(),
      description: 'geolocation_desc'.tr(),
      showBadge: true,
      badgeText: 'geolocation_sent_at'.tr(args: ['31.01.2026 15:19']),
      isCompleted: true,
      padding: const EdgeInsets.fromLTRB(14, 12, 16, 16),
    );
  }

  Widget _buildAuthenticationCard() {
    return StatusCard(
      imagePath: 'lib/assets/authen.png',
      title: 'authentication'.tr(),
      description: 'authentication_desc'.tr(),
      isCompleted: true,
    );
  }

  Widget _buildRegistrationCard() {
    return StatusCard(
      imagePath: 'lib/assets/diar.png',
      title: 'registration'.tr(),
      description: 'registration_desc'.tr(),
      isCompleted: true,
    );
  }

  Widget _buildPlaceOfStayCard() {
    return StatusCard(
      imagePath: 'lib/assets/locat.png',
      title: 'place_of_stay'.tr(),
      actionsAlignTop: true,
      descriptionWidget: RichText(
        text: TextSpan(
          style: const TextStyle(color: Color(0xFF3C4451), fontSize: 11, height: 1.3),
          children: [
            TextSpan(text: 'city_label'.tr() + '\n', style: const TextStyle(color: Color(0xFF909499), fontWeight: FontWeight.w500)),
            const TextSpan(text: 'Москва, улица Генерала Тюленева, 23к1\n', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
            TextSpan(text: 'street_label'.tr() + ' ', style: const TextStyle(color: Color(0xFF909499), fontWeight: FontWeight.w500)),
            const TextSpan(text: 'улица Генерала Тюленева\n', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
            TextSpan(text: 'house_label'.tr() + ' ', style: const TextStyle(color: Color(0xFF909499), fontWeight: FontWeight.w500)),
            const TextSpan(text: '23к1   ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
            TextSpan(text: 'apartment_label'.tr() + ' ', style: const TextStyle(color: Color(0xFF909499), fontWeight: FontWeight.w500)),
            const TextSpan(text: '9', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
          ],
        ),     
      ),
      isCompleted: true,
      showEditAction: true,
    );
  }

  Widget _buildPhoneNumberCard() {
    return StatusCard(
      imagePath: 'lib/assets/call.png',
      title: 'phone_number'.tr(),
      description: '+7 926 666-02-23',
      isCompleted: true,
      showEditAction: true,
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
      title: 'story_1'.tr(),
      imagePath: 'lib/assets/story0.png',
    ),
    _StoryItem(
      title: 'story_2'.tr(),
      imagePath: 'lib/assets/00.png',
    ),
    _StoryItem(
      title: 'story_3'.tr(),
      imagePath: 'lib/assets/000.png',
    ),
      _StoryItem(
      title: "story_4".tr(),
      imagePath: 'lib/assets/0000.png',
    ),
    _StoryItem( 
      title: 'story_5'.tr(),
      imagePath: 'lib/assets/00000.png',
    ),
  ];

  void _nextStory() {
    if (_currentIndex < _stories.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      Navigator.of(context, rootNavigator: true).pop();
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
                          fontSize: 18,
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
            // Close Button (Top Right)
            Positioned(
              top: 35,
              right: 25,
              child: SafeArea(
                child: GestureDetector(
                  onTap: () => Navigator.of(context, rootNavigator: true).pop(),
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.black, size: 20),
                  ),
                ),
              ),
            ),
            // Dynamic Bottom Navigation Bar
            Positioned(
              bottom: 50,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  // Back Button (only if not first story)
                  if (_currentIndex > 0) ...[
                    GestureDetector(
                      onTap: _previousStory,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.chevron_left, color: Colors.black, size: 28),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  // Next / Close Button
                  Expanded(
                    child: GestureDetector(
                      onTap: _nextStory,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            _currentIndex == _stories.length - 1 ? 'Закрыть' : 'Далее',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          // Tap anywhere on right half to go next
          Positioned(
            top: 80,
            bottom: 120, // Avoid overlapping bottom buttons
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
            bottom: 120, // Avoid overlapping bottom buttons
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
                  child: Image.asset('lib/assets/imp.png', width: 55  , height: 55),
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
        const SizedBox(width: 2),
        // User Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    letterSpacing: 0.5,
                  ),
                  children: [
                    TextSpan(
                      text: 'FCC: ',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    TextSpan(
                      text: 'AA1365228',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Text(
                'КУТЛУГМУРОД',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                  
                  letterSpacing: 0.5,
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
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Image.asset('lib/assets/notiif.png', width: 20, height: 20),
          ),
        ),
        const SizedBox(width: 5),
        GestureDetector(
          onTap: onSettingsTap,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Image.asset('lib/assets/SET.png', width: 20, height: 20),
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
  final bool showEditAction;
  final bool actionsAlignTop;
  final EdgeInsetsGeometry? padding;

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
    this.showEditAction = false,
    this.actionsAlignTop = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
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
            padding: padding ?? const EdgeInsets.fromLTRB(14, 12, 16, 12),
            child: Row(
              crossAxisAlignment: actionsAlignTop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (imagePath != null)
                            Image.asset(imagePath!, width: 20, height: 20, fit: BoxFit.contain)
                          else if (icon != null)
                            Icon(icon, color: Colors.black, size: 20),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      descriptionWidget ??
                          (description != null
                              ? Text(
                                  description!,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 11,
                                    height: 1.2,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              : const SizedBox.shrink()),
                    ],
                  ),
                ),
                if (showEditAction) ...[
                  const SizedBox(width: 8),
                  Image.asset('lib/assets/editicon.png', width: 17, height: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Change'.tr(),
                    style: const TextStyle(
                      color: Color(0xFF5A5E62),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (isCompleted) ...[
                    const SizedBox(width: 8),
                    Image.asset('lib/assets/tickk.png', width: 24, height: 24),
                  ],
                ] else if (isCompleted && !showBadge) ...[
                  const SizedBox(width: 8),
                  Image.asset('lib/assets/tickk.png', width: 24, height: 24),
                ],
              ],
            ),
          ),
          if (showBadge && badgeText != null)
            Positioned(
              top: 8,
              right: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF02C739),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badgeText!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isCompleted) ...[
                    const SizedBox(height: 7),
                    Image.asset('lib/assets/tickk.png', width: 24, height: 24),
                  ],
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
