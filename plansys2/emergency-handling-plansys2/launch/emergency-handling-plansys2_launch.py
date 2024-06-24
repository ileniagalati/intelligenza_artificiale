# Copyright 2019 Intelligent Robotics Lab
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import os

from ament_index_python.packages import get_package_share_directory

from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument, IncludeLaunchDescription
from launch.launch_description_sources import PythonLaunchDescriptionSource
from launch.substitutions import LaunchConfiguration
from launch_ros.actions import Node


def generate_launch_description():
    # Get the launch directory
    example_dir = get_package_share_directory('emergency-handling-plansys2')
    namespace = LaunchConfiguration('namespace')

    declare_namespace_cmd = DeclareLaunchArgument(
        'namespace',
        default_value='',
        description='Namespace')

    plansys2_cmd = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(os.path.join(
            get_package_share_directory('plansys2_bringup'),
            'launch',
            'plansys2_bringup_launch_monolithic.py')),
        launch_arguments={
          'model_file': example_dir + '/pddl/domain.pddl',
          'namespace': namespace
          }.items())

    # Specify the actions
    move_cmd = Node(
        package='emergency-handling-plansys2',
        executable='move_node',
        name='move_node',
        namespace=namespace,
        output='screen',
        parameters=[])

    move_to_need_cmd = Node(
        package='emergency-handling-plansys2',
        executable='move_to_need_node',
        name='move_to_need_node',
        namespace=namespace,
        output='screen',
        parameters=[])
    
    move_agent_cmd = Node(
        package='emergency-handling-plansys2',
        executable='move_agent_node',
        name='move_agent_node',
        namespace=namespace,
        output='screen',
        parameters=[])
    
    load_box_cmd = Node(
        package='emergency-handling-plansys2',
        executable='load_box_node',
        name='load_box_node',
        namespace=namespace,
        output='screen',
        parameters=[])


    unload_box_cmd = Node(
        package='emergency-handling-plansys2',
        executable='unload_box_node',
        name='unload_box_node',
        namespace=namespace,
        output='screen',
        parameters=[])
    
    empty_box_cmd = Node(
        package='emergency-handling-plansys2',
        executable='empty_box_node',
        name='empty_box_node',
        namespace=namespace,
        output='screen',
        parameters=[])
    
    fill_cmd = Node(
        package='emergency-handling-plansys2',
        executable='fill_node',
        name='fill_node',
        namespace=namespace,
        output='screen',
        parameters=[]) 


# Create the launch description and populate
    ld = LaunchDescription()

    ld.add_action(declare_namespace_cmd)

    # Declare the launch options
    ld.add_action(plansys2_cmd)

    ld.add_action(move_cmd)
    ld.add_action(move_to_need_cmd)
    ld.add_action(move_agent_cmd)
    ld.add_action(fill_cmd)
    ld.add_action(empty_box_cmd)
    ld.add_action(load_box_cmd)
    ld.add_action(unload_box_cmd)
    
    
    
    

    return ld