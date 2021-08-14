<?php
/**
 * Created by PhpStorm
 * User: Yuuri/NaoOtosaka
 * Date: 2019/7/2
 * Time: 23:02
 */
/**
 * Class Node   节点类
 */
class Node{
//    基本属性
    public $key;
    public $value;
    public $pre = null;
    public $next = null;
//    初始化键值
    public function __construct(string $key = '', string $value = '')
    {
        $this->value = $value;
        $this->key = $key;
    }
//    打印
    public function showNode(){
        $msg =  '{'.$this->key.'}->'.'{'.$this->value.'}';
        return $msg;
    }
}
/**
 * Class DoubleLinkedList   双向链表
 */
class DoubleLinkedList{
//    基本属性
    public $capacity;
    public $head = null;
    public $tail = null;
    public $size = 0;
//    构造函数
    public function __construct($capacity = 0xffff)
    {
        $this->capacity = $capacity;
    }

    /**
     * 头节点添加
     * @param object $node 新节点
     * @return object
     */
    public function add_head(object $node){
        if (!$this->head) {
            $this->head = $node;
            $this->tail = $node;
            $this->head->next = null;
            $this->head->pre = null;
        }
        else{
//            链接节点
            $node->next = $this->head;
            $this->head->pre = $node;
//            移动指针
            $this->head = $node;
            $this->head->pre = null;
        }
        $this->size += 1;
        return $node;
    }

    /**
     * 添加尾部节点
     * @param object $node  新节点
     * @return object
     */
    public function add_tail(object $node){
        if (!$this->tail){
            $this->head = $node;
            $this->tail = $node;
            $this->tail->next = null;
            $this->tail->pre = null;
        }else{
//            链接节点
            $node->pre = $this->tail;
            $this->tail->next = $node;
//            移动指针
            $this->tail = $node;
            $this->tail->next = null;
        }
        $this->size += 1;
        return $node;
    }

    /**
     * 删除头部节点
     */
    private function remove_head(){
    //        链表是否存在头部节点
        if (!$this->head){
            echo '该链表为空';
            return null;
        }
        $node = $this->head;
        if (isset($node->next)) {
            if ($node->next){
                $this->head = $node->next;
                $this->head->pre = null;
                $this->size -= 1;
            }
        }else{
            $this->tail = $this->head = null;
            $this->size = 0;
        }
        return $node;
    }

    /**
     * 删除尾部节点
     */
    private function remove_tail(){
        //        链表是否存在尾部节点
        if (!$this->tail){
            echo '该链表为空';
            return null;
        }
        $node = $this->tail;
        if (isset($node->pre)) {
            if ($node->pre){
                $this->tail = $node->pre;
                $this->tail->next = null;
                $this->size -= 1;
            }
        }else{
            $this->tail = $this->head = null;
            $this->size = 0;
        }
        return $node;
    }
    /**
     * 删除内部节点
     * @param object $node 需要删除的节点
     * @return object
     */
    private function remove_node(object $node){
        //        更新上下节点链接
        $node->pre->next = $node->next;
        $node->next->pre = $node->pre;
        //        更新列表长度
        $this->size -= 1;
        return $node;
    }

    /**
     * 删除任意节点
     * @param object|null $node 需要删除的节点
     * @return object|null
     */
    public function remove(object $node = null){
        //        当链表只有一个节点时，直接删除头节点
        if ($this->size == 1){
            return $this->remove_head();
        }
        //        当未传入节点时，默认删除尾部节点
        if (!$node){
            $node = $this->tail;
        }
        //        当删除节点为尾部时
        if ($node == $this->tail){
            return $this->remove_tail();
        }
        //        当删除节点为头部时
        elseif ($node == $this->head){
            return $this->remove_head();
        }
        //        正常删除
        else{
            return $this->remove_node($node);
        }
    }
    /**
     * 弹出头部节点
     * @return null
     */
    public function pop(){
        return $this->remove_head();
    }
    /**
     * 添加节点(默认尾部)
     * @param object $node  新添加节点
     * @return object
     */
    public function append(object $node){
        return $this->add_tail($node);
    }

    /**
     * 打印链表
     */
    public function print(){
        $n = $this->head;
        $p = '';
        while ($n){
            $p .= 'key['.$n->key.']->value['.$n->value.']';
            $n = $n->next;
            if ($n){
                $p .= ' => ';
            }
        }
        echo $p;
    }
}

//$list = new DoubleLinkedList(10);
//$nodes = array();
//for ($i = 1;$i <= 10;$i++){
//    $node = new Node($i, $i);
//    array_push($nodes,$node);
//}
//
//$list->append($nodes[0]);
//$list->print();
//echo "<br>";
//$list->add_tail($nodes[8]);
//$list->print();
//echo "<br>";
//$list->add_head($nodes[6]);
//$list->print();
//echo "<br>";
//$list->pop();
//$list->print();
//echo "<br>";
//$list->remove();
//$list->print();