struct Gsymbol* GLookup(char *name) {
    struct Gsymbol *temp = Ghead;

    while (temp != NULL && (strcmp(temp->name, name) != 0)) {
        temp = temp->next;
    }

    return temp;
}

struct Lsymbol* LLookup(char *name) {
    struct Lsymbol *temp = Lhead;

    while (temp != NULL && (strcmp(temp->name, name) != 0)) {
        temp = temp->next;
    }

    return temp;
}

struct Paramstruct* PLookup(char *name) {
    struct Paramstruct *temp = Phead;

    while (temp != NULL && (strcmp(temp->name, name) != 0)) {
        temp = temp->next;
    }

    return temp;
}

struct Typetable *TLookup(char *name) {
    struct Typetable *temp = Thead;
    while(temp != NULL && strcmp(temp->name, name) != 0) {
        temp = temp->next;
    }

    return temp;
}

struct Fieldlist *FLookup(char *name, struct Fieldlist *list) {
    while(list != NULL && strcmp(list->name, name) != 0) {
        list = list->next;
    }

    return list;
}

void FInstall(char *name, struct Typetable *type) {
    struct Fieldlist *ftemp;
    ftemp = (struct Fieldlist*)malloc(sizeof(struct Fieldlist));

    ftemp->name = (char*)malloc(sizeof(name));
    strcpy(ftemp->name, name);
    ftemp->type = type;
    ftemp->next = NULL;

    if(Fhead == NULL) {
        Fhead = ftemp;
        Ftail = ftemp;
    } else {
        Ftail->next = ftemp;
        Ftail = ftemp;
    }

    return;
}

void TInstall(char *name, struct Fieldlist *fields) {
    struct Typetable *temp;
    struct Fieldlist *ftemp;
    int counter = 0;
    temp = (struct Typetable *)malloc(sizeof(struct Typetable));

    temp->name = (char*)malloc(sizeof(name));
    strcpy(temp->name, name);
    temp->next = NULL;

    if(Thead == NULL) {
        Thead = temp;
        Ttail = temp;
    } else {
        Ttail->next = temp;
        Ttail = temp;
    }

    ftemp = fields;
    while(ftemp != NULL) {
        if (ftemp->type == TLookup("dummy")) {
            ftemp->type = TLookup(name);
        }

        ftemp->fieldIndex = counter++;
        ftemp = ftemp->next;
    }

    temp->fields = fields;
    temp->size = counter;
    Fhead = NULL;
    Ftail = NULL;
    return;
}

void GInstall(char *name, struct Typetable *type, int size, struct Paramstruct *paramlist) {
    struct Gsymbol* temp;
    temp = (struct Gsymbol *)malloc(sizeof(struct Gsymbol));
    temp->name = (char*)malloc(sizeof(name));
    strcpy(temp->name, name);
    temp->type = type;
    temp->size = size;
    temp->next = NULL;

    if(paramlist != NULL)
        temp->paramlist = paramlist;

    if(size != -1) {
        temp->binding = totalCount;
        totalCount = totalCount + temp->size;
    } else {
        temp->flabel = fLabelCount;
        fLabelCount++;
    }

    if (Ghead != NULL) {
        Gtail->next = temp;
        Gtail = temp;
    } else {
        Ghead = temp;
        Gtail = temp;
    }

    return;
}

void LInstall(char *name, struct Typetable *type) {
    struct Lsymbol *temp;
    temp = (struct Lsymbol *)malloc(sizeof(struct Lsymbol));
    temp->name = (char*)malloc(sizeof(name));
    strcpy(temp->name, name);
    temp->type = type;
    temp->binding = localBindingStart;
    localBindingStart++;

    if (Lhead != NULL) {
        Ltail->next = temp;
        Ltail = temp;
    } else {
        Lhead = temp;
        Ltail = temp;
    }

    return;
}

void InstallParamsInLocal() {
    struct Paramstruct *temp = Phead;
    int count = 0;

    while(temp != NULL) {
        count++;
        temp = temp->next;
    }

    localBindingStart = -1*count - 2;
    temp = Phead;
    while(temp != NULL) {
        LInstall(temp->name, temp->type);
        temp = temp->next;
    }

    localBindingStart = 1;
    return;
}

void PInstall(char *name, struct Typetable *type) {
    struct Paramstruct *temp;
    temp = (struct Paramstruct*)malloc(sizeof(struct Paramstruct));
    temp->name = (char*)malloc(sizeof(name));
    strcpy(temp->name, name);
    temp->type = type;

    if (Phead != NULL) {
        Ptail->next = temp;
        Ptail = temp;
    } else {
        Phead = temp;
        Ptail = temp;
    }

    return;
}

void printGSymbolTable() {
    struct Gsymbol* temp = Ghead;
    printf("\nGlobal Variables:\n");
    while (temp != NULL) {
        printf("%s --- %d --- %d\n", temp->name, temp->type, temp->binding);
        temp = temp->next;
    }
}

void printLSymbolTable() {
    struct Lsymbol* temp = Lhead;
    printf("\nLocal Variables:\n");
    while (temp != NULL) {
        printf("%s --- %d --- %d\n", temp->name, temp->type, temp->binding);
        temp = temp->next;
    }
}
