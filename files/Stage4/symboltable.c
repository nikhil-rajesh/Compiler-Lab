struct Gsymbol* GLookup(char * name) {
    struct Gsymbol *temp = Ghead;

    while (temp != NULL && (strcmp(temp->name, name) != 0)) {
        temp = temp->next;
    }

    return temp;
}

void GInstall(char *name, int type, int size) {
    struct Gsymbol* temp;

    temp = GLookup(name);
    if (temp != NULL) {
        yyerror("Variable re-initialized");
        printf("\"%s\"\n", name);
        exit(1);
    } else if(size < 1) {
        yyerror("Invalid array size");
        exit(1);
    }

    temp = (struct Gsymbol *)malloc(sizeof(struct Gsymbol));
    temp->name = (char*)malloc(sizeof(name));
    strcpy(temp->name, name);
    temp->type = type;
    temp->size = size;
    temp->binding = totalCount;
    totalCount = totalCount + temp->size;
    temp->next = NULL;

    if (Ghead != NULL) {
        Gtail->next = temp;
        Gtail = temp;
    } else {
        Ghead = temp;
        Gtail = temp;
    }

    return;
}

void printSymbolTable() {
    struct Gsymbol* temp = Ghead;
    while (temp != NULL) {
        printf("%s---%d---%d\n", temp->name, temp->type, temp->binding);
        temp = temp->next;
    }
}
