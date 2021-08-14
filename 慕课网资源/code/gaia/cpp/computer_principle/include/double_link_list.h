#ifndef __DOUBLE_LINK_LIST_H__
#define __DOUBLE_LINK_LIST_H__

#include <iostream>
#include <sstream>
#include <string>

class Node {
   private:
    /* data */
    int key;
    int value;
    Node* prev;
    Node* next;

   public:
    Node(int key, int value) {
        this->key = key;
        this->value = value;
        this->next = nullptr;
        this->prev = nullptr;
    }

    ~Node(){};

    int get_key() { return this->key; };
    int get_value() { return this->value; };
    Node* get_prev() { return this->prev; };
    Node* get_next() { return this->next; };
    void set_key(int key) { this->key = key; };
    void set_value(int value) { this->value = value; };
    void set_prev(Node* prev) { this->prev = prev; };
    void set_next(Node* next) { this->next = next; };

    std::string to_string() {
        std::ostringstream ss;
        // ss << "@"<< this << "{key: " << this->key << ", value: " << this->value << "}";
        ss << "{key: " << this->key << ", value: " << this->value << "}";
        return ss.str();
    }
};

class DoubleLinkList {
   private:
    int size;
    int capacity;
    Node* head;
    Node* tail;

    Node* add_head(Node*);
    Node* add_tail(Node*);
    Node* del_head();
    Node* del_tail();
    Node* _remove(Node* node=nullptr);

   public:
    DoubleLinkList(int capacity = 0xffff) {
    this->capacity = capacity;
    this->size = 0;
    this->head = nullptr;
    this->tail = nullptr;
    };
    ~DoubleLinkList(){};

    Node* pop();
    Node* append(Node*);
    Node* append_front(Node*);
    Node* remove(Node* node=nullptr);

    int get_capacity() { return this->capacity; };
    int set_capacity(int capacity) { this->capacity = capacity; };
    int get_size() { return this->size; };

    std::string to_string() {
        std::ostringstream ss;
        Node* p = this->head;
        int num = this->size;
        while (p != nullptr && num --) {
            ss << p->to_string();
            if (p->get_next() != nullptr) {
                ss << "->";
            }
            p = p->get_next();
        }
        return ss.str();
    }
};

#endif