import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/app_database.dart';
import '../core/foodcat_colors.dart';
import 'home_shell.dart';

const pink = FoodCatColors.primary;
const ink = FoodCatColors.dark;
const roles = ['Customer', 'Restaurant Partner', 'Rider', 'Admin'];

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool signup = false;
  bool obscure = true;
  String role = 'Customer';
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final phone = TextEditingController();

  Future<void> submit() async {
    if (email.text.trim().isEmpty || password.text.isEmpty ||
        (signup && name.text.trim().isEmpty)) {
      msg('Please complete the required fields.');
      return;
    }
    try {
      Map<String, Object?>? user;
      if (signup) {
        await AppDatabase.instance.register(
          name: name.text,
          email: email.text,
          password: password.text,
          role: role,
          phone: phone.text,
        );
      }
      user = await AppDatabase.instance.login(email.text, password.text, role);
      if (user == null) {
        msg(signup
          ? 'Could not create account. Check the email or try another.'
          : 'No account found for this role. Please sign up first.');
        return;
      }
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeShell(user: user!)),
      );
    } catch (error) {
      msg(error.toString().contains('UNIQUE')
        ? 'This email is already registered.'
        : 'Something went wrong: $error');
    }
  }

  void msg(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Image.asset(
                  'assets/branding/foodcat_splash.png',
                  height: 245,
                  fit: BoxFit.contain,
                ).animate().fadeIn(duration: 700.ms).slideY(
                  begin: .12, end: 0, curve: Curves.easeOutCubic,
                ),
                const SizedBox(height: 28),
                Text(
                  signup ? 'Create your account' : 'Welcome back',
                  style: const TextStyle(
                    fontSize: 25, fontWeight: FontWeight.w900, color: ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  signup
                    ? 'Join FoodCat and get things moving.'
                    : 'Sign in to continue to your FoodCat workspace.',
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 22),
                const Text(
                  'CHOOSE YOUR ROLE',
                  style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.bold,
                    letterSpacing: 1.1, color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: roles.map((item) => ChoiceChip(
                    label: Text(item),
                    selected: role == item,
                    onSelected: (_) => setState(() => role = item),
                    selectedColor: const Color(0xFFFFD8E8),
                  )).toList(),
                ),
                const SizedBox(height: 18),
                if (signup) ...[
                  TextField(
                    controller: name,
                    decoration: const InputDecoration(
                      labelText: 'Full name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phone,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone number',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: password,
                  obscureText: obscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => obscure = !obscure),
                      icon: Icon(obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    ),
                  ),
                ),
                if (!signup)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RecoverScreen()),
                      ),
                      child: const Text('Forgot password?'),
                    ),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 54,
                  child: FilledButton(
                    onPressed: submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: pink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      signup ? 'Create account' : 'Sign in',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => signup = !signup),
                    child: Text(signup
                      ? 'Already have an account? Sign in'
                      : 'New to FoodCat? Create an account'),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEAF2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'Demo tip: Create separate accounts for Customer, Restaurant Partner, Rider and Admin. Each role opens its own workspace.',
                    style: TextStyle(color: ink, fontSize: 12, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class RecoverScreen extends StatelessWidget {
  const RecoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text('Recover account')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter your registered email. This demo will show the recovery guidance locally.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Email address'),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'For this offline demo, contact your platform administrator to reset your password.',
                  ),
                ),
              ),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
