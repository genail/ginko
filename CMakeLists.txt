project("filemgr" C)
cmake_minimum_required(VERSION 2.6)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/vala)
include(ValaPrecompile)
include(ValaVersion)

find_package(Vala)
ensure_vala_version("0.7.8" MINIMUM)

find_package(PkgConfig)
pkg_check_modules(GTK REQUIRED gtk+-2.0)
pkg_check_modules(GIO REQUIRED gio-2.0)
pkg_check_modules(GNOME_VFS REQUIRED gnome-vfs-2.0)
pkg_check_modules(GNOME_UI REQUIRED libgnomeui-2.0)
add_definitions(
    ${GTK_CFLAGS} ${GTK_CFLAGS_OTHER}
    ${GIO_CFLAGS} ${GIO_CFLAGS_OTHER}
    ${GNOME_VFS_CFLAGS} ${GNOME_VFS_CFLAGS_OTHER}
    ${GNOME_UI_CFLAGS} ${GNOME_UI_CFLAGS_OTHER}
)
link_libraries(${GTK_LIBRARIES} ${GIO_LIBRARIES} ${GNOME_VFS_LIBRARIES} ${GNOME_UI_LIBRARIES})
link_directories(${GTK_LIBRARY_DIRS} ${GIO_LIBRARY_DIRS} ${GNOME_VFS_LIBRARY_DIRS} ${GNOME_UI_LIBRARY_DIRS})

vala_precompile(VALA_C
    "src/main.vala"
    "src/main_window.vala"
    "src/directory_view.vala"
    "src/directory_controller.vala"
PACKAGES
    gtk+-2.0
    gio-2.0
    gnome-vfs-2.0
    libgnomeui-2.0
)

add_executable("ginko" ${VALA_C})
