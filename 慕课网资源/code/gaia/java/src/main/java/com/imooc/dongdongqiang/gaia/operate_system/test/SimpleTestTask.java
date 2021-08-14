package com.imooc.dongdongqiang.gaia.operate_system.test;

import com.imooc.dongdongqiang.gaia.operate_system.task.Task;

public class SimpleTestTask extends Task {

    public SimpleTestTask(){
        super(SimpleTestTask.class, "process");
    }

    public void process(){
        try {
            System.out.println(String.format("{%d} This is a process from SimpleTask 1.", System.currentTimeMillis()));
            Thread.sleep(1000);
            System.out.println(String.format("{%d} This is a process from SimpleTask 2.", System.currentTimeMillis()));
            Thread.sleep(1000);
        } catch (Exception e){
            e.printStackTrace();
        }
    }
}
