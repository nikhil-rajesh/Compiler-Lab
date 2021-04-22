FILE *stream;
int count = 0;
char* findKey(struct ASTNode*);

void print_dot_aux(struct ASTNode* node) {
    static int nullcount = 0;
    count += 1;
    int temp = count;

    if (node->ptr1) {
        fprintf(stream, "    \"%d.%s\" -> \"%d.%s\";\n", temp, findKey(node), count + 1, findKey(node->ptr1));
        print_dot_aux(node->ptr1);
    }

    if (node->ptr2) {
        fprintf(stream, "    \"%d.%s\" -> \"%d.%s\";\n", temp, findKey(node), count + 1, findKey(node->ptr2));
        print_dot_aux(node->ptr2);
    }

    if (node->ptr3) {
        fprintf(stream, "    \"%d.%s\" -> \"%d.%s\";\n", temp, findKey(node), count + 1, findKey(node->ptr3));
        print_dot_aux(node->ptr3);
    }

    if (node->arglist) {
        fprintf(stream, "    \"%d.%s\":e -> \"%d.%s\":w;\n", temp, findKey(node), count + 1, findKey(node->arglist));
        print_dot_aux(node->arglist);
    }
}

void print_dot(struct ASTNode* tree, char* name) {
    count = 0;
    char filename[200];
    sprintf(filename, "./TreeVisualizations/%s.gv", name);
    stream = fopen(filename, "w");
    fprintf(stream, "digraph BST {\n");
    fprintf(stream, "    node [fontname=\"Arial\"];\n");

    if (!tree)
        fprintf(stream, "\n");
    else if (!tree->ptr2 && !tree->ptr1)
        fprintf(stream, "    %s;\n", findKey(tree));
    else
        print_dot_aux(tree);
    fprintf(stream, "}\n");

    fclose(stream);
}

char* findKey(struct ASTNode* head) {
    char *key = malloc(20);
    switch(head->nodetype) {
        case NODE_CONNECTOR:
            strcpy(key, "_");
            break;
        case NODE_PLUS:
            strcpy(key, "+");
            break;
        case NODE_MINUS:
            strcpy(key, "-");
            break;
        case NODE_MUL:
            strcpy(key, "*");
            break;
        case NODE_DIV:
            strcpy(key, "/");
            break;
        case NODE_MOD:
            strcpy(key, "%");
            break;
        case NODE_ID:
            strcpy(key, head->name);
            break;
        case NODE_FUNC:
            sprintf(key, "%s()", head->name);
            break;
        case NODE_NUM:
            sprintf(key, "%d", head->value.intval);
            break;
        case NODE_ASSGN:
            strcpy(key, "=");
            break;
        case NODE_READ:
            strcpy(key, "read");
            break;
        case NODE_WRITE:
            strcpy(key, "write");
            break;
        case NODE_IF:
            strcpy(key, "if");
            break;
        case NODE_IF_ELSE:
            strcpy(key, "if else");
            break;
        case NODE_WHILE:
            strcpy(key, "while");
            break;
        case NODE_LT:
            strcpy(key, "<");
            break;
        case NODE_GT:
            strcpy(key, ">");
            break;
        case NODE_LE:
            strcpy(key, "<=");
            break;
        case NODE_GE:
            strcpy(key, ">=");
            break;
        case NODE_EQ:
            strcpy(key, "==");
            break;
        case NODE_NEQ:
            strcpy(key, "!=");
            break;
        case NODE_BREAK:
            strcpy(key, "break");
            break;
        case NODE_CONT:
            strcpy(key, "continue");
            break;
        case NODE_STRVAL:
            strcpy(key, head->value.strval+1);
            key[strlen(key)-1] = '\0';
            break;
        case NODE_ARRAY:
            strcpy(key, "array");
            break;
        case NODE_RET:
            strcpy(key, "return");
            break;
        case NODE_FIELD:
            strcpy(key, "field");
            break;
        case NODE_FIELDFUNC:
            strcpy(key, "fieldfunction");
            break;
        case NODE_SELF:
            strcpy(key, "self");
            break;
        case NODE_NEW:
            strcpy(key, "new");
            break;
        case NODE_DELETE:
            strcpy(key, "delete");
            break;
        case NODE_NULL:
            strcpy(key, "NULL");
            break;
        case NODE_ALLOC:
            strcpy(key, "alloc()");
            break;
        case NODE_FREE:
            strcpy(key, "free()");
            break;
        case NODE_INIT:
            strcpy(key, "initialize()");
            break;
        default: 
            printf("Graphviz: No Node %d found", head->nodetype);
            exit(1);
    }
    return key;        
}
