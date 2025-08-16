# Admin Panel Documentation

## Overview
A React TypeScript-based administrative dashboard for the Charity Application, providing comprehensive management tools for cases, users, mosques, and donation tracking with real-time analytics.

## Project Structure
```
admin_panel/
├── README.md
├── package.json
├── package-lock.json
├── tsconfig.json
├── public/
│   ├── favicon.ico
│   ├── index.html
│   ├── logo192.png
│   ├── logo512.png
│   ├── manifest.json
│   └── robots.txt
└── src/
    ├── App.css
    ├── App.test.tsx
    ├── App.tsx
    ├── index.css
    ├── index.tsx
    ├── logo.svg
    ├── react-app-env.d.ts
    ├── reportWebVitals.ts
    ├── setupTests.ts
    ├── components/
    │   ├── Layout.css
    │   ├── Layout.tsx
    │   └── PrivateRoute.tsx
    ├── context/
    │   ├── AuthContext.tsx
    │   └── CaseContext.tsx
    ├── pages/
    │   ├── CaseManagement.css
    │   ├── CaseManagement.tsx
    │   ├── Dashboard.css
    │   ├── Dashboard.tsx
    │   ├── Login.css
    │   ├── Login.tsx
    │   ├── MosqueVerification.tsx
    │   ├── Pages.css
    │   ├── Reports.tsx
    │   ├── Settings.tsx
    │   ├── UserManagement.css
    │   └── UserManagement.tsx
    ├── services/
    ├── types/
    │   └── index.ts
    └── utils/
        └── mockData.ts
```

## Package Information
- **Name**: admin_panel
- **Version**: 0.1.0
- **Private**: true

## Dependencies

### Core Dependencies
- **react**: ^19.1.1 - React framework
- **react-dom**: ^19.1.1 - React DOM rendering
- **react-router-dom**: ^7.8.0 - Routing library
- **typescript**: ^4.9.5 - TypeScript support
- **axios**: ^1.11.0 - HTTP client
- **recharts**: ^3.1.2 - Charting library

### TypeScript Types
- **@types/react**: ^19.1.10
- **@types/react-dom**: ^19.1.7
- **@types/react-router-dom**: ^5.3.3
- **@types/node**: ^16.18.126
- **@types/jest**: ^27.5.2

### Testing Libraries
- **@testing-library/react**: ^16.3.0
- **@testing-library/jest-dom**: ^6.7.0
- **@testing-library/dom**: ^10.4.1
- **@testing-library/user-event**: ^13.5.0

### Other
- **react-scripts**: 5.0.1 - Create React App scripts
- **web-vitals**: ^2.1.4 - Performance monitoring

## Scripts
- `npm start` - Start development server (port 3000)
- `npm build` - Build for production
- `npm test` - Run tests
- `npm eject` - Eject from Create React App

## Type Definitions

### User Type
```typescript
interface User {
  id: string;
  cnic: string;
  phoneNumber: string;
  location: string;
  role: 'imam' | 'donor' | 'beneficiary';
  isVerified: boolean;
  additionalInfo?: Record<string, any>;
  createdAt: string;
}
```

### Case Type
```typescript
interface Case {
  id: string;
  beneficiaryName: string;
  beneficiaryId: string;
  title: string;
  description: string;
  type: 'medical' | 'education' | 'emergency' | 'housing' | 'food' | 'other';
  targetAmount: number;
  raisedAmount: number;
  location: string;
  mosqueId: string;
  mosqueName: string;
  isImamVerified: boolean;
  isAdminApproved: boolean;
  status: 'pending' | 'active' | 'completed' | 'rejected';
  createdAt: string;
  updatedAt?: string;
  documents?: string[];
}
```

### Mosque Type
```typescript
interface Mosque {
  id: string;
  name: string;
  address: string;
  city: string;
  imamId: string;
  imamName: string;
  isVerified: boolean;
  verificationStatus: 'pending' | 'approved' | 'rejected';
  createdAt: string;
}
```

### Donation Type
```typescript
interface Donation {
  id: string;
  donorId: string;
  caseId: string;
  amount: number;
  timestamp: string;
  paymentMethod: string;
}
```

### Dashboard Statistics Type
```typescript
interface DashboardStats {
  totalCases: number;
  activeCases: number;
  pendingCases: number;
  totalDonations: number;
  totalRaised: number;
  verifiedMosques: number;
  totalUsers: number;
}
```

