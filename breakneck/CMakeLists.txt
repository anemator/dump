set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)

set(SRCS src/driver.cpp src/elevator.cpp src/elevator_bank_panel.cpp
  src/elevator_scheduler.cpp)

include_directories(include)
add_executable(breakneck ${SRCS})
target_link_libraries(breakneck PRIVATE Threads::Threads)
