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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1E293B),
            size: 18,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Create New Team',
          style: TextStyle(
            color: Color(0xFF1E293B),
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
                content: Text('Team created successfully'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
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
                _buildLabel('TEAM NAME'),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _nameController,
                  hint: 'e.g. Design Team',
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 24),
                _buildLabel('DESCRIPTION'),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _descriptionController,
                  hint: 'What does this team do?',
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                _buildLabel('CATEGORY'),
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
                  border: Border.all(color: const Color(0xFFF1F5F9), width: 8),
                ),
              ),
              GestureDetector(
                onTap: () => context.read<TeamsCubit>().pickTeamLogo(),
                child: CircleAvatar(
                  radius: 46,
                  backgroundColor: const Color(0xFFF8FAFC),
                  child: _logoBase64 != null
                      ? ClipOval(
                          child: Image(
                            image: ImageHelper.getProvider(_logoBase64)!,
                            width: 92,
                            height: 92,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(
                          Icons.add_a_photo_rounded,
                          color: Color(0xFF2563EB),
                          size: 32,
                        ),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Team Logo',
            style: TextStyle(
              color: Color(0xFF64748B),
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
        color: Color(0xFF64748B),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: Color(0xFF1E293B),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            vertical: maxLines > 1 ? 12 : 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          value: _selectedCategory,
          onChanged: (val) {
            if (val != null) setState(() => _selectedCategory = val);
          },
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF64748B),
          ),
          decoration: const InputDecoration(border: InputBorder.none),
          items: AppStrings.teamCategories
              .map(
                (cat) => DropdownMenuItem(
                  value: cat,
                  child: Text(
                    cat,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildPrivacyToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.lock_person_rounded,
              color: Color(0xFF2563EB),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Private Team',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Only invited members can join',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isPrivate,
            onChanged: (val) => setState(() => _isPrivate = val),
            activeColor: const Color(0xFF2563EB),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _submitForm(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: const Color(0xFF2563EB).withValues(alpha: 0.3),
        ),
        child: const Text(
          'Create Team',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
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
}
