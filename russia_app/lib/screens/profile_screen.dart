import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _showDocuments = false;
  bool _showPersonalInfo = false;
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await _apiService.getUserData();
    setState(() {
      _userData = userData;
      _isLoading = false;
    });
  }

  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выйти'),
        content: const Text('Вы уверены, что хотите выйти?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _apiService.logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background
          ProfileBackground(
            imagePath: _showPersonalInfo 
                ? 'lib/assets/bgg.png' 
                : (_showDocuments ? 'lib/assets/ground.png' : 'lib/assets/bg.png'),
          ),
          
          // Content - toggle between profile, documents, and personal info
          _showPersonalInfo
              ? _buildPersonalInfoView()
              : _showDocuments
                  ? _buildDocumentsView()
                  : _buildProfileView(),
        ],
      ),
    );
  }

  Widget _buildProfileView() {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Header
              const Center(
                child: Text(
                  'Профиль',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3C4451),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // User Info Card
              _buildUserInfoCard(),
              
              const SizedBox(height: 12),
              
              // Foreign Citizen Card
              _buildForeignCitizenCard(),
              
              const SizedBox(height: 12),
              
              // Personal Information Button
              _buildNavigationButton(
                imagePath: 'lib/assets/pi.png',
                title: 'Персональные данные',
                onTap: () {
                  setState(() {
                    _showPersonalInfo = true;
                  });
                },
              ),
              
              const SizedBox(height: 10),
              
              // Documents Button
              _buildNavigationButton(
                imagePath: 'lib/assets/docs.png',
                title: 'Документы',
                onTap: () {
                  setState(() {
                    _showDocuments = true;
                  });
                },
              ),
              
              const SizedBox(height: 10),
              
              // Logout Button
              GestureDetector(
                onTap: _handleLogout,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
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
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.logout,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Выйти из аккаунта',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Extra padding for bottom nav
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentsView() {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Header with back button and refresh icon
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showDocuments = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Color(0xFF3C4451),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Документы',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3C4451),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(8),
                    // decoration: BoxDecoration(
                    //   color: Colors.white,
                    //   shape: BoxShape.circle,
                    //   boxShadow: [
                    //     BoxShadow(
                    //       color: Colors.black.withOpacity(0.05),
                    //       blurRadius: 8,
                    //       offset: const Offset(0, 2),
                    //     ),
                    //   ],
                    // ),
                    child: const Icon(
                      Icons.refresh,
                      color: Color(0xFF3C4451),
                      size: 24,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Identity Document Card
              _buildDocumentCard(
                imagePath: 'lib/assets/ps.png',
                title: 'Документ, удостоверяющий личность',
                onTap: () {
                  // TODO: Navigate to Identity Document detail
                },
              ),
              
              const SizedBox(height: 16),
              
              // Migration Card
              _buildDocumentCard(
                imagePath: 'lib/assets/d.png',
                title: 'Миграционная карта',
                onTap: () {
                  // TODO: Navigate to Migration Card detail
                },
              ),
              
              // Extra padding for bottom nav
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoView() {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with back button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showPersonalInfo = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Color(0xFF3C4451),
                        size: 20,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Персональные данные',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3C4451),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 120), // Balance the back button
                ],
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  const SizedBox(height: 55),
                  // Personal Information Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
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
                        // Full Name and Gender Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Text(
                                      'ФИО',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      '',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF3C4451),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Пол',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Мужской',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF3C4451),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 6),
                        
                        // Date of Birth and Gender Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Text(
                                      'Дата рождения',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      '2000-12-06',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF3C4451),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 6),
                        
                        // Place of Birth
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              Text(
                                'Место рождения',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Узбекистан',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF3C4451),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Contact Details Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
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
                        Text(
                          'Контактные данные',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Phone Number
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Номер телефона',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              '+79099893489',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF3C4451),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Additional Number
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Дополнительный номер',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              '',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF3C4451),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Extra padding for bottom nav
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildDocumentCard({
    required String imagePath,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image with background
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  imagePath,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Title
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3C4451),
                ),
              ),
            ),
            // Arrow
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _isLoading
          ? const Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(child: CircularProgressIndicator()),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ФИО',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _userData?['name']?.toString().toUpperCase() ?? 'НЕ УКАЗАНО',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3C4451),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _userData?['email'] ?? 'Не указано',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3C4451),
                  ),
                ),
                if (_userData?['phone'] != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Телефон',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _userData?['phone'] ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3C4451),
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildForeignCitizenCard() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          const Text(
            'Карта иностранного гражданина',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3C4451),
            ),
          ),
          const SizedBox(height: 6),
          
          // KIG Number and Expiry Date
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Номер КИГ',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'AA1484021',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3C4451),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Срок действия КИГ:',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '2030-12-29',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3C4451),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 10),
          
          // Card Image and QR Code
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Card Image Placeholder
              Container(
                width: 190,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'lib/assets/card.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              // QR Code
              Container(
                width: 110,
                height: 130,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'lib/assets/qrr.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton({
    required String imagePath,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 44,
              height: 44,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 2),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3C4451),
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}

