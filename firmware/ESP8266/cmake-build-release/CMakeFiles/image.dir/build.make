# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.12

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:


#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:


# Remove some rules from gmake that .SUFFIXES does not remove.
SUFFIXES =

.SUFFIXES: .hpux_make_needs_suffix_list


# Suppress display of executed commands.
$(VERBOSE).SILENT:


# A target that is always out of date.
cmake_force:

.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /opt/clion-183.3795.17/bin/cmake/linux/bin/cmake

# The command to remove a file.
RM = /opt/clion-183.3795.17/bin/cmake/linux/bin/cmake -E remove -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /home/paolo/workspace/CNC/firmware/ESP8266

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/paolo/workspace/CNC/firmware/ESP8266/cmake-build-release

# Utility rule file for image.

# Include the progress variables for this target.
include CMakeFiles/image.dir/progress.make

CMakeFiles/image:
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --blue --bold --progress-dir=/home/paolo/workspace/CNC/firmware/ESP8266/cmake-build-release/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "create image file"
	/home/paolo/esp2866/espressif/ESP8266_RTOS_SDK/components/esptool_py/esptool/esptool.py --chip esp8266 elf2image --flash_mode qio --flash_freq 40m --flash_size 4MB --version=3 -o ./firmware.bin ./firmware

image: CMakeFiles/image
image: CMakeFiles/image.dir/build.make

.PHONY : image

# Rule to build all files generated by this target.
CMakeFiles/image.dir/build: image

.PHONY : CMakeFiles/image.dir/build

CMakeFiles/image.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/image.dir/cmake_clean.cmake
.PHONY : CMakeFiles/image.dir/clean

CMakeFiles/image.dir/depend:
	cd /home/paolo/workspace/CNC/firmware/ESP8266/cmake-build-release && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/paolo/workspace/CNC/firmware/ESP8266 /home/paolo/workspace/CNC/firmware/ESP8266 /home/paolo/workspace/CNC/firmware/ESP8266/cmake-build-release /home/paolo/workspace/CNC/firmware/ESP8266/cmake-build-release /home/paolo/workspace/CNC/firmware/ESP8266/cmake-build-release/CMakeFiles/image.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/image.dir/depend
