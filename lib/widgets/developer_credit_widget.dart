import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DeveloperCreditWidget extends StatelessWidget {
  const DeveloperCreditWidget({super.key});

  static final Uri _projectUrl = Uri.parse('https://github.com/jalobler7');

  Future<void> _openProjectUrl() async {
    if (!await launchUrl(_projectUrl, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $_projectUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 6,
        children: [
          Text(
            'Desenvolvido por Jo\u00E3o Lobler',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.52),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
          InkWell(
            onTap: _openProjectUrl,
            borderRadius: BorderRadius.circular(999),
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                color: Colors.white.withValues(alpha: 0.03),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.code_rounded,
                    size: 14,
                    color: Colors.white.withValues(alpha: 0.68),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'GitHub',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.68),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
