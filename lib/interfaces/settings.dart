// screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skedule/providers.dart';
import 'package:skedule/theme/colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final fontProvider = Provider.of<FontProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme Toggle
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: AppColors.card,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Dark Mode',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: fontProvider.fontSize,
                      fontFamily: fontProvider.fontFamily,
                    ),
                  ),
                  Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme(value);
                    },
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Font Size
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: AppColors.card,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Font Size',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: fontProvider.fontSize,
                      fontFamily: fontProvider.fontFamily,
                    ),
                  ),
                  Slider(
                    value: fontProvider.fontSize,
                    min: 14,
                    max: 24,
                    divisions: 5,
                    onChanged: (value) {
                      fontProvider.setFontSize(value);
                    },
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Font Family
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: AppColors.card,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Font Family',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: fontProvider.fontSize,
                      fontFamily: fontProvider.fontFamily,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: fontProvider.fontFamily,
                    items: const [
                      DropdownMenuItem(
                        value: 'Roboto',
                        child: Text('Roboto'),
                      ),
                      DropdownMenuItem(
                        value: 'OpenSans',
                        child: Text('Open Sans'),
                      ),
                      DropdownMenuItem(
                        value: 'Montserrat',
                        child: Text('Montserrat'),
                      ),
                      DropdownMenuItem(
                        value: 'Poppins',
                        child: Text('Poppins'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        fontProvider.setFontFamily(value);
                      }
                    },
                    dropdownColor: AppColors.card,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          // Logout Button
          Center(
            child: ElevatedButton(
              onPressed: () {
                // Implement logout logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontProvider.fontSize,
                  fontFamily: fontProvider.fontFamily,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}