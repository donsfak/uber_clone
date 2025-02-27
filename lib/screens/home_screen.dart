// ignore_for_file: unused_field, deprecated_member_use, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_clone/auth/login_screen.dart';
import 'package:uber_clone/global/global_var.dart';
import 'package:uber_clone/methods/common_methods.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final Completer<GoogleMapController> googleMapCompleterController =
      Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  Position? currentPositionOfUser;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _drawerAnimationController;
  late Animation<double> _drawerAnimation;
  CommonMethods cMethods = CommonMethods();
  double searchContainerHeight = 276;
  double bottomMapPadding = 0;

  @override
  void initState() {
    super.initState();

    // Initialisation de l'animation du tiroir
    _drawerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _drawerAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _drawerAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _drawerAnimationController.dispose();
    super.dispose();
  }

  void updateMapTheme(GoogleMapController controller) {
    getJsonFileFromThemes(
      'themes/retro_style.json',
    ).then((value) => setGoogleMapStyle(value, controller));
  }

  Future<String> getJsonFileFromThemes(String mapStylePath) async {
    ByteData byteData = await rootBundle.load(mapStylePath);
    var list = byteData.buffer.asUint8List(
      byteData.offsetInBytes,
      byteData.lengthInBytes,
    );
    return utf8.decode(list);
  }

  void setGoogleMapStyle(
    String googleMapStyle,
    GoogleMapController controller,
  ) {
    controller.setMapStyle(googleMapStyle);
  }

  Future<void> getCurrentLiveLocationOfUser() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez activer la localisation')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission de localisation refusée')),
        );
        return;
      }
    }

    Position positionUser = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );
    currentPositionOfUser = positionUser;
    LatLng positionOfUserLatLng = LatLng(
      currentPositionOfUser!.latitude,
      currentPositionOfUser!.longitude,
    );

    CameraPosition cameraPosition = CameraPosition(
      target: positionOfUserLatLng,
      zoom: 15,
    );
    controllerGoogleMap!.animateCamera(
      CameraUpdate.newCameraPosition(cameraPosition),
    );
    await getUserInfoAndCheckBookingStatus();
  }

  void _openDrawer() {
    if (_drawerAnimationController.isCompleted) {
      _drawerAnimationController.reverse();
    } else {
      _drawerAnimationController.forward();
    }
    scaffoldKey.currentState!.openDrawer();
  }

  void _closeDrawer() {
    _drawerAnimationController.reverse();
    Navigator.of(context).pop();
  }

  getUserInfoAndCheckBookingStatus() async {
    // Récupérer les informations de l'utilisateur
    DatabaseReference userRef = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(FirebaseAuth.instance.currentUser!.uid);
    // Vérifier si l'utilisateur a une course en cours

    await userRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        if ((snap.snapshot.value as Map)["blockStatus"] == "no") {
          setState(() {
            userName = (snap.snapshot.value as Map)["name"];
          });
        } else {
          FirebaseAuth.instance.signOut();
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder:
                  (context, animation, secondaryAnimation) => LoginScreen(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                var tween = Tween(
                  begin: begin,
                  end: end,
                ).chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);
                return SlideTransition(position: offsetAnimation, child: child);
              },
            ),
          );
          cMethods.displaySnackBar("you are blocked. Contact admin", context);
        }
      } else {
        FirebaseAuth.instance.signOut();
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) => LoginScreen(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween = Tween(
                begin: begin,
                end: end,
              ).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);
              return SlideTransition(position: offsetAnimation, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ListView(
            children: [
              // Header du tiroir
              Container(
                height: 160.0,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent, Colors.purpleAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10.0,
                      spreadRadius: 2.0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: DrawerHeader(
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/avatarman.png',
                        height: 60.0,
                        width: 60.0,
                      ),
                      const SizedBox(width: 16.0),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontFamily: 'Brand-Bold',
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6.0),
                          Text(
                            'Profile',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontFamily: 'Brand-Bold',
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              // Corps du tiroir
              ListTile(
                leading: const Icon(Icons.info, color: Colors.white),
                title: const Text(
                  'About',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  _closeDrawer();
                },
              ),
              GestureDetector(
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder:
                          (context, animation, secondaryAnimation) =>
                              LoginScreen(),
                      transitionsBuilder: (
                        context,
                        animation,
                        secondaryAnimation,
                        child,
                      ) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.easeInOut;
                        var tween = Tween(
                          begin: begin,
                          end: end,
                        ).chain(CurveTween(curve: curve));
                        var offsetAnimation = animation.drive(tween);
                        return SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        );
                      },
                    ),
                  );
                },
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.white),
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            padding: EdgeInsets.only(top: 26.0, bottom: bottomMapPadding),
            mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition: const CameraPosition(
              target: LatLng(
                0,
                0,
              ), // Remplacez par la position initiale souhaitée
              zoom: 15,
            ),
            onMapCreated: (GoogleMapController mapController) {
              controllerGoogleMap = mapController;
              updateMapTheme(controllerGoogleMap!);
              googleMapCompleterController.complete(controllerGoogleMap);

              setState(() {
                bottomMapPadding = 150;
              });

              getCurrentLiveLocationOfUser();
            },
          ),
          // Bouton hamburger avec animation
          Positioned(
            top: 45.0,
            left: 22.0,
            child: GestureDetector(
              onTap: _openDrawer,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 6.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 20.0,
                  child: Icon(Icons.menu, color: Colors.black, size: 25.0),
                ),
              ),
            ),
          ),
          // Boutons de recherche avec animations
          Positioned(
            bottom: -80,
            right: 0,
            left: 0,
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/search_screen');
              },
              child: SizedBox(
                height: searchContainerHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildAnimatedButton(
                      icon: Icons.search,
                      onPressed: () {
                        //Navigator.pushNamed(context, '/search_screen');
                      },
                    ),
                    _buildAnimatedButton(
                      icon: Icons.home,
                      onPressed: () {
                        //Navigator.pushNamed(context, '/search_screen');
                      },
                    ),
                    _buildAnimatedButton(
                      icon: Icons.work,
                      onPressed: () {
                        //Navigator.pushNamed(context, '/search_screen');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      transform: Matrix4.identity()..scale(1.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(24),
          elevation: 5,
          shadowColor: Colors.black.withOpacity(0.3),
        ),
        child: Icon(icon, color: Colors.white, size: 25.0),
      ),
    );
  }
}
