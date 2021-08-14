package com.imooc.dongdongqiang.gaia.operate_system.pool;

import com.imooc.dongdongqiang.gaia.operate_system.ThreadSafeQueue;
import com.imooc.dongdongqiang.gaia.operate_system.task.Task;

import java.util.List;

public class ThreadPool {

    private ThreadSafeQueue<ProcessThread> pool;

    private ThreadSafeQueue<Task> taskQueue;

    public ThreadPool(){
        this(4);
    }

    public ThreadPool(int size){
        this.pool = new ThreadSafeQueue<>(size);
        this.taskQueue = new ThreadSafeQueue<>();

        for(int i = 0; i < size; i++){
            this.pool.put(new ProcessThread(this.taskQueue));
        }
    }

    public void start(){
        for(int i = 0; i < this.pool.size(); i ++){
            ProcessThread thread = this.pool.get(i);
            thread.start();
        }
    }

    public void join() throws Exception{
        for(int i = 0; i < this.pool.size(); i ++){
            ProcessThread thread = this.pool.get(i);
            thread.stop();
        }
        while (this.pool.size() != 0){
            ProcessThread thread = this.pool.pop();
            thread.join();
        }
    }

    public void put(Task task){
        this.taskQueue.put(task);
    }

    public void batchPut(List<Task> taskList){
        for(Task task: taskList){
            this.put(task);
        }
    }

    public int size(){
        return this.pool.size();
    }
}
