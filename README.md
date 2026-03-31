# ESI / PF File Generator

A Flutter app for managing Employee Provident Fund (EPF) and Employee State Insurance (ESI) contributions for companies.

## Features

- **Companies**: Add companies with configurable EPF/ESI percentages (employee & employer)
- **Data**: Manage employees (name, UAN, IP Number, salary per day)
- **Transaction**: View monthly transaction cards with ESI, PF, total salary
- **Entry**: Add entries by selecting month, employee, and days worked
- **Export Excel**: Export transaction details in the standard EPF/ESI format

## Firebase Setup

1. Create a project at [Firebase Console](https://console.firebase.google.com)
2. Enable **Firestore Database**
3. Run `flutterfire configure` to link your Flutter app (installs FlutterFire CLI: `dart pub global activate flutterfire_cli`)
4. Deploy Firestore indexes: `firebase deploy --only firestore:indexes`

See **FIREBASE_COLLECTIONS.md** for the complete collection structure.

## Running the App

```bash
flutter pub get
flutter run
```

## Project Structure

- `lib/models/` - Company, Employee, Transaction, TransactionEntry
- `lib/screens/` - Companies, Add Company, Company Detail (Data/Transaction/Entry tabs), Transaction Detail
- `lib/services/` - FirebaseService, ExcelService
# EPF-ESI---PROJECT
