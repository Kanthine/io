package com.imooc.dongdongqiang.gaia.computer_principle;

import com.alibaba.fastjson.JSON;

public class Node<T> {

    private T key;

    private T value;

    private Node prev;

    private Node next;

    public Node(T key, T value){
        this.key = key;
        this.value = value;
        this.prev = null;
        this.next = null;
    }

    public String toString(){
        return String.format("{key: %s, value: %s}", this.key, this.value);
    }

    public T getKey() {
        return key;
    }

    public void setKey(T key) {
        this.key = key;
    }

    public T getValue() {
        return value;
    }

    public void setValue(T value) {
        this.value = value;
    }

    public Node getPrev() {
        return prev;
    }

    public void setPrev(Node prev) {
        this.prev = prev;
    }

    public Node getNext() {
        return next;
    }

    public void setNext(Node next) {
        this.next = next;
    }
}
