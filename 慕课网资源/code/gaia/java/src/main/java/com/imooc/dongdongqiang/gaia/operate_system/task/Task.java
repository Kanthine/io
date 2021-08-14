package com.imooc.dongdongqiang.gaia.operate_system.task;

import java.lang.reflect.Method;
import java.lang.reflect.Parameter;
import java.util.UUID;

public class Task {

    private UUID id;

    protected Callable callable;

    public Task(Class class_, String methodName){
        callable = new Callable();
        callable.aClass = class_;
        callable.methodName = methodName;

        this.id = UUID.randomUUID();
    }

    public Object call() throws Exception{
        Method method = callable.aClass.getMethod(callable.methodName);
        Task task = (Task)callable.aClass.getDeclaredConstructor().newInstance();
        return method.invoke(task);
    }

    public UUID getId() {
        return id;
    }

    public Callable getCallable() {
        return callable;
    }
}
