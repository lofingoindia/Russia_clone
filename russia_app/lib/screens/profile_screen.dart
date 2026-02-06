import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
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
  bool _showDocumentDetail = false;
  String? _selectedDocTitle;
  String? _selectedDocKey;
  List<String> _selectedDocUrls = [];
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // Check if logged in first
    final isLoggedIn = await _apiService.isLoggedIn();
    if (!isLoggedIn) return;

    // Fetch fresh profile data to get document URLs
    final profileData = await _apiService.getUserProfile();
    
    if (mounted) {
      if (profileData['success'] == true) {
        setState(() {
          _userData = profileData['user'];
          _isLoading = false;
        });
      } else {
        // Fallback to locally stored data if network fails
        final localData = await _apiService.getUserData();
        setState(() {
          _userData = localData;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('logout_confirmation_title'.tr()),
        content: Text('logout_confirmation'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('logout'.tr()),
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
                ? 'lib/assets/backy.png' 
                : (_showDocuments ? 'lib/assets/backy.png' : 'lib/assets/backy.png'),
          ),
          
          // Content - toggle between profile, documents, personal info, and document detail
          _showDocumentDetail
              ? _buildDocumentDetailView()
              : _showPersonalInfo
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
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 22),
              
              // Header
              Center(
                child: Text(
                  'profile'.tr(),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
              
              const SizedBox(height: 15),
              
              // User Info Card
              _buildUserInfoCard(),
              
              const SizedBox(height: 20),
              
              // Foreign Citizen Card
              _buildForeignCitizenCard(),
              
              const SizedBox(height: 20),
              
              // Personal Information Button
              _buildNavigationButton(
                imagePath: 'lib/assets/t.png',
                title: 'personal_data'.tr(),
                onTap: () {
                  setState(() {
                    _showPersonalInfo = true;
                  });
                },
              ),
              
              const SizedBox(height: 20),
              
              // Documents Button
              _buildNavigationButton(
                imagePath: 'lib/assets/tt.png',
                title: 'documents'.tr(),
                onTap: () {
                  setState(() {
                    _showDocuments = true;
                  });
                },
              ),
              
              const SizedBox(height: 10),

              // // Logout Button
              // GestureDetector(
              //   onTap: _handleLogout,
              //   child: Container(
              //     width: double.infinity,
              //     padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              //     decoration: BoxDecoration(
              //       color: Colors.white,
              //       borderRadius: BorderRadius.circular(16),
              //       boxShadow: [
              //         BoxShadow(
              //           color: Colors.black.withOpacity(0.04),
              //           blurRadius: 10,
              //           offset: const Offset(0, 4),
              //         ),
              //       ],
              //     ),
              //     child: Row(
              //       children: [
              //         Container(
              //           padding: const EdgeInsets.all(8),
              //           decoration: BoxDecoration(
              //             color: Colors.red.withOpacity(0.1),
              //             borderRadius: BorderRadius.circular(8),
              //           ),
              //           child: const Icon(
              //             Icons.logout,
              //             color: Colors.red,
              //             size: 20,
              //           ),
              //         ),
              //         const SizedBox(width: 12),
              //         Text(
              //           'logout'.tr(),
              //           style: const TextStyle(
              //             fontSize: 14,
              //             fontWeight: FontWeight.w600,
              //             color: Colors.red,
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              
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
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Header with back button
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
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
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
                  const SizedBox(width: 16),
                  Text(
                    'documents'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3C4451),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Identity Document Card
              _buildDocumentCard(
                imagePath: 'lib/assets/d11.png',
                title: 'doc_identity'.tr(),
                onTap: () {
                  setState(() {
                    _selectedDocTitle = 'doc_identity'.tr();
                    _selectedDocKey = 'doc_identity';
                    _selectedDocUrls = _userData?['doc1Url'] != null 
                        ? [_userData!['doc1Url'] as String] 
                        : [];
                    _showDocumentDetail = true;
                  });
                },
              ),
              
              const SizedBox(height: 8),
              
              // Fingerprint and Photo Registration Card
              _buildDocumentCard(
                imagePath: 'lib/assets/d2.png',
                title: 'doc_fingerprint'.tr(),
                onTap: () {
                  setState(() {
                    _selectedDocTitle = 'doc_fingerprint'.tr();
                    _selectedDocKey = 'doc_fingerprint';
                    // Fetch all additional documents
                    final doc3Urls = _userData?['doc3Urls'];
                    if (doc3Urls != null && doc3Urls is List) {
                      _selectedDocUrls = List<String>.from(doc3Urls);
                    } else {
                      _selectedDocUrls = [];
                    }
                    _showDocumentDetail = true;
                  });
                },
              ),
              
              const SizedBox(height: 8),

              // Taxpayer Identification Number (INN) Card
              _buildDocumentCard(
                imagePath: 'lib/assets/d3.png',
                title: 'doc_inn'.tr(),
                onTap: () {
                  setState(() {
                    _selectedDocTitle = 'doc_inn'.tr();
                    _selectedDocKey = 'doc_inn';
                    // Fetch INN documents
                    final doc4Urls = _userData?['doc4Urls'];
                    if (doc4Urls != null && doc4Urls is List) {
                       _selectedDocUrls = List<String>.from(doc4Urls);
                    } else {
                      _selectedDocUrls = [];
                    }
                    _showDocumentDetail = true;
                  });
                },
              ),
              
              const SizedBox(height: 8),
              
              // Migration Card
              _buildDocumentCard(
                imagePath: 'lib/assets/mc.png',
                title: 'doc_migration'.tr(),
                onTap: () {
                  setState(() {
                    _selectedDocTitle = 'doc_migration'.tr();
                    _selectedDocKey = 'doc_migration';
                    _selectedDocUrls = _userData?['doc2Url'] != null 
                        ? [_userData!['doc2Url'] as String] 
                        : [];
                    _showDocumentDetail = true;
                  });
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
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showPersonalInfo = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.black,
                        size: 25,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'personal_data'.tr(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 170), // Balance the back button
                ],
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Personal Information Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
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
                                      'full_name'.tr(),
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _userData?['name']?.toString() ?? '-',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // const SizedBox(width: 15),
                            // Column(
                            //   crossAxisAlignment: CrossAxisAlignment.end,
                            //   children: [
                            //     Text(
                            //       'gender'.tr(),
                            //       style: TextStyle(
                            //         fontSize: 10,
                            //         color: Colors.grey[600],
                            //         fontWeight: FontWeight.w600,
                            //       ),
                            //     ),
                            //     const SizedBox(height: 2),
                            //     Text(
                            //       'static_gender_value'.tr(),
                            //       style: TextStyle(
                            //         fontSize: 12,
                            //         fontWeight: FontWeight.w600,
                            //         color: Color(0xFF3C4451),
                            //       ),
                            //     ),
                            //   ],
                            // ),
                          ],
                        ),
                        
                        const SizedBox(height: 10),
                        
                        // Date of Birth and Gender Row (tighter spacing)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'dob'.tr(),
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'static_dob_value'.tr(),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 45),
                            Flexible(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'gender'.tr(),
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'static_gender_value'.tr(),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 10),
                        
                        // Place of Birth
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              Text(
                                'pob'.tr(),
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'static_pob_value'.tr(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 14),
                  
                  // Contact Details Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
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
                          'contact_data'.tr(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Phone Number
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'phone_number'.tr(),
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _userData?['phone']?.toString() ?? '-',
                              style: const TextStyle(
                                fontSize: 16, 
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // Additional Number
                        // Column(
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: [
                        //     Text(
                        //       'additional_number'.tr(),
                        //       style: TextStyle(
                        //         fontSize: 10,
                        //         color: Colors.grey[600],
                        //         fontWeight: FontWeight.w600,
                        //       ),
                        //     ),
                        //     const SizedBox(height: 2),
                        //     // Text(
                        //     //   _userData?['additional_phone']?.toString() ?? _userData?['alt_phone']?.toString() ?? '-',
                        //     //   style: const TextStyle(
                        //     //     fontSize: 12,
                        //     //     fontWeight: FontWeight.w600,
                        //     //     color: Color(0xFF3C4451),
                        //     //   ),
                        //     // ),
                        //   ],
                        // ),
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

  Widget _buildDocumentDetailView() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showDocumentDetail = false;
                      _selectedDocTitle = null;
                      _selectedDocKey = null;
                      _selectedDocUrls = [];
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
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
                // Flexible title to handle long text
                Expanded(
                  child: Text(
                    _selectedDocTitle ?? 'documents'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3C4451),
                      height: 1.2,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Document Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 20.0),
                  child: Container( // Outer White Card
                    width: double.infinity,
                    padding: const EdgeInsets.all(20), // Padding between outer card and inner border
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container( // Inner Grey Border Container
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 450),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
                          child: _selectedDocUrls.isNotEmpty
                              ? Column(
                                  children: _selectedDocUrls.map((url) => Padding(
                                    padding: const EdgeInsets.only(bottom: 20.0),
                                    child: Image.network(
                                      url,
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.topCenter,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded / 
                                                    loadingProgress.expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) =>
                                          Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                            SizedBox(height: 10),
                                            Text('error_loading_doc'.tr(), style: TextStyle(color: Colors.grey)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )).toList(),
                                )
                              : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.insert_drive_file, size: 50, color: Colors.grey),
                                      const SizedBox(height: 10),
                                      Text('doc_not_loaded'.tr(), style: TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: _selectedDocKey == 'doc_migration'
                              ? Column(
                                  children: [
                                    Text(
                                      'doc_not_actual'.tr(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14, // Slightly larger base text
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'contact_mc_link'.tr(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.blue, // Blue link color
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.blue,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  'doc_display_issue'.tr(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                    height: 1.4,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
              ),
            ),
          ),
          
          const SizedBox(height: 40), // Spacing for bottom nav
        ],
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
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
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  imagePath,
                  width: 45,
                  height: 45,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Title
            Expanded(
              child: Text(
                title,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3C4451),
                  height: 1.2,
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
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
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
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _userData?['name']?.toString().toUpperCase() ?? 'НЕ УКАЗАНО',
                  style: const TextStyle(
                    fontSize: 17.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Гражданство',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _userData?['citizenship'] ?? 'Киргизия',
                  style: const TextStyle(
                    fontSize: 17.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                // const SizedBox(height: 6),
                // Text(
                //   'Email',
                //   style: TextStyle(
                //     fontSize: 10,
                //     color: Colors.grey[600],
                //     fontWeight: FontWeight.w400,
                //   ),
                // ),
                // const SizedBox(height: 2),
                // Text(
                //   _userData?['email'] ?? 'Не указано',
                //   style: const TextStyle(
                //     fontSize: 12,
                //     fontWeight: FontWeight.w600,
                //     color: Color(0xFF3C4451),
                //   ),
                // ),
                if (_userData?['phone'] != null) ...[
                  // const SizedBox(height: 6),
                  // Text(
                  //   'Телефон',
                  //   style: TextStyle(
                  //     fontSize: 10,
                  //     color: Colors.grey[600],
                  //     fontWeight: FontWeight.w400,
                  //   ),
                  // ),
                  // const SizedBox(height: 2),
                  // Text(
                  //   _userData?['phone'] ?? '',
                  //   style: const TextStyle(
                  //     fontSize: 12,
                  //     fontWeight: FontWeight.w600,
                  //     color: Color(0xFF3C4451),
                  //   ),
                  // ),
                ],
              ],
            ),
    );
  }

  Widget _buildForeignCitizenCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
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
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          
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
                        fontSize: 15.5,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'AA11365228',
                      style: TextStyle(
                        fontSize: 17.5,
                        fontWeight: FontWeight.bold ,
                        color: Colors.black,
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
                        fontSize: 15.5,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '2030-12-29',
                      style: TextStyle(
                        fontSize: 17.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Card Image and QR Code
          // Combined Card and QR Image
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 22, 6, 2),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'lib/assets/dqc.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
            ), 
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
              width: 30,
              height: 30,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Color.fromARGB(255, 91, 91, 91), size: 18),
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
        imagePath ?? 'lib/assets/bgg.png',
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

