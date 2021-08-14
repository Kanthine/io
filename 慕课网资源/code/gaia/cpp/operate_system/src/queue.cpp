#include "queue.h"

#include <iostream>

int ThreadSafeQueue::size(){
    return this->queue_size;
}

void ThreadSafeQueue::put(Task* item){
    pthread_mutex_lock(&mutex);
    this->queue->push_back(item);
    this->queue_size += 1;
    pthread_mutex_unlock(&mutex);
    pthread_cond_signal(&condition);
}

void ThreadSafeQueue::batch_put(std::vector<Task*> items){
    int size = items.size();
    for(int i = 0; i < size; i ++){
        Task* item = items[i];
        this->put(item);
    } 
}

Task* ThreadSafeQueue::pop(){
    pthread_mutex_lock(&mutex);
    while (this->queue_size == 0){
        pthread_cond_wait(&condition, &mutex);
    }
    Task* item = this->queue->front();
    this->queue->pop_front();
    this->queue_size -= 1;
    pthread_mutex_unlock(&mutex);
    return item;
}
