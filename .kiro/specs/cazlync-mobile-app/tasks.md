# Implementation Plan

- [x] 1. Set up Flutter project structure and dependencies



  - Create new Flutter project with proper package name and organization
  - Add all required dependencies to pubspec.yaml (firebase_core, firebase_auth, cloud_firestore, firebase_storage, firebase_messaging, riverpod, cached_network_image, image_picker, flutter_image_compress)
  - Configure Firebase for Android and iOS platforms
  - Set up folder structure following clean architecture (presentation, domain, data layers)
  - Create base classes and interfaces for repositories and controllers
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 12.1, 12.2, 12.3, 12.4, 12.5_

- [x] 2. Implement authentication module



  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 13.1, 13.2, 13.3, 13.4, 13.5_




- [ ] 2.1 Create authentication data models and repository interface
  - Define User model with all required fields
  - Create AuthRepository interface with methods for all authentication types

  - Implement UserProfile model for Firestore storage
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

- [ ] 2.2 Implement Firebase authentication service
  - Create AuthService class wrapping Firebase Auth
  - Implement email/password authentication methods
  - Implement Google OAuth authentication
  - Implement Facebook OAuth authentication

  - Implement phone number authentication with OTP verification

  - Add auth state change stream
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 13.2, 13.3_

- [ ] 2.3 Create authentication UI screens
  - Build LoginScreen with email and social login options

  - Build RegisterScreen with form validation
  - Build PhoneVerificationScreen with OTP input
  - Implement navigation flow between auth screens

  - Add loading states and error handling UI
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

- [ ] 2.4 Set up authentication state management
  - Create AuthController using StateNotifierProvider
  - Implement auth state persistence

  - Add session timeout logic (30 days)
  - Handle authentication errors and display user-friendly messages



  - _Requirements: 1.5, 13.4_

- [ ]* 2.5 Write authentication tests
  - Create unit tests for AuthService methods
  - Create widget tests for authentication screens
  - Test error handling and validation
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

- [x] 3. Implement listing management module
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 3.1, 3.2, 3.3, 3.4, 3.5, 4.1, 4.2, 4.3, 4.4, 4.5_

- [x] 3.1 Create listing data models and repository interface
  - Define Listing model with all specifications
  - Create ListingRepository interface with CRUD methods
  - Define ListingFilter model for search criteria
  - Create ListingStatus enum (pending, active, rejected, deleted)
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 3.1, 3.2, 3.3, 3.4, 4.1, 4.2_

- [x] 3.2 Implement Firestore listing service
  - Create ListingService class for Firestore operations
  - Implement getListings with filter support
  - Implement createListing with image upload
  - Implement updateListing and deleteListing methods
  - Add real-time listing stream with watchListings
  - Implement view count increment
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 4.1, 4.2, 4.3, 4.4, 4.5_

- [x] 3.3 Implement image upload and compression service
  - Create ImageUploadService for handling images
  - Implement image compression using flutter_image_compress (target < 500KB)
  - Upload compressed images to Cloud Storage
  - Generate and return download URLs
  - Validate image count (3-20 images) and size limits
  - _Requirements: 4.3, 4.4, 12.2, 12.5_

- [x] 3.4 Create listing UI screens
  - Build HomeScreen with listing grid (2 columns)
  - Build ListingDetailScreen with image gallery and specifications
  - Build CreateListingScreen with form and image picker
  - Build EditListingScreen for updating listings
  - Add loading states, empty states, and error handling
  - _Requirements: 2.1, 3.1, 3.2, 3.3, 3.4, 3.5, 4.1, 4.2_

- [x] 3.5 Set up listing state management
  - Create ListingController using StateNotifierProvider
  - Implement pagination for listing results (20 items per page)
  - Add local caching using Hive for offline access
  - Handle listing creation, update, and deletion flows
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 4.1, 4.2, 4.3, 4.4, 4.5, 12.3_

