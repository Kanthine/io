package com.imooc.dongdongqiang.gaia.operate_system.test;

import com.imooc.dongdongqiang.gaia.operate_system.task.AsyncTask;

public class SimpleTestResultTask extends AsyncTask {

    public SimpleTestResultTask(){
        super(SimpleTestResultTask.class, "process", null, null);
    }

    public long process(){
        try {
            System.out.println(String.format("{%d} This is a process from SimpleTestResultTask 1.", System.currentTimeMillis()));
            Thread.sleep(1000);
            System.out.println(String.format("{%d} This is a process from SimpleTestResultTask 2.", System.currentTimeMillis()));
            Thread.sleep(1000);
        } catch (Exception e){
            e.printStackTrace();
        }
        return System.currentTimeMillis();
    }
}
