package com.imooc.dongdongqiang.gaia.operate_system;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

public class ThreadSafeQueue<T> {

    private List<T> queue;

    private int maxSize;

    private Lock lock;

    private Condition condition;

    public ThreadSafeQueue(){
        this.maxSize = 0;
        this.queue = new ArrayList<>();
        this.lock = new ReentrantLock();
        this.condition = this.lock.newCondition();
    }

    public ThreadSafeQueue(int maxSize){
        this.maxSize = maxSize;
        this.queue = new ArrayList<>();
        this.lock = new ReentrantLock();
        this.condition = this.lock.newCondition();
    }

    public int size(){
        int len;
        this.lock.lock();
        len = this.queue.size();
        this.lock.unlock();
        return len;
    }

    public void put(T item){
        if (this.maxSize != 0 && this.size() > this.maxSize){
            System.err.println("ThreadSafeQueue full...");
            return;
        }
        this.lock.lock();
        this.queue.add(item);
        this.condition.signal();
        this.lock.unlock();
    }

    public void batchPut(List<T> items){
        for(T item: items){
            this.put(item);
        }
    }

    public T pop(){
        return this.pop(true, 0);
    }

    public T pop(int timeout){
        return this.pop(true, timeout);
    }

    public T pop(boolean block, int timeout){
        if (this.size() == 0){
            if (block){
                try {
                    this.lock.lock();
                    this.condition.await(timeout, TimeUnit.SECONDS);
                } catch (Exception e){
                    e.printStackTrace();
                }finally {
                    this.lock.unlock();
                }
            } else {
                return null;
            }
        }
        T item = null;
        this.lock.lock();
        if (this.queue.size() > 0) {
            item = this.queue.remove(0);
        }
        this.lock.unlock();
        return item;
    }

    public T get(int index){
        this.lock.lock();
        T item = null;
        try {
            item = this.queue.get(index);
        } catch (Exception e){
            e.printStackTrace();
        }
        return item;
    }

    public static void main(String[] args){
        ThreadSafeQueue<Integer> queue = new ThreadSafeQueue<>(100);
        new Thread(() -> {
            int num = 0;
            while (true){
                try {
                    queue.put(num);
                    Thread.sleep(1000);
                    System.out.println("put item to queue: " + num);
                    num += 1;
                } catch (Exception e){
                    e.printStackTrace();
                }
            }
        }).start();

        new Thread(() -> {
            while (true){
                try {
                    int item = queue.pop();
                    System.out.println("get item from queue: " + item);
                    Thread.sleep(500);
                } catch (Exception e){
                    continue;
                }
            }
        }).start();
    }
}
