#include "task.h"

#include <thread>
#include <chrono>

void Task::set_result(int result){
    pthread_mutex_lock(&mutex);
    this->result = result;
    this->done = true;
    pthread_mutex_unlock(&mutex);
    pthread_cond_signal(&condition);
}

int Task::get_result(){
    pthread_mutex_lock(&mutex);
    int r = 0;
    if ( this->done ){
        r = this->result;
    } else{
        pthread_cond_wait(&condition, &mutex);
        r = this->result;
    }
    pthread_mutex_unlock(&mutex);
    return r;
}

int Task::callable(){
    std::chrono::milliseconds ms = std::chrono::duration_cast< std::chrono::milliseconds >(
        std::chrono::system_clock::now().time_since_epoch()
    );
    // std::this_thread::sleep_for(std::chrono::seconds(1));
    return ms.count()/1000;
}
