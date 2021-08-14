//
//  DoubleListNode.c
//  Algorithm
//
//  Created by 苏沫离 on 2021/8/7.
//

#include "DoubleListNode.h"
#include <stdlib.h>

#pragma mark - 节点操作

void logMyListNode(DoubleListNode * head) {
    while (head != NULL) {
        printf("%d , ",head ->data);
        head = head -> next;
    }
    printf("\n");
}

DoubleListNode* myLinkedListCreate(int data) {
    DoubleListNode *list = malloc(sizeof(DoubleListNode));
    list -> data = data;
    list -> prev = NULL;
    list -> next = NULL;
    return list;
}

#pragma mark - 链表操作

/// 创建一个双向链表
DoubleList *allocDoubleList(void) {
    DoubleList *list = malloc(sizeof(DoubleList));
    list -> head = NULL;
    list -> tail = NULL;
    list -> size = 0;
    return list;
}

void freeDoubleList(DoubleList *list) {
    DoubleListNode *temp = list -> head;
    while (temp != NULL) {
        DoubleListNode *next = temp -> next;
        free(temp);
        temp = next;
    }
    free(list);
    list = NULL;
}

/// 头节点
int pushNodeToHead(DoubleList *list, int data) {
    if (list == NULL) return -1;
    
    DoubleListNode *node = myLinkedListCreate(data);
    if (list -> head == NULL) {
        list -> tail = node;
    } else {
        node -> next = list -> head;
        list -> head -> prev = node;
    }
    list -> head = node;
    (list -> size)++;
    return 0;
}

/// 尾节点
int pushNodeToTail(DoubleList *list, int data) {
    if (list == NULL) return -1;
    
    DoubleListNode *node = myLinkedListCreate(data);
    if (list -> tail == NULL) {
        list -> head = node;
    } else {
        node -> prev = list -> tail;
        list -> tail -> next = node;
    }
    list -> tail = node;
    (list -> size)++;
    return 0;
}

int pushNodeToIndex(DoubleList *list, int index ,int data) {
    if (list == NULL) return -1;
    if (index == list -> size - 1) {
        return pushNodeToTail(list, data);
    }else if (index == 0) {
        return pushNodeToHead(list, data);
    } else {
        
    }
    return 0;
}

int popNodeToHead(DoubleList *list) {
    return popNodeInIndex(list, 0);
}

int popNodeToTail(DoubleList *list) {
    if (list == NULL) return -1;
    return popNodeInIndex(list, list -> size - 1);
}

/// 删除任意节点
int popNodeByData(DoubleList *list, int data) {
    if (list == NULL) return -1;
    int index = 0;
    DoubleListNode *temp = list -> head;
    while (temp != NULL && temp -> data != data) {
        temp = temp -> next;
        index ++;
    }
    return popNodeInIndex(list, index);
}

/// 删除指定位置的节点
int popNodeInIndex(DoubleList *list, int index) {
    if (list == NULL || list -> size <= index) return -1;
    
    if (index == list -> size - 1) {
        if (list -> size == 1) { /// 仅有一个节点
            free(list -> tail);
            list -> head = NULL;
            list -> tail = NULL;
        } else { /// 删除尾节点
            DoubleListNode *prevNode = list -> tail -> prev;
            prevNode -> next = NULL;
            free(list -> tail);
            list -> tail = prevNode;
        }
    } else if (index == 0) { /// 删除头节点
        DoubleListNode *nextNode = list -> head -> next;
        nextNode -> prev = NULL;
        free(list -> head);
        list -> head = nextNode;
    } else {
        DoubleListNode *temp = list -> head;
        for (int i = 0; i < list -> size; i++) {
            if (i == index) break;
            temp = temp -> next;
        }
        DoubleListNode *prevNode = temp -> prev;
        DoubleListNode *nextNode = temp -> next;
        free(temp);
        prevNode -> next = nextNode;
        nextNode -> prev = prevNode;
    }
    return 0;
}
