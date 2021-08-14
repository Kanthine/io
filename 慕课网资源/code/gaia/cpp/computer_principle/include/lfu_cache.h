#include "double_link_list.h"

#include <map>

class LFUNode: public Node{
public:
    int freq;
    LFUNode(int key, int value): Node(key, value) {
        this->freq = 0;
    };
    ~LFUNode(){}
};

class LFUCache {
private:
    int capacity;
    int size;
    std::map<int, LFUNode*> map;
    std::map<int, DoubleLinkList*> freq_map;

    void update_freq(LFUNode* node);

public:
    LFUCache(int capacity=0xffff): capacity(0) {
        this->capacity = capacity;
        this->size = 0;
    };

    int get(int key);
    Node* put(int key, int value);
    std::string to_string();

    ~LFUCache(){
        
    };
};