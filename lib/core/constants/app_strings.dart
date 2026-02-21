/// AppStrings — all app text in one place for easy maintenance.
class AppStrings {
  AppStrings._();

  // App General
  static const String appName = 'TeamFlow';
  static const String appSlogan = 'Manage your team flow';

  // Authentication
  static const String welcomeBack = 'Welcome Back! 👋';
  static const String loginSubtitle = 'Login to manage your team flow.';
  static const String createAccount = 'Create Account';
  static const String alreadyHaveAccount = 'Already have an account? Login';
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
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String saveChanges = 'Save Changes';

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

  // Teams — General
  static const String myTeams = 'My Teams 🚀';
  static const String newTeam = 'New Team';
  static const String teamName = 'Team Name';
  static const String teamNameHint = 'e.g. Flutter Squad';
  static const String members = 'Members';

  // Teams — Pages
  static const String createNewTeam = 'Create New Team';
  static const String createTeam = 'Create Team';
  static const String editTeam = 'Edit Team';

  // Teams — Delete Dialog
  static const String deleteTeam = 'Delete Team';
  static const String deleteTeamConfirmation =
      'Are you sure you want to delete';

  // Teams — Snackbars
  static const String teamCreated = 'Team created successfully 🎉';
  static const String teamUpdated = 'Team updated successfully ✅';
  static const String teamDeleted = 'Team deleted successfully ✅';

  // Teams — Empty State
  static const String noTeamsYet = 'No teams yet.';
  static const String noTeamsHint = 'Tap + to create one!';

  // General
  static const String or = 'OR';
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String errorPrefix = 'Error: ';

  // Error Messages
  static const String checkInternetConnection =
      'Please check your internet connection';
  static const String unexpectedError = 'Unexpected error, please try again';
}
