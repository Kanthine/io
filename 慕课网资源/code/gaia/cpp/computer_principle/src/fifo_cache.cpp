#include "fifo_cache.h"


int FIFOCache::get(int key){
    auto it = this->map.find(key);
    if (it == this->map.end()){
        return -1;
    }
    return this->map.find(key)->second->get_value();
}

Node* FIFOCache::put(int key, int value){
    if(this->capacity == 0){
        return nullptr;
    }
    auto it = this->map.find(key);
    if (it != this->map.end()){
        Node* node = this->map.find(key)->second;
        this->list->remove(node);
        node->set_value(value);
        return this->list->append(node);
    } else {
        if (this->list->get_size() == this->list->get_capacity()){
            Node* node = this->list->pop();
            this->map.erase(node->get_key());
            delete node;
        }
        Node* node = new Node(key, value);
        this->list->append(node);
        auto it = this->map.begin();
        this->map.insert(std::pair<int, Node*>(key, node));
        return node;
    }
}