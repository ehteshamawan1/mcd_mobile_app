# Flutter Charity Mobile App - Claude Code Development Plan

## Project Overview
Build a Flutter mobile application for a charity platform connecting donors with verified needy individuals through mosque networks. The app serves three user roles: **Imam**, **Donor**, and **Beneficiary**. Admin functionality is handled by a separate web application.

## Technical Requirements

### Flutter Setup
- **Flutter Version**: Latest stable (3.x+)
- **Dart Version**: 3.x+
- **Target Platforms**: Android & iOS
- **Minimum SDK**: Android API 21, iOS 12.0

### Architecture Pattern
- **State Management**: Provider pattern
- **Navigation**: GoRouter for declarative routing
- **Project Structure**: Feature-based with clean architecture
- **API Integration**: Mock services (no real third-party integrations)

## Project Structure Requirements

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   ├── themes/
│   ├── utils/
│   └── routes/
├── data/
│   ├── models/
│   ├── repositories/
│   └── services/
├── presentation/
│   ├── providers/
│   ├── screens/
│   └── widgets/
└── shared/
    ├── components/
    └── layouts/
```

## Data Models Specification

### User Model
```dart
enum UserRole { imam, donor, beneficiary }

class User {
  String id;
  String cnic;           // Format: 12345-1234567-1
  String phoneNumber;    // Format: +923xxxxxxxxx
  String name;
  String email;
  String location;
  UserRole role;
  bool isVerified;
  Map<String, dynamic>? additionalInfo;  // Role-specific data
  DateTime createdAt;
}
```

### Case Model
```dart
enum CaseType { medical, education, emergency, housing, food, other }
enum CaseStatus { pending, active, completed, rejected }

class CaseModel {
  String id;
  String beneficiaryName;
  String beneficiaryId;
  String title;
  String description;
  CaseType type;
  double targetAmount;
  double raisedAmount;
  String location;
  String mosqueId;
  String mosqueName;
  bool isImamVerified;
  bool isAdminApproved;
  CaseStatus status;
  DateTime createdAt;
  DateTime? updatedAt;
  List<String> documentUrls;
  List<String> imageUrls;
}
```

### Donation Model
```dart
class Donation {
  String id;
  String donorId;
  String caseId;
  double amount;
  DateTime timestamp;
  String paymentMethod;
  String transactionId;
  String status;
}
```

### Mosque Model
```dart
class Mosque {
  String id;
  String name;
  String address;
  String city;
  String imamId;
  String imamName;
  bool isVerified;
  DateTime createdAt;
}
```

## Required Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6.1.1
  
  # Navigation
  go_router: ^12.1.3
  
  # HTTP & Storage
  dio: ^5.4.0
  shared_preferences: ^2.2.2
  
  # UI & Media
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.0
  image_picker: ^1.0.4
  
  # Forms & Validation
  flutter_form_builder: ^9.1.1
  form_builder_validators: ^9.1.0
  
  # Utilities
  intl: ^0.19.0
  uuid: ^4.2.1
  equatable: ^2.0.5
  
  # UI Components
  flutter_spinkit: ^5.2.0
  fluttertoast: ^8.2.4

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  mockito: ^5.4.4
```

## Screen Requirements by User Role

### Authentication Screens (Shared)
1. **Splash Screen**
   - App logo and branding
   - Automatic navigation to login or dashboard if logged in

2. **Role Selection Screen**
   - Three role cards: Imam, Donor, Beneficiary
   - Navigate to appropriate registration/login

3. **Login Screen**
   - CNIC input field (formatted: 12345-1234567-1)
   - Phone number input field
   - Mock authentication (bypass real verification)
   - Role-based navigation after login

4. **Registration Screen**
   - Role-specific registration forms
   - CNIC, phone, name, email, location fields
   - Additional fields based on role selection
   - Mock OTP verification

5. **OTP Verification Screen**
   - 4-digit OTP input
   - Mock verification (accept any 4-digit code)
   - Resend OTP functionality

