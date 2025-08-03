import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:valuatorx/utils/common.dart';

class CreateButton extends StatefulWidget {
  final String label;
  final Widget Function(String option) onOpen;
  final List<CreateButtonOption> options;

  const CreateButton({super.key, required this.label, this.options = const [], required this.onOpen});

  @override
  State<CreateButton> createState() => _CreateButtonState();
}

class _CreateButtonState extends State<CreateButton> {
  bool open = false;
  String option = "";
  bool showLabel = true;
  Function openContainerCallback = () {};

  void toggleMenu() {
    setState(() => open = !open);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    optionWidget(String id, String label) {
      return InkWell(
        onTap: () async {
          option = id;
          setState(() => showLabel = false);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            openContainerCallback();
          });
        },
        borderRadius: BorderRadius.circular(21),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
          child: Text(
            label,
            textAlign: TextAlign.right,
            style: theme.textTheme.labelLarge!.copyWith(fontWeight: FontWeight.normal, overflow: TextOverflow.ellipsis, color: colorScheme.onPrimaryContainer),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile(context) ? 8 : 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: 8,
        children: [
          AnimatedSlide(
            offset: Offset(0.02, open ? 0 : 0.2),
            duration: Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            child: AnimatedOpacity(
              opacity: open ? 1 : 0,
              duration: Duration(milliseconds: 150),
              curve: Curves.easeOutExpo,
              child: Card(
                color: colorScheme.primaryContainer,
                shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(24)),
                elevation: 6,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 15),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 180),
                    child: Column(
                      spacing: 0,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ...widget.options.map(
                          (option) => Column(
                            spacing: 0,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              optionWidget(option.id, option.label),
                              Divider(endIndent: 13, indent: 13, color: colorScheme.onPrimaryContainer.withAlpha(32)),
                            ],
                          ),
                        ),
                        optionWidget("", "Blank form"),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          OpenContainer(
            transitionType: ContainerTransitionType.fade,
            openBuilder: (context, _) {
              return widget.onOpen(option);
            },
            onClosed: (data) {
              setState(() => open = false);
              Future.delayed(Duration(milliseconds: 350)).then((_) => setState(() => showLabel = true));
            },
            closedColor: colorScheme.primaryContainer,
            closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(!open ? 16 : 64)),
            closedElevation: 8,
            closedBuilder: (context, openContainer) {
              openContainerCallback = openContainer;
              return widget.options.isEmpty
                  ? FloatingActionButton.extended(
                    elevation: 0,
                    onPressed: widget.options.isEmpty ? openContainer : toggleMenu,
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(widget.label, style: TextStyle(fontWeight: FontWeight.normal)),
                  )
                  : TextButton(
                    onPressed: toggleMenu,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: kIsWeb ? 26 : 18, horizontal: 18),
                      backgroundColor: Colors.transparent,
                      shape: BeveledRectangleBorder(),
                      elevation: 0,
                      foregroundColor: colorScheme.onPrimaryContainer,
                    ),
                    child: AnimatedSize(
                      duration: Duration(milliseconds: 150),
                      curve: Curves.easeOutCubic,
                      child: Row(
                        spacing: 8,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedRotation(
                            turns: !open ? 0 : 0.125,
                            curve: Curves.easeOutCubic,
                            duration: Duration(milliseconds: 150),
                            child: Icon(Icons.add, size: 16),
                          ),
                          if (!open && showLabel)
                            Text(
                              widget.label,
                              overflow: TextOverflow.clip,
                              softWrap: true,
                              style: TextStyle(fontWeight: FontWeight.normal),
                            ),
                        ],
                      ),
                    ),
                  );
            },
          ),
        ],
      ),
    );
  }
}

class CreateButtonOption {
  final String id;
  final String label;
  CreateButtonOption({required this.id, required this.label});
}
