import 'package:chatpilot_app/app/theme/app_colors.dart';
import 'package:chatpilot_app/app/theme/app_tokens.dart';
import 'package:chatpilot_app/features/chat/domain/ai_model.dart';
import 'package:flutter/material.dart';

class ModelSelector extends StatelessWidget {
  const ModelSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final AiModel value;
  final ValueChanged<AiModel> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<AiModel>(
        key: const ValueKey('model-selector'),
        value: value,
        borderRadius: BorderRadius.circular(AppRadius.md),
        onChanged: (next) {
          if (next == null) return;
          onChanged(next);
        },
        items: [
          for (final model in AiModel.values)
            DropdownMenuItem(
              value: model,
              child: Text(
                model.menuLabel,
                style: const TextStyle(
                  fontFamily: AppFonts.secondary,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
