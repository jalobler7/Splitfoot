import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/player_model.dart';
import 'team_share_text_builder.dart';

Future<void> handleShareOrCopy(
  BuildContext context, {
  required List<PlayerModel> teamA,
  required List<PlayerModel> teamB,
  String? title,
}) async {
  final shareText = buildShareText(
    teamA: teamA,
    teamB: teamB,
    title: title,
  );

  if (kIsWeb) {
    await Clipboard.setData(ClipboardData(text: shareText));

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Times copiados para a \u00E1rea de transfer\u00EAncia',
        ),
      ),
    );
    return;
  }

  final box = context.findRenderObject() as RenderBox?;

  await SharePlus.instance.share(
    ShareParams(
      text: shareText,
      title: title,
      subject: title,
      sharePositionOrigin:
          box == null ? null : box.localToGlobal(Offset.zero) & box.size,
    ),
  );
}
