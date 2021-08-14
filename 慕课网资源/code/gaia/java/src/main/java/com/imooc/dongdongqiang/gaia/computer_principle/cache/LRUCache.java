package com.imooc.dongdongqiang.gaia.computer_principle.cache;

import com.imooc.dongdongqiang.gaia.computer_principle.DoubleLinkList;
import com.imooc.dongdongqiang.gaia.computer_principle.Node;

import java.util.Map;

public class LRUCache<T> extends BaseCache<T> {

    public LRUCache(long capacity){
        super(capacity);
    }

    /**
     * def get(self, key):
     *         """
     *         :type key: int
     *         :rtype: int
     *         """
     *         if key in self.map.keys():
     *             node = self.map[key]
     *             self.list.remove(node)
     *             self.list.append_front(node)
     *             return node.value
     *         else:
     *             return -1
     */
    public T get(T key){
        if(this.map.containsKey(key)){
            Node node = this.map.get(key);
            this.list.remove(node);
            this.list.appendFront(node);
            return (T)node.getValue();
        } else {
            return null;
        }
    }

    /**
     * def put(self, key, value):
     *         """
     *         :type key: int
     *         :type value: int
     *         :rtype: None
     *         """
     *         if key in self.map.keys():
     *             old_node = self.map[key]
     *             self.list.remove(old_node)
     *             new_node = old_node
     *             new_node.value = value
     *             self.list.append_front(new_node)
     *         else:
     *             new_node = Node(key, value)
     *             if self.list.size >= self.list.capacity:
     *                 node = self.list.remove()
     *                 self.map.pop(node.key)
     *
     *             node = self.list.append_front(new_node)
     *             self.map[key] = node
     */
    public void put(T key, T value){
        if (this.map.containsKey(key)){
            Node oldNode = this.map.get(key);
            this.list.remove(oldNode);
            Node newNode = oldNode;
            newNode.setValue(value);
            this.list.appendFront(newNode);
        } else {
            Node newNode = new Node(key, value);
            if (this.list.getSize() >= this.list.getCapacity()){
                Node node = this.list.remove();
                this.map.remove(node.getKey());
            }
            Node node = this.list.appendFront(newNode);
            this.map.put(key, node);
        }
    }
}
