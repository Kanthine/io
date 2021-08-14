#ifndef __QUEUE_H__
#define __QUEUE_H__

#include "task.h"

#include <list>
#include <vector>
#include <pthread.h>

class ThreadSafeQueue
{
private:
    /* data */
    int queue_size;
    std::list<Task*>* queue;
    pthread_mutex_t mutex;
    pthread_cond_t condition;

public:
    int size();
    void put(Task*);
    void batch_put(std::vector<Task*>);
    Task* pop();
    ThreadSafeQueue(){
        queue_size = 0;
        pthread_mutex_init(&mutex, NULL);
        pthread_cond_init(&condition, NULL);
        this->queue = new std::list<Task*>();
    };
    ~ThreadSafeQueue(){/* delete items of queue. */};
};

#endif