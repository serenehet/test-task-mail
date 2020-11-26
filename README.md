# test-task-mail
Тестовое задание для вакансию iOS-разработчик в почту mail.ru

Problem
Implement an iOS app that presents movie and music items from iTunes using iTunes Search API (https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/iTuneSearchAPI/Searching.html#//apple_ref/doc/uid/TP40017632-CH5-SW1). Running the app should bring user to the main screen with the following layout:

1. Header with currently using string for searching content which is hardcoded in the app.
2. Section with movie items. Each item should contain at least avatar and title.
3. Section with music items. Each item should contain at least avatar and title.

Requirements
1. The app must perform all required HTTP requests for filling up main page in parallel.
2. The user should be informed if an error occurred while fetching
the data.
