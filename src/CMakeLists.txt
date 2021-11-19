set(camera_SRCS
    main.cpp
    plasmacamera.cpp
    camerautils.cpp
    CameraPhotosModel.cpp
    resources.qrc
)

add_executable(camera ${camera_SRCS})
target_link_libraries(camera Qt5::Core Qt5::Qml Qt5::Quick Qt5::Svg
    KF5::CoreAddons
    KF5::I18n
    KF5::ConfigGui
    KF5::KIOCore
    KF5::KIOFileWidgets
    KF5::KIOWidgets
    mediainfo
    jappcoreqt)

kconfig_add_kcfg_files(camera GENERATE_MOC camerasettings.kcfgc)

if(ANDROID)
    target_link_libraries(camera Qt5::AndroidExtras Qt5::Svg KF5::Kirigami2)

    kirigami_package_breeze_icons(ICONS
        emblem-videos-symbolic
        camera-photo-symbolic
        dialog-error-symbolic
        media-playback-start
        media-playback-stop
        alarm-symbolic
        camera-photo
        ratiocrop
        whitebalance
        clock
        help-about
    )

endif()

install(TARGETS camera ${KF5_INSTALL_TARGETS_DEFAULT_ARGS})
