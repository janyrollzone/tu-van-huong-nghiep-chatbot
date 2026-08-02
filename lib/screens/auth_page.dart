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
  final _confirmPassword = TextEditingController();
  bool _loading = false;
  bool _isRegistering = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  bool _validate({required bool includeConfirmation}) {
    final email = _email.text.trim();
    if (!email.contains('@')) {
      setState(() => _error = 'Vui lòng nhập địa chỉ email hợp lệ.');
      return false;
    }
    if (_password.text.length < 6) {
      setState(() => _error = 'Mật khẩu cần có ít nhất 6 ký tự.');
      return false;
    }
    if (includeConfirmation && _password.text != _confirmPassword.text) {
      setState(() => _error = 'Xác nhận mật khẩu chưa trùng khớp.');
      return false;
    }
    return true;
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await action();
    } on AuthException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Không thể kết nối. Vui lòng thử lại.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signIn() async {
    if (!_validate(includeConfirmation: false)) return;
    await _run(
      () => Supabase.instance.client.auth.signInWithPassword(
        email: _email.text.trim(),
        password: _password.text,
      ),
    );
  }

  Future<void> _signUp() async {
    if (!_validate(includeConfirmation: true)) return;
    await _run(() async {
      final response = await Supabase.instance.client.auth.signUp(
        email: _email.text.trim(),
        password: _password.text,
      );
      if (response.session == null && mounted) {
        setState(() {
          _error = 'Tài khoản đã tạo. Hãy xác nhận email trước khi đăng nhập.';
          _isRegistering = false;
        });
      }
    });
  }

  void _showRegisterForm() {
    setState(() {
      _isRegistering = true;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final title = _isRegistering ? 'Tạo tài khoản' : 'Định hướng tương lai';
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
            padding: const EdgeInsets.all(24),
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
                        title,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isRegistering
                            ? 'Tạo tài khoản để lưu phiên tư vấn của bạn'
                            : 'Trợ lý hướng nghiệp dành cho học sinh THPT',
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
                      if (_isRegistering) ...[
                        const SizedBox(height: 12),
                        TextField(
                          controller: _confirmPassword,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Xác nhận mật khẩu',
                            prefixIcon: Icon(Icons.lock_reset_outlined),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
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
                              : (_isRegistering ? _signUp : _signIn),
                          icon: Icon(
                            _isRegistering
                                ? Icons.person_add_alt_1
                                : Icons.login,
                          ),
                          label: Text(
                            _isRegistering
                                ? 'Đăng ký và vào chat'
                                : 'Đăng nhập',
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _loading
                            ? null
                            : () {
                                if (_isRegistering) {
                                  setState(() {
                                    _isRegistering = false;
                                    _error = null;
                                  });
                                } else {
                                  _showRegisterForm();
                                }
                              },
                        child: Text(
                          _isRegistering
                              ? 'Quay lại đăng nhập'
                              : 'Tạo tài khoản mới',
                        ),
                      ),
                      if (!_isRegistering) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _loading
                                ? null
                                : () => _run(
                                    () => Supabase.instance.client.auth
                                        .signInAnonymously(),
                                  ),
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