- [ ]* 3.6 Write listing module tests
  - Create unit tests for ListingService methods
  - Create widget tests for listing screens
  - Test image upload and compression
  - Test pagination and caching logic
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 3.1, 3.2, 3.3, 3.4, 3.5, 4.1, 4.2, 4.3, 4.4, 4.5_

- [x] 4. Implement search and filter functionality



  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_



- [ ] 4.1 Create search and filter UI components
  - Build SearchScreen with search bar and filter chips
  - Build FilterBottomSheet with all filter options (brand, model, price, year, mileage)
  - Implement price range sliders
  - Add filter reset and apply buttons

  - _Requirements: 2.2, 2.3, 2.4_

- [ ] 4.2 Implement search and filter logic
  - Create SearchController for managing search state
  - Implement text search using Firestore queries
  - Apply client-side filtering for multiple criteria
  - Add debouncing for search input (300ms delay)
  - Cache search results locally
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 12.1_

- [ ]* 4.3 Write search and filter tests
  - Create unit tests for search logic
  - Test filter combinations
  - Test debouncing behavior
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

- [x] 5. Implement favorites functionality



  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_



- [ ] 5.1 Create favorites data layer
  - Add toggleFavorite method to ListingRepository
  - Implement getFavorites method
  - Update Firestore user document with favorite listings array


  - _Requirements: 5.1, 5.2, 5.3, 5.4_

- [ ] 5.2 Build favorites UI
  - Add favorite icon button to listing cards
  - Implement filled/unfilled icon states

  - Create FavoritesScreen showing saved listings
  - Add empty state for no favorites
  - _Requirements: 5.1, 5.2, 5.3, 5.5_


- [ ] 5.3 Implement favorites state management
  - Create FavoritesController using StateNotifierProvider

  - Handle favorite toggle with optimistic updates
  - Sync favorites across devices
  - Remove deleted listings from favorites
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_





- [x]* 5.4 Write favorites tests


  - Test toggle favorite functionality
  - Test favorites synchronization

  - Test deleted listing removal
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_




- [ ] 6. Implement chat module
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_



- [ ] 6.1 Create chat data models and repository interface
  - Define ChatSession model with participant info


  - Define Message model with timestamp and read status
  - Create ChatRepository interface with messaging methods
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

- [ ] 6.2 Implement Firestore chat service
  - Create ChatService for Firestore chat operations
  - Implement createChatSession method

  - Implement sendMessage with real-time updates
  - Implement watchMessages stream for real-time chat
  - Implement watchChatSessions for chat list
  - Add markAsRead functionality with unread count tracking
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

- [ ] 6.3 Create chat UI screens
  - Build ChatListScreen showing all conversations
  - Build ChatRoomScreen with message list and input
  - Add listing preview card at top of chat room
  - Implement message bubbles with sender/receiver styling

  - Add timestamp grouping for messages
  - Show unread indicators on chat list



  - _Requirements: 6.1, 6.3, 6.4, 6.5_

- [ ] 6.4 Set up chat state management
  - Create ChatController using StateNotifierProvider
  - Handle real-time message streams
  - Implement message sending with optimistic updates
  - Update unread counts when messages viewed
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

- [ ]* 6.5 Write chat module tests
  - Test chat session creation
  - Test message sending and receiving
  - Test unread count updates
  - Test real-time stream behavior
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

- [ ] 7. Implement push notifications
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_




- [x] 7.1 Set up Firebase Cloud Messaging


  - Configure FCM for Android and iOS
  - Request notification permissions
  - Store FCM tokens in user Firestore document
  - Handle token refresh and update in Firestore
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_


- [ ] 7.2 Implement notification service
  - Create NotificationService for handling FCM messages
  - Implement foreground notification display
  - Implement background notification handling




  - Add deep linking to navigate to relevant content
  - _Requirements: 7.1, 7.2, 7.3, 7.5_



