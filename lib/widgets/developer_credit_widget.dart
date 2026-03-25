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

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          children: [
            Text(
              'Desenvolvido por João Lobler: ',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            InkWell(
              onTap: _openProjectUrl,
              child: Text(
                'https://github.com/jalobler7',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}