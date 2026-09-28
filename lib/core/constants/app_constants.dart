/// App-wide Constants
library;

class AppConstants {
  // App Info
  static const String appName = 'Domexa';
  static const String appTagline = 'AI-Powered House Construction Planning';
  static const String version = '1.0.0';

  // Validation Constants
  static const double minPlotArea = 500;
  static const double maxPlotArea = 20000;
  static const int minFloors = 1;
  static const int maxFloors = 4;
  static const int maxBedrooms = 10;
  static const int maxBathrooms = 8;

  // Budget Categories
  static const String budgetLow = 'low';
  static const String budgetMedium = 'medium';
  static const String budgetHigh = 'high';

  // Room Types
  static const String roomBedroom = 'bedroom';
  static const String roomMasterBedroom = 'master_bedroom';
  static const String roomLivingRoom = 'living_room';
  static const String roomDrawingRoom = 'drawing_room';
  static const String roomDiningRoom = 'dining_room';
  static const String roomKitchen = 'kitchen';
  static const String roomBathroom = 'bathroom';
  static const String roomStudyRoom = 'study_room';
  static const String roomTvLounge = 'tv_lounge';
  static const String roomGuestRoom = 'guest_room';
  static const String roomKidsRoom = 'kids_room';

  // Style Preferences
  static const String styleModern = 'modern';
  static const String styleTraditional = 'traditional';
  static const String styleMinimalist = 'minimalist';
  static const String styleLuxury = 'luxury';

  // Local Storage Keys
  static const String keyUserToken = 'user_token';
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';
  static const String keyThemeMode = 'theme_mode';
  static const String keyOnboardingCompleted = 'onboarding_completed';
}