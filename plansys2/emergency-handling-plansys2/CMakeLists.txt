cmake_minimum_required(VERSION 3.5)
project(emergency-handling-plansys2)


find_package(ament_cmake REQUIRED)
find_package(rclcpp REQUIRED)
find_package(rclcpp_action REQUIRED)
find_package(plansys2_msgs REQUIRED)
find_package(plansys2_executor REQUIRED)

set(CMAKE_CXX_STANDARD 17)

set(dependencies
    rclcpp
    rclcpp_action
    plansys2_msgs
    plansys2_executor
)

add_executable(empty_box_node src/empty_box.cpp)
ament_target_dependencies(empty_box_node ${dependencies})

add_executable(fill_node src/fill.cpp)
ament_target_dependencies(fill_node ${dependencies})

add_executable(load_box_node src/load_box.cpp)
ament_target_dependencies(load_box_node ${dependencies})

add_executable(move_node src/move.cpp)
ament_target_dependencies(move_node ${dependencies})

add_executable(move_to_need_node src/move_to_need.cpp)
ament_target_dependencies(move_to_need_node ${dependencies})

add_executable(move_agent_node src/move_agent.cpp)
ament_target_dependencies(move_agent_node ${dependencies})

add_executable(unload_box_node src/unload_box.cpp)
ament_target_dependencies(unload_box_node ${dependencies})

install(DIRECTORY launch pddl DESTINATION share/${PROJECT_NAME})

install(TARGETS
  empty_box_node
  fill_node
  load_box_node
  move_node
  move_to_need_node
  move_agent_node
  unload_box_node
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib
  RUNTIME DESTINATION lib/${PROJECT_NAME}
)

if(BUILD_TESTING)
  find_package(ament_lint_auto REQUIRED)
  ament_lint_auto_find_test_dependencies()

  find_package(ament_cmake_gtest REQUIRED)
endif()

ament_export_dependencies(${dependencies})

ament_package()