### Admin User Type
```typescript
interface AdminUser {
  id: string;
  username: string;
  role: string;
}
```

## Application Architecture

### Main Application Component (App.tsx)
- Sets up routing with React Router
- Provides authentication and case management contexts
- Defines protected routes

### Routing Structure
```
/login           - Login page (public)
/                - Redirects to /dashboard
/dashboard       - Main dashboard with statistics
/cases           - Case management interface
/users           - User management interface
/mosques         - Mosque verification interface
/reports         - Reporting and analytics
/settings        - Application settings
```

## Context Providers

### AuthContext
Manages authentication state and operations:
- **State**: `isAuthenticated`, `user`
- **Methods**: 
  - `login(username, password)` - Authenticate admin
  - `logout()` - Clear authentication
- **Mock Credentials**: username: "admin", password: "admin123"

### CaseContext
Manages application data:
- **State**: `cases`, `users`, `mosques`
- **Methods**:
  - `approveCase(caseId)` - Approve pending case
  - `rejectCase(caseId)` - Reject pending case

## Components

### Layout Component
- Main application layout wrapper
- Navigation sidebar
- Header with user info
- Content area for page components

### PrivateRoute Component
- Protected route wrapper
- Redirects to login if not authenticated
- Wraps authenticated pages

## Pages

### Dashboard Page
Features:
- **Statistics Cards**:
  - Total Cases
  - Active Cases
  - Pending Approval
  - Total Raised Amount
- **Charts**:
  - Monthly trends (Line chart)
  - Case types distribution (Pie chart)
- **Information Panels**:
  - User statistics breakdown
  - Mosque verification status
  - Funding progress
- **Recent Activities**: Activity timeline

### Case Management Page
Features:
- **Filtering Options**:
  - All cases
  - Pending approval
  - Approved cases
  - Rejected cases
- **Case Table**:
  - Case ID, beneficiary, title, type
  - Target/raised amounts
  - Mosque information
  - Status badges
- **Case Details View**:
  - Full case information
  - Verification status
  - Approval/rejection actions

### User Management Page
Features:
- User list with role filtering
- User verification status
- User details and editing
- Role management

### Mosque Verification Page
Features:
- Mosque listing
- Verification status tracking
- Approval workflow

### Reports Page
Features:
- Donation analytics
- Case completion metrics
- User activity reports

### Settings Page
Features:
- Application configuration
- Admin preferences

### Login Page
Features:
- Admin authentication form
- Username/password fields
- Session management

## Styling
- Component-specific CSS files
- Responsive design
- Badge system for status indicators
- Color coding for different states

## Badge Color Schemes

### Status Badges
- **Pending**: Warning (yellow)
- **Approved**: Success (green)
- **Rejected**: Danger (red)
- **Active**: Info (blue)

### Case Type Badges
- **Medical**: Special medical color
- **Education**: Education theme color
- **Emergency**: Emergency alert color
- **Housing**: Housing theme color
- **Food**: Food assistance color
- **Other**: Default color

## Data Flow
1. Admin logs in via Login page
2. AuthContext manages authentication state
3. Dashboard loads data from CaseContext
4. Admin navigates to management pages
5. Actions (approve/reject) update context state
6. UI reflects changes immediately

## Security Features
- Protected routes requiring authentication
- Token-based session management (localStorage)
- Role-based access control ready

## Development Setup

1. Install dependencies:
```bash
npm install
```

2. Start development server:
```bash
npm start
```

3. Access at: `http://localhost:3000`

## Build for Production

```bash
npm run build
```

Creates optimized production build in `build/` directory.

## Testing

```bash
npm test
```

Runs test suite with Jest and React Testing Library.

## Browser Support
- Production: >0.2%, not dead, not op_mini all
- Development: Latest Chrome, Firefox, Safari

## ESLint Configuration
Extends:
- react-app
- react-app/jest

## Key Features Summary
- **Real-time Dashboard**: Live statistics and charts
- **Case Management**: Complete workflow from submission to approval
- **User Management**: Role-based user administration
- **Mosque Verification**: Verification and approval system
- **Reporting**: Comprehensive analytics and reports
- **Responsive Design**: Works on desktop and mobile
- **Type Safety**: Full TypeScript implementation