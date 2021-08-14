#include "lru_cache.h"


int LRUCache::get(int key){
    auto it = this->map.find(key);
    if (it == this->map.end()){
        return -1;
    }
    Node* node = this->map.find(key)->second;
    this->list->remove(node);
    this->list->append_front(node);
    return node->get_value();
}

Node* LRUCache::put(int key, int value){
    if(this->capacity == 0){
        return nullptr;
    }
    auto it = this->map.find(key);
    if (it != this->map.end()){
        Node* node = this->map.find(key)->second;
        this->list->remove(node);
        node->set_value(value);
        return this->list->append_front(node);
    } else {
        Node* node = new Node(key, value);
        if (this->list->get_size() >= this->list->get_capacity()){
            Node* node = this->list->remove();
            this->map.erase(node->get_key());
            delete node;
        }
        this->list->append_front(node);
        auto it = this->map.begin();
        this->map.insert(std::pair<int, Node*>(key, node));
        return node;
    }
}