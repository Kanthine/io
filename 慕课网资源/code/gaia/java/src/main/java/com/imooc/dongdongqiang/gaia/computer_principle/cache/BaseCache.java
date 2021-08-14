package com.imooc.dongdongqiang.gaia.computer_principle.cache;

import com.imooc.dongdongqiang.gaia.computer_principle.DoubleLinkList;
import com.imooc.dongdongqiang.gaia.computer_principle.Node;

import java.util.HashMap;
import java.util.Map;

public abstract class BaseCache<T> {

    protected Map<T, Node> map;

    protected DoubleLinkList list;

    public BaseCache(){
        this.map = new HashMap<>();
        this.list = new DoubleLinkList();
    }

    public BaseCache(long capacity){
        this.map = new HashMap<>();
        this.list = new DoubleLinkList(capacity);
    }

    abstract public T get(T key);

    abstract public void put(T key, T value);

    public String toString(){
        return this.list.toString();
    }

}
