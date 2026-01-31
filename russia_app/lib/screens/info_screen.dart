import 'package:flutter/material.dart';
import '../main_screen.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [

          
          // Text Content Overlay
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Пользователям',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3C4451),
                  ),
                ),
                const SizedBox(height: 10),
                Image.asset(
                  'lib/assets/us.png',
                  height: 220,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                
                // Info list
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildInfoRow('lib/assets/l.png', 'Заходите в приложение каждый день'),
                      const SizedBox(height: 6),
                      _buildInfoRow('lib/assets/pl.png', 'Не отключайте геолокацию'),
                      const SizedBox(height: 6),
                      _buildInfoRow('lib/assets/v.png', 'Выключайте VPN при использовании приложения'),
                      const SizedBox(height: 6),
                      _buildInfoRow('lib/assets/no.png', 'Не отключайте Push-уведомления.'),
                    ],  
                  ),
                ),
                
                // const Spacer(),
                const SizedBox(height: 160),
                // Footer
                const Text(
                  'При возникновении трудностей,\nобратитесь на горячую линию',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF3C4451),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('lib/assets/call.png', width: 24, height: 24, fit: BoxFit.contain),
                    SizedBox(width: 10),
                    Text(
                      '+7 (499) 530-56-88',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3C4451),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 90), // Space for the button in f.png
              ],
            ),
          ),
          
          // Transparent clickable area over the image button
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            height: 50,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const MainScreen()),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF3C4451),
                  borderRadius: BorderRadius.circular(30),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Закрыть',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String imagePath, String text, {double iconSize = 24}) {
    return Row(
      children: [
        Opacity(
          opacity: 0.8,
          child: Image.asset(
            imagePath,
            width: iconSize,
            height: iconSize,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF3C4451),
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRowWithIcon(IconData icon, String text, {double iconSize = 28}) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF3C4451),
          size: iconSize,
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF3C4451),
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
