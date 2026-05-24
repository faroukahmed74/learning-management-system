import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/app_settings_controls.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/responsive_content.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bioController;
  late final TextEditingController _nativeController;
  late final TextEditingController _targetController;
  bool _saving = false;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _bioController = TextEditingController();
    _nativeController = TextEditingController();
    _targetController = TextEditingController();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = await ref.read(currentUserProvider.future);
    if (user == null || !mounted) return;
    setState(() {
      _nameController.text = user.fullName;
      _phoneController.text = user.phone ?? '';
      _bioController.text = user.bio ?? '';
      _nativeController.text = user.nativeLanguage ?? '';
      _targetController.text = user.targetLanguage ?? '';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _nativeController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final user = await ref.read(currentUserProvider.future);
      if (user == null) throw Exception(context.l10n.notSignedIn);

      await ref.read(profileRepositoryProvider).updateProfile(
            userId: user.id,
            fullName: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            bio: _bioController.text.trim(),
            nativeLanguage: _nativeController.text.trim(),
            targetLanguage: _targetController.text.trim(),
          );
      ref.invalidate(currentUserProvider);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickAvatar() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) return;

    setState(() => _uploading = true);
    try {
      final user = await ref.read(currentUserProvider.future);
      if (user == null) return;

      final url = await ref.read(profileRepositoryProvider).uploadAvatar(
            userId: user.id,
            bytes: bytes,
            fileName: file.name,
          );
      await ref.read(profileRepositoryProvider).updateProfile(
            userId: user.id,
            avatarUrl: url,
          );
      ref.invalidate(currentUserProvider);
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editProfile),
        actions: [
          const AppSettingsControls(compact: true),
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.save),
          ),
        ],
      ),
      body: userAsync.when(
        loading: () => Center(child: Text(l10n.loading)),
        error: (e, _) => ErrorView(error: e),
        data: (user) {
          if (user == null) return Center(child: Text(l10n.notSignedIn));

          return ResponsiveContent(
            maxWidth: 480,
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundImage: user.avatarUrl != null
                              ? NetworkImage(user.avatarUrl!)
                              : null,
                          child: user.avatarUrl == null
                              ? Text(
                                  user.fullName.isNotEmpty
                                      ? user.fullName[0].toUpperCase()
                                      : '?',
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IconButton.filled(
                            onPressed: _uploading ? null : _pickAvatar,
                            icon: _uploading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.camera_alt, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: l10n.fullName),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? l10n.fieldRequired(l10n.fullName)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: user.email,
                    readOnly: true,
                    decoration: InputDecoration(labelText: l10n.email),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(labelText: l10n.phone),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _bioController,
                    decoration: InputDecoration(labelText: l10n.bio),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nativeController,
                    decoration: InputDecoration(labelText: l10n.nativeLanguage),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _targetController,
                    decoration: InputDecoration(labelText: l10n.targetLanguage),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
