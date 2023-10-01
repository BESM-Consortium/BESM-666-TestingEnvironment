

add_library(besm666-integration-runtime STATIC)
target_sources(besm666-integration-runtime PRIVATE
    ./startup.s
)
set_property(SOURCE ./startup.s APPEND PROPERTY COMPILE_OPTIONS
    "-x" "assembler-with-cpp")
set_property(TARGET besm666-integration-runtime PROPERTY LINK_DEPENDS 
    ${CMAKE_CURRENT_SOURCE_DIR}/linker.ld)
target_link_options(besm666-integration-runtime PUBLIC
    "-T" "${CMAKE_CURRENT_SOURCE_DIR}/linker.ld"
    "-ffreestanding" "-nostdlib" "-fno-pie" "-fno-pic"
)
