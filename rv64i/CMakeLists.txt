

add_executable(besm666-integration-dummy)
target_sources(besm666-integration-dummy PRIVATE
    ./dummy.s)
set_property(SOURCE ./dummy.s APPEND PROPERTY COMPILE_OPTIONS
    "-x" "assembler-with-cpp")
target_link_libraries(besm666-integration-dummy PRIVATE
    besm666-integration-runtime
)

