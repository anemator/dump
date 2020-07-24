#ifndef ELEVATOR_H
#define ELEVATOR_H

#include <atomic>
#include <optional>
#include <condition_variable>
#include <thread>
#include <vector>

class Elevator final {
  std::condition_variable mCondVar;
  mutable std::mutex mMutex;
  std::atomic_bool mJoinThread;
  std::thread mThread;

  const int mId;
  std::atomic_int mFloorNum;
  const int mMinFloor;
  const int mMaxFloor;

public:
  typedef std::vector<int> Queue;
  typedef Queue::difference_type FloorDiffType;
  enum class Direction { Up, Down, Stand, Maintenance };

private:
  Direction mDirection;
  Queue mNextFloorQueue; // INVARIANT must always be sorted

private:
  std::optional<FloorDiffType> distToQueuedFloor(int num) const;

  void goToFloor(int num);

  void moveTo(int destFloor);

  void openDoor();

  void start();

  bool validFloor(int num) const;

public:
  Elevator(int id, int startFloor, int minFloor, int maxFloor);

  Elevator(const Elevator&) = delete;

  Elevator& operator=(const Elevator&) = delete;

  Elevator(Elevator&&) = delete;

  Elevator& operator=(Elevator&&) = delete;

  ~Elevator();

  std::optional<FloorDiffType> addFloor(int floorNum, bool now);

  std::optional<FloorDiffType> addFloorIfInPath(int destFloor);

  std::optional<FloorDiffType> distToFloor(int num, const Direction&) const;

  Direction getDirection() const;
};

inline Elevator::Direction Elevator::getDirection() const { return mDirection; }

#endif // ELEVATOR_H
