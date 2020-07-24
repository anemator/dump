#include <algorithm>
#include <cassert>
#include <iostream>
#include "elevator.h"

namespace {
std::mutex ioMutex;
}

Elevator::Elevator(int id, int startFloor, int minFloor, int maxFloor)
    : mJoinThread(false), mThread(&Elevator::start, this)
    , mId(id), mFloorNum(startFloor), mMinFloor(minFloor)
    , mMaxFloor(maxFloor) , mDirection(Direction::Stand) {
    assert(minFloor < maxFloor && "minFloor must be less than maxFloor");
    assert(validFloor(startFloor) && "startFloor not within range");
}

Elevator::~Elevator() {
    std::unique_lock<std::mutex> guard(mMutex);
    mJoinThread = true;
    guard.unlock();
    mCondVar.notify_one();
    mThread.join();
}

std::optional<Elevator::FloorDiffType>
Elevator::addFloor(int floorNum, bool now) {
    if (!validFloor(floorNum)) {
        return std::nullopt;
    }
    if (now) {
        std::unique_lock<std::mutex> guard(mMutex);
        if (mNextFloorQueue.front() != floorNum) {
            std::remove(mNextFloorQueue.begin(), mNextFloorQueue.end(), floorNum);
            mNextFloorQueue.emplace(mNextFloorQueue.begin(), floorNum);
        }
        guard.unlock();
        mCondVar.notify_one();
        return std::make_optional(0L);
    } else {
        if (auto dist = distToQueuedFloor(floorNum)) {
            return dist;
        }
        goToFloor(floorNum);
        return distToQueuedFloor(floorNum);
    }
}

std::optional<Elevator::FloorDiffType>
Elevator::addFloorIfInPath(int destFloor) {
    if (!validFloor(destFloor)) {
        return std::nullopt;
    }
    if (auto dist = distToQueuedFloor(destFloor)) {
        return dist;
    }
    if (mDirection == Direction::Stand
        || destFloor == mMinFloor || destFloor == mMaxFloor
        || (destFloor < mFloorNum && mDirection == Direction::Down)
        || (destFloor > mFloorNum && mDirection == Direction::Up)) {
        goToFloor(destFloor);
        return distToQueuedFloor(destFloor);
    }
    return std::nullopt;
}

std::optional<Elevator::FloorDiffType>
Elevator::distToQueuedFloor(int num) const {
    std::unique_lock<std::mutex> guard(mMutex);
    auto itr = std::find(mNextFloorQueue.cbegin(), mNextFloorQueue.cend(), num);
    if (itr == mNextFloorQueue.cend()) {
       return std::nullopt;
    }
    auto dist = std::distance(itr, mNextFloorQueue.cend());
    guard.unlock();
    return std::make_optional(std::abs(dist));
}

std::optional<Elevator::FloorDiffType>
Elevator::distToFloor(int num, const Direction& dir) const {
    using std::make_optional;
    switch (dir) {
      case Direction::Up:
          return make_optional(static_cast<FloorDiffType>(num - mFloorNum));
      case Direction::Down:
          return make_optional(static_cast<FloorDiffType>(mFloorNum - num));
      case Direction::Stand:
      case Direction::Maintenance:
          return std::nullopt;
      default:
          assert(false);
    }
}

void Elevator::goToFloor(int num) {
    std::unique_lock<std::mutex> guard(mMutex);
    mNextFloorQueue.emplace_back(num);
    std::sort(mNextFloorQueue.begin(), mNextFloorQueue.end());
    guard.unlock();
    mCondVar.notify_one();
}

void Elevator::moveTo(int destFloor) {
    if (destFloor < mFloorNum) {
        mDirection = Direction::Down;
    } else if (destFloor > mFloorNum) {
        mDirection = Direction::Up;
    }
    for (; destFloor != mFloorNum;) {
        switch (mDirection) {
          case Direction::Up:
            // std::this_thread::sleep_for(std::chrono::seconds(1));
            ++mFloorNum;
            break;
          case Direction::Down:
            // std::this_thread::sleep_for(std::chrono::seconds(1));
            --mFloorNum;
            break;
          case Direction::Maintenance:
          case Direction::Stand:
            assert(destFloor == mFloorNum && "Cannot move in Stand/Maintenance");
            break;
          default:
            assert(false);
        }
    }
    assert(validFloor(mFloorNum) && "Cannot move to floor");
}

void Elevator::openDoor() {
    std::lock_guard<std::mutex> guard(::ioMutex);
    std::cout << mId << ": " << mFloorNum << '\n';
    //std::this_thread::sleep_for(std::chrono::seconds(1));
    //closeDoor();
}

void Elevator::start() {
    for (;;) {
        std::unique_lock<std::mutex> guard(mMutex);
        if (mNextFloorQueue.empty()) {
            mCondVar.wait(guard);
        }
        if (mJoinThread) {
            return;
        }
        if (mNextFloorQueue.size() < 1) {
            continue;
        }
        auto destFloor = mNextFloorQueue.front();
        mNextFloorQueue.erase(mNextFloorQueue.cbegin());
        guard.unlock();
        moveTo(destFloor);
        openDoor();
    }
}

inline bool Elevator::validFloor(int num) const {
    return num >= mMinFloor && num <= mMaxFloor;
}
