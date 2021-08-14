package com.imooc.dongdongqiang.gaia.operate_system.test;

import com.imooc.dongdongqiang.gaia.operate_system.pool.ThreadPool;
import com.imooc.dongdongqiang.gaia.operate_system.task.AsyncTask;
import com.imooc.dongdongqiang.gaia.operate_system.task.Task;

import java.util.ArrayList;
import java.util.List;

public class Test {

    public void simpleTest(){
        ThreadPool testPool = new ThreadPool();
        testPool.start();
        for(int i = 0; i < 10; i ++){
            SimpleTestTask task = new SimpleTestTask();
            testPool.put(task);
        }
    }

    public void simpleAsyncTest(){
        ThreadPool testPool = new ThreadPool();
        testPool.start();
        List<Task> taskArrayList = new ArrayList<>();
        for(int i = 0; i < 10; i ++){
            SimpleTestResultTask task = new SimpleTestResultTask();
            taskArrayList.add(task);
            testPool.put(task);
        }
        for(int i = 0; i < 10; i ++){
            AsyncTask task = (AsyncTask)taskArrayList.get(i);
            long currentTime = (Long)task.getResult();
            System.out.println((String.format("Get result from async task, current time: %d", currentTime)));
        }
    }

    public static void main(String[] args){
        Test test = new Test();
        test.simpleTest();
        test.simpleAsyncTest();
    }
}
