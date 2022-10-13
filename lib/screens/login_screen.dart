import 'package:flutter/material.dart';
import 'package:live_app/utils/firebase_utils.dart';
import 'package:live_app/screens/home_screen.dart';
import 'package:live_app/styles/colors.dart';
import 'package:live_app/utils/navigation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _colorUtils = ColorUtils();

  Future<void> _signIn() async {
    await FirebaseUtils.signInWithGoogle();
    Future.delayed(
      const Duration(seconds: 0),
      () {
        NavigationUtils().pushReplace(
          context,
          const HomeScreen(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        padding: const EdgeInsets.symmetric(
          vertical: 128,
          horizontal: 32,
        ),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/bg.png',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildLogo(),
            _buildButton(),
            _buildText(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Expanded(
      child: Image.asset('assets/images/logo.png'),
    );
  }

  Widget _buildButton() {
    return InkWell(
      onTap: _signIn,
      child: Container(
        height: 48,
        width: MediaQuery.of(context).size.width * 0.6,
        margin: const EdgeInsets.all(16),
        child: Material(
          color: _colorUtils.white,
          elevation: 4,
          borderRadius: BorderRadius.circular(24),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Image.asset('assets/images/ic_google.png'),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Join with Google',
                    style: TextStyle(
                      color: _colorUtils.textColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildText() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'Login means you agree to Terms of Use, Privacy Policy \nPowered by Yeah!live',
        style: TextStyle(
          color: _colorUtils.textColor,
          fontSize: 10,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