### Imam Role Screens
1. **Imam Dashboard**
   - Overview cards: Total cases, pending approvals, active cases
   - Recent cases list
   - Quick actions: Add case, view mosque profile
   - Navigation to other imam features

2. **Case Management Screen**
   - List of all cases created by imam
   - Filter by status: All, Pending, Active, Completed
   - Case status indicators and progress bars
   - Edit/delete actions for pending cases

3. **Create Case Screen**
   - Multi-step form:
     - Beneficiary details (name, CNIC, phone, relationship)
     - Case details (title, description, type, target amount)
     - Location and mosque information
     - Document upload (mock file picker)
   - Form validation and submission

4. **Case Details Screen**
   - Complete case information display
   - Donation progress and history
   - Beneficiary verification status
   - Edit case (if pending status)

5. **Beneficiary Verification Screen**
   - List of beneficiaries to verify
   - Verification checklist (CNIC, phone, need assessment)
   - Approve/reject verification actions
   - Comments and notes

6. **Mosque Profile Screen**
   - Mosque information display and editing
   - Imam profile details
   - Verification status and documents
   - Contact information

### Donor Role Screens
1. **Donor Dashboard**
   - Featured cases carousel
   - Category browse buttons (Medical, Education, Emergency, etc.)
   - Recent donations summary
   - Quick donation amounts

2. **Browse Cases Screen**
   - List/grid view of active cases
   - Filter options: Category, location, amount range
   - Search functionality
   - Sort options: newest, amount needed, location

3. **Case Details Screen**
   - Complete case information
   - Progress bar and donation statistics
   - Beneficiary details and verification badges
   - Mosque information
   - Donation history
   - Donate button

4. **Donation Screen**
   - Amount selection (preset amounts + custom)
   - Payment method selection (mock options)
   - Donation confirmation
   - Mock payment processing with loading states
   - Success/failure feedback

5. **Donation History Screen**
   - List of all user donations
   - Filter by date range, amount, case type
   - Transaction details
   - Download receipt option (mock)

6. **Donor Profile Screen**
   - Personal information editing
   - Donation statistics and achievements
   - Notification preferences
   - Privacy settings

### Beneficiary Role Screens
1. **Beneficiary Dashboard**
   - My cases overview
   - Application status tracking
   - Recent donations received
   - Quick apply for new case

2. **Submit Case Screen**
   - Personal information form
   - Case description and details
   - Required documents upload (mock)
   - Mosque selection
   - Target amount specification

3. **My Cases Screen**
   - List of submitted cases
   - Status tracking for each case
   - Edit pending cases
   - View case performance

4. **Case Progress Screen**
   - Detailed view of case progress
   - Donation timeline
   - Verification status updates
   - Thank you messages to donors

5. **Document Management Screen**
   - Upload required documents
   - View uploaded documents
   - Document verification status
   - Resubmit rejected documents

6. **Beneficiary Profile Screen**
   - Personal information management
   - Contact details
   - Case history
   - Verification status

### Shared Screens
1. **Search & Filter Screen**
   - Advanced search with multiple filters
   - Location-based filtering
   - Category and amount filters
   - Save search preferences

2. **Notifications Screen**
   - In-app notifications
   - Case updates, donation confirmations
   - System announcements
   - Mark as read functionality

3. **Settings Screen**
   - Profile management
   - Notification preferences
   - Privacy settings
   - App theme selection
   - Logout functionality

4. **Help & Support Screen**
   - FAQ sections
   - Contact information
   - User guide
   - Report issues

## Navigation Structure

### Bottom Navigation (Role-based)

#### Imam Navigation
- Dashboard
- Cases
- Verify
- Profile

#### Donor Navigation
- Browse
- My Donations
- Favorites
- Profile

#### Beneficiary Navigation
- Dashboard
- My Cases
- Submit
- Profile

### Route Configuration
```dart
// Route paths structure
/splash
/role-selection
/login
/register
/otp-verification

// Role-based routes
/imam/dashboard
/imam/cases
/imam/create-case
/imam/verify
/imam/profile

/donor/browse
/donor/case-details/:id
/donor/donate/:id
/donor/history
/donor/profile

/beneficiary/dashboard
/beneficiary/submit
/beneficiary/my-cases
/beneficiary/progress/:id
/beneficiary/profile

// Shared routes
/search
/notifications
/settings
/help
```

