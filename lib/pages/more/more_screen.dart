import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:valuatorx/pages/common/tiles/link_tile.dart';
import 'package:valuatorx/pages/more/compass_screen.dart';
import 'package:valuatorx/providers/auth_provider.dart';
import 'package:valuatorx/utils/common.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  String name = "Full name";
  String email = "email@samanto.in";
  String profile = "SA";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final (resName, resEmail, resProfile) = await authProvider.getProfile();
      setState(() {
        name = resName;
        email = resEmail;
        profile = resProfile;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final authProvider = Provider.of<AuthProvider>(context);
    final skeletonDecoration = BoxDecoration(color: colorScheme.surfaceContainer, borderRadius: BorderRadius.circular(40));

    onLogOut() {
      authProvider.signOut();
      Navigator.pushNamedAndRemoveUntil(context, '/', (Route<dynamic> route) => false);
    }

    onOpenURL(String url) async {
      if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not launch Google Maps')));
      }
    }

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainer,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MoreTitle(title: "Account"),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 21),
                    decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(26)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          spacing: 21,
                          children: [
                            CircleAvatar(
                              backgroundColor: colorScheme.primaryContainer,
                              radius: 24,
                              child:
                                  authProvider.isLoading
                                      ? SizedBox(height: 21, width: 21, child: CircularProgressIndicator(strokeWidth: 3))
                                      : Text(profile),
                            ),
                            authProvider.isLoading
                                ? Shimmer.fromColors(
                                  baseColor: colorScheme.surfaceContainerHigh,
                                  highlightColor: colorScheme.surfaceContainer,
                                  child: Column(
                                    spacing: 8,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(width: 76, height: 13, decoration: skeletonDecoration),
                                      Container(width: 161, height: 13, decoration: skeletonDecoration),
                                    ],
                                  ),
                                )
                                : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name, style: textTheme.bodyLarge),
                                    Text(email, style: textTheme.bodyMedium!.copyWith(color: theme.hintColor)),
                                  ],
                                ),
                          ],
                        ),
                        PopupMenuButton(
                          icon: Icon(Icons.more_vert),
                          offset: const Offset(-5, 5),
                          itemBuilder:
                              (ctx) => [
                                PopupMenuItem(
                                  onTap: () => onOpenURL('https://myaccount.microsoft.com/'),
                                  child: Text("View account  ", style: textTheme.bodyMedium),
                                ),
                                PopupMenuItem(
                                  onTap: onLogOut,
                                  child: Row(
                                    children: [Text("Log out   ", style: textTheme.bodyMedium!.copyWith(color: colorScheme.error))],
                                  ),
                                ),
                              ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  MoreTitle(title: "Shortcuts"),
                  Container(
                    padding: EdgeInsets.fromLTRB(11,24,15,24),
                    decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(26)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 8),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            double itemWidth = 76;
                            double columnCount = MediaQuery.of(context).size.width / (isMobile(context) ? 100 : 120);
                            double spacing = (constraints.maxWidth - columnCount.floor() * itemWidth) / (columnCount.floor() - 1);
                            final tiles = [
                              LinkTile(
                                onPressed: () => onOpenURL('https://samantoassociates-my.sharepoint.com/my?id=%2Fpersonal%2Fantopaul%5Fsamanto%5Fin%2FDocuments%2FSAMANTO%20ASSOCIATES%20%28P%29%20Ltd'),
                                title: "Onedrive",
                                subTitle: "Open",
                                icon: Icons.cloud,
                              ),
                              LinkTile(
                                onPressed: () => onOpenURL('https://mapp.lichousing.com/LIC-HFL-VYOM/login'),
                                title: "LIC Portal",
                                subTitle: "Open",
                                icon: Icons.home_rounded,
                              ),
                              LinkTile(
                                onPressed: () => onOpenURL('https://vvm.bank.sbi:9445/VVM/portal/'),
                                title: "SBI Portal",
                                subTitle: "Open",
                                icon: Icons.account_balance,
                              ),
                              LinkTile(
                                onPressed: () => onOpenURL('https://igr.kerala.gov.in/index.php/fairvalue/view_fairvalue'),
                                title: "Fair Value \nof Land",
                                subTitle: "Open",
                                icon: Icons.paid_rounded,
                              ),
                              LinkTile(
                                onPressed: () => onOpenURL('https://bhuvan-app1.nrsc.gov.in/bhuvan2d2.0/'),
                                title: "Bhuvan 2D",
                                subTitle: "Open",
                                icon: Icons.public_rounded,
                              ),
                              LinkTile(
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CompassScreen())),
                                title: "Compass",
                                subTitle: "Open",
                                icon: Icons.explore_rounded,
                              ),
                            ];
                            return Wrap(
                              spacing: spacing,
                              runSpacing: 32,
                              alignment: WrapAlignment.start,
                              crossAxisAlignment: WrapCrossAlignment.start,
                              children: [...tiles.map((tile) => SizedBox(width: itemWidth, child: tile))],
                            );
                          },
                        ),
                        SizedBox(height: 15),
                      ],
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.only(bottom: isMobile(context) ? 8 : 11, top: 18),
                    child: Text("ValuatorX\nApp Version: v1.0.3", textAlign: TextAlign.center, style: TextStyle(color: theme.hintColor)),
                  ),
                ],
              ),
            ),
            if (!isMobile(context)) SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class MoreTitle extends StatelessWidget {
  final String title;
  const MoreTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Padding(padding: EdgeInsets.symmetric(vertical: 15, horizontal: 8), child: Text(title, style: textTheme.bodyLarge));
  }
}
