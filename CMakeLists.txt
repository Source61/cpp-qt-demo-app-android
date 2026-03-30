cmake_minimum_required(VERSION 3.21)

project(MobileApp VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.5 REQUIRED COMPONENTS Quick QuickControls2)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(mobileapp
  src/main.cpp
)

qt_add_qml_module(mobileapp
  URI MobileApp
  VERSION 1.0
  QML_FILES
    qml/Main.qml
  RESOURCES
    icons/icon.svg
)

set_target_properties(mobileapp PROPERTIES
  MACOSX_BUNDLE TRUE
  WIN32_EXECUTABLE TRUE
  QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android"
)

# Android-specific settings
if(ANDROID)
  set_target_properties(mobileapp PROPERTIES
    QT_ANDROID_MIN_SDK_VERSION 26
    QT_ANDROID_TARGET_SDK_VERSION 34
  )
endif()

# iOS-specific settings
if(IOS)
  set_target_properties(mobileapp PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER "com.example.mobileapp"
    MACOSX_BUNDLE_BUNDLE_VERSION "${PROJECT_VERSION}"
    MACOSX_BUNDLE_SHORT_VERSION_STRING "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}"
  )
endif()

target_link_libraries(mobileapp PRIVATE
  Qt6::Quick
  Qt6::QuickControls2
)
