struct ASTNode* TreeCreate(
    struct Typetable *type,
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

struct ASTNode* insertFieldId(struct ASTNode *field, struct ASTNode *id) {
    struct ASTNode *last, *iterator = field;
    struct Fieldlist *fieldList;
    while(iterator->ptr2->ptr2 != NULL) {
        iterator = iterator->ptr2;
    }
    last = iterator->ptr2;
    fieldList = FLookup(id->name, last->type->fields);

    if(
            fieldList == NULL ||
            last->type == TLookup("integer") ||
            last->type == TLookup("string")) {
        yyerror("Un-declared Field Variable '%s' access\n", id->name);
        exit(1);
    }

    id->type = fieldList->type;
    iterator->ptr2 = TreeCreate(TLookup("void"), NODE_FIELD, NULL, NULL, NULL, last, id, NULL);
    field->type = id->type;
    return field;
}
