include(vcpkg_common_functions)

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://git.assembla.com/portaudio.git
    REF 0cdb346fdca725cfc98da5cbe2d079096f91b624
    SHA512 2d984f5fca49a6c8477fa5216d0be9e3ef57d8943be4c5733ec288c31b3da645e34c160e5ed1dcc8eb5607b94c5b015b81a3551e684d6667e00c00c699ad524a
    PATCHES
        cmakelists-install.patch
        find_dsound.patch
        crt_linkage_build_config.patch
        pa_win_waveformat.patch
)

# NOTE: the ASIO backend will be built automatically if the ASIO-SDK is provided
# in a sibling folder of the portaudio source in vcpkg/buildtrees/portaudio/src
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DPA_USE_DS=ON
        -DPA_USE_WASAPI=ON
        -DPA_USE_WDMKS=ON
        -DPA_USE_WMME=ON
        -DPA_ENABLE_DEBUG_OUTPUT:BOOL=ON
)

vcpkg_install_cmake()

# Remove static builds from dynamic builds and otherwise
# Remove x86 and x64 from resulting files
if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
	file (REMOVE ${CURRENT_PACKAGES_DIR}/lib/portaudio_static_${VCPKG_TARGET_ARCHITECTURE}.lib)
	file (REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/portaudio_static_${VCPKG_TARGET_ARCHITECTURE}.lib)

	file (RENAME ${CURRENT_PACKAGES_DIR}/lib/portaudio_${VCPKG_TARGET_ARCHITECTURE}.lib ${CURRENT_PACKAGES_DIR}/lib/portaudio.lib)
	file (RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/portaudio_${VCPKG_TARGET_ARCHITECTURE}.lib ${CURRENT_PACKAGES_DIR}/debug/lib/portaudio.lib)
else ()
	file (RENAME ${CURRENT_PACKAGES_DIR}/lib/portaudio_static_${VCPKG_TARGET_ARCHITECTURE}.lib ${CURRENT_PACKAGES_DIR}/lib/portaudio.lib)
	file (RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/portaudio_static_${VCPKG_TARGET_ARCHITECTURE}.lib ${CURRENT_PACKAGES_DIR}/debug/lib/portaudio.lib)

	file (REMOVE ${CURRENT_PACKAGES_DIR}/lib/portaudio_${VCPKG_TARGET_ARCHITECTURE}.lib)
	file (REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
	file (REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/portaudio_${VCPKG_TARGET_ARCHITECTURE}.lib)
	file (REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
endif ()

vcpkg_copy_pdbs()

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/portaudio)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/portaudio/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/portaudio/copyright)

file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake/portaudio ${CURRENT_PACKAGES_DIR}/share/portaudio/cmake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)
