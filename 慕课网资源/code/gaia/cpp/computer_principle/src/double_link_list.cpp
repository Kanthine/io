#include "double_link_list.h"

/** Node* add_head(Node*);
    Node* add_tail(Node*);
    Node* del_head();
    Node* del_tail();
    Node* _remove();
*/

Node* DoubleLinkList::add_head(Node* node){
    if(this->head == nullptr){
        node->set_prev(nullptr);
        node->set_next(nullptr);
        this->head = node;
        this->tail = node;
    } else {
        node->set_next(this->head);
        this->head->set_prev(node);
        this->head = node;
        this->head->set_prev(nullptr);
    }
    this->size += 1;
    return node;
}

Node* DoubleLinkList::add_tail(Node* node){
    if(this->tail == nullptr){
        node->set_prev(nullptr);
        node->set_next(nullptr);
        this->head = node;
        this->tail = node;
    } else {
        this->tail->set_next(node);
        node->set_prev(this->tail);
        this->tail = node;
        this->tail->set_next(nullptr);
    }
    this->size += 1;
    return node;
}

Node* DoubleLinkList::del_head(){
    if(this->head == nullptr){
        return nullptr;
    }
    Node* node = this->head;
    if(this->head->get_next() != nullptr){
        this->head->get_next()->set_prev(nullptr);
        this->head = this->head->get_next();
    } else {
        this->head = nullptr;
        this->tail = nullptr;
    }
    this->size -= 1;
    return node;
}

Node* DoubleLinkList::del_tail(){
    if (this->tail == nullptr){
        return nullptr;
    }
    Node* node = this->tail;
    if (this->tail->get_prev() != nullptr){
        this->tail = this->tail->get_prev();
        this->tail->set_next(nullptr);
    } else {
        this->tail = nullptr;
        this->head = nullptr;
    }
    this->size -= 1;
    return node;
}

Node* DoubleLinkList::_remove(Node* node){
    if (node == nullptr){
        node = this->tail;
    }
    if (node == this->head){
        return this->del_head();
    }

    if (node == this->tail){
        return this->del_tail();
    }

    node->get_prev()->set_next(node->get_next());
    node->get_next()->set_prev(node->get_prev());
    this->size -= 1;
    return node;
}

Node* DoubleLinkList::pop(){
    return this->del_head();
}

Node* DoubleLinkList::append(Node* node){
    return this->add_tail(node);
}

Node* DoubleLinkList::append_front(Node* node){
    return this->add_head(node);
}

Node* DoubleLinkList::remove(Node* node){
    return this->_remove(node);
}