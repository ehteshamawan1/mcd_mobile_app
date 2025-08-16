# API Mock Server Documentation

## Overview
A Node.js Express-based mock API server for the Charity Application providing RESTful endpoints for authentication, case management, user management, donations, and administrative functions.

## Project Structure
```
api_mock/
├── node_modules/
├── package-lock.json
├── package.json
└── server.js
```

## Package Information
- **Name**: api_mock
- **Version**: 1.0.0
- **License**: ISC

## Dependencies
- **express**: ^5.1.0 - Web framework for Node.js
- **cors**: ^2.8.5 - CORS middleware for cross-origin requests
- **body-parser**: ^2.2.0 - Body parsing middleware

## Scripts
- `npm start` - Start the server
- `npm run dev` - Start the server (development)
- `npm test` - Run tests (not implemented)

## Server Configuration
- **Port**: 3001
- **Middleware**: CORS enabled, JSON body parsing, URL-encoded body parsing

## Data Models

### User Model
```javascript
{
  id: string,
  cnic: string,
  phoneNumber: string,
  location: string,
  role: 'imam' | 'donor' | 'beneficiary',
  isVerified: boolean,
  additionalInfo: object,
  createdAt: string (ISO date)
}
```

### Case Model
```javascript
{
  id: string,
  beneficiaryName: string,
  beneficiaryId: string,
  title: string,
  description: string,
  type: 'medical' | 'education' | 'emergency' | 'housing' | 'food' | 'other',
  targetAmount: number,
  raisedAmount: number,
  location: string,
  mosqueId: string,
  mosqueName: string,
  isImamVerified: boolean,
  isAdminApproved: boolean,
  status: 'pending' | 'active' | 'completed' | 'rejected',
  createdAt: string (ISO date),
  updatedAt?: string (ISO date)
}
```

### Donation Model
```javascript
{
  id: string,
  donorId: string,
  caseId: string,
  amount: number,
  timestamp: string (ISO date)
}
```

### Mosque Model
```javascript
{
  id: string,
  name: string,
  address: string,
  isVerified: boolean
}
```

## API Endpoints

### Authentication Endpoints

#### POST `/api/auth/login`
Login user with CNIC and phone number
- **Request Body**: `{ cnic: string, phoneNumber: string }`
- **Response**: `{ success: boolean, user?: object, token?: string, message?: string }`
- **Mock Credentials**: CNIC: "42101-1234567-8", Phone: "+923001234567"

#### POST `/api/auth/register`
Register new user
- **Request Body**: User object
- **Response**: `{ success: boolean, user: object }`

#### POST `/api/auth/verify-otp`
Verify OTP for authentication
- **Request Body**: OTP verification data
- **Response**: `{ success: boolean, message: string }`

#### POST `/api/auth/logout`
Logout user
- **Response**: `{ success: boolean, message: string }`

### Case Management Endpoints

#### GET `/api/cases`
Get all cases with optional filtering
- **Query Parameters**: 
  - `status`: Filter by case status
  - `type`: Filter by case type
  - `location`: Filter by location (partial match)
- **Response**: `{ success: boolean, cases: array }`

#### POST `/api/cases`
Create new case
- **Request Body**: Case object (without id, raisedAmount, status)
- **Response**: `{ success: boolean, case: object }`

#### PUT `/api/cases/:id`
Update existing case
- **Parameters**: `id` - Case ID
- **Request Body**: Partial case object
- **Response**: `{ success: boolean, case: object }`

#### DELETE `/api/cases/:id`
Delete case
- **Parameters**: `id` - Case ID
- **Response**: `{ success: boolean, message: string }`

#### POST `/api/cases/:id/approve`
Approve case (admin only)
- **Parameters**: `id` - Case ID
- **Response**: `{ success: boolean, case: object }`
- **Action**: Sets `isAdminApproved: true` and `status: 'active'`

#### POST `/api/cases/:id/reject`
Reject case (admin only)
- **Parameters**: `id` - Case ID
- **Response**: `{ success: boolean, case: object }`
- **Action**: Sets `isAdminApproved: false` and `status: 'rejected'`

### User Management Endpoints

#### GET `/api/users`
Get all users with optional filtering
- **Query Parameters**: 
  - `role`: Filter by user role
- **Response**: `{ success: boolean, users: array }`

#### PUT `/api/users/:id`
Update user information
- **Parameters**: `id` - User ID
- **Request Body**: Partial user object
- **Response**: `{ success: boolean, user: object }`

#### POST `/api/users/verify`
Verify user account
- **Request Body**: `{ userId: string }`
- **Response**: `{ success: boolean, user: object }`

### Donation Endpoints

#### POST `/api/donations`
Create new donation
- **Request Body**: Donation object
- **Response**: `{ success: boolean, donation: object }`
- **Side Effect**: Updates case raised amount

#### GET `/api/donations/:userId`
Get donations by user
- **Parameters**: `userId` - User ID
- **Response**: `{ success: boolean, donations: array }`

#### GET `/api/reports/donations`
Get donation statistics
- **Response**: 
```javascript
{
  success: boolean,
  report: {
    totalDonations: number,
    totalCases: number,
    activeCases: number,
    donationCount: number,
    averageDonation: number
  }
}
```

### Mosque Endpoints

#### GET `/api/mosques`
Get all mosques
- **Response**: `{ success: boolean, mosques: array }`

#### POST `/api/mosques/verify`
Verify mosque
- **Request Body**: `{ mosqueId: string }`
- **Response**: `{ success: boolean, mosque: object }`

### Admin Endpoints

#### POST `/api/admin/login`
Admin login
- **Request Body**: `{ username: string, password: string }`
- **Response**: `{ success: boolean, token?: string, user?: object, message?: string }`
- **Mock Credentials**: Username: "admin", Password: "admin123"

### Health Check

#### GET `/health`
Server health check
- **Response**: `{ status: 'ok', timestamp: string }`

## Mock Data

### Default User
```javascript
{
  id: 'user_001',
  cnic: '42101-1234567-8',
  phoneNumber: '+923001234567',
  location: 'Karachi',
  role: 'imam',
  isVerified: true,
  additionalInfo: {
    mosqueName: 'Masjid Al-Noor',
    mosqueAddress: 'Block 5, Gulshan-e-Iqbal'
  }
}
```

### Default Case
```javascript
{
  id: 'case_001',
  beneficiaryName: 'Sara Ahmed',
  title: 'Urgent Medical Treatment for Heart Surgery',
  description: 'Sara Ahmed, a 45-year-old mother of three, urgently needs heart surgery.',
  type: 'medical',
  targetAmount: 500000,
  raisedAmount: 125000,
  location: 'Karachi, Gulshan-e-Iqbal',
  mosqueName: 'Masjid Al-Noor',
  isImamVerified: true,
  isAdminApproved: false,
  status: 'pending'
}
```

## Running the Server

1. Install dependencies:
```bash
npm install
```

2. Start the server:
```bash
npm start
```

3. Server will run on: `http://localhost:3001`

## Console Output
On startup, the server logs:
- Server URL
- List of all available endpoints

## Error Handling
- 401 Unauthorized for invalid credentials
- 404 Not Found for non-existent resources
- Standard HTTP status codes for responses

## Security Notes
- This is a mock server for development purposes
- No actual authentication or authorization implementation
- Data is stored in memory and reset on server restart
- CORS is enabled for all origins