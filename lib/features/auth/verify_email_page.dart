import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';

import 'widgets/auth_background.dart';
import '../../widgets/glass_card.dart';
import '../dashboard/dashboard_page.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  Timer? _autoCheckTimer;
  Timer? _cooldownTimer;

  bool _busy = false;
  int _cooldown = 0;

  fb.User? get _user => fb.FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();

    // Send verification email once when page opens (if needed)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _sendVerificationIfNeeded();
      _startAutoCheck();
    });
  }

  @override
  void dispose() {
    _autoCheckTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _startAutoCheck() {
    _autoCheckTimer?.cancel();
    _autoCheckTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await _checkVerified(silent: true);
    });
  }

  Future<void> _sendVerificationIfNeeded() async {
    final u = _user;
    if (u == null) return;

    try {
      await u.reload();
      final fresh = fb.FirebaseAuth.instance.currentUser;
      if (fresh == null) return;

      if (!fresh.emailVerified) {
        await fresh.sendEmailVerification();
      }
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _checkVerified({bool silent = false}) async {
    if (_busy) return;
    final u = _user;
    if (u == null) {
      if (!silent) _snack("No user found. Please sign in again.");
      return;
    }

    setState(() => _busy = true);

    try {
      await u.reload();
      final fresh = fb.FirebaseAuth.instance.currentUser;

      if (fresh != null && fresh.emailVerified) {
        _autoCheckTimer?.cancel();

        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const DashboardPage()),
          (_) => false,
        );
      } else {
        if (!silent) _snack("Not verified yet. Please check your email.");
      }
    } catch (e) {
      if (!silent) _snack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resend() async {
    if (_cooldown > 0) return;

    final u = _user;
    if (u == null) {
      _snack("No user found. Please sign in again.");
      return;
    }

    setState(() {
      _busy = true;
      _cooldown = 30;
    });

    try {
      await u.sendEmailVerification();
      _snack("Verification email sent again.");
      _startCooldownTimer();
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''));
      if (mounted) setState(() => _cooldown = 0);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _startCooldownTimer() {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_cooldown <= 1) {
        setState(() => _cooldown = 0);
        t.cancel();
      } else {
        setState(() => _cooldown--);
      }
    });
  }

  Future<void> _signOut() async {
    await fb.FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final email = _user?.email ?? "";

    return Scaffold(
      body: AuthBackground(
        child: GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.mark_email_read_outlined,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 12),
                const Text(
                  "Verify your email",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "We sent a verification link to:\n$email\n\nYou cannot proceed until it is verified.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.80)),
                ),
                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _busy ? null : () => _checkVerified(),
                    child: _busy
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text("I verified, re-check"),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: (_busy || _cooldown > 0) ? null : _resend,
                    child: Text(
                      _cooldown > 0
                          ? "Resend in $_cooldown s"
                          : "Resend verification email",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                TextButton(
                  onPressed: _busy ? null : _signOut,
                  child: Text(
                    "Sign out",
                    style: TextStyle(color: Colors.white.withOpacity(0.85)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}