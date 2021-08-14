package com.imooc.dongdongqiang.gaia.computer_principle.cache;

import com.imooc.dongdongqiang.gaia.computer_principle.DoubleLinkList;
import com.imooc.dongdongqiang.gaia.computer_principle.Node;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

public class LFUCache<T> extends BaseCache<T> {

    class LFUNode<T> extends Node<T>{

        private int freq;


        public LFUNode(T key, T value) {
            super(key, value);
            this.freq = 0;
        }
    }

    private Map<Integer, DoubleLinkList> freqMap;


    private int size;

    private long capacity;

    public LFUCache(long capacity){
        super();
        this.size = 0;
        this.capacity = capacity;
        this.freqMap = new HashMap<>();
    }

    /**
     * def update_freq(self, node):
     *         freq = node.freq
     *         node = self.freq_map[freq].remove(node)
     *         if self.freq_map[freq].size == 0:
     *             del self.freq_map[freq]
     *         freq += 1
     *         node.freq = freq
     *         if freq not in self.freq_map:
     *             self.freq_map[freq] = DoubleLinkedList()
     *         self.freq_map[freq].append(node)
     */
    private void updateFreq(LFUNode node){
        int freq = node.freq;
        node = (LFUNode)this.freqMap.get(freq).remove(node);
        if(this.freqMap.get(freq).getSize() == 0){
            this.freqMap.remove(freq);
        }
        freq += 1;
        node.freq = freq;
        if (! this.freqMap.containsKey(freq)){
            this.freqMap.put(freq, new DoubleLinkList());
        }
        this.freqMap.get(freq).append(node);
    }

    /**
     * def get(self, key):
     *         """
     *         :type key: int
     *         :rtype: int
     *         """
     *         if key not in self.map:
     *             return -1
     *         else:
     *             node = self.map.get(key)
     *             self.update_freq(node)
     *             return node.value
     */
    public T get(T key){
        if(! this.map.containsKey(key)){
            return null;
        }
        LFUNode node = (LFUNode)this.map.get(key);
        this.updateFreq(node);
        return (T)node.getValue();
    }

    /**
     * def put(self, key, value):
     *         """
     *         :type key: int
     *         :type value: int
     *         :rtype: None
     *         """
     *         if self.capacity == 0:
     *             return
     *
     *         if key in self.map:
     *             node = self.map.get(key)
     *             node.value = value
     *             self.update_freq(node)
     *         else:
     *             if self.size == self.capacity:
     *                 min_freq = min(self.freq_map)
     *                 node = self.freq_map[min_freq].pop()
     *                 del self.map[node.key]
     *                 self.size -= 1
     *             node = LFUNode(key, value)
     *             node.freq = 1
     *             self.map[key] = node
     *             if 1 not in self.freq_map:
     *                 self.freq_map[1] = DoubleLinkedList()
     *             node = self.freq_map[1].append(node)
     *             self.size += 1
     */
    public void put(T key, T value){
        if (this.capacity == 0){
            return;
        }
        if (this.map.containsKey(key)){
            LFUNode node = (LFUNode)this.map.get(key);
            node.setValue(value);
            this.updateFreq(node);
        } else {
            if (this.size == this.capacity){
                Set<Integer> set = this.freqMap.keySet();
                Object[] obj = set.toArray();
                Arrays.sort(obj);
                int minFreq = (Integer)obj[0];
                Node node = this.freqMap.get(minFreq).pop();
                this.map.remove(node.getKey());
                this.size -= 1;
            }
            LFUNode node = new LFUNode(key, value);
            node.freq = 1;
            this.map.put(key, node);
            if (! this.freqMap.containsKey(node.freq)){
                this.freqMap.put(node.freq, new DoubleLinkList());
            }
            this.freqMap.get(node.freq).append(node);
            this.size += 1;
        }
    }

    public String toString(){
        StringBuffer buffer = new StringBuffer();
        buffer.append("**********************\r\n");
        for(int key: this.freqMap.keySet()){
            buffer.append(String.format("%d: %s", key, this.freqMap.get(key)));
            buffer.append("\r\n");
        }
        return buffer.toString().trim();
    }
}