## Mock Data Requirements

### Mock Users Data
- Create 10+ users for each role
- Include verified and unverified users
- Diverse locations and case types
- Realistic Pakistani names and locations

### Mock Cases Data
- 20+ sample cases across all categories
- Various status levels (pending, active, completed)
- Different funding progress levels
- Realistic Pakistani context (cities, amounts in PKR)

### Mock Mosques Data
- 15+ mosques from major Pakistani cities
- Verified and unverified mosques
- Real mosque names and locations

### Mock Donations Data
- Transaction history for cases
- Various donation amounts
- Different time periods
- Multiple donors per case

## State Management Structure

### Providers Required
1. **AuthProvider**
   - User authentication state
   - Login/logout functionality
   - User session management

2. **CaseProvider**
   - Cases CRUD operations
   - Filtering and searching
   - Status updates

3. **UserProvider**
   - User profile management
   - Role-specific data

4. **DonationProvider**
   - Donation processing
   - Transaction history
   - Payment flow management

5. **AppProvider**
   - Global app state
   - Theme management
   - Settings

## UI/UX Requirements

### Design System
- **Color Scheme**: 
  - Primary: #00caff (cyan blue)
  - Secondary: #0f67b1 (dark blue)
  - Background: white, light gray variations
  - Text: dark gray, white on colored backgrounds
- **Typography**: 
  - Primary Font: DM Sans (headings, UI elements)
  - Secondary Font: Manjari (body text, descriptions)
  - Proper hierarchy with clear font weights and sizes
- **Icons**: Consistent icon set (Material or custom)
- **Cards**: Consistent card layouts for cases, users, etc.

### Component Standards
- **Loading States**: Shimmer effects, spinners
- **Empty States**: Meaningful empty state illustrations
- **Error Handling**: User-friendly error messages
- **Form Validation**: Real-time validation with helpful messages
- **Status Badges**: Color-coded status indicators

### Responsive Design
- Support multiple screen sizes
- Tablet-friendly layouts
- Proper keyboard handling
- Accessibility considerations

## Mock Service Implementation

### Authentication Service
```dart
class MockAuthService {
  // Simulate login with any valid CNIC format
  // Return user based on role selection
  // Mock OTP always accepts 1234
  // Session management with SharedPreferences
}
```

### Payment Service
```dart
class MockPaymentService {
  // Simulate payment processing (3-second delay)
  // Always return success for demo
  // Generate mock transaction IDs
  // Update case raised amount
}
```

### File Upload Service
```dart
class MockFileService {
  // Simulate document/image upload
  // Return mock URLs
  // Handle multiple file types
}
```

### Location Service
```dart
class MockLocationService {
  // Return predefined Pakistani cities
  // Mock mosque listings
  // Distance calculations for filtering
}
```



## Quality Requirements

### Performance
- Smooth 60fps animations
- Fast screen transitions
- Efficient list rendering
- Optimized image loading

### Security (Mock Level)
- Basic input validation
- Secure local storage
- Session timeout handling

### Accessibility
- Screen reader support
- Proper color contrast
- Keyboard navigation
- Font scaling support

## Testing Strategy

### Unit Tests
- Provider logic testing
- Model serialization/deserialization
- Utility function testing
- Mock service testing

### Widget Tests
- Screen rendering tests
- User interaction tests
- Form validation tests
- Navigation tests

### Integration Tests
- Complete user flows
- Role-based access testing
- Cross-screen data flow

## Deliverables

### Code Structure
- Clean, well-documented code
- Consistent naming conventions
- Proper error handling
- Modular architecture

### Documentation
- README with setup instructions
- API documentation for mock services
- User flow documentation
- Code comments and explanations

### Demo Data
- Comprehensive mock data sets
- Realistic Pakistani context
- Various test scenarios

This plan provides everything needed to build a complete Flutter charity mobile application with three user roles, comprehensive functionality, and proper architecture for future scalability.