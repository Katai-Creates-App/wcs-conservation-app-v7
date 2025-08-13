# Conservation Data Collection App

This Flutter mobile application is designed for conservation data collection, allowing users to store and manage plant and animal observations locally using SQLite.

## Features

- **Local Storage**: Utilizes SQLite for storing observations of plants and animals.
- **Observation Management**: Users can add, edit, and delete observations.
- **Observation Details**: View detailed information about each observation.
- **Filtered Lists**: Separate screens for viewing plant and animal observations.
- **User-Friendly Interface**: Intuitive UI for easy navigation and data entry.
- **Settings Screen**: Manage app preferences and settings.
- **Nature-Themed UI**: Clean, earth-tone color scheme and responsive design.

## Folder Structure

```
lib/
  models/observation.dart
  providers/observation_provider.dart
  services/db_helper.dart
  screens/
    home_screen.dart
    observation_form_screen.dart
    observation_detail_screen.dart
    settings_screen.dart
  main.dart
assets/
  placeholder.png
```

## Database Structure

The app uses SQLite to manage the following table:

- **Observations**: 
  - `id`: Integer, primary key
  - `species_name`: Text
  - `species_type`: Integer (0=plant, 1=animal)
  - `location`: Text
  - `date`: Text (ISO8601)
  - `quantity`: Integer
  - `description`: Text
  - `photo`: Text (file path)
  - `conservation_status`: Integer (0=Healthy, 1=Threatened, 2=Endangered, 3=Critical)
  - `habitat_type`: Integer (0=Forest, 1=Wetland, 2=Grassland, 3=Desert, 4=Marine, 5=Other)

## Technical Requirements

- Flutter SDK
- Dart
- SQLite (using the `sqflite` package)
- State Management (using the `provider` package)
- Add a PNG image named `placeholder.png` to the `assets/` directory for photo simulation.

## Screens

1. **Home Screen**: Displays a list of all observations with navigation options.
2. **Add/Edit Observation Screen**: Form for adding or editing observations.
3. **Observation Detail Screen**: Shows detailed information about a selected observation.
4. **Settings Screen**: Allows users to manage app settings.

## Installation

1. Clone the repository:
   ```
   git clone <repository-url>
   ```
2. Navigate to the project directory:
   ```
   cd conservation_data_app
   ```
3. Install dependencies:
   ```
   flutter pub get
   ```
4. Add a PNG image named `placeholder.png` to the `assets/` directory.
5. Run the app:
   ```
   flutter run
   ```

## Usage

- Launch the app and navigate through the screens to manage your conservation data.
- Use the Add Observation Screen to input new observations.
- View and edit existing observations from the Home Screen.

## Contributing

Contributions are welcome! Please submit a pull request or open an issue for any enhancements or bug fixes.

## License

This project is licensed under the MIT License - see the LICENSE file for details.