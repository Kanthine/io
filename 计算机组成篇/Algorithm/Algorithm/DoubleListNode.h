//
//  DoubleListNode.h
//  Algorithm
//
//  Created by 苏沫离 on 2021/8/7.
//
// 双向链表

#ifndef DoubleListNode_h
#define DoubleListNode_h

#include <stdio.h>

/// 链表节点
typedef struct DoubleListNode_t {
    int data;
    struct DoubleListNode_t *prev;
    struct DoubleListNode_t *next;
} DoubleListNode;

/// 双向链表
typedef struct DoubleList_t {
    int size;
    struct DoubleListNode_t *head;
    struct DoubleListNode_t *tail;
} DoubleList;

/// 创建一个双向链表
DoubleList *allocDoubleList(void);
void freeDoubleList(DoubleList *list);

/// 头节点
int pushNodeToHead(DoubleList *list, int data);
int popNodeToHead(DoubleList *list);

/// 尾节点
int pushNodeToTail(DoubleList *list, int data);
int popNodeToTail(DoubleList *list);

int pushNodeToIndex(DoubleList *list, int index ,int data);

/// 删除任意节点
int popNodeByData(DoubleList *list, int data);
int popNodeInIndex(DoubleList *list, int index);


#endif
