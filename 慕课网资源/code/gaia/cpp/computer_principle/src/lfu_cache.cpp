#include "lfu_cache.h"

#include <cstdlib>

void LFUCache::update_freq(LFUNode* node){
    int freq = node->freq;
    this->freq_map.find(freq)->second->remove((Node*)node);
    if(this->freq_map.find(freq)->second->get_size() == 0){
        DoubleLinkList* list = this->freq_map.find(freq)->second;
        this->freq_map.erase(freq);
        delete list;
    }
    freq += 1;
    node->freq = freq;
    auto it = this->freq_map.find(freq);
    if (it == this->freq_map.end()){
        auto it = this->freq_map.begin();
        this->freq_map.insert(std::pair<int, DoubleLinkList*>(freq, new DoubleLinkList()));
    }
    this->freq_map.find(freq)->second->append((Node*)node);
}

int LFUCache::get(int key){
    auto it = this->map.find(key);
    if (it == this->map.end()){
        return -1;
    }
    LFUNode* node = this->map.find(key)->second;
    this->update_freq(node);
    return node->get_value();
}

Node* LFUCache::put(int key, int value){
    if(this->capacity == 0){
        return nullptr;
    }
    auto it = this->map.find(key);
    if (it != this->map.end()){
        LFUNode* node = this->map.find(key)->second;
        node->set_value(value);
        this->update_freq(node);
    } else {
        if (this->size == this->capacity) {
            int min_freq = 0xffff;
            for(auto iter: this->freq_map){
                min_freq = std::min(min_freq, iter.first);
            }
            Node *node = this->freq_map.find(min_freq)->second->pop();
            this->map.erase(node->get_key());
            delete node;
            this->size -= 1;
        }
        LFUNode *node = new LFUNode(key, value);
        node->freq = 1;
        auto it = this->map.begin();
        this->map.insert(it, std::pair<int, LFUNode*>(key, node));
        auto p = this->freq_map.find(node->freq);
        if (p == this->freq_map.end()){
            auto it = this->freq_map.begin();
            this->freq_map.insert(it, std::pair<int, DoubleLinkList*>(node->freq, new DoubleLinkList()));
        }
        this->freq_map.find(node->freq)->second->append(node);
        this->size += 1;
    }
}

std::string LFUCache::to_string(){
    std::ostringstream ss;
    ss << "*********************\r\n";
    for(auto item: this->freq_map){
        ss << item.first << ": " << item.second->to_string() << "\r\n";
    }
    return ss.str();
}