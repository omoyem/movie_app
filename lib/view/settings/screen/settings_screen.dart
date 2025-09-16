import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godly_seed_app/constants/color_palette.dart';
import 'package:godly_seed_app/utils/helpers.dart';
import '../controller/settings_controller.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false, 
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          children: [
            _SettingsTile(
              icon: Icons.person,
              label: 'Profile',
              onTap: () {},
              showArrow: true,
            ),
            _SettingsTile(
              icon: Icons.lock,
              label: 'Change Password',
              onTap: () {},
              showArrow: true,
            ),
            _SettingsTile(
              icon: Icons.description,
              label: 'Terms of use and privacy',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.info_outline,
              label: 'About Us',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.star_border,
              label: 'Rate Us',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.logout,
              label: 'Logout',
              onTap: () => logout(),                        
            ),
          ],
        ),
      ),
        );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool showArrow;
  final Color? iconColor;
  final Color? textColor;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.showArrow = false,
    this.iconColor,
    this.textColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5CDB2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(icon, color: iconColor ?? const Color(0xFFA86A43)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor ?? Colors.black,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                if (showArrow)
                  const Icon(Icons.arrow_forward_ios, size: 18, color: Color(0xFFA86A43)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}