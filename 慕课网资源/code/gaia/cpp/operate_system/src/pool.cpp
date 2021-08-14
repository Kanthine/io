#include "pool.h"


void* wrapper(void* p){
    ThreadPool *pool = (ThreadPool*)p;
    pool->process();
}

ThreadPool::ThreadPool(int size){
    if(size == 0){
        size = 4;
    }
    this->size = size;
    this->flag = true;
    this->queue = new ThreadSafeQueue();
    pool = (pthread_t*)malloc(sizeof(pthread_t) * size);

    for (int i = 0; i < size; i++)
    {
        pthread_create(&pool[i], NULL, wrapper, this);
    }

}

void ThreadPool::start(){
    // already start in constructor.
}

void ThreadPool::join(){
    for(int i = 0; i < size; i ++){
        pthread_join(pool[i], NULL);
    }
}

void ThreadPool::put(Task* task){
    this->queue->put(task);
}

void ThreadPool::process()
{
    while (flag){
        Task* task = this->queue->pop();
        int result = task->callable();
        task->set_result(result);
    }
}

void ThreadPool::stop(){
    this->flag = false;
}