// Background widget similar to HomeScreen
class ProfileBackground extends StatelessWidget {
  final String? imagePath;
  const ProfileBackground({super.key, this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Image.asset(
        imagePath ?? 'lib/assets/bg.png',
        fit: BoxFit.fill,
      ),
    );
  }
}

// Reuse SkylinePainter from HomeScreen
class SkylinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Base layer - furthest back, most subtle
    final paint1 = Paint()
      ..color = const Color(0xFFF1FBF6)
      ..style = PaintingStyle.fill;

    final path1 = Path();
    path1.moveTo(0, size.height);
    path1.lineTo(0, size.height * 0.4);
    path1.lineTo(size.width * 0.1, size.height * 0.4);
    path1.lineTo(size.width * 0.1, size.height * 0.2);
    path1.lineTo(size.width * 0.2, size.height * 0.2);
    path1.lineTo(size.width * 0.2, size.height * 0.5);
    path1.lineTo(size.width * 0.3, size.height * 0.5);
    path1.lineTo(size.width * 0.3, size.height * 0.1);
    path1.lineTo(size.width * 0.45, size.height * 0.1);
    path1.lineTo(size.width * 0.45, size.height * 0.4);
    path1.lineTo(size.width * 0.6, size.height * 0.4);
    path1.lineTo(size.width * 0.6, size.height * 0.25);
    path1.lineTo(size.width * 0.75, size.height * 0.25);
    path1.lineTo(size.width * 0.75, size.height * 0.45);
    path1.lineTo(size.width, size.height * 0.45);
    path1.lineTo(size.width, size.height);
    path1.close();
    canvas.drawPath(path1, paint1);

    // Medium layer
    final paint2 = Paint()
      ..color = const Color(0xFFE8F7F0)
      ..style = PaintingStyle.fill;
      
    final path2 = Path();
    path2.moveTo(0, size.height);
    path2.lineTo(0, size.height * 0.6);
    path2.lineTo(size.width * 0.15, size.height * 0.6);
    path2.lineTo(size.width * 0.15, size.height * 0.45);
    path2.lineTo(size.width * 0.25, size.height * 0.45);
    path2.lineTo(size.width * 0.25, size.height * 0.7);
    path2.lineTo(size.width * 0.4, size.height * 0.7);
    path2.lineTo(size.width * 0.4, size.height * 0.35);
    path2.lineTo(size.width * 0.55, size.height * 0.35);
    path2.lineTo(size.width * 0.55, size.height * 0.6);
    path2.lineTo(size.width * 0.7, size.height * 0.6);
    path2.lineTo(size.width * 0.7, size.height * 0.5);
    path2.lineTo(size.width * 0.9, size.height * 0.5);
    path2.lineTo(size.width * 0.9, size.height * 0.75);
    path2.lineTo(size.width, size.height * 0.75);
    path2.lineTo(size.width, size.height);
    path2.close();
    canvas.drawPath(path2, paint2);

    // Front layer - closest, slightly more defined
    final paint3 = Paint()
      ..color = const Color(0xFFDFF5EB)
      ..style = PaintingStyle.fill;
      
    final path3 = Path();
    path3.moveTo(0, size.height);
    path3.lineTo(0, size.height * 0.8);
    path3.lineTo(size.width * 0.1, size.height * 0.8);
    path3.lineTo(size.width * 0.1, size.height * 0.65);
    path3.lineTo(size.width * 0.2, size.height * 0.65);
    path3.lineTo(size.width * 0.2, size.height * 0.85);
    path3.lineTo(size.width * 0.35, size.height * 0.85);
    path3.lineTo(size.width * 0.35, size.height * 0.6);
    path3.lineTo(size.width * 0.5, size.height * 0.6);
    path3.lineTo(size.width * 0.5, size.height * 0.8);
    path3.lineTo(size.width * 0.65, size.height * 0.8);
    path3.lineTo(size.width * 0.65, size.height * 0.7);
    path3.lineTo(size.width * 0.8, size.height * 0.7);
    path3.lineTo(size.width * 0.8, size.height * 0.9);
    path3.lineTo(size.width, size.height * 0.9);
    path3.lineTo(size.width, size.height);
    path3.close();
    canvas.drawPath(path3, paint3);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Card pattern painter for the foreign citizen card
class CardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Create a simple geometric pattern
    for (double i = 0; i < size.width; i += 8) {
      for (double j = 0; j < size.height; j += 8) {
        canvas.drawRect(
          Rect.fromLTWH(i, j, 4, 4),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Mini QR code painter for the card
class MiniQRPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final cellSize = size.width / 8;
    
    // Simple QR-like pattern
    final pattern = [
      [1, 1, 1, 0, 1, 1, 1, 1],
      [1, 0, 1, 0, 0, 1, 0, 1],
      [1, 1, 1, 1, 0, 1, 1, 1],
      [0, 0, 0, 1, 1, 0, 0, 0],
      [1, 0, 1, 0, 1, 0, 1, 0],
      [1, 1, 1, 0, 0, 1, 1, 1],
      [1, 0, 1, 1, 0, 1, 0, 1],
      [1, 1, 1, 0, 1, 1, 1, 1],
    ];

    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (pattern[i][j] == 1) {
          canvas.drawRect(
            Rect.fromLTWH(j * cellSize, i * cellSize, cellSize, cellSize),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// QR Code painter for the large QR code
class QRCodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final cellSize = size.width / 16;
    
    // More complex QR-like pattern
    final pattern = [
      [1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1],
      [1, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0, 0, 1],
      [1, 0, 1, 1, 1, 0, 1, 0, 0, 1, 0, 1, 1, 1, 0, 1],
      [1, 0, 1, 1, 1, 0, 1, 1, 0, 1, 0, 1, 1, 1, 0, 1],
      [1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 0, 1, 1, 1, 0, 1],
      [1, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 0, 0, 0, 0, 1],
      [1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1],
      [0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0],
      [0, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 0, 1, 0],
      [1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 1],
      [0, 1, 1, 1, 0, 0, 1, 1, 0, 1, 1, 0, 1, 1, 1, 0],
      [1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1],
      [0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0, 1, 1, 0, 0],
      [1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 0, 1, 0, 1, 1, 1],
      [1, 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 1, 0, 0, 1],
      [1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 0],
    ];

    for (int i = 0; i < 16; i++) {
      for (int j = 0; j < 16; j++) {
        if (pattern[i][j] == 1) {
          canvas.drawRect(
            Rect.fromLTWH(j * cellSize, i * cellSize, cellSize, cellSize),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
