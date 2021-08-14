#include <vector>

#include "double_link_list.h"
#include "fifo_cache.h"
#include "lru_cache.h"
#include "lfu_cache.h"

void test_double_link_list(){
    DoubleLinkList* list = new DoubleLinkList(4);
    std::vector<Node> nodes;
    for(int i = 0; i < 10; i ++){
        Node node(i, i);
        nodes.push_back(node);
    }
    list->append(&nodes[0]);
    std::cout << list->to_string() << std::endl;
    list->append(&nodes[1]);
    std::cout << list->to_string() << std::endl;
    list->append(&nodes[2]);
    std::cout << list->to_string() << std::endl;
    list->append(&nodes[3]);
    std::cout << list->to_string() << std::endl;
    list->pop();
    std::cout << list->to_string() << std::endl;
    list->remove();
    std::cout << list->to_string() << std::endl;
    list->append_front(&nodes[3]);
    std::cout << list->to_string() << std::endl;
}

void test_fifo_cache(){
    FIFOCache cache(2);
    cache.put(1, 1);
    cache.put(2, 2);
    cache.put(3, 3);
    cache.put(4, 4);
    std::cout << cache.to_string() << std::endl;
    std::cout << cache.get(1) << std::endl;
    cache.put(5, 5);
    std::cout << cache.to_string() << std::endl;
    cache.put(2, 20);
    std::cout << cache.to_string() << std::endl;
}

void test_lru_cache(){
    LRUCache cache(2);
    cache.put(1, 1);
    cache.put(2, 2);
    cache.put(3, 3);
    cache.put(4, 4);
    std::cout << cache.to_string() << std::endl;
    std::cout << cache.get(1) << std::endl;
    std::cout << cache.to_string() << std::endl;
    std::cout << cache.get(3) << std::endl;
    std::cout << cache.to_string() << std::endl;
    cache.put(5, 5);
    std::cout << cache.to_string() << std::endl;
    cache.put(2, 20);
    std::cout << cache.to_string() << std::endl;
}

void test_lfu_cache(){
    LFUCache cache(3);
    cache.put(1, 1);
    cache.put(2, 2);
    cache.put(3, 3);
    cache.put(4, 4);
    std::cout << cache.to_string() << std::endl;
    std::cout << cache.get(1) << std::endl;
    std::cout << cache.to_string() << std::endl;
    std::cout << cache.get(3) << std::endl;
    std::cout << cache.to_string() << std::endl;
    cache.put(5, 5);
    std::cout << cache.to_string() << std::endl;
    cache.put(2, 2);
    std::cout << cache.to_string() << std::endl;
    cache.put(1, 1);
    std::cout << cache.to_string() << std::endl;
    std::cout << cache.get(2) << std::endl;
    std::cout << cache.to_string() << std::endl;
    std::cout << cache.get(1) << std::endl;
    std::cout << cache.to_string() << std::endl;
}


int main(){
    // test_double_link_list();
    // test_fifo_cache();
    // test_lru_cache();
    test_lfu_cache();
}