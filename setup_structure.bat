@echo off
echo Building VINE architecture...

:: 1. Create the directories
mkdir lib\core 2>NUL
mkdir lib\shared\widgets 2>NUL
mkdir lib\features\home 2>NUL
mkdir lib\features\music 2>NUL
mkdir lib\features\library 2>NUL
mkdir lib\features\sermons 2>NUL
mkdir lib\features\farming 2>NUL
mkdir lib\features\profile 2>NUL

:: 2. Create the core files
type NUL > lib\core\theme.dart
type NUL > lib\core\constants.dart
type NUL > lib\core\main_navigation.dart

:: 3. Create the shared widget files
type NUL > lib\shared\widgets\custom_app_bar.dart
type NUL > lib\shared\widgets\audio_player_widget.dart
type NUL > lib\shared\widgets\content_card.dart
type NUL > lib\shared\widgets\offline_banner.dart

:: 4. Create the feature files (Home)
type NUL > lib\features\home\home_screen.dart
type NUL > lib\features\home\quote_model.dart

:: 5. Create the feature files (Music)
type NUL > lib\features\music\music_screen.dart
type NUL > lib\features\music\music_player_screen.dart
type NUL > lib\features\music\song_model.dart

:: 6. Create the feature files (Library)
type NUL > lib\features\library\library_screen.dart
type NUL > lib\features\library\pdf_viewer_screen.dart
type NUL > lib\features\library\book_model.dart

:: 7. Create the feature files (Sermons)
type NUL > lib\features\sermons\sermons_screen.dart
type NUL > lib\features\sermons\sermon_model.dart

:: 8. Create the feature files (Farming)
type NUL > lib\features\farming\farming_screen.dart
type NUL > lib\features\farming\category_detail_screen.dart
type NUL > lib\features\farming\farming_topic_model.dart

:: 9. Create the feature files (Profile)
type NUL > lib\features\profile\profile_screen.dart

echo Success! All folders and files have been created.