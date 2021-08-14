package com.imooc.dongdongqiang.gaia.computer_principle.cache;

import com.imooc.dongdongqiang.gaia.computer_principle.Node;


public class FIFOCache<T> extends BaseCache<T> {

    public FIFOCache(long capacity){
        super(capacity);
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
     *             return node.value
     */
    public T get(T key){
        if (! this.map.containsKey(key)){
            return null;
        }
        Node node = this.map.get(key);
        T value = (T)node.getValue();
        return value;
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
     *             self.list.remove(node)
     *             self.list.append(node)
     *         else:
     *             if self.size == self.capacity:
     *                 node = self.list.pop()
     *                 del self.map[node.key]
     *                 self.size -= 1
     *
     *             node = Node(key, value)
     *             self.list.append(node)
     *             self.map[key] = node
     *             self.size += 1
     */
    public void put(T key, T value){
        if (this.list.getCapacity() == 0){
            return;
        }

        if (this.map.containsKey(key)){
            Node node = this.map.get(key);
            this.list.remove(node);
            node.setValue(value);
            System.out.println("========"+this.list.toString());
            this.list.append(node);
            System.out.println("========"+this.list.toString());
        } else {
            if (this.list.getSize() == this.list.getCapacity()){
                Node node = this.list.pop();
                this.map.remove(node.getKey());
            }
            Node node = new Node(key, value);
            this.list.append(node);
            this.map.put(key, node);
        }
    }
}
