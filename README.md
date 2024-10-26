# Building Expense Manager

Building Expense Manager is a Flutter application designed to help manage and track expenses for residential buildings. It allows users to add residents, record expenses, and process payments efficiently.

## Features

- Add and manage residents with details like name, floor, apartment number, and millimeters (for utility calculations)
- Add expenses categorized as Power, Water, or Other
- Automatically calculate and distribute Power and Water expenses based on residents' millimeters
- Manually assign Other expenses to specific residents
- Process payments for residents and update their balances
- View a list of all expenses
- Sort residents by floor and apartment number

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK (latest stable version)
- An IDE (e.g., Android Studio, VS Code) with Flutter and Dart plugins installed

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/building-expense-manager.git
   ```

2. Navigate to the project directory:
   ```
   cd building-expense-manager
   ```

3. Get the dependencies:
   ```
   flutter pub get
   ```

4. Run the app:
   ```
   flutter run
   ```

## Usage

1. **Adding Residents**: 
   - Tap the menu icon to open the resident list
   - Tap "Add Resident" and fill in the details

2. **Adding Expenses**:
   - Tap "Add Expense" on the main screen
   - Select the expense category (Power, Water, or Other)
   - Enter the amount
   - For Other expenses, select the residents to assign the expense to

3. **Viewing Expenses**:
   - Tap "View Expenses" to see a list of all expenses

4. **Processing Payments**:
   - Open the resident list and tap on a resident
   - In the resident details dialog, enter a payment amount and tap "Make Payment"

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Acknowledgments

- Flutter team for the excellent framework
- All contributors who have helped shape this project
