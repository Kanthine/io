package com.imooc.dongdongqiang.gaia.computer_principle;

import com.imooc.dongdongqiang.gaia.computer_principle.DoubleLinkList;
import com.imooc.dongdongqiang.gaia.computer_principle.Node;
import com.imooc.dongdongqiang.gaia.computer_principle.cache.FIFOCache;
import com.imooc.dongdongqiang.gaia.computer_principle.cache.LFUCache;
import com.imooc.dongdongqiang.gaia.computer_principle.cache.LRUCache;

import java.util.ArrayList;
import java.util.List;

public class Test {

    private static void testDoubleLinkList(){
        DoubleLinkList list = new DoubleLinkList();
        int size = 10;
        List<Node<Integer>> nodeList = new ArrayList<>();
        for(int i = 0; i < size; i ++){
            Node<Integer> node = new Node<>(i, i*i);
            nodeList.add(node);
        }
        list.append(nodeList.get(0));
        System.out.println(list.toString());
        list.append(nodeList.get(1));
        System.out.println(list.toString());
        list.append(nodeList.get(2));
        System.out.println(list.toString());
        list.pop();
        System.out.println(list.toString());
        list.appendFront(nodeList.get(3));
        System.out.println(list.toString());
        list.remove();
        System.out.println(list.toString());
        list.remove(nodeList.get(1));
        System.out.println(list.toString());
    }

    private static void testFIFOCache(){
        FIFOCache<Integer> fifoCache = new FIFOCache<>(2);
        fifoCache.put(1, 1);
        fifoCache.put(2, 2);
        fifoCache.put(3, 3);
        fifoCache.put(4, 4);
        System.out.println(fifoCache.get(1));
        System.out.println(fifoCache.toString());
        fifoCache.put(5, 5);
        System.out.println(fifoCache.get(1));
        System.out.println(fifoCache.toString());
        fifoCache.put(2, 20);
        System.out.println(fifoCache.toString());
    }

    private static void testLRUCache(){
        LRUCache<Integer> lruCache = new LRUCache<>(4);
        lruCache.put(1, 1);
        lruCache.put(2, 2);
        lruCache.put(3, 3);
        lruCache.put(4, 4);
        System.out.println(lruCache.toString());
        System.out.println(lruCache.get(1));
        System.out.println(lruCache.toString());
        lruCache.put(5, 5);
        System.out.println(lruCache.toString());
        System.out.println(lruCache.get(1));
        System.out.println(lruCache.toString());
        lruCache.put(2, 20);
        System.out.println(lruCache.toString());
    }

    private static void testLFUCache(){
        LFUCache<Integer> lfuCache = new LFUCache<>(4);
        lfuCache.put(1, 1);
        lfuCache.put(2, 2);
        lfuCache.put(3, 3);
        lfuCache.put(4, 4);
        System.out.println(lfuCache.toString());
        System.out.println(lfuCache.get(1));
        System.out.println(lfuCache.toString());
        lfuCache.put(5, 5);
        System.out.println(lfuCache.toString());
        System.out.println(lfuCache.get(1));
        System.out.println(lfuCache.toString());
        lfuCache.put(2, 20);
        System.out.println(lfuCache.toString());
        lfuCache.get(2);
        System.out.println(lfuCache.toString());
        lfuCache.get(2);
        System.out.println(lfuCache.toString());
    }

    public static void main(String []args){
        testDoubleLinkList();
        // testFIFOCache();
        // testLRUCache();
        // testLFUCache();
    }
}
