struct ASTNode* TreeCreate(
    int type,
    int nodetype,
    char *name,
    union Constant *value,
    struct ASTNode *arglist,
    struct ASTNode *ptr1,
    struct ASTNode *ptr2,
    struct ASTNode *ptr3
) {
    struct ASTNode* temp;
    temp = (struct ASTNode*)malloc(sizeof(struct ASTNode));

    if(value != NULL) 
        temp->value = *value;

    temp->type = type;
    temp->nodetype = nodetype;
    temp->name = name;
    temp->ptr1 = ptr1;
    temp->ptr2 = ptr2;
    temp->ptr3 = ptr3;
    temp->arglist = arglist;
    return temp;
}

struct ASTNode* reverseList(struct ASTNode* head) {
    struct ASTNode *prev = NULL, *current;

    while(head != NULL) {
        current = head->arglist;
        head->arglist = prev;
        prev = head;
        head = current;
    }

    return prev;
}
