#ifndef __LRU_CACHE_H__
#define __LRU_CACHE_H__

#include "double_link_list.h"

#include <map>

class LRUCache {
private:
    int capacity;
    std::map<int, Node*> map;
    DoubleLinkList* list;

public:
    LRUCache(int capacity=0xffff): capacity(0) {
        this->capacity = capacity;
        list = new DoubleLinkList(this->capacity);
    };

    int get(int key);
    Node* put(int key, int value);

    std::string to_string(){
        return this->list->to_string();
    }

    ~LRUCache(){
        delete this->list;
    };
};

#endif