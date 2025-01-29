import 'package:apidash/utils/extensions/context.dart';
import 'package:apidash_design_system/apidash_design_system.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:apidash/providers/providers.dart';
import 'package:apidash/widgets/widgets.dart';
import 'package:apidash/consts.dart';
import '../common_widgets/common_widgets.dart';
import './editor_pane/variables_pane.dart';

class EnvironmentEditor extends ConsumerWidget {
  const EnvironmentEditor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(selectedEnvironmentIdStateProvider);
    final name = ref
        .watch(selectedEnvironmentModelProvider.select((value) => value?.name));
    return Padding(
      padding: context.isMediumWindow
          ? kPb10
          : (kIsMacOS || kIsWindows)
              ? kPt28o8
              : kP8,
      child: Column(
        children: [
          kVSpacer5,
          !context.isMediumWindow
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    kHSpacer10,
                    Expanded(
                      child: Text(
                        name ?? "",
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    EditorTitleActions(
                      onRenamePressed: id == kGlobalEnvironmentId
                          ? null
                          : () {
                              showRenameDialog(
                                  context, "Rename Environment", name, (val) {
                                ref
                                    .read(environmentsStateNotifierProvider
                                        .notifier)
                                    .updateEnvironment(id!, name: val);
                              });
                            },
                      onDuplicatePressed: () => ref
                          .read(environmentsStateNotifierProvider.notifier)
                          .duplicateEnvironment(id!),
                      onDeletePressed: id == kGlobalEnvironmentId
                          ? null
                          : () {
                              ref
                                  .read(environmentsStateNotifierProvider
                                      .notifier)
                                  .removeEnvironment(id!);
                            },
                    ),
                    kHSpacer4,
                  ],
                )
              : const SizedBox.shrink(),
          kVSpacer5,
          Expanded(
            child: Container(
              margin: context.isMediumWindow ? null : kP4,
              child: Card(
                margin: EdgeInsets.zero,
                color: kColorTransparent,
                surfaceTintColor: kColorTransparent,
                shape: context.isMediumWindow
                    ? null
                    : RoundedRectangleBorder(
                        side: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                        ),
                        borderRadius: kBorderRadius12,
                      ),
                elevation: 0,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          context.strings.environmentVariable,
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const EditEnvironmentVariables(
                          type: EnvironmentVariableType.variable,
                        ),
                        Text(
                          context.strings.headers,
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const EditEnvironmentVariables(
                          type: EnvironmentVariableType.header,
                        ),
                        Text(
                          context.strings.queryParameters,
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const EditEnvironmentVariables(
                          type: EnvironmentVariableType.params,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
