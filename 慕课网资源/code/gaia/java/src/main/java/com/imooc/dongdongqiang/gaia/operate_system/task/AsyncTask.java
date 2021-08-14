package com.imooc.dongdongqiang.gaia.operate_system.task;

import java.lang.reflect.Method;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

public abstract class AsyncTask<T> extends Task {

    private Lock lock;

    private Condition condition;

    private T result;

    public AsyncTask(Class class_, String methodName, Class[] paramTypes, Object[] params){
        super(class_, methodName);
        callable.paramTypes = paramTypes;
        callable.params = params;
        this.lock = new ReentrantLock();
        this.condition = this.lock.newCondition();
    }

    public void setResult(T result){
        this.lock.lock();
        this.result = result;
        this.condition.signal();
        this.lock.unlock();
    }

    public T getResult(){
        T returnResult;
        this.lock.lock();
        if (this.result == null){
            try {
                this.condition.await();
            } catch (Exception e){
                e.printStackTrace();
            }
        }
        returnResult = this.result;
        this.lock.unlock();
        return returnResult;
    }
}
