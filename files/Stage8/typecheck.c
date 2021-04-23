int checkAvailability(char *name, int code) {
    // Code 0 - Global Variable
    // Code 1 - Local Variable
    // Code 2 - Class Member Field
    
    if(code == 1) {
        Gtemp = GLookup(name);
        if(Gtemp != NULL) {
            yyerror("Re-initialization of variable/function '%s'\n", name);
            exit(1);
        }
    } else if(code == 2) {
        Mtemp = Class_Mlookup(CCurrent, name);
        Ftemp = Class_Flookup(CCurrent, name);

        if(Mtemp != NULL || Ftemp != NULL) {
            yyerror("Re-initialization of member field/function '%s' in class\n", name);
            exit(1);
        }
    } else {
        Ltemp = LLookup(name);
        Ptemp = PLookup(name);
        if(Ptemp != NULL || Ltemp != NULL) {
            yyerror("Re-initialization of variable '%s'\n", name);
            exit(1);
        }
    }

    return 1;
}

//void assignTypeField(struct ASTNode* node, struct Fieldlist *fields) {
//    struct Fieldlist *temp = FLookup(node->name, fields);
//    if(temp == NULL) {
//        yyerror("No member field named '%s'", node->name);
//        exit(1);
//    }
//    node->type = temp->type;
//}

void assignType(struct ASTNode* node, int code) {
    // Code 0 - Local or Global Variable
    // Code 1 - Function
    // Code 2 - Array
    // Code 3 - Class Function
    
    if(code == 3) {
        struct Memberfunclist *tempClassFunc;
        tempClassFunc = Class_Mlookup(node->ptr1->Ctype, node->ptr2->name);

        if(tempClassFunc == NULL) {
            yyerror("Function '%s' not declared inside class!", node->ptr2->name);
            exit(1);
        }

        node->type = tempClassFunc->type;
        return;
    }

    Ltemp = LLookup(node->name);
    if(Ltemp != NULL && code == 0) {
        node->Lentry = Ltemp;
        node->type = Ltemp->type;
        node->Ctype = NULL;
    } else {
        Gtemp = GLookup(node->name);
        if(Gtemp != NULL) {
            node->Gentry = Gtemp;
            node->type = Gtemp->type;
            node->Ctype = Gtemp->Ctype;

            if(code == 1 && Gtemp->size != -1) {
                yyerror("conflict in ID NodeType : Expected Function \n", NULL);
                printf("%s\n", node->name);
                exit(1);
            }
        } else {
            if(code == 1)
                yyerror("Function '%s' not declared!", node->name);
            else
                yyerror("Variable '%s' not declared!", node->name);
            exit(1);
        }
    }

    return;
}

void typecheck(struct Typetable *t1, struct Typetable *t2, char c) {
    switch(c) {
        case 'w': if(t1 != t2) {
                      yyerror("Expected Boolean in WHILE check\n", NULL);
                      exit(1);
                  }
                  break;
        case 'e': if(t1 != t2) {
                      yyerror("Expected Boolean in IF ELSE check\n", NULL);
                      exit(1);
                  }
                  break;
        case 'i': if(t1 != t2) {
                      yyerror("Expected Boolean in IF check\n", NULL);
                      exit(1);
                  }
                  break;
        case 'a': if(t1 != TLookup("integer") || t2 != TLookup("integer")) {
                      yyerror("Invalid type for arithmetic operation\n", NULL);
                      exit(1);
                  }
                  break;
        case 'b': if(t1 != TLookup("integer") || t2 != TLookup("integer")) {
                      yyerror("Invalid type for comparing (<, >, <=..) operation\n", NULL);
                      exit(1);
                  }
                  break;
        case '=': if(t1 != t2) {
                      yyerror("Invalid type for assignment operation\n", NULL);
                      exit(1);
                  }
                  break;
        case '!': if (t1 == TLookup("string") || t1 == TLookup("integer")) {
                      yyerror("Interger or String cannot be compared with NULL\n", NULL);
                      exit(1);
                  }
                  break;
    }
}