- [ ] 7.3 Create Cloud Functions for notifications
  - Write Cloud Function to send notification on new message
  - Write Cloud Function to send notification on listing approval
  - Write Cloud Function to send notification on premium expiry (3 days before)



  - Write Cloud Function for new listing alerts based on saved searches
  - _Requirements: 7.1, 7.2, 7.3, 7.4_

- [ ] 7.4 Build notification settings UI
  - Create NotificationSettingsScreen

  - Add toggles for each notification category
  - Store preferences in user Firestore document
  - _Requirements: 7.4_

- [ ]* 7.5 Write notification tests
  - Test FCM token storage and refresh
  - Test notification display
  - Test deep linking navigation
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_

- [ ] 8. Implement user profile module
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

- [ ] 8.1 Create profile data layer
  - Create ProfileRepository interface
  - Implement ProfileService for Firestore user operations
  - Add methods for updating profile data
  - Add method for fetching user listings
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

- [ ] 8.2 Build profile UI screens
  - Create ProfileScreen with user info header
  - Add tab bar for My Listings, Favorites, Settings
  - Build EditProfileScreen with form
  - Build MyListingsScreen showing user's listings with status
  - Add profile photo upload functionality
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

- [ ] 8.3 Implement profile state management
  - Create ProfileController using StateNotifierProvider
  - Handle profile updates with optimistic UI
  - Implement listing deletion from profile
  - Handle listing editing and resubmission
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

- [ ]* 8.4 Write profile module tests
  - Test profile data updates
  - Test listing management from profile
  - Test profile photo upload
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

- [ ] 9. Implement admin dashboard
  - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 10.1, 10.2, 10.3, 10.4, 10.5_

- [ ] 9.1 Create admin data layer
  - Create AdminRepository interface
  - Implement AdminService for admin operations
  - Add methods for listing moderation (approve, reject, remove)
  - Add methods for fetching analytics data
  - Add method for managing reports
  - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 10.1, 10.2, 10.3, 10.4, 10.5_

- [ ] 9.2 Build admin UI screens
  - Create AdminDashboardScreen with analytics overview
  - Build ListingModerationScreen showing pending listings
  - Build AnalyticsScreen with detailed metrics
  - Build ReportsScreen for managing user reports
  - Add admin-only navigation and access control
  - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 10.1, 10.2, 10.3, 10.4, 10.5_

- [ ] 9.3 Implement admin state management
  - Create AdminController using StateNotifierProvider
  - Handle listing approval/rejection with status updates
  - Implement report management
  - Fetch and display analytics data
  - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 10.1, 10.2, 10.3, 10.4, 10.5_

- [ ] 9.4 Set up Firestore security rules for admin
  - Create admin role in user document
  - Add security rules restricting admin operations
  - Implement admin verification checks
  - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5_

- [ ]* 9.5 Write admin module tests
  - Test listing moderation operations
  - Test analytics data fetching
  - Test admin access control
  - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 10.1, 10.2, 10.3, 10.4, 10.5_

- [ ] 10. Implement premium listings functionality
  - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5_

- [ ] 10.1 Create premium listing data layer
  - Add premium fields to Listing model
  - Update ListingRepository with premium methods
  - Implement premium status tracking with expiration
  - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5_

- [ ] 10.2 Build premium listing UI
  - Create PremiumListingScreen showing packages and pricing
  - Add premium badge to listing cards
  - Display premium listings at top of search results
  - Add premium expiry notification UI
  - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5_

- [ ] 10.3 Implement premium listing logic
  - Create PremiumController for managing premium status
  - Implement premium activation after payment
  - Add Cloud Function to check and expire premium listings daily
  - Send notification 3 days before expiry
  - _Requirements: 11.2, 11.3, 11.4, 11.5_

- [ ]* 10.4 Write premium listing tests
  - Test premium status activation
  - Test premium expiration logic
  - Test premium sorting in search results
  - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5_

- [ ] 11. Implement verified seller functionality
  - _Requirements: 14.1, 14.2, 14.3, 14.4, 14.5_

