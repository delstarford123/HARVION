#!/bin/bash

# Ensure we are in the Flutter project root by checking for pubspec.yaml
if [ ! -f "pubspec.yaml" ]; then
    echo "Error: Please run this script from the root of your VINE Flutter project."
    exit 1
fi

echo "Building VINE architecture..."

# 1. Create the directories
mkdir -p lib/core
mkdir -p lib/shared/widgets
mkdir -p lib/features/home
mkdir -p lib/features/music
mkdir -p lib/features/library
mkdir -p lib/features/sermons
mkdir -p lib/features/farming
mkdir -p lib/features/profile

# 2. Create the core files
touch lib/core/theme.dart
touch lib/core/constants.dart
touch lib/core/main_navigation.dart

# 3. Create the shared widget files
touch lib/shared/widgets/custom_app_bar.dart
touch lib/shared/widgets/audio_player_widget.dart
touch lib/shared/widgets/content_card.dart
touch lib/shared/widgets/offline_banner.dart

# 4. Create the feature files (Home)
touch lib/features/home/home_screen.dart
touch lib/features/home/quote_model.dart

# 5. Create the feature files (Music)
touch lib/features/music/music_screen.dart
touch lib/features/music/music_player_screen.dart
touch lib/features/music/song_model.dart

# 6. Create the feature files (Library)
touch lib/features/library/library_screen.dart
touch lib/features/library/pdf_viewer_screen.dart
touch lib/features/library/book_model.dart

# 7. Create the feature files (Sermons)
touch lib/features/sermons/sermons_screen.dart
touch lib/features/sermons/sermon_model.dart

# 8. Create the feature files (Farming)
touch lib/features/farming/farming_screen.dart
touch lib/features/farming/category_detail_screen.dart
touch lib/features/farming/farming_topic_model.dart

# 9. Create the feature files (Profile)
# Ready for your Delstarford Works bio and innovator background
touch lib/features/profile/profile_screen.dart

echo "Success! All folders and files have been created."