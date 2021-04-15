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

void FInstall(char *name, struct Typetable *type, struct Classtable *Ctype) {
    struct Fieldlist *ftemp;
    ftemp = (struct Fieldlist*)malloc(sizeof(struct Fieldlist));

    ftemp->name = (char*)malloc(sizeof(name));
    strcpy(ftemp->name, name);
    ftemp->type = type;
    ftemp->Ctype = Ctype;
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
    temp = TLookup(name);
    if(temp != NULL) {
        yyerror("Redeclaration of type: %s", name);
        exit(1);
    }

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

        ftemp->fieldIndex = ++counter;
        ftemp = ftemp->next;
    }

    temp->fields = fields;
    temp->size = counter;

    if(counter >= 8) {
        yyerror("Too many member fields", NULL);
        exit(1);
    }

    Fhead = NULL;
    Ftail = NULL;
    return;
}

void printTypeTable() {
    printf("-----TYPE TABLE-----\n");
    struct Typetable *temp = Thead;
    struct Fieldlist *ftemp;
    while(temp != NULL) {
        printf("%s\t%d\n", temp->name, temp->size);
        ftemp = temp->fields;
        while(ftemp != NULL) {
            printf("\t%d\t%s\t%s\n", ftemp->fieldIndex, ftemp->name, ftemp->type->name);
            ftemp = ftemp->next;
        }
        temp = temp->next;
    }
    printf("\n");
}