- [ ] 11.1 Create verification data layer
  - Add verification fields to UserProfile model
  - Create VerificationRepository interface
  - Implement verification document upload to Cloud Storage
  - _Requirements: 14.1, 14.2, 14.3, 14.4, 14.5_

- [ ] 11.2 Build verification UI
  - Create VerificationRequestScreen with requirements and fee info
  - Build document upload interface
  - Add verified badge to user profiles and listings
  - Display verification status in profile
  - _Requirements: 14.1, 14.2, 14.3, 14.4, 14.5_

- [ ] 11.3 Implement verification workflow
  - Create VerificationController for managing verification
  - Handle document submission and admin review
  - Implement verification approval/rejection by admin
  - Add Cloud Function to check and expire verification after 12 months
  - Send renewal notification when verification expires
  - _Requirements: 14.1, 14.2, 14.3, 14.4, 14.5_

- [ ]* 11.4 Write verification tests
  - Test document upload
  - Test verification approval workflow
  - Test verification expiration
  - _Requirements: 14.1, 14.2, 14.3, 14.4, 14.5_

- [ ] 12. Implement security and data protection
  - _Requirements: 13.1, 13.2, 13.3, 13.4, 13.5_

- [ ] 12.1 Configure Firestore security rules
  - Write security rules for users collection
  - Write security rules for listings collection
  - Write security rules for chatSessions collection
  - Write security rules for admin-only collections
  - Implement read/write access controls based on authentication
  - _Requirements: 13.1, 13.5_

- [ ] 12.2 Configure Cloud Storage security rules
  - Write security rules for listing images
  - Write security rules for user profile photos
  - Write security rules for verification documents
  - Restrict access based on ownership and authentication
  - _Requirements: 13.1_

- [ ] 12.3 Implement input validation and sanitization
  - Add validation for all form inputs
  - Sanitize user-generated content (listings, messages)
  - Implement profanity filter for text content
  - Validate image uploads (type, size, count)
  - _Requirements: 13.5_

- [ ] 12.4 Add security monitoring
  - Integrate Firebase Crashlytics for error logging
  - Set up Firebase Performance Monitoring
  - Implement rate limiting on Cloud Functions
  - Add logging for sensitive operations
  - _Requirements: 13.1, 13.4_

- [ ]* 12.5 Perform security testing
  - Test authentication bypass attempts
  - Test unauthorized data access
  - Test input injection attacks
  - Test file upload vulnerabilities
  - _Requirements: 13.1, 13.2, 13.3, 13.4, 13.5_

- [ ] 13. Implement performance optimizations
  - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5_

- [ ] 13.1 Optimize image loading
  - Implement cached_network_image for all listing images
  - Add progressive loading with placeholders
  - Implement lazy loading in scrollable lists
  - Generate and use thumbnails for list views
  - _Requirements: 12.2, 12.5_

- [ ] 13.2 Optimize data fetching
  - Implement pagination for all list views (20 items per page)
  - Add pull-to-refresh functionality
  - Enable Firestore offline persistence
  - Implement local caching with Hive
  - _Requirements: 12.1, 12.3, 12.4_

- [ ] 13.3 Optimize app performance
  - Use const constructors where possible
  - Implement ListView.builder for all lists
  - Add debouncing for search inputs
  - Minimize widget rebuilds with proper state management
  - _Requirements: 12.1, 12.2_

- [ ]* 13.4 Perform performance testing
  - Measure app startup time (target < 3 seconds)
  - Measure listing load time (target < 2 seconds)
  - Measure image load time (target < 1 second)
  - Monitor memory usage (target < 200MB)
  - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5_

- [ ] 14. Build UI theme and styling
  - _Requirements: All requirements (UI applies to entire app)_

