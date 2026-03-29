import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:team_flow/core/constants/app_colors.dart';
import 'package:team_flow/core/constants/app_strings.dart';
import 'package:team_flow/features/teams/domain/entities/team_entity.dart';
import 'package:team_flow/features/teams/presentation/cubit/team_cubit.dart';
import 'package:team_flow/features/teams/presentation/cubit/team_state.dart';
import 'package:uuid/uuid.dart';

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
  Uint8List? _logoBytes;
  String? _submissionId;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_resetSubmissionId);
    _descriptionController.addListener(_resetSubmissionId);
  }

  void _resetSubmissionId() {
    if (_submissionId != null) {
      setState(() => _submissionId = null);
    }
  }

  void _updateCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _submissionId = null;
    });
  }

  void _updatePrivacy(bool value) {
    setState(() {
      _isPrivate = value;
      _submissionId = null;
    });
  }

  @override
  void dispose() {
    _nameController.removeListener(_resetSubmissionId);
    _descriptionController.removeListener(_resetSubmissionId);
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.slate800,
            size: 18,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          AppStrings.createNewTeam,
          style: TextStyle(
            color: AppColors.slate800,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocListener<TeamsCubit, TeamsState>(
        listener: (context, state) {
          if (state is TeamCreatedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(AppStrings.teamCreatedSuccess),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.pop();
          } else if (state is TeamLogoPicked) {
            setState(() {
              _logoBytes = state.imageBytes;
              _submissionId = null;
            });
          } else if (state is TeamsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLogoUploadSection(),
                const SizedBox(height: 32),
                _buildLabel(AppStrings.teamNameLabel),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _nameController,
                  hint: AppStrings.teamNameHint,
                  validator: (val) => val == null || val.trim().isEmpty
                      ? AppStrings.requiredField
                      : null,
                ),
                const SizedBox(height: 24),
                _buildLabel(AppStrings.teamDescriptionLabel),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _descriptionController,
                  hint: AppStrings.teamDescriptionHint,
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                _buildLabel(AppStrings.teamCategoryLabel),
                const SizedBox(height: 10),
                _buildCategoryDropdown(),
                const SizedBox(height: 32),
                _buildPrivacyToggle(),
                const SizedBox(height: 48),
                _buildCreateButton(),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoUploadSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.slate100, width: 8),
                ),
              ),
              GestureDetector(
                onTap: () => context.read<TeamsCubit>().pickTeamLogo(),
                child: CircleAvatar(
                  radius: 46,
                  backgroundColor: AppColors.lightGray.withValues(alpha: -0.8),
                  child: _logoBytes != null
                      ? ClipOval(
                          child: Image.memory(
                            _logoBytes!,
                            width: 92,
                            height: 92,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(
                          Icons.add_a_photo_rounded,
                          color: AppColors.primaryBlue,
                          size: 32,
                        ),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => context.read<TeamsCubit>().pickTeamLogo(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 3),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: AppColors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            AppStrings.teamLogo,
            style: TextStyle(
              color: AppColors.slate500,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: AppColors.slate500,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: AppColors.slate800,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: AppColors.slate400,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            vertical: maxLines > 1 ? 12 : 14,
            horizontal: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return GestureDetector(
      onTap: () => _showCategoryPicker(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.slate50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.slate200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.blueBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getCategoryIcon(_selectedCategory),
                color: AppColors.primaryBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _selectedCategory,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.slate800,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.slate500,
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.slate200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              AppStrings.selectCategory,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.slate800,
              ),
            ),
            const SizedBox(height: 24),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: AppStrings.teamCategories.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final category = AppStrings.teamCategories[index];
                  final isSelected = category == _selectedCategory;
                  return InkWell(
                    onTap: () {
                      _updateCategory(category);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.blueBg : AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryBlue
                              : AppColors.slate200,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryBlue
                                  : AppColors.slate100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getCategoryIcon(category),
                              color: isSelected
                                  ? AppColors.white
                                  : AppColors.slate500,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            category,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              fontSize: 16,
                              color: isSelected
                                  ? AppColors.primaryBlue
                                  : AppColors.slate800,
                            ),
                          ),
                          const Spacer(),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.primaryBlue,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    return switch (category) {
      'Development' => Icons.code_rounded,
      'Design' => Icons.palette_outlined,
      'Marketing' => Icons.campaign_outlined,
      'Sales' => Icons.trending_up_rounded,
      'HR' => Icons.groups_outlined,
      _ => Icons.more_horiz_rounded,
    };
  }

  Widget _buildPrivacyToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.blueBorder,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.lock_person_rounded,
              color: AppColors.primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppStrings.privateTeam,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppColors.slate800,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  AppStrings.privateTeamDescription,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.slate500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isPrivate,
            onChanged: _updatePrivacy,
            activeThumbColor: AppColors.primaryBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return BlocBuilder<TeamsCubit, TeamsState>(
      builder: (context, state) {
        final isSubmitting = state is TeamCreateSubmitting;
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isSubmitting ? null : () => _submitForm(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              shadowColor: AppColors.primaryBlue.withValues(alpha: 0.3),
            ),
            child: isSubmitting
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Creating...',
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                    ],
                  )
                : const Text(
                    AppStrings.createTeam,
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
          ),
        );
      },
    );
  }

  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Generate a stable submission ID if we don't have one yet
        _submissionId ??= const Uuid().v4();

        context.read<TeamsCubit>().createTeam(
              TeamEntity(
                id: _submissionId!,
                name: _nameController.text.trim(),
                description: _descriptionController.text.trim(),
                adminId: user.uid,
                membersIds: [user.uid],
                category: _selectedCategory,
                isPrivate: _isPrivate,
                photoUrl: null,
              ),
              logoBytes: _logoBytes,
            );
      }
    }
  }
}
