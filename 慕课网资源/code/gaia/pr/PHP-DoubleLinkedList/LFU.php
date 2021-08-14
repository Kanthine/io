<?php
/**
 * Created by PhpStorm
 * User: Yuuri/NaoOtosaka
 * Date: 2019/7/4
 * Time: 9:48
 */

include 'DoubleLinkedList.php';

class LFUNode extends Node {

    public $freq = 0;

    public function __construct(string $key, string $value)
    {
        parent::__construct($key, $value);
    }
}

class LFUCache{

    public $capacity;
    public $map = array();
    public $freq_map = array();
    public $size = 0;

    public function __construct(int $capacity)
    {
        $this->capacity = $capacity;
    }

    private function update_freq($node){
        $freq = $node->freq;
        $this->freq_map[$freq]->remove($node);
        if ($this->freq_map[$freq]->size == 0){
            unset($this->freq_map[$freq]);
        }
        $freq += 1;
        $node->freq = $freq;
        if (!array_key_exists($freq, $this->freq_map)){
            $this->freq_map[$freq] = new DoubleLinkedList();
        }
        $this->freq_map[$freq]->append($node);
    }

    public function get(string $key){
        if (array_key_exists($key, $this->map)){
            $node = $this->map[$key];
            $this->update_freq($node);
            return $node->value;
        }else{
            return -1;
        }
    }

    public function put(string $key, string $value){
        if ($this->capacity == 0){
            return;
        }
        if (array_key_exists($key, $this->map)){
            $node = $this->map[$key];
            $node->value = $value;
            $this->update_freq($node);
        }else{
            if ($this->size == $this->capacity){
                $min_freq = min(array_keys($this->freq_map));
                $node = $this->freq_map[$min_freq]->pop();
                unset($this->map[$node->key]);
                $this->size -= 1;
            }
            $node = new LFUNode($key, $value);
            $node->freq = 1;
            $this->map[$key] = $node;
            if (!array_key_exists($node->freq, $this->freq_map)){
                $this->freq_map[$node->freq] = new DoubleLinkedList();
            }
            $this->freq_map[$node->freq]->append($node);
            $this->size += 1;
        }
    }

    public function print(){
        echo '----------------------------------'."<br>";
        foreach ($this->freq_map as $key => $value){
            echo 'Freq:'.$key."<br>";
            $this->freq_map[$key]->print();
            echo "<br>";
        }
    }

}

$lfu = new LFUCache(3);
$lfu->put('1', 'a');
$lfu->print();
$lfu->put('2', 'b');
$lfu->print();
$lfu->get('1');
$lfu->print();
$lfu->put('3', 'c');
$lfu->print();
$lfu->get('3');
$lfu->get('2');
//var_dump($lfu->freq_map[2]);
$lfu->get('1');
$lfu->print();
$lfu->put('4','d');
$lfu->print();


$lfu->put('5', 'e');
$lfu->put('6', 'F');
$lfu->put('7', '8');
$lfu->put('8', 't');
$lfu->print();


