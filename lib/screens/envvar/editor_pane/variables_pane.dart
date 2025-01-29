import 'dart:math';

import 'package:apidash/consts.dart';
import 'package:apidash/models/models.dart';
import 'package:apidash/providers/providers.dart';
import 'package:apidash/utils/utils.dart';
import 'package:apidash/widgets/widgets.dart';
import 'package:apidash_design_system/apidash_design_system.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class EditEnvironmentVariables extends ConsumerStatefulWidget {
  const EditEnvironmentVariables({super.key, required this.type});

  final EnvironmentVariableType type;

  @override
  ConsumerState<EditEnvironmentVariables> createState() =>
      EditEnvironmentVariablesState();
}

EnvironmentVariableModel _emptyEnvironment(EnvironmentVariableType type) =>
    EnvironmentVariableModel(
      key: "",
      value: "",
      type: type,
    );

class EditEnvironmentVariablesState
    extends ConsumerState<EditEnvironmentVariables> {
  late int seed;
  final random = Random.secure();
  late List<EnvironmentVariableModel> variableRows;
  bool isAddingRow = false;

  @override
  void initState() {
    super.initState();
    seed = random.nextInt(kRandMax);
  }

  void _onFieldChange(String selectedId) {
    final environment = ref.read(selectedEnvironmentModelProvider);
    final otherVariables = <EnvironmentVariableModel>[];
    for (final type in EnvironmentVariableType.values) {
      if (type != widget.type) {
        otherVariables.addAll(getEnvironmentByType(environment, type));
      }
    }
    ref.read(environmentsStateNotifierProvider.notifier).updateEnvironment(
      selectedId,
      values: [
        ...variableRows.sublist(0, variableRows.length - 1),
        ...otherVariables
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedId = ref.watch(selectedEnvironmentIdStateProvider);
    ref.watch(selectedEnvironmentModelProvider.select((environment) =>
        getEnvironmentByType(environment, widget.type).length));
    var rows = getEnvironmentByType(
        ref.read(selectedEnvironmentModelProvider), widget.type);
    variableRows = rows.isEmpty
        ? [
            _emptyEnvironment(widget.type),
          ]
        : rows + [_emptyEnvironment(widget.type)];
    isAddingRow = false;

    // List<DataColumn> columns = const [
    //   DataColumn(label: Text(kNameCheckbox)),
    //   DataColumn2(label: Text("Variable name")),
    //   DataColumn2(label: Text('=')),
    //   DataColumn2(label: Text("Variable value")),
    //   DataColumn2(label: Text('')),
    // ];

    List<TableRow> dataRows = List<TableRow>.generate(
      variableRows.length,
      (index) {
        bool isLast = index + 1 == variableRows.length;
        return TableRow(
          key: ValueKey("$selectedId-$index-variables-row-$seed"),
          children: [
            _DataCell(
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 24, minWidth: 24),
                child: ADCheckBox(
                  keyId: "$selectedId-$index-variables-c-$seed",
                  value: variableRows[index].enabled,
                  onChanged: isLast
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() {
                              variableRows[index] =
                                  variableRows[index].copyWith(enabled: value);
                            });
                          }
                          _onFieldChange(selectedId!);
                        },
                  colorScheme: Theme.of(context).colorScheme,
                ),
              ),
            ),
            _DataCell(
              CellField(
                keyId: "$selectedId-$index-variables-k-$seed",
                initialValue: variableRows[index].key,
                hintText: "Add Variable",
                onChanged: (value) {
                  if (isLast && !isAddingRow) {
                    isAddingRow = true;
                    variableRows[index] =
                        variableRows[index].copyWith(key: value, enabled: true);
                    variableRows.add(_emptyEnvironment(widget.type));
                  } else {
                    variableRows[index] =
                        variableRows[index].copyWith(key: value);
                  }
                  _onFieldChange(selectedId!);
                },
                colorScheme: Theme.of(context).colorScheme,
              ),
            ),
            _DataCell(
              Center(
                child: Text(
                  "=",
                  style: kCodeStyle,
                ),
              ),
            ),
            _DataCell(
              Row(
                children: [
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: CellField(
                        keyId: "$selectedId-$index-variables-v-$seed",
                        initialValue: variableRows[index].value,
                        hintText: kHintAddValue,
                        onChanged: (value) {
                          if (isLast && !isAddingRow) {
                            isAddingRow = true;
                            variableRows[index] = variableRows[index]
                                .copyWith(value: value, enabled: true);
                            variableRows.add(_emptyEnvironment(widget.type));
                          } else {
                            variableRows[index] =
                                variableRows[index].copyWith(value: value);
                          }
                          _onFieldChange(selectedId!);
                        },
                        colorScheme: Theme.of(context).colorScheme,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _DataCell(
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 24, minWidth: 24),
                child: InkWell(
                  onTap: isLast
                      ? null
                      : () {
                          seed = random.nextInt(kRandMax);
                          if (variableRows.length == 2) {
                            setState(() {
                              variableRows = [
                                kEnvironmentVariableEmptyModel,
                              ];
                            });
                          } else {
                            variableRows.removeAt(index);
                          }
                          _onFieldChange(selectedId!);
                        },
                  child: Theme.of(context).brightness == Brightness.dark
                      ? kIconRemoveDark
                      : kIconRemoveLight,
                ),
              ),
            ),
          ],
        );
      },
    );

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: kBorderRadius12,
      ),
      margin: kP10,
      child: Theme(
        data: Theme.of(context)
            .copyWith(scrollbarTheme: kDataTableScrollbarTheme),
        child: Table(
          columnWidths: const {
            0: FixedColumnWidth(24),
            1: FlexColumnWidth(),
            2: FixedColumnWidth(24),
            3: FlexColumnWidth(),
            4: FixedColumnWidth(24),
          },
          children: dataRows,
        ),
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  const _DataCell(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 36),
          child: child,
        ),
      ),
    );
  }
}
