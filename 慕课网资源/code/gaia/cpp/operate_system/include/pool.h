#ifndef __GAIA_POOL_H__
#define __GAIA_POOL_H__

#include "task.h"
#include "queue.h"
#include <thread>
#include <pthread.h>

class ThreadPool
{
private:
    int size;
    bool flag;
    pthread_t* pool;
    ThreadSafeQueue* queue;

public:
    void process();
    ThreadPool(int size);
    ~ThreadPool()
    {
        delete this->pool;
        delete this->queue;
    };

    void start();
    void put(Task*);
    void stop();
    void join(); 
};

void* wrapper(void* p);

#endif
