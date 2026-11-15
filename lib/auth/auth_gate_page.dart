import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../admin/admin.dart';
import '../customer/customer_shell.dart';
import '../owner/owner.dart';
import '../rider/rider.dart';

/// One authenticated entry point for all four Foodie account types.
/// Public registration is available only for customers, restaurant owners and riders.
class AuthGatePage extends StatefulWidget {
  final String accountType;
  const AuthGatePage({super.key, required this.accountType});
  @override
  State<AuthGatePage> createState() => _AuthGatePageState();
}

class _AuthGatePageState extends State<AuthGatePage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _register = false, _busy = false;
  String? _message;
  String get _role => widget.accountType;
  bool get _canRegister => _role != 'admin';

  @override
  void dispose() {
    _name.dispose(); _email.dispose(); _password.dispose(); super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() { _busy = true; _message = null; });
    try {
      final auth = FirebaseAuth.instance;
      UserCredential credential;
      if (_register) {
        credential = await auth.createUserWithEmailAndPassword(
          email: _email.text.trim(), password: _password.text,
        );
        final pending = _role != 'customer';
        await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
          'uid': credential.user!.uid,
          'name': _name.text.trim(),
          'email': _email.text.trim().toLowerCase(),
          'role': _role,
          'status': pending ? 'pending' : 'active',
          'createdAt': FieldValue.serverTimestamp(),
        });
        if (pending) {
          await auth.signOut();
          if (mounted) setState(() => _message = 'Your application has been submitted. Sign in after an administrator approves your account.');
          return;
        }
      } else {
        credential = await auth.signInWithEmailAndPassword(
          email: _email.text.trim(), password: _password.text,
        );
      }
      final user = credential.user!;
      final snap = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (!snap.exists) {
        await auth.signOut();
        throw Exception('No Foodie profile was found for this account. Contact the administrator.');
      }
      final data = snap.data()!;
      if (data['role'] != _role) {
        await auth.signOut();
        throw Exception('This account is not registered as ${_roleLabel(_role)}. Choose the correct account type.');
      }
      if (data['status'] != 'active') {
        await auth.signOut();
        throw Exception(data['status'] == 'pending'
          ? 'Your account is awaiting administrator approval.'
          : 'This account is not active. Contact the administrator.');
      }
      if (!mounted) return;
      Widget destination = switch (_role) {
        'customer' => const CustomerShell(),
        'restaurant' => const OwnerShell(),
        'rider' => const RiderShell(),
        'admin' => const AdminShell(),
        _ => const CustomerShell(),
      };
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => destination), (_) => false);
    } on FirebaseAuthException catch (e) {
      setState(() => _message = _authError(e.code));
    } catch (e) {
      setState(() => _message = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _authError(String code) => switch (code) {
    'email-already-in-use' => 'An account already exists with this email.',
    'invalid-email' => 'Enter a valid email address.',
    'weak-password' => 'Choose a stronger password (at least 6 characters).',
    'user-not-found' || 'wrong-password' || 'invalid-credential' => 'Email or password is incorrect.',
    'network-request-failed' => 'Network error. Check your internet connection.',
    'too-many-requests' => 'Too many attempts. Please try again later.',
    _ => 'Authentication failed ($code). Please try again.',
  };

  String _roleLabel(String role) => switch (role) {
    'customer' => 'customer', 'restaurant' => 'restaurant owner', 'rider' => 'delivery rider', _ => 'admin'
  };

  @override
  Widget build(BuildContext context) {
    final title = _roleLabel(_role);
    return Scaffold(
      appBar: AppBar(title: Text('${_register ? 'Create' : 'Sign in'} · ${title[0].toUpperCase()}${title.substring(1)}')),
      body: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440), child: Form(key: _form, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Icon(Icons.restaurant_menu_rounded, size: 54, color: Color(0xFFFF7043)),
          const SizedBox(height: 12),
          Text(_register ? 'Join Foodie' : 'Welcome back', textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(_register ? (_role == 'customer' ? 'Create your customer account.' : 'Submit your application for review.') : 'Sign in to your Foodie account.', textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 28),
          if (_register) ...[
            TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Full name', prefixIcon: Icon(Icons.person_outline)), validator: (v) => (v == null || v.trim().length < 2) ? 'Enter your name' : null),
            const SizedBox(height: 14),
          ],
          TextFormField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email address', prefixIcon: Icon(Icons.email_outlined)), validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null),
          const SizedBox(height: 14),
          TextFormField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline)), validator: (v) => (v == null || v.length < 6) ? 'Password must be at least 6 characters' : null),
          if (_message != null) ...[
            const SizedBox(height: 14),
            Text(_message!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
          ],
          const SizedBox(height: 22),
          FilledButton(onPressed: _busy ? null : _submit, style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF7043), padding: const EdgeInsets.symmetric(vertical: 16)), child: _busy ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(_register ? 'Create account' : 'Sign in')),
          if (_canRegister) TextButton(onPressed: _busy ? null : () => setState(() { _register = !_register; _message = null; }), child: Text(_register ? 'Already have an account? Sign in' : 'New here? Create an account')),
          if (_register && _role != 'customer') const Padding(padding: EdgeInsets.only(top: 8), child: Text('Your account will remain pending until an administrator approves your application.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, fontSize: 12))),
        ])),
      ))),
    );
  }
}
