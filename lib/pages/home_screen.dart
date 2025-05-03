import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:valuatorx/modals/tab.dart';
import 'package:valuatorx/pages/common/create_button.dart';
import 'package:valuatorx/pages/common/header.dart';
import 'package:valuatorx/pages/land_rate/land_rate_screen.dart';
import 'package:valuatorx/pages/valuation/valuation_screen.dart';
import 'package:valuatorx/providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  bool showLeading = false;
  bool showTrailing = false;
  double groupAlignment = -1.0;
  String searchQuery = "";
  late final AuthProvider authProvider;
  late final List<TabItem> tabs;

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
        createText: "New report",
        onCreate: () => Navigator.pushNamed(context, "/valuation/add"),
        onSearch: (query) => print(query),
        child: Valuations(),
      ),
      TabItem(
        name: "Land rate",
        title: "Land Rate Data",
        icon: Icon(Icons.map_outlined),
        selectedIcon: Icon(Icons.map),
        createText: "Add data",
        onCreate: () => Navigator.pushNamed(context, "/land_rate/add"),
        onSearch: (query) => print(query),
        child: LandRateScreen(),
      ),
      TabItem(
        name: "More",
        title: "More tools",
        icon: Icon(Icons.more_horiz_outlined),
        selectedIcon: Icon(Icons.more_horiz_rounded),
        child: Text("Coming soon"),
      ),
    ];
  }

  final TextEditingController searchController = TextEditingController();

  void clearSearch() {
    searchController.clear();
  }

  void signOut() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: colorScheme.surfaceContainer,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        floatingActionButton: CreateButton(item: tabs[selectedIndex]),
        body: SafeArea(
          child: Row(
            children: <Widget>[
              NavigationRail(
                groupAlignment: -1,
                selectedIndex: selectedIndex,
                labelType: NavigationRailLabelType.all,
                backgroundColor: colorScheme.surfaceContainer,
                onDestinationSelected: (int index) {
                  setState(() => selectedIndex = index);
                  clearSearch();
                },
                leading: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 12, 0, 32),
                  child: Opacity(
                    opacity: 0.9,
                    child: Image.asset('assets/logo_mono.png', fit: BoxFit.contain, height: 48),
                  ),
                ),
                trailing: Expanded(
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    padding: EdgeInsets.only(bottom: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.logout), tooltip: 'Sign Out', onPressed: signOut),
                        Text("Log out"),
                      ],
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
              Expanded(
                child: Container(
                  color: colorScheme.surfaceContainer,
                  child: Column(
                    children: [
                      Header(item: tabs[selectedIndex], searchController: searchController),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(8, 8, 12, 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: colorScheme.surface,
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Center(child: tabs[selectedIndex].child),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
