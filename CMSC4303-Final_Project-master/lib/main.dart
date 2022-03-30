import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/screen/addcomment_screen.dart';
import 'package:lesson3/screen/addphotomemo_screen.dart';
import 'package:lesson3/screen/favorites_screen.dart';
import 'package:lesson3/screen/sharedwith_screen.dart';
import 'package:lesson3/screen/sharedwithdetails_screen.dart';
import 'package:lesson3/screen/signin_screen.dart';
import 'package:lesson3/screen/signup_screen.dart';
import 'package:lesson3/screen/userhome_screen.dart';
import 'package:lesson3/screen/detailedview_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(PhotoMemoApp());
}

class PhotoMemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: !Constant.DEV,
        theme: ThemeData(
          brightness: Brightness.dark, //DARK MODE
          primarySwatch: Colors.yellow,
          primaryColor: Colors.yellow[600],
        ),
        initialRoute: SignInScreen.routeName,
        routes: {
          SignInScreen.routeName: (context) => SignInScreen(),
          UserHomeScreen.routeName: (context) => UserHomeScreen(),
          AddPhotoMemoScreen.routeName: (context) => AddPhotoMemoScreen(),
          DetailedViewScreen.routeName: (context) => DetailedViewScreen(),
          SignUpScreen.routeName: (context) => SignUpScreen(),
          SharedWithScreen.routeName: (context) => SharedWithScreen(),
          FavoritesScreen.routeName: (context) => FavoritesScreen(),
          AddCommentScreen.routeName: (context) => AddCommentScreen(),
          SharedWithDetailsScreen.routeName: (context) => SharedWithDetailsScreen(),
        });
  }
}
