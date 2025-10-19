import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:valuatorx/models/tab.dart';
import 'package:valuatorx/pages/land_rate/land_rate_screen.dart';
import 'package:valuatorx/pages/more/more_screen.dart';
import 'package:valuatorx/pages/valuation/valuation_screen.dart';
import 'package:valuatorx/providers/auth_provider.dart';
import 'package:animations/animations.dart';
import 'package:valuatorx/utils/common.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  int previousIndex = 0;
  bool showLeading = false;
  bool showTrailing = false;
  double groupAlignment = -1.0;
  String searchQuery = "";
  late final AuthProvider authProvider;
  late final List<TabItem> tabs;

  final TextEditingController searchController = TextEditingController();

  void clearSearch() {
    searchController.clear();
  }

  void signOut() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/', (Route<dynamic> route) => false);
  }

  void onSelectTab(int index) {
    setState(() => previousIndex = selectedIndex);
    setState(() => selectedIndex = index);
    clearSearch();
  }

  @override
  void initState() {
    super.initState();
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    tabs = [
      TabItem(
        name: "Valuation",
        title: "Valuation Reports",
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        child: Valuations(),
      ),
      TabItem(
        name: "Land rate",
        title: "Land Rate Data",
        icon: Icon(Icons.map_outlined),
        selectedIcon: Icon(Icons.map),
        child: LandRateScreen(),
      ),
      TabItem(
        name: "More",
        title: "More tools",
        icon: Icon(Icons.more_horiz_outlined),
        selectedIcon: Icon(Icons.more_horiz_rounded),
        child: MoreScreen(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    Widget selectedPage() {
      return Container(
        height: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        color: colorScheme.surfaceContainer,
        child: PageTransitionSwitcher(
          reverse: previousIndex > selectedIndex,
          transitionBuilder: defaultTransition(colorScheme.surfaceContainer, orientation: SharedAxisTransitionType.vertical),
          child: tabs[selectedIndex].child,
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainer,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 0,
        backgroundColor: colorScheme.surfaceContainer,
        surfaceTintColor: colorScheme.surfaceContainer,
      ),
      body:
          isMobile(context)
              ? selectedPage()
              : Row(
                children: <Widget>[
                  NavigationRail(
                    groupAlignment: -1,
                    selectedIndex: selectedIndex,
                    labelType: NavigationRailLabelType.all,
                    backgroundColor: colorScheme.surfaceContainer,
                    onDestinationSelected: onSelectTab,
                    leading: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 16, 0, 32),
                      child: Opacity(opacity: 0.9, child: Image.asset('assets/logo_mono.png', fit: BoxFit.contain, height: 40)),
                    ),
                    trailing: Expanded(
                      child: Container(
                        alignment: Alignment.bottomCenter,
                        padding: EdgeInsets.only(bottom: 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [IconButton(icon: Icon(Icons.logout), onPressed: signOut), Text("Log out")],
                        ),
                      ),
                    ),
                    destinations:
                        tabs
                            .map(
                              (tab) => NavigationRailDestination(
                                padding: EdgeInsets.all(8),
                                icon: tab.icon,
                                selectedIcon: tab.selectedIcon,
                                label: Text(tab.name, style: textTheme.bodyMedium),
                              ),
                            )
                            .toList(),
                  ),
                  Expanded(child: selectedPage()),
                ],
              ),
      bottomNavigationBar:
          isMobile(context)
              ? Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                color: colorScheme.surfaceContainer,
                child: NavigationBar(
                  elevation: 0,
                  height: 68,
                  onDestinationSelected: onSelectTab,
                  selectedIndex: selectedIndex,
                  backgroundColor: colorScheme.surfaceContainer,
                  labelTextStyle: WidgetStateProperty.resolveWith(
                    (states) => textTheme.labelMedium!.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: states.contains(WidgetState.selected) ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                  destinations: [
                    ...tabs.map((tab) => NavigationDestination(icon: tab.icon, selectedIcon: tab.selectedIcon, label: tab.name)),
                  ],
                ),
              )
              : null,
    );
  }
}

class LogOutButtonMobile extends StatelessWidget {
  final VoidCallback onTap;
  const LogOutButtonMobile({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Material(
      shape: CircleBorder(),
      clipBehavior: Clip.hardEdge,
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            spacing: 0,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.logout, size: 18, color: theme.unselectedWidgetColor),
              Text("Log out", style: textTheme.bodyMedium!.copyWith(color: theme.unselectedWidgetColor)),
            ],
          ),
        ),
      ),
    );
  }
}
