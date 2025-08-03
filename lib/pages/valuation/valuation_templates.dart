import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valuatorx/pages/common/button/create_button.dart';
import 'package:valuatorx/pages/common/expandable_list.dart';
import 'package:valuatorx/pages/common/modal/delete_dialog.dart';
import 'package:valuatorx/pages/common/tiles/summary_tile.dart';
import 'package:valuatorx/pages/valuation/valuation_form.dart';
import 'package:valuatorx/providers/valuation_provider.dart';
import 'package:valuatorx/utils/common.dart';

class ValuationTemplates extends StatelessWidget {
  final VoidCallback onBack;
  const ValuationTemplates({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = Provider.of<ValuationProvider>(context);

    onEditValuation(String id) {
      provider.setSelectedItem(id);
      Navigator.push(context, MaterialPageRoute(builder: (context) => ValuationForm(mode: Mode.templateEdit))).then((_) {
        provider.setSelectedItem('');
      });
    }

    onDeleteAction(valuation) async {
      await showDialog<bool>(
        context: context,
        builder:
            (ctx) => DeleteDialog(
              onDelete: () async {
                await provider.deleteValuation(context, valuation);
              },
            ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => onBack(),
      child: Scaffold(
        backgroundColor: colorScheme.surfaceContainer,
        floatingActionButton: CreateButton(onOpen: (_) => ValuationForm(mode: Mode.templateCreate), label: "Create template"),
        appBar: AppBar(
          backgroundColor: colorScheme.surfaceContainer,
          title: Text('Templates', style: headerTheme),
          leading: IconButton(icon: Icon(Icons.arrow_back_outlined), onPressed: onBack),
        ),
        body: Container(
          margin: EdgeInsets.only(top: 11),
          height: double.infinity,
          width: double.infinity,
          child: ExpandableList(
            items: provider.getSearchResults(query: '', filter: 'template'),
            isLoading: provider.isLoading,
            initialCount: 30,
            incrementCount: 30,
            itemBuilder: (ctx, valuation, index) {
              return SummaryTile(
                id: valuation.id,
                title: valuation.templateTile,
                subtitle: 'Edit template',
                info: '',
                tag: '',
                onTapAction: onEditValuation,
                actions: [
                  IconButton(onPressed: () => onDeleteAction(valuation), icon: Icon(Icons.delete_outline, color: colorScheme.error)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
