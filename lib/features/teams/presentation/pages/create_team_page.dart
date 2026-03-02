import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:team_flow/core/constants/app_colors.dart';
import 'package:team_flow/core/constants/app_strings.dart';
import 'package:team_flow/core/helpers/image_helper.dart';
import 'package:team_flow/features/teams/domain/entities/team_entity.dart';
import 'package:team_flow/features/teams/presentation/cubit/team_cubit.dart';
import 'package:team_flow/features/teams/presentation/cubit/team_state.dart';

/// Create a new team with full details.
class CreateTeamPage extends StatefulWidget {
  const CreateTeamPage({super.key});

  @override
  State<CreateTeamPage> createState() => _CreateTeamPageState();
}

class _CreateTeamPageState extends State<CreateTeamPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = AppStrings.teamCategories.first;
  bool _isPrivate = false;
  String? _logoBase64;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundScreen,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundScreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          AppStrings.createNewTeam,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          BlocBuilder<TeamsCubit, TeamsState>(
            builder: (context, state) {
              if (state is TeamsLoading) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              return TextButton(
                onPressed: () => _submitForm(context),
                child: const Text(
                  'Save',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocListener<TeamsCubit, TeamsState>(
        listener: (context, state) {
          if (state is TeamCreatedSuccess) {
            _showSnackBar(context, AppStrings.teamCreated, AppColors.success);
            context.pop();
          } else if (state is TeamLogoPicked) {
            setState(() => _logoBase64 = state.base64Image);
          } else if (state is TeamsError) {
            _showSnackBar(context, state.message, AppColors.error);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LogoUploadSection(logoBase64: _logoBase64),
                const SizedBox(height: 24),
                _buildLabel(AppStrings.teamName),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _nameController,
                  hint: AppStrings.teamNameHint,
                  maxLength: 50,
                  validator: (val) => val == null || val.trim().isEmpty
                      ? AppStrings.required
                      : null,
                ),
                const SizedBox(height: 20),
                _buildLabel(AppStrings.teamDescriptionLabel),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _descriptionController,
                  hint: AppStrings.teamDescriptionHint,
                  maxLines: 3,
                  maxLength: 200,
                ),
                const SizedBox(height: 20),
                _buildLabel(AppStrings.teamCategoryLabel),
                const SizedBox(height: 8),
                _CategoryDropdown(
                  value: _selectedCategory,
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                ),
                const SizedBox(height: 24),
                _PrivacyToggle(
                  isPrivate: _isPrivate,
                  onChanged: (val) => setState(() => _isPrivate = val),
                ),
                const SizedBox(height: 32),
                _CreateTeamButton(onPressed: () => _submitForm(context)),
                const SizedBox(height: 12),
                _CancelButton(onPressed: () => context.pop()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        fontSize: 14,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textHint),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        filled: true,
        fillColor: AppColors.cardBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        context.read<TeamsCubit>().createTeam(
          TeamEntity(
            id: '',
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            adminId: user.uid,
            membersIds: [user.uid],
            category: _selectedCategory,
            isPrivate: _isPrivate,
            photoUrl: _logoBase64,
          ),
        );
      }
    }
  }

  void _showSnackBar(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }
}

class _LogoUploadSection extends StatelessWidget {
  final String? logoBase64;
  const _LogoUploadSection({this.logoBase64});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          DottedCircleAvatar(
            photoUrl: logoBase64,
            onTap: () => context.read<TeamsCubit>().pickTeamLogo(),
          ),
          const SizedBox(height: 8),
          const Text(
            AppStrings.uploadLogo,
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dashed-border circle for team logo upload.
class DottedCircleAvatar extends StatelessWidget {
  final VoidCallback onTap;
  final String? photoUrl;

  const DottedCircleAvatar({super.key, required this.onTap, this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primaryBlue,
            width: 2,
            style: BorderStyle.solid,
          ),
          color: AppColors.primaryBlueLight,
        ),
        child: photoUrl != null
            ? ClipOval(
                child: Image(
                  image: ImageHelper.getProvider(photoUrl)!,
                  fit: BoxFit.cover,
                ),
              )
            : const Icon(
                Icons.camera_alt_outlined,
                color: AppColors.primaryBlue,
                size: 32,
              ),
      ),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const _CategoryDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        filled: true,
        fillColor: AppColors.cardBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      items: AppStrings.teamCategories
          .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
          .toList(),
    );
  }
}

class _PrivacyToggle extends StatelessWidget {
  final bool isPrivate;
  final ValueChanged<bool> onChanged;

  const _PrivacyToggle({required this.isPrivate, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryBlueLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.lock_outline,
              color: AppColors.primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppStrings.privateTeam,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppStrings.privateTeamDesc,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isPrivate,
            onChanged: onChanged,
            activeThumbColor: AppColors.primaryBlue,
          ),
        ],
      ),
    );
  }
}

class _CreateTeamButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CreateTeamButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.check),
        label: const Text(
          AppStrings.createTeam,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

class _CancelButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CancelButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          side: const BorderSide(color: AppColors.divider),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(AppStrings.cancel, style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