- [ ] 14.1 Create app theme
  - Define color palette (Primary #D32F2F, Secondary #212121, Accent #FFD54F)
  - Configure typography using Poppins font family
  - Create light and dark theme configurations
  - Define button styles and input decorations
  - _Requirements: All requirements_

- [ ] 14.2 Create reusable UI components
  - Build custom ListingCard widget
  - Build custom ChatBubble widget
  - Build custom AppButton widget
  - Build custom SearchBar widget
  - Build custom FilterChip widget
  - Create loading indicators and empty state widgets
  - _Requirements: All requirements_

- [ ] 14.3 Implement navigation
  - Set up bottom navigation bar with 5 tabs
  - Configure named routes for all screens
  - Implement deep linking for notifications
  - Add navigation transitions
  - _Requirements: All requirements_

- [ ]* 14.4 Create UI component tests
  - Test custom widget rendering
  - Test navigation flows
  - Test theme switching
  - _Requirements: All requirements_

- [ ] 15. Set up error handling and logging
  - _Requirements: All requirements (error handling applies throughout)_

- [ ] 15.1 Implement error handling framework
  - Create custom exception classes for different error types
  - Build error message mapping for user-friendly messages
  - Implement retry logic for network errors (max 3 attempts)
  - Add offline mode detection and handling
  - _Requirements: All requirements_

- [ ] 15.2 Create error UI components
  - Build error dialog widget
  - Build error snackbar widget
  - Create empty state screens for no data
  - Add retry buttons for failed operations
  - Display offline indicator banner
  - _Requirements: All requirements_

- [ ] 15.3 Set up logging and monitoring
  - Integrate Firebase Crashlytics
  - Configure error logging for all caught exceptions
  - Add performance monitoring for key operations
  - Implement analytics event tracking
  - _Requirements: All requirements_

- [ ]* 15.4 Test error handling
  - Test network error scenarios
  - Test authentication error handling
  - Test validation error display
  - Test offline mode behavior
  - _Requirements: All requirements_

- [ ] 16. Configure deployment and CI/CD
  - _Requirements: All requirements (deployment applies to entire app)_

- [ ] 16.1 Set up Firebase projects
  - Create Firebase project for development (cazlync-dev)
  - Create Firebase project for staging (cazlync-staging)
  - Create Firebase project for production (cazlync-prod)
  - Configure each project with appropriate settings
  - _Requirements: All requirements_

- [ ] 16.2 Configure Android build
  - Set up signing keys for release builds
  - Configure build.gradle with proper versioning
  - Set up Google Play Console project
  - Configure app bundle generation
  - _Requirements: All requirements_

- [ ] 16.3 Configure iOS build
  - Set up provisioning profiles and certificates
  - Configure Xcode project settings
  - Set up App Store Connect project
  - Configure IPA generation
  - _Requirements: All requirements_

- [ ] 16.4 Set up CI/CD pipeline
  - Configure GitHub Actions or Codemagic
  - Add automated testing step
  - Add build step for Android and iOS
  - Configure deployment to Firebase App Distribution
  - Set up production deployment with phased rollout
  - _Requirements: All requirements_

- [ ]* 16.5 Create deployment documentation
  - Document build and release process
  - Document environment configuration
  - Document troubleshooting steps
  - _Requirements: All requirements_

- [ ] 17. Final integration and testing
  - _Requirements: All requirements_

- [ ] 17.1 Perform end-to-end integration testing
  - Test complete user registration to listing creation flow
  - Test browse to chat initiation flow
  - Test admin approval workflow
  - Test premium listing purchase flow
  - Test verification request flow
  - _Requirements: All requirements_

- [ ] 17.2 Perform cross-platform testing
  - Test on multiple Android devices and versions
  - Test on multiple iOS devices and versions
  - Verify UI consistency across platforms
  - Test performance on low-end devices
  - _Requirements: All requirements_

- [ ] 17.3 Perform user acceptance testing
  - Deploy to staging environment
  - Conduct beta testing with target users
  - Gather feedback and identify issues
  - Make necessary adjustments based on feedback
  - _Requirements: All requirements_

- [ ]* 17.4 Create user documentation
  - Write user guide for buyers
  - Write user guide for sellers
  - Write admin documentation
  - Create FAQ section
  - _Requirements: All requirements_
