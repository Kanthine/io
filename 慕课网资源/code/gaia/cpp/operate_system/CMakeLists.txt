cmake_minimum_required (VERSION 2.8)
project(computer_priciple)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g -std=gnu++11 -Wall ")

include_directories(./include)
aux_source_directory(./src SRC_DIR)
link_libraries(pthread)
add_executable(main main.cpp ${SRC_DIR})
