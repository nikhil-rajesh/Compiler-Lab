FILE *stream;
int count = 0;
char* findKey(struct tnode*);

void print_dot_aux(struct tnode* node) {
    static int nullcount = 0;
    count += 1;
    int temp = count;

    if (node->left) {
        fprintf(stream, "    \"%d.%s\" -> \"%d.%s\";\n", temp, findKey(node), count + 1, findKey(node->left));
        print_dot_aux(node->left);
    }

    if (node->middle) {
        fprintf(stream, "    \"%d.%s\" -> \"%d.%s\";\n", temp, findKey(node), count + 1, findKey(node->middle));
        print_dot_aux(node->middle);
    }

    if (node->right) {
        fprintf(stream, "    \"%d.%s\" -> \"%d.%s\";\n", temp, findKey(node), count + 1, findKey(node->right));
        print_dot_aux(node->right);
    }
}

void print_dot(struct tnode* tree) {
    stream = fopen("temp.dot", "w");
    fprintf(stream, "digraph BST {\n");
    fprintf(stream, "    node [fontname=\"Arial\"];\n");

    if (!tree)
        fprintf(stream, "\n");
    else if (!tree->right && !tree->left)
        fprintf(stream, "    %s;\n", findKey(tree));
    else
        print_dot_aux(tree);
    fprintf(stream, "}\n");

    fclose(stream);
}

char* findKey(struct tnode* head) {
    char *key = malloc(10);
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
        case NODE_ID:
            strcpy(key, head->varname);
            break;
        case NODE_NUM:
            strcpy(key, head->val);
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
    }
    return key;        
}
