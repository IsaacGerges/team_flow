import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:team_flow/core/constants/app_colors.dart';
import 'package:team_flow/core/constants/app_strings.dart';
import 'package:team_flow/features/teams/domain/entities/team_entity.dart';
import 'package:team_flow/features/teams/presentation/cubit/team_cubit.dart';
import 'package:team_flow/features/teams/presentation/cubit/team_state.dart';
import 'package:team_flow/features/teams/presentation/pages/create_team_page.dart';

/// Pre-filled form to edit an existing team.
class UpdateTeamPage extends StatefulWidget {
  final TeamEntity team;

  const UpdateTeamPage({super.key, required this.team});

  @override
  State<UpdateTeamPage> createState() => _UpdateTeamPageState();
}

class _UpdateTeamPageState extends State<UpdateTeamPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late String _selectedCategory;
  late bool _isPrivate;
  String? _logoBase64;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.team.name);
    _descriptionController = TextEditingController(
      text: widget.team.description,
    );
    _selectedCategory = AppStrings.teamCategories.contains(widget.team.category)
        ? widget.team.category
        : AppStrings.teamCategories.first;
    _isPrivate = widget.team.isPrivate;
    _logoBase64 = widget.team.photoUrl;
  }

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
          AppStrings.editTeam,
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
                  AppStrings.saveChanges,
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
          if (state is TeamUpdatedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(AppStrings.teamUpdated),
                backgroundColor: AppColors.success,
              ),
            );
            context.pop();
          } else if (state is TeamLogoPicked) {
            setState(() => _logoBase64 = state.base64Image);
          } else if (state is TeamsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: DottedCircleAvatar(
                    onTap: () => context.read<TeamsCubit>().pickTeamLogo(),
                    photoUrl: _logoBase64,
                  ),
                ),
                const SizedBox(height: 24),
                _FormLabel(label: AppStrings.teamNameLabel),
                const SizedBox(height: 8),
                _FormTextField(
                  controller: _nameController,
                  hint: AppStrings.teamNameHint,
                  maxLength: 50,
                  validator: (val) => val == null || val.trim().isEmpty
                      ? AppStrings.required
                      : null,
                ),
                const SizedBox(height: 20),
                _FormLabel(label: AppStrings.teamDescriptionLabel),
                const SizedBox(height: 8),
                _FormTextField(
                  controller: _descriptionController,
                  hint: AppStrings.teamDescriptionHint,
                  maxLines: 3,
                  maxLength: 200,
                ),
                const SizedBox(height: 20),
                _FormLabel(label: AppStrings.teamCategoryLabel),
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
                _SaveButton(onPressed: () => _submitForm(context)),
                const SizedBox(height: 12),
                _CancelButton(onPressed: () => context.pop()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<TeamsCubit>().updateTeam(
        widget.team.id,
        TeamEntity(
          id: widget.team.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          adminId: widget.team.adminId,
          membersIds: widget.team.membersIds,
          photoUrl: _logoBase64,
          category: _selectedCategory,
          isPrivate: _isPrivate,
          progressPercent: widget.team.progressPercent,
        ),
      );
    }
  }
}

// --- Shared sub-widgets (reused from create_team_page style) ---

class _FormLabel extends StatelessWidget {
  final String label;
  const _FormLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        fontSize: 14,
      ),
    );
  }
}

class _FormTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;

  const _FormTextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
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
              children: const [
                Text(
                  AppStrings.privateTeam,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  AppStrings.privateTeamDesc,
                  style: TextStyle(
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

class _SaveButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _SaveButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.save_outlined),
        label: const Text(
          AppStrings.saveChanges,
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
