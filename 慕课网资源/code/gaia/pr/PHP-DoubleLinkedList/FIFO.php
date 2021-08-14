<?php
/**
 * Created by PhpStorm
 * User: Yuuri/NaoOtosaka
 * Date: 2019/7/3
 * Time: 10:55
 */

include 'DoubleLinkedList.php';

class FIFOCache{

    public $capacity;
    public $size = 0;
    public $map = array();
    public $list;

    public function __construct(int $capacity)
    {
        $this->capacity = $capacity;
        $this->list = new DoubleLinkedList($this->capacity);
    }

    /**
     * 查询缓存
     * @param string $key   查询键名
     * @return int
     */
    public function get(string $key){
        if (!array_key_exists($key, $this->map)){
            return -1;
        }else{
            $node = $this->map[$key];
            return $node->value;
        }
    }

    /**
     * 添加缓存
     * @param string $key   插入键名
     * @param string $value 插入键值
     */
    public function put(string $key, string $value){
        if ($this->capacity == 0){
            return;
        }
        if (array_key_exists($key,$this->map)){
            $node = $this->map[$key];
            $this->list->remove($node);
            $node->value = $value;
            $this->list->append($node);
        }else{
            if ($this->size == $this->capacity){
                $node = $this->list->pop();
                unset($this->map[$node->key]);
                $this->size -= 1;
            }
            $node = new Node($key, $value);
            $this->list->append($node);
            $this->map[$key] = $node;
            $this->size += 1;
        }
    }

    /**
     * 打印
     */
    public function print(){
        $this->list->print();
    }
}

//$cache = new FIFOCache(2);
//$cache->print();
//echo "<br>";
//$cache->put('1','a');
//$cache->print();
//echo "<br>";
//$cache->put('2','b');
//$cache->print();
//echo "<br>";
//$cache->put('3','c');
//$cache->print();
//echo "<br>";
////var_dump($cache);
//echo $cache->get('3');
//echo "<br>";
//$cache->put('2','d');
//echo $cache->get('2');
//echo "<br>";
//$cache->print();