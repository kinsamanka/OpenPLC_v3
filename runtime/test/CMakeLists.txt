# Copyright 2019 Smarter Grid Solutions
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http ://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

cmake_minimum_required(VERSION 3.0.0)

# This set builds unit tests that we can execute to validate the behavior
# of the core runtime.

include_directories(../core)
include_directories(../core/lib)
include_directories(../vendor/catch2-2.7.0)
include_directories(../vendor/fakeit-2.0.5)
include_directories(../vendor/inih-r46)

if (NOT OPLC_DNP3_OUTSTATION)
    message(WARNING "Building of tests does not have DNP3 outstation enabled")
endif()

# This is all of our test files
file(GLOB oplctest_SRC *.cpp **/*.cpp)
file(GLOB oplc_core_SRC ../core/ini_util.cpp ../core/pstorage.cpp ../core/server.cpp ../core/dnp3s/*.cpp ../core/modbusslave/*.cpp)

add_executable(oplc_unit_test ${oplctest_SRC} ${oplc_core_SRC} ../core/glue.cpp ../vendor/inih-r46/ini.c)

target_link_libraries(oplc_unit_test ${OPLC_PTHREAD})
if (OPLC_DNP3_OUTSTATION)
    target_link_libraries(oplc_unit_test asiodnp3)
endif()

enable_testing()
add_test(NAME oplc_test COMMAND oplc_unit_test)
