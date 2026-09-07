import 'package:flutter/material.dart';

import '../../../../core/theme/retro_style.dart';

class SettingsActionTile extends StatelessWidget {
  const SettingsActionTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: const TextStyle(fontFamily: RetroStyle.fontFamily, fontSize: 19),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: const TextStyle(
                fontFamily: RetroStyle.fontFamily,
                fontSize: 16,
              ),
            ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
