import 'package:flutter/material.dart';

import 'summary_card.dart';

void main() => runApp(const MyApp());

const groups = ['IT-2301', 'IT-2302', 'IT-2303', 'IT-2304', 'IT-2305'];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
    home: const SignUpScreen(),
  );
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _birthText = TextEditingController();
  final _emailFocus = FocusNode();

  String? _group;
  DateTime? _birth;
  bool _agreed = false;
  bool _done = false;
  int _passwordLength = 0;

  @override
  void dispose() {
    for (final controller in [_name, _email, _password, _confirm, _birthText]) {
      controller.dispose();
    }
    _emailFocus.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created')),
      );
      setState(() {
        _done = true;
      });
    }
  }

  Future<void> _chooseBirth() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _birth ?? DateTime(2005),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (selected == null) {
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _birth = selected;
      final day = selected.day.toString().padLeft(2, '0');
      final month = selected.month.toString().padLeft(2, '0');
      _birthText.text = '$day.$month.${selected.year}';
    });
  }

  void _startOver() {
    setState(() {
      for (final controller in [_name, _email, _password, _confirm, _birthText]) {
        controller.clear();
      }
      _group = null;
      _birth = null;
      _agreed = false;
      _passwordLength = 0;
      _done = false;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sign up')),
    body: _done
        ? SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SummaryCard(
                  name: _name.text.trim(),
                  email: _email.text.trim(),
                  group: _group ?? '',
                  birthDate: _birthText.text,
                ),
                TextButton(onPressed: _startOver, child: const Text('Start over')),
              ],
            ),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'Name'),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                    onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                    validator: (value) => (value ?? '').trim().length < 2
                        ? 'Name is too short'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _email,
                    focusNode: _emailFocus,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'name@kbtu.kz',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    textInputAction: TextInputAction.next,
                    onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                    validator: (value) {
                      final email = (value ?? '').trim();
                      final at = email.indexOf('@');
                      if (at < 1 || !email.substring(at + 1).contains('.')) {
                        return 'Email looks wrong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      helperText: 'At least 8 characters',
                    ),
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    onChanged: (value) => setState(() => _passwordLength = value.length),
                    onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                    validator: (value) => (value ?? '').length < 8
                        ? 'Password is too short'
                        : null,
                  ),
                  Text('$_passwordLength of 8'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _confirm,
                    decoration: const InputDecoration(labelText: 'Confirm password'),
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) {
                      if (_agreed) {
                        _submit();
                      }
                    },
                    onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                    validator: (value) => value != _password.text
                        ? 'Passwords do not match'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _group,
                    decoration: const InputDecoration(labelText: 'Group'),
                    items: [
                      for (final group in groups)
                        DropdownMenuItem(value: group, child: Text(group)),
                    ],
                    onChanged: (value) => setState(() => _group = value),
                    validator: (value) => value == null ? 'Choose a group' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _birthText,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Date of birth',
                      suffixIcon: Icon(Icons.calendar_month),
                    ),
                    onTap: _chooseBirth,
                    onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                    validator: (_) => _birth == null ? 'Choose a date' : null,
                  ),
                  CheckboxListTile(
                    title: const Text('I agree to the rules'),
                    value: _agreed,
                    onChanged: (value) => setState(() => _agreed = value ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _agreed ? _submit : null,
                    child: const Text('Sign up'),
                  ),
                ],
              ),
            ),
          ),
  );
}
