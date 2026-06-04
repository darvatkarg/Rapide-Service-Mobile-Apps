import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:hyper_local/bloc/settings_bloc/settings_bloc.dart';
import 'package:hyper_local/router/app_routes.dart';
import 'package:hyper_local/screens/home_page/bloc/brands/brands_bloc.dart';
import 'package:hyper_local/screens/user_profile/bloc/user_profile_bloc/user_profile_bloc.dart';
import 'package:hyper_local/utils/widgets/custom_image_container.dart';
import 'package:hyper_local/utils/widgets/custom_scaffold.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../bloc/user_details_bloc/user_details_bloc.dart';
import '../../bloc/user_details_bloc/user_details_state.dart';
import '../../config/global.dart';
import '../../config/helper.dart';
import '../../config/notification_service.dart';
import '../../config/settings_data_instance.dart';
import '../../config/theme.dart';
import '../../services/location/location_service.dart';
import '../home_page/bloc/banner/banner_bloc.dart';
import '../home_page/bloc/banner/banner_event.dart';
import '../home_page/bloc/category/category_bloc.dart';
import '../home_page/bloc/category/category_event.dart';
import '../home_page/bloc/feature_section_product/feature_section_product_bloc.dart';
import '../home_page/bloc/feature_section_product/feature_section_product_event.dart';
import '../home_page/bloc/sub_category/sub_category_bloc.dart';
import '../home_page/bloc/sub_category/sub_category_event.dart';

