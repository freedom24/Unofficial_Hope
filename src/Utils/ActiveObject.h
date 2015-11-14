    /*
    ---------------------------------------------------------------------------------------
    This source file is part of SWG:ANH (Star Wars Galaxies - A New Hope - Server Emulator)

    For more information, visit http://www.swganh.com

    Copyright (c) 2006 - 2015 The SWG:ANH Team /Unofficial Hope Edit
    ---------------------------------------------------------------------------------------
    Use of this source code is governed by the GPL v3 license that can be found
    in the COPYING file or at http://www.gnu.org/licenses/gpl-3.0.html

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
    ---------------------------------------------------------------------------------------
    */

    #ifndef SRC_UTILS_ACTIVEOBJECT_H_
    #define SRC_UTILS_ACTIVEOBJECT_H_

    #include <functional>
    #include <memory>
    #include <thread>
    #include <mutex>
    #include <chrono>
    #include <condition_variable>
    #include "logger.h"

    #include <tbb/concurrent_queue.h>

    namespace utils {

    class ActiveObject {
    public:
        // Messages are implemented as std::function to allow maximum flexibility for
        // how a message can be created with support for functions, functors, class members,
        // and most importantly lambdas.

        typedef std::function<void()> AO_Message;

    public:
    public:
        // Messages are implemented as std::function to allow maximum flexibility for
        // how a message can be created with support for functions, functors, class members,
        // and most importantly lambdas.

        typedef std::function<void()> AO_Message;

    public:
        // Default constructor kicks off the private thread that listens for incoming messages.
        ActiveObject(){

            done_ = false;
            thread_ = std::move(std::thread([=] { this->Run(); }));

            }

        // Default destructor sends an end message and waits for the private thread to complete.
        ~ActiveObject(){
            Send([&] { done_ = true; });
            thread_.join();
            }

        void Send(AO_Message message){
            message_queue_.push(message);
            condition_.notify_one();
            }

    private:
        /// Runs the ActiveObject's message loop until an end message is received.
        void Run(){
            AO_Message message;

            std::unique_lock<std::mutex> lock(mutex_);

            while (! done_) {

                    condition_.wait_for(lock, std::chrono::milliseconds(1000));

                    if(message_queue_.try_pop(message)) {
                            message();
                            }

                    }//while

            }

        tbb::concurrent_queue<AO_Message> message_queue_;

        std::thread                         thread_;
        std::condition_variable        condition_;
        std::mutex                          mutex_;

        bool done_;
    };
    }  // namespace utils

    #endif  // SRC_UTILS_ACTIVEOBJECT_H_
