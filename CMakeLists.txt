project("filemgr" C)
cmake_minimum_required(VERSION 2.6)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/vala)
include(ValaPrecompile)
include(ValaVersion)

find_package(Vala)
ensure_vala_version("0.11.5" MINIMUM)

find_package(PkgConfig)
pkg_check_modules(GTK REQUIRED gtk+-2.0)
pkg_check_modules(GIO REQUIRED gio-2.0)
pkg_check_modules(GEE REQUIRED gee-1.0)
add_definitions(
    ${GTK_CFLAGS} ${GTK_CFLAGS_OTHER}
    ${GIO_CFLAGS} ${GIO_CFLAGS_OTHER}
    ${GEE_CFLAGS} ${GEE_CFLAGS_OTHER}
)
link_libraries(
    ${GTK_LIBRARIES}
    ${GIO_LIBRARIES}
    ${GEE_LIBRARIES}
)
link_directories(
    ${GTK_LIBRARY_DIRS}
    ${GIO_LIBRARY_DIRS}
    ${GEE_LIBRARY_DIRS}
)

vala_precompile(VALA_C
    "src/application_context.vala"
    "src/breadcrumbs.vala"
    "src/directory_controller.vala"
    "src/directory_view.vala"
    "src/main.vala"
    "src/main_window.vala"
    "src/navigator_controller.vala"
    "src/navigator_view.vala"
    "src/stock.vala"

    "src/actions/accelerator.vala"
    "src/actions/action.vala"
    "src/actions/action_context.vala"
    "src/actions/copy_file_action.vala"
    "src/actions/copy_file_action_configure_dialog.vala"
PACKAGES
    gtk+-2.0
    gio-2.0
    gee-1.0
OPTIONS
    -g --save-temps
)

add_executable("ginko" ${VALA_C})
