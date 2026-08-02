import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await action();
    } on AuthException catch (e) {
      if (mounted) {
        setState(() => _error = e.message);
      }
    } catch (_) {
      if (mounted)
        setState(() => _error = 'Không thể kết nối. Vui lòng thử lại.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              scheme.primaryContainer,
              scheme.surface,
              scheme.secondaryContainer,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Card(
                elevation: 0,
                color: scheme.surface.withValues(alpha: .92),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: scheme.primary,
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          color: scheme.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Định hướng tương lai',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Trợ lý hướng nghiệp dành cho học sinh THPT',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 28),
                      TextField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.mail_outline),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _password,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Mật khẩu',
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: scheme.error),
                          ),
                        ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _loading
                              ? null
                              : () => _run(() async {
                                  await Supabase.instance.client.auth
                                      .signInWithPassword(
                                        email: _email.text.trim(),
                                        password: _password.text,
                                      );
                                }),
                          icon: const Icon(Icons.login),
                          label: const Text('Đăng nhập'),
                        ),
                      ),
                      TextButton(
                        onPressed: _loading
                            ? null
                            : () => _run(() async {
                                final response = await Supabase
                                    .instance
                                    .client
                                    .auth
                                    .signUp(
                                      email: _email.text.trim(),
                                      password: _password.text,
                                    );
                                if (response.session == null) {
                                  await Supabase.instance.client.auth
                                      .signInWithPassword(
                                        email: _email.text.trim(),
                                        password: _password.text,
                                      );
                                }
                              }),
                        child: const Text('Tạo tài khoản mới'),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _loading
                              ? null
                              : () => _run(() async {
                                  await Supabase.instance.client.auth
                                      .signInAnonymously();
                                }),
                          icon: const Icon(Icons.person_outline),
                          label: const Text('Dùng với tư cách khách'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Chế độ khách không lưu hồ sơ của bạn.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
