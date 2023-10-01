cmake_minimum_required(VERSION 3.22.1)


set(CMAKE_CXX_STANDARD 17)
set(CMAKE_EXPORT_COMPILE_COMMANDS)

include(ExternalProject)


# Fetch all submodules
find_package(Git REQUIRED)
if(GIT_FOUND)
    option(BESM666_GIT_SUBMODULE "Check submodules during build" ON)
    if(BESM666_GIT_SUBMODULE)
        message(STATUS "Fetch RISCV tests submodules")
        execute_process(
            COMMAND ${GIT_EXECUTABLE} submodule update --init --recursive
                -- ./third_party/riscv-tests
            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
            RESULT_VARIABLE GIT_SUBMODULE_UPDATE_RESULT
        )
        if(NOT GIT_SUBMODULE_UPDATE_RESULT EQUAL "0")
            message(FATAL_ERROR "Failed to fetch RISCV tests submodules")
        endif()

        message(STATUS "Fetch RISCV GNU toolchain")
        execute_process(
            COMMAND ${GIT_EXECUTABLE} submodule update --init 
                -- ./third_party/riscv-gnu-toolchain
            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
            RESULT_VARIABLE GIT_SUBMODULE_UPDATE_RESULT
        )
        if(NOT GIT_SUBMODULE_UPDATE_RESULT EQUAL "0")
            message(FATAL_ERROR "Failed to fetch RISCV GNU toolchain")
        endif()
    endif()
endif()

# Setup sysroot folder for BESM666 environment
if(NOT DEFINED BESM666_FAKEROOT)
    message(FATAL_ERROR "BESM666_FAKEROOT should be specified")
    if(NOT EXISTS ${BESM666_FAKEROOT})
        execute_process(
            COMMAND mkdir -p ${BESM666_FAKEROOT}
            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
            RESULT_VARIABLE BESM666_MKDIR_RESULT
        )
        if(NOT ${BESM666_MKDIR_RESULT} EQUAL "0")
            message(FATAL_ERROR "Failed to create sysroot directory ${BESM666_FAKEROOT}")
        endif()
    endif()
    if(NOT IS_DIRECTORY ${BESM666_FAKEROOT})
        message(FATAL_ERROR "BESM666_FAKEROOT should be a path to directory")
    endif()
endif()

# Build RISCV toolchain
option(BESM666_SKIP_TOOLCHAIN_BUILD "Skip RISCV GNU toolchain build step" OFF)
if(NOT BESM666_SKIP_TOOLCHAIN_BUILD)
    ExternalProject_Add(riscv-gnu-toolchain
        SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/third_party/riscv-gnu-toolchain
        CONFIGURE_COMMAND 
            ${CMAKE_CURRENT_SOURCE_DIR}/third_party/riscv-gnu-toolchain/configure
            --prefix=${BESM666_FAKEROOT} --enable-multilib --disable-gdb
        BUILD_COMMAND ${MAKE}
    )
endif()

# Setup RISCV64 toolchain as CMake default
set(BESM666_GNU_TOOLCHAIN_BIN ${BESM666_FAKEROOT}/bin)

set(CMAKE_SYSTEM_NAME unknown)
set(CMAKE_SYSTEM_PROCESSOR riscv64)
set(CMAKE_SYSROOT ${BESM666_FAKEROOT})

set(CMAKE_C_COMPILER ${BESM666_GNU_TOOLCHAIN_BIN}/riscv64-unknown-elf-gcc)
set(CMAKE_CXX_COMPILER ${BESM666_GNU_TOOLCHAIN_BIN}/riscv64-unknown-elf-g++)
set(CMAKE_LINKER ${BESM666_GNU_TOOLCHAIN_BIN}/riscv64-unknown-elf-ld)
#set(CMAKE_ASM_COMPILER ${BESM666_GNU_TOOLCHAIN_BIN}/riscv64-unknown-elf-as)
set(CMAKE_OBJCOPY ${BESM666_GNU_TOOLCHAIN_BIN}/riscv64-unknown-elf-objcopy)
set(CMAKE_STRIP ${BESM666_GNU_TOOLCHAIN_BIN}/riscv64-unknown-elf-strip)
set(CMAKE_CPP ${BESM666_GNU_TOOLCHAIN_BIN}/riscv64-unknown-elf-cpp)

set(CMAKE_FIND_ROOT_PATH ${BESM666_GNU_TOOLCHAIN_BIN})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)

project(BESM-666-TestingEmvironment ASM C CXX)

# Build riscv-tests (can be used as tests development example)
ExternalProject_Add(riscv-tests
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/third_party/riscv-tests
    CONFIGURE_COMMAND 
        ${CMAKE_CURRENT_SOURCE_DIR}/third_party/riscv-tests/configure
        --prefix=${BESM666_FAKEROOT}
    BUILD_COMMAND 
        make RISCV_PREFIX=${BESM666_FAKEROOT}/bin/riscv64-unknown-elf-
    INSTALL_COMMAND
        make RISCV_PREFIX=${BESM666_FAKEROOT}/bin/riscv64-unknown-elf- install
)

add_subdirectory(./runtime)
add_subdirectory(./rv64i)
