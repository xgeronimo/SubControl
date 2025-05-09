import 'package:flutter/material.dart';
import 'screens/subscriptions_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/add_subscription_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/add_category_screen.dart';
import 'services/hive_service.dart';
import 'theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Менеджер подписок',
      theme: appTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const MainScreen(),
        '/add-subscription': (context) => const AddSubscriptionScreen(),
        '/add-category': (context) => const AddCategoryScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const SubscriptionsScreen(),
    CategoriesScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      floatingActionButton: _buildCenterFab(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildCenterFab(BuildContext context) {
    return RawMaterialButton(
      onPressed: () {
        Navigator.pushNamed(context, '/add-subscription');
      },
      elevation: 6,
      fillColor: Theme.of(context).primaryColor,
      constraints: const BoxConstraints.tightFor(width: 95.0, height: 95.0),
      shape: const CircleBorder(
        side: BorderSide(color: Colors.blueAccent, width: 4.0),
      ),
      child: const Icon(
        Icons.add,
        size: 36,
        color: Colors.white,
      ),
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const CustomBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60.0,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 60.0),
            painter: BottomNavBarPainter(),
          ),
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildNavItem(Icons.list, 0, 'Подписки', context),
                const SizedBox(
                    width: 70),
                _buildNavItem(Icons.category, 1, 'Категории', context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      IconData icon, int index, String label, BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        color: selectedIndex == index
            ? Theme.of(context).primaryColor
            : Colors.grey,
      ),
      onPressed: () => onItemTapped(index),
      tooltip: label,
    );
  }
}

class BottomNavBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.fill;

    double cornerRadius = 20.0;
    double notchRadius = 50.0;
    double notchWidth = 105.0;

    Path path = Path();

    path.addRRect(RRect.fromRectAndCorners(
      Rect.fromLTWH(0, 0, size.width, size.height),
      topLeft: Radius.circular(cornerRadius),
      topRight: Radius.circular(cornerRadius),
    ));

    path.moveTo((size.width - notchWidth) / 2, 0);
    path.arcToPoint(
      Offset((size.width + notchWidth) / 2, 0),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
