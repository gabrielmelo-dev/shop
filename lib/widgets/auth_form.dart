import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/exceptions/app_auth_exception.dart';
import 'package:shop/providers/auth.dart';

enum AuthMode { signup, login }

class AuthForm extends StatefulWidget {
  const AuthForm({Key? key}) : super(key: key);

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm>
    with SingleTickerProviderStateMixin {
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  AuthMode _authMode = AuthMode.login;
  final Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  AnimationController? _animationController;
  Animation<double>? _opacityAnimation;
  Animation<Offset>? _slideAnimation;

  bool _isLogin() => _authMode == AuthMode.login;

  // bool _isSignup() => _authMode == AuthMode.signup;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _opacityAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.linear,
      ),
    );

    _slideAnimation = Tween(
      begin: const Offset(0, -1.5),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.linear,
      ),
    );

  }

  @override
  void dispose() {
    super.dispose();
    _animationController?.dispose();
  }

  void _switchAuthMode() {
    setState(() {
      if (_isLogin()) {
        _formKey.currentState?.reset();
        _authMode = AuthMode.signup;
        _animationController?.forward();
      } else {
        _formKey.currentState?.reset();
        _authMode = AuthMode.login;
        _animationController?.reverse();
      }
    });
  }

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('An error has occurred'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          )
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    setState(() => _isLoading = true);

    _formKey.currentState?.save();
    Auth auth = Provider.of(context, listen: false);

    try {
      if (_isLogin()) {
        await auth.login(_authData['email']!, _authData['password']!);
      } else {
        await auth.signup(_authData['email']!, _authData['password']!);
      }
    } on AppAuthException catch (error) {
      _showErrorDialog(error.toString());
    } catch (error) {
      _showErrorDialog('An unexpected error occurred');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
        padding: const EdgeInsets.all(16),
        height: _isLogin() ? 330 : 410,
        width: deviceSize.width * 0.75,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'E-mail'),
                keyboardType: TextInputType.emailAddress,
                onSaved: (email) => _authData['email'] = email ?? '',
                validator: (email) {
                  bool emailValid = RegExp(
                          r"[a-z0-9!#$%&'*+\/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+\/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                      .hasMatch(email!);
                  if (email.trim().isEmpty || !emailValid) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                keyboardType: TextInputType.text,
                obscureText: true,
                controller: _passwordController,
                onSaved: (password) => _authData['password'] = password ?? '',
                validator: (password) {
                  bool passwordValid = RegExp(
                          r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$")
                      .hasMatch(password!);
                  if (password.isEmpty || !passwordValid) {
                    return 'Enter a valid password';
                  }
                  return null;
                },
              ),
                AnimatedContainer(
                  constraints: BoxConstraints(
                    minHeight: _isLogin() ? 0 : 60,
                    maxHeight:  _isLogin() ? 0 : 120,
                  ),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.linear,
                  child: FadeTransition(
                    opacity: _opacityAnimation!,
                    child: SlideTransition(
                      position: _slideAnimation!,
                      child: TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Confirm password'),
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        validator: _isLogin()
                            ? null
                            : (password) {
                                if (password != _passwordController.text) {
                                  return 'Passwords don\'t match';
                                }
                                return null;
                              },
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 8,
                        ),
                      ),
                      child: Text(_isLogin() ? 'Login' : 'Sign up'),
                    ),
              const Spacer(),
              TextButton(
                onPressed: _switchAuthMode,
                child: Text(
                    _isLogin() ? 'Don\'t have an account? Sign up' : 'Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
