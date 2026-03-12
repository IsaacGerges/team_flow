import 'package:flutter/material.dart';
import 'package:team_flow/core/constants/app_colors.dart';

/// A redesigned social sign-in button matching the Stitch mockup.
class SocialLoginButton extends StatelessWidget {
  final String label;
  final String iconPath;
  final VoidCallback onPressed;

  const SocialLoginButton({
    super.key,
    required this.label,
    required this.iconPath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56, // Fixed height to match form inputs
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFE2E8F0)), // slate-200
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDkkWWNkuLENHev-vjmw78nkMBVrzo2HDacEAiJ_bB2a87CmpNFirJIxyCBSXRvy-_GsgDAG9_jPPcAuVeOB-xq4c-bvqRyEvOhDeMLzYenMyxripeps8xJ7bkS5InmvW2AEDvV4ndMQpsUssaMURz5cDDtlnK7B9E20k-lzdHXPnh4ZXLQEgtqjGsrNziYzNIA46IbGNh9bpytrYyP4DY8lABfVG9tZdsEsvEUewP-F4p_UhMxPP9yqce_bqp_RIw93g4MAHDoo9M',
              height: 20,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.g_mobiledata, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
