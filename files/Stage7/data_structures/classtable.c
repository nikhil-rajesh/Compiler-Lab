struct Classtable* CLookup(char *name) {
    struct Classtable *temp = Chead;

    while (temp != NULL && (strcmp(temp->name, name) != 0)) {
        temp = temp->next;
    }
    return temp;
}

struct Memberfunclist* Class_Mlookup(struct Classtable* Ctype, char* name) {
    struct Memberfunclist *temp = Ctype->Vfuncptr; 

    while (temp != NULL && (strcmp(temp->name, name) != 0)) {
        temp = temp->next;
    }
    return temp;
}

struct Fieldlist* Class_Flookup(struct Classtable* Ctype, char* name) {
    struct Fieldlist *temp = Ctype->memberfield;

    while (temp != NULL && (strcmp(temp->name, name) != 0)) {
        temp = temp->next;
    }
    return temp;
}

void Class_Minstall(struct Classtable *cptr, char *name, struct Typetable *type, struct Paramstruct *paramlist) {
    struct Memberfunclist *mtemp, *funcIter;
    mtemp = (struct Memberfunclist*)malloc(sizeof(struct Memberfunclist));

    mtemp->name = (char*)malloc(sizeof(name));
    strcpy(mtemp->name, name);
    mtemp->flabel = classFuncLabelCount++;
    mtemp->type = type;
    mtemp->paramlist = paramlist;
    mtemp->next = NULL;

    cptr->methodCount++;
    if(cptr->methodCount > 8) {
        yyerror("More than 8 methods not allowed\n", NULL);
        exit(1);
    }

    funcIter = cptr->Vfuncptr;
    if(funcIter == NULL) {
        mtemp->funcPosition = 0;
        cptr->Vfuncptr = mtemp;
    } else {
        while(funcIter->next != NULL) {
            funcIter = funcIter->next;
        }
        mtemp->funcPosition = funcIter->funcPosition + 1;
        funcIter->next = mtemp;
    }
    
    return;
}

void Class_Finstall(struct Classtable *cptr, struct Typetable *type, struct Classtable *Ctype, char *name) {
    struct Fieldlist *ftemp, *fieldIter;
    ftemp = (struct Fieldlist*)malloc(sizeof(struct Fieldlist));

    ftemp->name = (char*)malloc(sizeof(name));
    strcpy(ftemp->name, name);
    ftemp->next = NULL;
    ftemp->type = type;
    ftemp->Ctype = Ctype;

    cptr->fieldCount++;
    if(cptr->fieldCount == 8) {
        yyerror("More than 8 member fields\n", NULL);
        exit(1);
    }
    
    fieldIter = cptr->memberfield;
    if(fieldIter == NULL) {
        ftemp->fieldIndex = 0;
        cptr->memberfield = ftemp;
    } else {
        while(fieldIter->next != NULL) {
            fieldIter = fieldIter->next;
        }
        ftemp->fieldIndex = fieldIter->fieldIndex + 1;
        fieldIter->next = ftemp;
    }

    return;
}

struct Classtable* CInstall(char *name, char *parent_class_name) {
    struct Typetable *Ttemp = TLookup(name);
    struct Classtable *Ctemp = CLookup(name);
    if(Ttemp != NULL || Ctemp != NULL) {
        yyerror("Re-declaration of class OR UDT with same name exists: %s", name);
        exit(1);
    }

    Ctemp = (struct Classtable*)malloc(sizeof(struct Classtable));
    Ctemp->name = (char*)malloc(sizeof(name));
    strcpy(Ctemp->name, name);
    Ctemp->fieldCount = 0;
    Ctemp->methodCount = 0;
    Ctemp->memberfield = NULL;
    Ctemp->Vfuncptr = NULL;
    Ctemp->next = NULL;
    Ctemp->parentptr = NULL;

    if(parent_class_name != NULL) {
        Ctemp->parentptr = CLookup(parent_class_name);
        if(Ctemp->parentptr == NULL) {
            yyerror("Invalid parent class %s\n", parent_class_name);
            exit(1);
        }
    }

    if(Chead != NULL) {
        Ctemp->classIndex = Ctail->classIndex + 1;
        Ctail->next = Ctemp;
        Ctail = Ctemp;
    } else {
        Ctemp->classIndex = 0;
        Chead = Ctemp;
        Ctail = Ctemp;
    }

    return Ctemp;
}
