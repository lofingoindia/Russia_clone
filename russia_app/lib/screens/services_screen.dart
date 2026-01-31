import 'package:flutter/material.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  bool _showInformationalMaterials = false;
  String? _selectedMaterial;
  int? _selectedMaterialIndex;
  String? _selectedSubItem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background
          const ServicesBackground(),
          
          // Content - toggle between services, materials list, material detail, and sub-item detail
          _selectedSubItem != null
              ? _buildSubItemDetailView()
              : _selectedMaterial != null
                  ? _buildMaterialDetailView()
                  : _showInformationalMaterials
                      ? _buildInformationalMaterialsView()
                      : _buildServicesView(),
        ],
      ),
    );
  }

  Widget _buildServicesView() {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Header
              const Center(
                child: Text(
                  'Сервисы',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Get Consultation Card
              _buildServiceCard(
                imagePath: 'lib/assets/bb.png',
                title: 'Получить консультацию',
                onTap: () {
                  _showConsultationDialog(context);
                },
              ),
              
              const SizedBox(height: 16),
              
              // Informational Materials Card
              _buildServiceCard(
                imagePath: 'lib/assets/aa.png',
                title: 'Информационные материалы',
                onTap: () {
                  setState(() {
                    _showInformationalMaterials = true;
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

  Widget _buildServiceCard({
    required String imagePath,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            // Image with background
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  imagePath,
                  width: 42,
                  height: 42,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Title
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            // Arrow
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildInformationalMaterialsView() {
    final materials = [
      'Обязательные процедуры',
      'Патент',
      'Постоянное и временное проживание',
      'Трудоустройство',
      'Противодействие терроризму',
      'Нормативные документы',
    ];

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
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
                        _showInformationalMaterials = false;
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
                        color: Colors.black87,
                        size: 16,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Информационные материалы',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40), // Balance the back button
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Materials List
              ...List.generate(materials.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildMaterialCard(
                    number: index + 1,
                    title: materials[index],
                    onTap: () {
                      setState(() {
                        _selectedMaterial = materials[index];
                        _selectedMaterialIndex = index;
                      });
                    },
                  ),
                );
              }),
              
              // Extra padding for bottom nav
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialCard({
    required int number,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
            // Number
            Text(
              '$number.',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 12),
            // Title
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            // Arrow
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialDetailView() {
    // Define sub-items for Mandatory Procedures (index 0)
    final mandatoryProceduresSubItems = [
      'Постановка на миграционный учет по месту пребывания',
      'Сроки и порядок постановки на учет',
    ];

    final hasMandatoryProcedures = _selectedMaterialIndex == 0;

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
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
                        _selectedMaterial = null;
                        _selectedMaterialIndex = null;
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
                        color: Colors.black87,
                        size: 16,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        _selectedMaterial ?? '',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40), // Balance the back button
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Content - either sub-items or "No Data Available"
              if (hasMandatoryProcedures)
                // Show sub-items for Mandatory Procedures
                ...List.generate(mandatoryProceduresSubItems.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildMaterialCard(
                      number: index + 1,
                      title: mandatoryProceduresSubItems[index],
                      onTap: () {
                        setState(() {
                          _selectedSubItem = mandatoryProceduresSubItems[index];
                        });
                      },
                    ),
                  );
                })
              else
                // Show "No Data Available" for other materials
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 150),
                    child: Text(
                      'Нет данных',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[500],
                      ),
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

  Widget _buildSubItemDetailView() {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
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
                        _selectedSubItem = null;
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
                        color: Colors.black87,
                        size: 16,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        _selectedSubItem ?? '',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40), // Balance the back button
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Show "No Data Available"
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 150),
                  child: Text(
                    'Нет данных',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[500],
                    ),
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


  void _showConsultationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const Text(
                  'Получить консультацию',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Institution Name
                const Text(
                  'ГБУ «Миграционный центр»',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                
                // Address
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                    children: [
                      TextSpan(
                        text: 'Адрес: ',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      TextSpan(
                        text: 'Москва, Троицкий административный округ, район Вороново, 64-й километр, 1, стр.47',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                
                // Working Hours
                const Text(
                  'Ежедневно с 08:00 до 20:00',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                
                // Telephone
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black87,
                    ),
                    children: [
                      TextSpan(
                        text: 'Телефон  ',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      TextSpan(
                        text: '+7 (495) 777-77-77',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Call Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement call functionality
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF32BA7C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Позвонить',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Cancel Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A5568),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Отмена',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Background widget similar to HomeScreen and ProfileScreen
class ServicesBackground extends StatelessWidget {
  const ServicesBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Image.asset(
        'lib/assets/ground.png',
        fit: BoxFit.fill,
      ),
    );
  }
}
