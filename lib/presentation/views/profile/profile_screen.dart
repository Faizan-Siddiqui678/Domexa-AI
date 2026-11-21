import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../widgets/common_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _url;

  @override
  void initState() {
    super.initState();
    _url = TextEditingController(text: context.read<ProfileViewModel>().baseUrl);
  }

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    final auth = context.read<AuthViewModel>();
    final nav = Navigator.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('Your saved projects stay in your account.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Stay signed in')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Sign out')),
        ],
      ),
    );
    if (ok == true) {
      await auth.signOut();
      nav.popUntil((r) => r.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final vm = context.watch<ProfileViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile and settings')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        SectionCard(
          title: 'Account',
          icon: Icons.person_outline,
          child: auth.isSignedIn
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(auth.displayName, style: Theme.of(context).textTheme.titleMedium),
            Text(auth.user?.email ?? '', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            OutlinedButton.icon(onPressed: _signOut, icon: const Icon(Icons.logout), label: const Text('Sign out')),
          ])
              : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('You are using Domexa as a guest. Sign in to save projects.'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () async {
                final nav = Navigator.of(context);
                await auth.signOut(); // ends guest mode -> login screen
                nav.popUntil((r) => r.isFirst);
              },
              child: const Text('Sign in or create account'),
            ),
          ]),
        ),
        SectionCard(
          title: 'Server address',
          icon: Icons.dns_outlined,
          subtitle: 'The computer running the Domexa backend. On a real phone use its Wi-Fi IP, e.g. http://192.168.1.20:8000',
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            TextField(controller: _url, keyboardType: TextInputType.url, decoration: const InputDecoration(labelText: 'Server URL')),
            const SizedBox(height: 12),
            Wrap(spacing: 10, runSpacing: 10, children: [
              FilledButton.tonal(
                onPressed: vm.isLoading
                    ? null
                    : () async {
                  await vm.saveServer(_url.text);
                  _url.text = vm.baseUrl;
                  vm.testConnection();
                },
                child: const Text('Save and test'),
              ),
              OutlinedButton(onPressed: vm.isLoading ? null : vm.testConnection, child: const Text('Test only')),
            ]),
            const SizedBox(height: 12),
            if (vm.isLoading) const LinearProgressIndicator(),
            if (vm.hasError) InfoNote(vm.errorMessage ?? 'Could not connect.', tone: NoteTone.error, title: 'Not connected'),
            for (final (text, ok) in vm.healthLines) InfoNote(text, tone: ok ? NoteTone.success : NoteTone.warning),
          ]),
        ),
        const SectionCard(
          title: 'About',
          icon: Icons.info_outline,
          child: Text('Domexa 2.0 - AI house planning for Pakistan.\nCOMSATS University Islamabad, Sahiwal Campus - Final Year Project, BS Software Engineering.'),
        ),
        const SizedBox(height: 12),
        Text('Material and cost figures are estimates for planning only.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
      ]),
    );
  }
}