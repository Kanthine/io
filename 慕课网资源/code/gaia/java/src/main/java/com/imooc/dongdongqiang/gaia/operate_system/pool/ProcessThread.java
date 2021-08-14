package com.imooc.dongdongqiang.gaia.operate_system.pool;

import com.imooc.dongdongqiang.gaia.operate_system.ThreadSafeQueue;
import com.imooc.dongdongqiang.gaia.operate_system.task.AsyncTask;
import com.imooc.dongdongqiang.gaia.operate_system.task.Task;

public class ProcessThread extends Thread {


    private ThreadSafeQueue<Task> taskQueue;

    public ProcessThread(ThreadSafeQueue<Task> queue){
        super();
        this.taskQueue = queue;
    }

    @Override
    public void run(){
        while (true){
            try {
                Task task = this.taskQueue.pop(1);
                if (task == null){
                    continue;
                }
                System.out.println(String.format("Thread id: %d get a task.", Thread.currentThread().getId()));
                Object result = task.call();
                if(task instanceof AsyncTask){
                    ((AsyncTask) task).setResult(result);
                }
            } catch (Exception e){
                e.printStackTrace();
            }
        }
    }
}
