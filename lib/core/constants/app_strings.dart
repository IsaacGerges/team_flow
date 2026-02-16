/// AppStrings - جميع نصوص التطبيق في مكان واحد
class AppStrings {
  // منع إنشاء instance من الكلاس (static only)
  AppStrings._();

  // App General
  static const String appName = 'TeamFlow';
  static const String appSlogan = 'Manage your team flow';

  // Authentication
  static const String welcomeBack = 'Welcome Back! 👋';
  static const String loginSubtitle = 'Login to manage your team flow.';
  static const String createAccount = 'Create Account';
  static const String alreadyHaveAccount = "Already have an account? Login";
  static const String dontHaveAccount = "Don't have an account?";

  // Form Fields
  static const String email = 'Email';
  static const String emailAddress = 'Email Address';
  static const String password = 'Password';
  static const String fullName = 'Full Name';

  // Buttons
  static const String login = 'Login';
  static const String signUp = 'Sign Up';
  static const String signInWithGoogle = 'Sign in with Google';
  static const String forgotPassword = 'Forgot Password?';
  static const String logout = 'Logout';

  // Validation Messages
  static const String required = 'Required';
  static const String enterYourName = 'Please enter your name';
  static const String enterValidEmail = 'Please enter a valid email';
  static const String passwordMinLength = 'Password must be at least 6 chars';

  // Success Messages
  static const String accountCreated = 'Account Created Successfully! 🎉';
  static const String loginSuccess = 'Login Successful! 🎉';

  // Home
  static const String home = 'Home';
  static const String welcomeToTeamFlow = 'Welcome to TeamFlow! 🚀';

  // General
  static const String or = 'OR';
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';
}
