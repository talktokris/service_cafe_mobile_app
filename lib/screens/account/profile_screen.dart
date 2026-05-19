import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:serve_cafe_mobile/core/api/api_client.dart';
import 'package:serve_cafe_mobile/core/api/api_endpoints.dart';
import 'package:serve_cafe_mobile/core/auth/auth_provider.dart';
import 'package:serve_cafe_mobile/core/theme/app_theme.dart';
import 'package:serve_cafe_mobile/data/countries.dart';
import 'package:serve_cafe_mobile/utils/phone_input.dart';
import 'package:serve_cafe_mobile/widgets/gradient_app_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _first;
  late final TextEditingController _last;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _address;
  String? _gender;
  String _country = 'Nepal';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final u = context.read<AuthProvider>().user;
    _first = TextEditingController(text: u?.firstName);
    _last = TextEditingController(text: u?.lastName);
    _email = TextEditingController(text: u?.email);
    _phone = TextEditingController(text: u?.phone ?? '+977');
    _address = TextEditingController(text: u?.address);
    _gender = u?.gender;
    if (u?.country != null && u!.country!.isNotEmpty) _country = u.country!;
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _email.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final phone = normalizeNepalPhone(_phone.text);
    if (!isValidNepalPhone(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone must be +977 followed by 9-10 digits')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await context.read<ApiClient>().put(ApiEndpoints.profile, data: {
        'first_name': _first.text.trim(),
        'last_name': _last.text.trim(),
        'email': _email.text.trim(),
        'phone': phone,
        'address': _address.text.trim(),
        'gender': _gender,
        'country': _country,
      });
      await context.read<AuthProvider>().fetchMe();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ApiClient.friendlyError(e))));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: 'Profile', showBack: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Personal Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: 12),
          TextField(controller: _first, decoration: const InputDecoration(labelText: 'First Name', prefixIcon: Icon(Icons.person_outline))),
          const SizedBox(height: 12),
          TextField(controller: _last, decoration: const InputDecoration(labelText: 'Last Name', prefixIcon: Icon(Icons.person_outline))),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _gender,
            decoration: const InputDecoration(labelText: 'Gender', prefixIcon: Icon(Icons.wc_outlined)),
            items: const [
              DropdownMenuItem(value: 'male', child: Text('Male')),
              DropdownMenuItem(value: 'female', child: Text('Female')),
              DropdownMenuItem(value: 'other', child: Text('Other')),
            ],
            onChanged: (v) => setState(() => _gender = v),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: kCountries.contains(_country) ? _country : 'Nepal',
            decoration: const InputDecoration(labelText: 'Country', prefixIcon: Icon(Icons.public)),
            isExpanded: true,
            items: kCountries.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => _country = v ?? 'Nepal'),
          ),
          const SizedBox(height: 20),
          const Text('Contact', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: 12),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email *', prefixIcon: Icon(Icons.email_outlined)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            onChanged: (v) {
              final n = normalizeNepalPhone(v);
              if (_phone.text != n) {
                _phone.value = TextEditingValue(text: n, selection: TextSelection.collapsed(offset: n.length));
              }
            },
            decoration: const InputDecoration(
              labelText: 'Phone (+977)',
              prefixIcon: Icon(Icons.phone_outlined),
              helperText: 'Format: +977XXXXXXXXX',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _address,
            maxLines: 3,
            maxLength: 500,
            decoration: const InputDecoration(labelText: 'Address', prefixIcon: Icon(Icons.home_outlined)),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _save,
              child: _loading
                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }
}
