import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../main_screen.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF9FFFB),
              Color(0xFFDFF8F4),
              Color(0xFFD3F1EF),
            ],
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  // Title
                  const Text(
                    'Пользователям',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF3C4451),
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 1,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                  // Image (replace with your asset)
                  Image.asset(
                    'lib/assets/us.png',
                    height:   255,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 70),
                  // Info list
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('lib/assets/1.png', 'info_daily'.tr()),
                        const SizedBox(height: 16),
                        _buildInfoRow('lib/assets/2.png', 'info_geo'.tr(), iconHeight: 24),
                        const SizedBox(height: 16),
                        _buildInfoRow('lib/assets/3.png', 'info_vpn'.tr()),
                        const SizedBox(height: 16),
                        _buildInfoRowWithRichText('lib/assets/4.png', 'info_push'.tr(), 'info_push_link'.tr()),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            // Button
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 300,
                  height: 51,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const MainScreen()),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Закрыть',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String imagePath, String text, {double iconSize = 30, double? iconHeight}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          imagePath,
          width: iconSize,
          height: iconHeight ?? 24,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRowWithRichText(String imagePath, String text, String link, {double iconSize = 22}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          imagePath,
          width: 28,
          height: 28,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
              children: [
                TextSpan(
                  text: text,
                ),
                TextSpan(
                  text: '\n' + link,
                  style: const TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

// ...existing code...
}