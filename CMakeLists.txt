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
    -DGETTEXT_PACKAGE="ginko"
#    --include config.h
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
    "src/application.vala"
    "src/application_context.vala"
    "src/breadcrumbs.vala"
    "src/config.vala"
    "src/context.vala"
    "src/directory_controller.vala"
    "src/directory_model.vala"
    "src/directory_view.vala"
    "src/main.vala"
    "src/main_window.vala"
    "src/messages.vala"
    "src/navigator_controller.vala"
    "src/navigator_view.vala"
    "src/settings.vala"
    "src/sizes.vala"

    "src/actions/accelerator.vala"
    "src/actions/action_descriptor.vala"
    "src/actions/action_context.vala"
    "src/actions/basic_actions.vala"

    "src/actions/copy_file/copy_file_action.vala"
    "src/actions/copy_file/copy_file_config.vala"
    "src/actions/copy_file/copy_file_configure_dialog.vala"
    "src/actions/copy_file/copy_file_descriptor.vala"

    "src/actions/dialogs/abstract_message_dialog.vala"
    "src/actions/dialogs/overwrite_dialog.vala"
    "src/actions/dialogs/progress_dialog.vala"
    "src/actions/dialogs/rename_dialog.vala"

    "src/dialogs/abstract_dialog.vala"

    "src/format/attr_format.vala"
    "src/format/size_format.vala"
    "src/format/time_format.vala"

    "src/io/files.vala"
    "src/io/tree_scanner.vala"

    "src/operations/operation.vala"
    "src/operations/copy_file_operation.vala"

    "src/util/async_task.vala"
    "src/util/gui_executor.vala"
PACKAGES
    gtk+-2.0
    gio-2.0
    gee-1.0
    posix
OPTIONS
    --save-temps
    --disable-warnings
    --thread
CUSTOM_VAPIS
    "vapi/config.vapi"
)

add_executable(
    "ginko.bin"
    ${VALA_C} glib-2.0/schemas/gschemas.compiled
)

add_custom_command(
    OUTPUT glib-2.0/schemas/gschemas.compiled
    COMMAND glib-compile-schemas ARGS glib-2.0/schemas
    DEPENDS glib-2.0/schemas/ginko.gschema.xml
)
