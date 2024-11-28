cmake_minimum_required(VERSION 3.25)

project(pinode_rpi)

set(CMAKE_CXX_STANDARD 20)

add_subdirectory(libbpl_sys)
add_subdirectory(libdevices_dht22)
add_subdirectory(libbpl_storage)
add_subdirectory(libbpl_net)
add_subdirectory(pinode)
