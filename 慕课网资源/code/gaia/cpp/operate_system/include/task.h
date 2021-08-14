#ifndef __TASK_H__
#define __TASK_H__

#include <iostream>
#include <pthread.h>

class Task
{
private:
    /* data */
    int result;

    bool done;
    pthread_mutex_t mutex;
    pthread_cond_t condition;
public:
    void set_result(int);
    int get_result();
    int callable();

    Task(){
        pthread_mutex_init(&mutex, NULL);
        pthread_cond_init(&condition, NULL);
        this->done = false;
    };
    ~Task(){
        std::cout << "delete task: " << this << std::endl;
    };
};

#endif