<?php
/**
 * Created by PhpStorm
 * User: Yuuri/NaoOtosaka
 * Date: 2019/7/3
 * Time: 14:34
 */
include 'DoubleLinkedList.php';

class LRUCache
{

    public $capacity;
    public $map = array();
    public $list;

    public function __construct(int $capacity)
    {
        $this->capacity = $capacity;
        $this->list = new DoubleLinkedList($this->capacity);
    }

    /**
     * @param string $key   查询键名
     * @return int
     */
    public function get(string $key){
        if (array_key_exists($key, $this->map)){
            $node = $this->map[$key];
            $this->list->remove($node);
            $this->list->add_head($node);
            return $node->value;
        }else{
            return -1;
        }
    }

    /**
     * @param string $key   插入键名
     * @param string $value 插入键值
     */
    public function put(string $key, string $value){
        if (array_key_exists($key, $this->map)){
            $node = $this->map[$key];
            $this->list->remove($node);
            $node->value = $value;
            $this->list->add_head($node);
        }else{
            $node = new Node($key, $value);
            if ($this->list->size >= $this->capacity){
                $old_node = $this->list->remove();
                unset($this->map[$old_node->key]);
            }
            $this->list->add_head($node);
            $this->map[$key] = $node;
        }
    }
    /**
     * 打印
     */
    public function print(){
        $this->list->print();
    }
}

//$lru = new LRUCache(3);
//$lru->put('1', 'a');
//$lru->put('2', 'b');
//$lru->print();
//echo "<br>";
//$lru->put('3', 'c');
//$lru->print();
//echo "<br>";
////var_dump($lru);
//echo $lru->get('1');
//echo "<br>";
//$lru->print();
//echo "<br>";
//$lru->put('4', 'd');
//$lru->print();
//echo "<br>";