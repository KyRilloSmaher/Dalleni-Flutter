import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/dalleni_theme.dart';

class OfficialEntityWebsiteButton extends StatelessWidget {
  const OfficialEntityWebsiteButton({super.key, this.websiteUrl});

  final String? websiteUrl;

  bool get _isValidUrl {
    if (websiteUrl == null || websiteUrl!.trim().isEmpty) return false;
    final uri = Uri.tryParse(websiteUrl!.trim());
    return uri != null && (uri.isScheme('http') || uri.isScheme('https'));
  }

  Future<void> _launchWebsite(BuildContext context) async {
    if (!_isValidUrl) return;

    final uri = Uri.parse(websiteUrl!.trim());
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذر فتح الرابط: $websiteUrl'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isValidUrl) return const SizedBox.shrink();

    final colors = context.dalleniColors;

    return ElevatedButton.icon(
      onPressed: () => _launchWebsite(context),
      icon: const Icon(Icons.language_rounded, size: 20),
      label: Text(
        context.l10n.translate('officialEntityWebsiteButton'),
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        minimumSize: const Size.fromHeight(52),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