import 'package:hyper_local/l10n/app_localizations.dart';
import '../../services/language_manager.dart';
import '../../services/translation_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasInitialized = false;
  bool _hasNavigated = false;
  bool _lastKnownConnectivity = true;

  bool _isStoredDefaultLocation() {
    final storedLocation = LocationService.getStoredLocation();
    if (storedLocation == null) {
      return false;
    }

    final defaultLat = double.tryParse(AppHelpers.defaultLat);
    final defaultLng = double.tryParse(AppHelpers.defaultLng);
    if (defaultLat == null || defaultLng == null) {
      return false;
    }

    return (storedLocation.latitude - defaultLat).abs() < 0.0001 &&
        (storedLocation.longitude - defaultLng).abs() < 0.0001;
  }

  @override
  void initState() {
    super.initState();
    getFcm();
    // Dispatch initial settings fetch immediately
    context.read<SettingsBloc>().add(FetchSettingsData(context: context));
  }

  Future<String?> getFcm() async {
    String? fcmToken = await getFCMToken();
    return fcmToken.toString();
  }

  // Helper method to show the location access dialog
  // Future<bool?> _showLocationAccessDialog() async {
  //   return await showDialog<bool>(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (dialogContext) => AlertDialog(
  //       title: Text(
  //         AppLocalizations.of(dialogContext)!.locationAccessNeeded,
  //       ),
  //       content: Text(
  //         AppLocalizations.of(dialogContext)!.locationAccessDescription,
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(dialogContext, false),
  //           child: Text(AppLocalizations.of(dialogContext)!.later),
  //         ),
  //         ElevatedButton(
  //           onPressed: () async {
  //             final permission = await Geolocator.requestPermission();
  //
  //             if (dialogContext.mounted) {
  //               Navigator.pop(
  //                   dialogContext,
  //                   permission == LocationPermission.always ||
  //                       permission == LocationPermission.whileInUse);
  //             }
  //           },
  //           child: const Text("Allow Location"),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Modified to use SettingsData.instance directly
  Future<void> _checkAndSetLocation() async {
    String? lat, lng;
    if (AppHelpers.isDemo) {
      lat = AppHelpers.defaultLat;
      lng = AppHelpers.defaultLng;

      if (lat.isNotEmpty && lng.isNotEmpty) {
        await LocationService.storeLocationFromCoordinates(
          latitude: lat,
          longitude: lng,
        );
        return;
      }
    }

    if (LocationService.hasStoredLocation() && !_isStoredDefaultLocation()) {
      return;
    }

    // final bool? granted = await _showLocationAccessDialog();
    //
    // if (granted == true) {
    //   final currentLoc = await LocationService.requestAndStoreLocationWithRetry();
    //   if (currentLoc != null) {
    //     return;
    //   }
    // }

    if (LocationService.hasStoredLocation()) {
      return;
    }

    final webSettings = SettingsData.instance.web;
    if (webSettings != null) {
      lat = webSettings.defaultLatitude;
      lng = webSettings.defaultLongitude;
    }

    if (lat != null && lng != null && lat.isNotEmpty && lng.isNotEmpty) {
      await LocationService.storeLocationFromCoordinates(
        latitude: lat,
        longitude: lng,
      );
    }
  }

  Future<void> navigate() async {
    print("Navigating from splash");
    print("Token: ${Global.userData?.token}");
    print("Connectivity: $_lastKnownConnectivity");
    _dispatchInitialDataFetches();
    if (_hasNavigated) {
      return;
    }
    _hasNavigated = true;

    // Initialize and download translation model if needed
    await LanguageManager.init();
    await TranslationService().setLanguage(LanguageManager.currentLanguage);

    await Future.delayed(const Duration(seconds: 3));

    // if (!mounted || !_lastKnownConnectivity) {
    //   _hasNavigated = false;
    //   return;
    // }

    if (!mounted) {
      _hasNavigated = false;
      return;
    }

    // If first launch -> show intro slider
    if (Global.isFirstTime) {
      GoRouter.of(context).go(AppRoutes.introSlider);
      return;
    }

    // Not first launch: if logged in, go to home
    if (Global.userData?.token.isNotEmpty ?? false) {
      if (mounted) {
        GoRouter.of(context).go(AppRoutes.home);
        print('after loginnnnnnn');
      }
    } else {
      // Not logged in -> go to login
      GoRouter.of(context).go(AppRoutes.login);
    }
  }

  void _handleConnectivityChanged(bool isConnected) {
    _lastKnownConnectivity = isConnected;

    if (!isConnected) {
      _hasNavigated = false;
      // You might want to show an offline UI here
      return;
    }

    // Hide offline UI here

    if (!_hasInitialized) {
      _hasInitialized = true;
      navigate();
      return;
    }

    if (!_hasNavigated) {
      navigate();
    }
  }

  void _dispatchInitialDataFetches() {
    // Settings data is already being fetched in initState.
    context.read<CategoryBloc>().add(FetchCategory(context: context));
    // context.read<CartBloc>().add(LoadCart());
    // context.read<GetUserCartBloc>().add(FetchUserCart());
    context.read<BannerBloc>().add(FetchBanner(categorySlug: ""));
    context.read<BrandsBloc>().add(const FetchBrands(categorySlug: ""));
    context
        .read<SubCategoryBloc>()
        .add(FetchSubCategory(slug: "", isForAllCategory: true));
    context
        .read<FeatureSectionProductBloc>()
        .add(FetchFeatureSectionProducts(slug: ""));
    context.read<UserProfileBloc>().add(FetchUserProfile());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsState>(
      // Listen for the settings data to be loaded
      listener: (context, state) async {
        if (state is MaintenanceModeEnabled) {
          GoRouter.of(context).go(AppRoutes.maintenancePage,
              extra: {'message': state.maintenanceModeMessage});
          return;
        }
        if (state is SettingsLoaded) {
          if (SettingsData.instance.system!.webMaintenanceMode) {
            log('Maintenance---Modeeee ${SettingsData.instance.system!.webMaintenanceMode}');
            GoRouter.of(context).go(
              AppRoutes.maintenancePage,
            );
            return;
          }
          // 1. Check/Set location using SettingsData.instance
          await _checkAndSetLocation();

          // 2. Now that settings and initial location logic is done, proceed with navigation logic
          if (_lastKnownConnectivity) {
            // If connectivity check already ran (before settings loaded), trigger navigation now
            _handleConnectivityChanged(true);
          }
        } else if (state is SettingsFailure) {
          // Handle settings failure - perhaps use default settings or navigate anyway
          log('Settings failed to load: ${state.error}');
          // For now, assume no maintenance and proceed with navigation
          // await _checkAndSetLocation();
          if (_lastKnownConnectivity) {
            _handleConnectivityChanged(true);
          }
        }
      },
      child: BlocListener<UserDataBloc, UserDataState>(
        listener: (BuildContext context, UserDataState state) {
          // Your existing UserDataBloc listener logic if needed
        },
        child: CustomScaffold(
          showViewCart: false,
          notifyConnectivityStatusOnInit: true,
          onConnectivityChanged: (isConnected, _) {
            _lastKnownConnectivity = isConnected;
            // Only proceed with navigation if settings have already been loaded,
            // or if the settings bloc listener hasn't run yet (it will handle navigation then).
            if (context.read<SettingsBloc>().state is SettingsLoaded) {
              Future.delayed(
                  const Duration(seconds: 1)); // Small delay for UI/Splash
              _handleConnectivityChanged(isConnected);
            }
          },
          body: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  color: AppTheme.mainLightBackgroundColor,
                  // image: DecorationImage(
                  //   image: AssetImage('assets/images/doodle.png'),
                  //   fit: BoxFit.cover,
                  // ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/app/Logo-UserApp.png',
                      height: 180,
                      width: 250,
                      fit: BoxFit.contain,
                    ),
                  )
                  // Center(
                  //   child: CustomImageContainer(
                  //     imagePath: getAppLogoUrl(context),
                  //     height: 180,
                  //     width: 250,
                  //     fit: BoxFit.contain,
                  //   ),
                  // )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:hyper_local/bloc/settings_bloc/settings_bloc.dart';
import 'package:hyper_local/router/app_routes.dart';
import 'package:hyper_local/screens/home_page/bloc/brands/brands_bloc.dart';
import 'package:hyper_local/screens/user_profile/bloc/user_profile_bloc/user_profile_bloc.dart';
import 'package:hyper_local/model/user_location/user_location_model.dart';
import 'package:hyper_local/utils/widgets/custom_image_container.dart';
import 'package:hyper_local/utils/widgets/custom_scaffold.dart';
import 'package:hyper_local/utils/widgets/empty_states_page.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../bloc/user_details_bloc/user_details_bloc.dart';
import '../../bloc/user_details_bloc/user_details_state.dart';
import '../../config/constant.dart';
import '../../config/global.dart';
import '../../services/location/location_service.dart';
import '../home_page/bloc/banner/banner_bloc.dart';
import '../home_page/bloc/banner/banner_event.dart';
import '../home_page/bloc/category/category_bloc.dart';
import '../home_page/bloc/category/category_event.dart';
import '../home_page/bloc/feature_section_product/feature_section_product_bloc.dart';
import '../home_page/bloc/feature_section_product/feature_section_product_event.dart';
import '../home_page/bloc/sub_category/sub_category_bloc.dart';
import '../home_page/bloc/sub_category/sub_category_event.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasInitialized = false;
  bool _hasNavigated = false;
  bool _lastKnownConnectivity = false;
  bool _settingsLoaded = false;
  bool _minSplashTimeElapsed = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> navigate() async {
    UserLocation? location = await LocationService.requestAndStoreLocationWithRetry();

    if (location == null) {
      // Optional: show guidance if still not ready
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.enableLocation),
          content: Text(
              AppLocalizations.of(context)!.turnOnLocationServices),
          actions: [
            TextButton(
              onPressed: () async {
                await Geolocator.openLocationSettings();
              },
              child: Text(
                AppLocalizations.of(context)!.locationServices,
                style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
              ),
            ),
            TextButton(
              onPressed: () async {
                await openAppSettings();
              },
              child: Text(
                AppLocalizations.of(context)!.appPermissions,
                style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppLocalizations.of(context)!.close,
                style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
              ),
            ),
          ],
        ),
      );
      // Try once more
      location = await LocationService.requestAndStoreLocationWithRetry();
    }

    // Dispatch all initial data fetches
    _dispatchInitialDataFetches();

    // Wait for minimum splash screen duration (3 seconds)
    await Future.delayed(Duration(seconds: 3));

    if (!mounted || !_lastKnownConnectivity) {
      return;
    }

    _minSplashTimeElapsed = true;

    // Check if settings are already loaded and navigate if ready
    _checkAndNavigate();
  }

  void _handleConnectivityChanged(bool isConnected) {
    _lastKnownConnectivity = isConnected;

    if (!isConnected) {
      _hasNavigated = false;
      // _showOfflinePage();
      return;
    }

    // _hideOfflinePage();

    if (!_hasInitialized) {
      _hasInitialized = true;
      navigate();
      return;
    }

    if (!_hasNavigated) {
      navigate();
    }
  }

  void _dispatchInitialDataFetches() {
    context.read<SettingsBloc>().add(FetchSettingsData(context: context));
    context.read<CategoryBloc>().add(FetchCategory(context: context));
    context.read<BannerBloc>().add(FetchBanner(categorySlug: ""));
    context.read<BrandsBloc>().add(FetchBrands(categorySlug: ""));
    context.read<SubCategoryBloc>().add(FetchSubCategory(slug: "", isForAllCategory: true));
    context
        .read<FeatureSectionProductBloc>()
        .add(FetchFeatureSectionProducts(slug: ""));
    context.read<UserProfileBloc>().add(FetchUserProfile());
  }

  void _handleSettingsSuccess() {
    _settingsLoaded = true;
    _checkAndNavigate();
  }

  void _checkAndNavigate() {
    // Only navigate if both conditions are met:
    // 1. Settings are loaded
    // 2. Minimum splash time has elapsed
    if (_hasNavigated || !_settingsLoaded || !_minSplashTimeElapsed) {
      return;
    }

    if (!mounted || !_lastKnownConnectivity) {
      return;
    }

    _performNavigation();
  }

  void _performNavigation() {
    if (_hasNavigated) {
      return;
    }

    _hasNavigated = true;

    // If first launch -> show intro slider
    if (Global.isFirstTime) {
      GoRouter.of(context).go(AppRoutes.introSlider);
      return;
    } else {
      if (mounted) {
        GoRouter.of(context).go(AppRoutes.home);
      }
    }

    // Alternative: Check if user is logged in
    // if (Global.userData?.token.isNotEmpty ?? false) {
    //   GoRouter.of(context).go(AppRoutes.home);
    // } else {
    //   GoRouter.of(context).go(AppRoutes.login);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<UserDataBloc, UserDataState>(
          listener: (BuildContext context, UserDataState state) {
            // Handle user data state if needed
          },
        ),
      ],
      child: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (BuildContext context, SettingsState state) {
          if (state is SettingsLoaded) {
            _handleSettingsSuccess();
          } else if (state is SettingsFailure) {
            // Handle settings failure if needed
            // You might want to show an error dialog or retry
            if (!_hasNavigated && mounted) {
              GoRouter.of(context).push(AppRoutes.maintenancePage);
              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(
              //     content: Text('Failed to load settings. Please try again.'),
              //     action: SnackBarAction(
              //       label: 'Retry',
              //       onPressed: () {
              //         context.read<SettingsBloc>().add(
              //           FetchSettingsData(context: context),
              //         );
              //       },
              //     ),
              //   ),
              // );
            }
          }
        },
        builder: (BuildContext context, SettingsState state) {
          if(state is SettingsFailure) {
            return MaintenancePage(
              onRetry: (){
                GoRouter.of(context).pushReplacement(AppRoutes.maintenancePage);
              },
            );
          }
          return Stack(
            children: [
              CustomScaffold(
                showViewCart: false,
                backgroundColor: Theme.of(context).colorScheme.surface,
                notifyConnectivityStatusOnInit: true,
                onConnectivityChanged: (isConnected, _) {
                  _handleConnectivityChanged(isConnected);
                },
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: CustomImageContainer(
                        imagePath: getAppLogoUrl(context),
                        height: 180,
                        width: 250,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 24),
                    // Optional: Add a loading indicator
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}*/
