import 'package:ekfalninew/providers/app_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/init.dart';

import 'l10n.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

// Core screens
import 'package:ekfalninew/screens/splash.dart';
import 'screens/login.dart';
import 'screens/signup.dart';
import 'screens/homepage.dart';
import 'screens/profile.dart';
import 'drawer/setting.dart';

// Navigation and common
import 'drawer/CustomDrawer.dart';
import 'drawer/help.dart';
import 'navigation/main_navigation.dart';

// Features
import 'features/donation/screens/donation.dart';
import 'features/donation/screens/mydonat.dart';
import 'features/donation/screens/fooddonation.dart';
import 'features/donation/screens/donationschool.dart';
import 'features/donation/screens/clothesdonation.dart';
import 'features/donation/screens/donation_form.dart';
import 'features/donation/screens/donation_list_screen.dart';
import 'features/donation/screens/donation_statistics_widget.dart';

import 'features/sponsor/screens/sponsor.dart';
import 'features/sponsor/screens/orphansponsorship.dart';
import 'features/sponsor/screens/sponsorship.dart';
import 'features/sponsor/screens/sponsorshipconfirmation.dart';
import 'features/sponsor/screens/mysponsor.dart';
import 'features/sponsor/screens/sponserchild.dart';

import 'features/association/screens/association.dart';
import 'features/association/screens/AssociationProjects.dart';
import 'features/association/screens/projectDetails.dart';

import 'features/payment/screens/paypal.dart';
import 'features/payment/screens/creditcard.dart';
import 'features/payment/screens/banktransfer.dart';

void main() async {
  await AppInitializer.initialize();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(languageProvider);
    // Watch app state to trigger rebuild when language changes
    ref.watch(appStateProvider);
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: locale,
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.primaryColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppTheme.backgroundColor,
        appBarTheme: AppBarTheme(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: AppTheme.cardColor,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: AppTheme.elevatedButtonStyle,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppTheme.backgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
          ),
        ),
        textTheme: GoogleFonts.cairoTextTheme(),
        pageTransitionsTheme: AppTheme.pageTransitionsTheme,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.primaryColor,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: AppBarTheme(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: const Color(0xFF1E1E1E),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: AppTheme.elevatedButtonStyle,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
          ),
        ),
        textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme),
        pageTransitionsTheme: AppTheme.pageTransitionsTheme,
      ),
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/main_nivigation': (context) => MainNavigation(),
        '/home': (context) => HomePage(),
        '/profile': (context) => const ProfileScreen(),
        '/customdrawer': (context) => drawer(),
        '/helppage': (context) => HelpPage(),

        // التبرعات
        '/donat': (context) => donation(),
        '/mydonat': (context) => MyDonationsScreen(),
        '/fooddonation': (context) => DonationFoodScreen(),
        '/schooldonation': (context) => DonationSchoolScreen(),
        '/clothesdonation': (context) => DonationClothesScreen(),
        '/DonationFormScreen':(context) => DonationFormScreen(),

        // الكفالة
        '/sponsor': (context) => sponsor(),
        '/orphansponser': (context) => OrphanSponsorshipPage(),
        '/sposership': (context) => sponsorship(),
        '/sponserchild': (context) => sponsorchild(),
        '/mysponsor': (context) => mysponsor(),
        '/sponsorshipconfirmation': (context) => const SponsorshipConfirmation(
          orphanName: '',
          duration: 0,
          amount: 0,
        ),

        // الجمعيات والمشاريع
        '/association': (context) => Association(),

        // الدفع
        '/paypal': (context) => PayPalPage(),
        '/creditcard': (context) => CreditCardPage(),
        '/banktransfar': (context) => BankTransferPage(),

        // الإعدادات
        '/settingpage': (context) => const SettingPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/association_projects') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) =>
                AssociationProjects(associationName: args['associationName']),
          );
        }

        if (settings.name == '/project_details') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => ProjectDetailsPage(
              projectTitle: args['projectTitle'],
              projectDescription: args['projectDescription'],
            ),
          );
        }

        return null;
      },
    );
  }
}
