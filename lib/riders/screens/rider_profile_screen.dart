import 'package:bokku_mart/features/auth/presentation/bloc/auth_state.dart';
import 'package:bokku_mart/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/repository_providers.dart';

class RiderProfileScreen extends ConsumerWidget {
  const RiderProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState is Authenticated ? authState.user : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (user != null) ...[
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Name'),
              subtitle: Text(user.fullName),
            ),
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text('Email'),
              subtitle: Text(user.email),
            ),
            ListTile(
              leading: const Icon(Icons.phone_outlined),
              title: const Text('Phone'),
              subtitle: Text(user.phoneNumber),
            ),
            ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: const Text('Rider ID'),
              subtitle: Text(user.customerId),
            ),
          ],
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sign out', style: TextStyle(color: Colors.red)),
            onTap: () async {
              // 1) Clear tokens via the repository directly.
              await ref.read(authRepositoryProvider).signOut();

              // 2) The DioClient will now 401 on next call, and
              //    CheckAuthStatusEvent on next app boot will return
              //    Unauthenticated. To force an immediate UI change
              //    without depending on auth_event.dart, we manually
              //    push the router to /signin.
              if (context.mounted) {
                context.go('/signin');
              }
            },
          ),
        ],
      ),
    );
  }
}
