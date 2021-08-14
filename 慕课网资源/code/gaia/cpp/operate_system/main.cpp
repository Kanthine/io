#include "task.h"
#include "queue.h"
#include "pool.h"

#include <iostream>

int main()
{
    ThreadPool* pool = new ThreadPool(4);
    pool->start();
    std::vector<Task*> tasks;
    for(int i = 0; i < 100; i ++){
        Task* task = new Task();
        tasks.push_back(task);
    }
    for(int i = 0; i < tasks.size(); i ++){
        pool->put(tasks[i]);
    }
    for(int i = 0; i < tasks.size(); i ++){
        int result = tasks[i]->get_result();
        std::cout << "Get result from task [" << i << "], result = " << result << std::endl;
        delete tasks[i];
    }
    pool->stop();
    pool->join();
    delete pool;
    
}
