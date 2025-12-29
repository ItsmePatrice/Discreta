import 'package:discreta/app/src/1_Front_end/Assets/colors.dart';
import 'package:discreta/app/src/1_Front_end/Assets/enum/text_size.dart';
import 'package:discreta/app/src/1_Front_end/lib/Components/discreta_text.dart';
import 'package:discreta/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class GuidePage extends StatelessWidget {
  const GuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: DiscretaText(
          text: t.howToUseDiscreta,
          size: TextSize.medium,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Power setup
            _guideSection(
              context,
              icon: Icons.power_settings_new,
              title: t.powerSetup,
              steps: [t.step1, t.step8],
            ),

            /// Pairing & connection
            _guideSection(
              context,
              icon: Icons.bluetooth,
              title: t.pairingConnection,
              steps: [
                t.step2,
                t.step2Observations,
                t.step3,
                t.step3Observations,
              ],
            ),

            /// Safety & alerts
            _guideSection(
              context,
              icon: Icons.warning_amber_rounded,
              title: t.safetyAlerts,
              steps: [t.step4, t.step6, t.step6Observation, t.step7, t.step9],
            ),
          ],
        ),
      ),
    );
  }

  Widget _guideSection(
    BuildContext context, {
    required String title,
    required List<String> steps,
    IconData? icon,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Section header
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: AppColors.primaryColor, size: 22),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: DiscretaText(
                  text: title,
                  size: TextSize.medium,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// Steps
          ...steps.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DiscretaText(
                    text: '${entry.key + 1}.',
                    size: TextSize.small,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DiscretaText(
                      text: entry.value,
                      size: TextSize.small,
                      fontWeight: FontWeight.w400,
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
