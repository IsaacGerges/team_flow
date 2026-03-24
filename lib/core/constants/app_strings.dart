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
  static const String confirmPassword = 'Confirm Password';
  static const String acceptTerms = 'I accept the Terms & Conditions';

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

  // Home Dashboard
  static const String goodMorning = 'Good Morning';
  static const String goodAfternoon = 'Good Afternoon';
  static const String goodEvening = 'Good Evening';
  static const String letsCheckUpdates = "Let's check your updates";
  static const String recentTasks = 'Recent Tasks';
  static const String seeAll = 'See All';
  static const String noRecentTasks = 'No recent tasks';
  static const String createTask = 'Create a Task';
  static const String totalTasks = 'Total Tasks';
  static const String pending = 'Pending';
  static const String completed = 'Completed';
  static const String seeAllSmall = 'See all';

  // Bottom Nav
  static const String homeNav = 'Home';
  static const String tasksNav = 'Tasks';
  static const String teamsNav = 'Teams';
  static const String profileNav = 'Profile';
  static const String alertsNav = 'Alerts';

  // Notifications Feature
  static const String notifications = 'Notifications';
  static const String markAllAsRead = 'Mark all as read';
  static const String filterAll = 'All';
  static const String filterUnread = 'Unread';
  static const String filterTeams = 'Teams';
  static const String filterTasks = 'Tasks';
  static const String filterMentions = 'Mentions';
  static const String today = 'Today';
  static const String yesterday = 'Yesterday';
  static const String reply = 'Reply';
  static const String viewTaskLabel = 'View Task';
  static const String snooze = 'Snooze';
  static const String accept = 'Accept';
  static const String decline = 'Decline';
  static const String noNotifications = 'No notifications yet';
  static const String noNotificationsHint = "You're all caught up! 🎉";

  // Teams — General
  static const String myTeams = 'My Teams';
  static const String newTeam = 'New Team';
  static const String teamName = 'Team Name *';
  static const String teamNameHint = 'e.g. Engineering Squad';
  static const String teamNameLabel = 'Team Name';
  static const String teamDescriptionLabel = 'Description';
  static const String teamDescriptionHint = "What is this team's purpose?";
  static const String teamCategoryLabel = 'Category';
  static const String selectCategory = 'Select Category...';
  static const String privateTeam = 'Private Team';
  static const String privateTeamDesc =
      "Only invited members can view this team's projects and discussions.";
  static const String uploadLogo = 'Upload Logo';
  static const String members = 'Members';
  static const String activeTasks = 'Active Tasks';
  static const String activeTasksShort = 'Active';
  static const String completedShort = 'Complete';
  static const String progress = 'Progress';

  // Teams — Pages
  static const String createNewTeam = 'Create New Team';
  static const String createTeam = 'Create Team';
  static const String editTeam = 'Edit Team';
  static const String teamDetailsTitle = 'Team Details';
  static const String addMembersTitle = 'Add Members';
  static const String addMembersButton = 'Add Members to Team';

  // Teams — Tabs
  static const String membersTab = 'Members';
  static const String tasksTab = 'Tasks';
  static const String chatTab = 'Chat';

  // Teams — Members
  static const String inviteNewMember = '+ Invite New Member';
  static const String searchMembers = 'Search team members...';
  static const String searchByEmailOrName = 'Search by name or email...';
  static const String inviteByEmail = 'Invite by Email';
  static const String suggestedPeople = 'Suggested People';
  static const String viewAll = 'View All';
  static const String selected = 'Selected';
  static const String clearAll = 'Clear All';
  static const String memberAdded = 'Member added successfully ✅';
  static const String memberRemoved = 'Member removed successfully';
  static const String noMembersYet = 'No members yet.';
  static const String teamLeads = 'Team Leads';
  static const String latestTaskUpdate = 'Latest Task Update';
  static const String adminRole = 'Admin';
  static const String memberRole = 'Member';

  // Teams — Chat
  static const String chatComingSoon = 'Team chat coming soon... 💬';

  // Teams — Delete Dialog
  static const String deleteTeam = 'Delete Team';
  static const String deleteTeamConfirmation =
      'Are you sure you want to delete';

  // Teams — Snackbars
  static const String teamCreated = 'Team created successfully 🎉';
  static const String teamUpdated = 'Team updated successfully ✅';
  static const String teamDeleted = 'Team deleted successfully ✅';

  // Teams — Category options
  static const List<String> teamCategories = [
    'Development',
    'Design',
    'Marketing',
    'Sales',
    'HR',
  ];

  // Teams — Empty State
  static const String noTeamsYet = 'No teams yet.';
  static const String noTeamsHint = 'Create your first team to get started';
  static const String createFirstTeam = 'Create Team';

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

  // Profile Feature
  static const String profile = 'Profile';
  static const String editProfile = 'Edit Profile';
  static const String changePhoto = 'Change Photo';
  static const String remove = 'Remove';
  static const String basicInfo = 'BASIC INFO';
  static const String phoneNumber = 'Phone Number';
  static const String professionalInfo = 'PROFESSIONAL INFO';
  static const String jobTitle = 'Job Title';
  static const String department = 'Department';
  static const String officeLocation = 'Office Location';
  static const String about = 'ABOUT';
  static const String bio = 'Bio';
  static const String skills = 'SKILLS';
  static const String addSkill = '+ Add Skill';
  static const String addSkillNew = '+ Add new';
  static const String privacySettings = 'PRIVACY SETTINGS';
  static const String visibleToTeam = 'Visible to Team';
  static const String visibleToTeamDesc =
      'Allow team members to see your profile';
  static const String shareContactInfo = 'Share Contact Info';
  static const String shareContactInfoDesc = 'Make phone number public';
  static const String profileUpdated = 'Profile updated successfully ✅';
  static const String logOut = 'Log Out';
  static const String teamsStats = 'TEAMS';
  static const String completedStats = 'COMPLETED';
  static const String activeStats = 'ACTIVE';
  static const String biography = 'BIOGRAPHY';
  static const String preferences = 'PREFERENCES';
  static const String darkMode = 'Dark Mode';
  static const String notificationsLabel = 'Notifications';
  static const String privacyAndSecurity = 'Privacy & Security';
  static const String activity = 'Activity';
}
