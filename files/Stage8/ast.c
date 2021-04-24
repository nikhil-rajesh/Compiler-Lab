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
    temp->Gentry = NULL;
    temp->Lentry = NULL;
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
    struct ASTNode *head, *left, *right;

    if(field->ptr2 == NULL) {
        head = NULL;
        left = field;
        right = id;
    } else {
        head = field;
        while(field->ptr2->ptr2 != NULL) {
            head = head->ptr2;
        }
        left = head->ptr2;
        right = id;
    }
    
    struct Fieldlist *fieldList;
    if(left->Ctype != NULL) {
        fieldList = FLookup(right->name, left->Ctype->memberfield);
    } else {
        fieldList = FLookup(right->name, left->type->fields);
    }

    if(
            fieldList == NULL ||
            right->type == TLookup("integer") ||
            right->type == TLookup("string")) {
        yyerror("Un-declared Field Variable '%s' access\n", id->name);
        exit(1);
    }

    right->type = fieldList->type;
    right->Ctype = fieldList->Ctype;

    if(head == NULL) {
        field = TreeCreate(TLookup("void"), NODE_FIELD, NULL, NULL, NULL, left, right, NULL);
    } else  {
        head->ptr2 = TreeCreate(TLookup("void"), NODE_FIELD, NULL, NULL, NULL, left, right, NULL);
    }
    field->type = right->type;
    field->Ctype = right->Ctype;
    return field;
}
