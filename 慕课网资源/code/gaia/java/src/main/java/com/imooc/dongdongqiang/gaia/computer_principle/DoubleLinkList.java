package com.imooc.dongdongqiang.gaia.computer_principle;


public class DoubleLinkList {

    private long capacity;

    private Node head;

    private Node tail;

    private long size;

    public DoubleLinkList(){
        this.capacity = Long.MAX_VALUE;
        this.size = 0;
    }

    public DoubleLinkList(long capacity){
        this.capacity = capacity;
        this.size = 0;
    }

    /**
     * # 从头部添加
     *     def __add_head(self, node):
     *         if not self.head:
     *             self.head = node
     *             self.tail = node
     *             self.head.next = None
     *             self.head.prev = None
     *         else:
     *             node.next = self.head
     *             self.head.prev = node
     *             self.head = node
     *             self.head.prev = None
     *         self.size += 1
     *         return node
     */
    private Node addHead(Node node){
        if (this.head == null){
            node.setPrev(null);
            node.setNext(null);
            this.head = node;
            this.tail = node;
        } else {
            node.setNext(this.head);
            this.head.setPrev(node);
            this.head = node;
            this.head.setPrev(null);
        }
        this.size += 1;
        return node;
    }

    /**
     * # 从尾部添加
     *     def __add_tail(self, node):
     *         if not self.tail:
     *             self.tail = node
     *             self.head = node
     *             self.tail.next = None
     *             self.tail.prev = None
     *         else:
     *             self.tail.next = node
     *             node.prev = self.tail
     *             self.tail = node
     *             self.tail.next = None
     *         self.size += 1
     *         return node
     */
    private Node addTail(Node node){
        if(this.tail == null){
            node.setPrev(null);
            node.setNext(null);
            this.head = node;
            this.tail = node;
        } else {
            this.tail.setNext(node);
            node.setPrev(this.tail);
            this.tail = node;
            this.tail.setNext(null);
        }
        this.size += 1;
        return node;
    }

    /**
     * # 从头部删除
     *     def __del_head(self):
     *         if not self.head:
     *             return
     *         node = self.head
     *         if self.head.next:
     *             self.head.next.prev = None
     *             self.head = self.head.next
     *         else:
     *             self.head = self.tail = None
     *         self.size -= 1
     *         return node
     */
    private Node delHead(){
        if (this.head == null){
            return null;
        }
        Node node = this.head;
        if (this.head.getNext() != null){
            this.head.getNext().setPrev(null);
            this.head = this.head.getNext();
        } else {
            this.head = null;
            this.tail = null;
        }
        this.size -= 1;
        return node;
    }

    /**
     * # 从尾部删除
     *     def __del_tail(self):
     *         if not self.tail:
     *             return
     *         node = self.tail
     *         if node.prev:
     *             self.tail = node.prev
     *             self.tail.next = None
     *         else:
     *             self.tail = self.head = None
     *         self.size -= 1
     *         return node
     */
    private Node delTail(){
        if (this.tail == null){
            return null;
        }
        Node node = this.tail;
        if (node.getPrev() != null){
            this.tail = node.getPrev();
            this.tail.setNext(null);
        } else {
            this.tail = null;
            this.head = null;
        }
        this.size -= 1;
        return node;
    }

    /**
     * # 任意节点删除
     *     def __remove(self, node):
     *         # 如果node=None, 默认删除尾部节点
     *         if not node:
     *             node = self.tail
     *         if node == self.tail:
     *             self.__del_tail()
     *         elif node == self.head:
     *             self.__del_head()
     *         else:
     *             node.prev.next = node.next
     *             node.next.prev = node.prev
     *             self.size -= 1
     *         return node
     */
    private Node _remove(Node node) {
        if (node == null){
            node = this.tail;
        }

        if (node == this.head){
            return this.delHead();
        }

        if (node == this.tail){
            return this.delTail();
        }

        node.getPrev().setNext(node.getNext());
        node.getNext().setPrev(node.getPrev());
        this.size -= 1;
        return node;
    }

    public Node pop(){
        return this.delHead();
    }

    public Node append(Node node){
        return this.addTail(node);
    }

    public Node appendFront(Node node){
        return this.addHead(node);
    }

    public Node remove(){
        return this._remove(null);
    }

    public Node remove(Node node){
        return this._remove(node);
    }

    public String toString(){
        Node node = this.head;
        StringBuffer buffer = new StringBuffer();
        long tmp = 6;
        while(node != null && tmp > 0){
            buffer.append(node.toString());
            node = node.getNext();
            if(node != null){
                buffer.append("->");
            }
            tmp -= 1;
        }
        return buffer.toString();
    }

    public long getCapacity() {
        return capacity;
    }

    public void setCapacity(long capacity) {
        this.capacity = capacity;
    }

    public Node getHead() {
        return head;
    }

    public void setHead(Node head) {
        this.head = head;
    }

    public Node getTail() {
        return tail;
    }

    public void setTail(Node tail) {
        this.tail = tail;
    }

    public long getSize() {
        return size;
    }

    public void setSize(long size) {
        this.size = size;
    }
}
