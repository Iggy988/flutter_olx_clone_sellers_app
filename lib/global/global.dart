import 'package:sellers_app/assistentMethods/cart_methods.dart';
import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences? sharedPreferences;
CartMethods cartMethods = CartMethods();
String previousEarning = '';

String fcmServerToken = '';
