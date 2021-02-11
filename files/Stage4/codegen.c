int counter = -1, i, j, label=0;
int whileStart = -1, whileEnd = -1;
extern FILE *intermediate;

int getlabel() {
    return ++label;
}
int getReg() {
    if(counter < 20)
        return ++counter;
    printf("Out of Registers");
    exit(1);
}
int freeReg() {
    if(counter >= 0)
        counter--;
}

int getMemoryAddress(struct tnode* t) {
    int r;
    if(t->nodetype == NODE_ID) {
        r = getReg();
        fprintf(intermediate, "MOV R%d, %d\n", r, t->Gentry->binding);
        return r;
    } else if(t->nodetype == NODE_ARRAY) {
        r = codegen(t->right);
        fprintf(intermediate, "ADD R%d, %d\n", r, t->left->Gentry->binding);
        return r;
    } else {
        return -1;
    }
}

int codegen(struct tnode* t) {
    int r1, r2, r3, l1, l2, number, status=0;
    int prevWhileStart, prevWhileEnd;

    if(t == NULL) {
        return -1;
    } else if(t->nodetype == NODE_CONNECTOR) {
        codegen(t->left);
        codegen(t->right);
        return -1;
    }

    switch(t->nodetype) {
        case NODE_NUM:
            r1 = getReg();
            fprintf(intermediate, "MOV R%d, %d\n", r1, t->val);
            return r1;
        case NODE_STRVAL:
            r1 = getReg();
            fprintf(intermediate, "MOV R%d, %s\n", r1, t->varname);
            return r1;
        case NODE_ID:
            r1 = getMemoryAddress(t);
            fprintf(intermediate, "MOV R%d, [R%d]\n", r1, r1);
            return r1;
        case NODE_ARRAY:
            r1 = getMemoryAddress(t);
            fprintf(intermediate, "MOV R%d, [R%d]\n", r1, r1);
            return r1;
        case NODE_PLUS:
            r1 = codegen(t->left);
            r2 = codegen(t->right);
            fprintf(intermediate, "ADD R%d, R%d\n", r1, r2);
            freeReg();
            return r1;
        case NODE_MINUS:
            r1 = codegen(t->left);
            r2 = codegen(t->right);
            fprintf(intermediate, "SUB R%d, R%d\n", r1, r2);
            freeReg();
            return r1;
        case NODE_MUL:
            r1 = codegen(t->left);
            r2 = codegen(t->right);
            fprintf(intermediate, "MUL R%d, R%d\n", r1, r2);
            freeReg();
            return r1;
        case NODE_DIV:
            r1 = codegen(t->left);
            r2 = codegen(t->right);
            fprintf(intermediate, "DIV R%d, R%d\n", r1, r2);
            freeReg();
            return r1;
        case NODE_MOD:
            r1 = codegen(t->left);
            r2 = codegen(t->right);
            fprintf(intermediate, "MOD R%d, R%d\n", r1, r2);
            freeReg();
            return r1;
        case NODE_LT:
            r1 = codegen(t->left);
            r2 = codegen(t->right);
            fprintf(intermediate, "LT R%d, R%d\n", r1, r2);
            freeReg();
            return r1;
        case NODE_GT:
            r1 = codegen(t->left);
            r2 = codegen(t->right);
            fprintf(intermediate, "GT R%d, R%d\n", r1, r2);
            freeReg();
            return r1;
        case NODE_LE:
            r1 = codegen(t->left);
            r2 = codegen(t->right);
            fprintf(intermediate, "LE R%d, R%d\n", r1, r2);
            freeReg();
            return r1;
        case NODE_GE:
            r1 = codegen(t->left);
            r2 = codegen(t->right);
            fprintf(intermediate, "GE R%d, R%d\n", r1, r2);
            freeReg();
            return r1;
        case NODE_EQ:
            r1 = codegen(t->left);
            r2 = codegen(t->right);
            fprintf(intermediate, "EQ R%d, R%d\n", r1, r2);
            freeReg();
            return r1;
        case NODE_NEQ:
            r1 = codegen(t->left);
            r2 = codegen(t->right);
            fprintf(intermediate, "NE R%d, R%d\n", r1, r2);
            freeReg();
            return r1;
        case NODE_ASSGN:
            r1 = getMemoryAddress(t->left);
            r2 = codegen(t->right);
            fprintf(intermediate, "MOV [R%d], R%d\n", r1, r2);
            freeReg();
            freeReg();
            return 0;
        case NODE_WRITE:
            for (i = 0; i <= counter; i++)
                fprintf(intermediate, "PUSH R%d\n", i);
            status = counter;

            fprintf(intermediate, "MOV R0,\"Write\"\n");
            fprintf(intermediate, "PUSH R0\n"); // function code "Write"
            fprintf(intermediate, "MOV R0,-2\n");
            fprintf(intermediate, "PUSH R0\n"); //Argument 1

            r1 = codegen(t->left);
            fprintf(intermediate, "PUSH R%d\n", r1); //Argument 2
            freeReg();
            fprintf(intermediate, "ADD SP,2\n");
            fprintf(intermediate, "CALL 0\n");
            fprintf(intermediate, "SUB SP,5\n");

            for (i = status; i >= 0; i--)
                fprintf(intermediate, "POP R%d\n", i);
            counter = status;
            break;
        case NODE_READ:
            for (i = 0; i <= counter; i++)
                fprintf(intermediate, "PUSH R%d\n", i);
            status = counter;

            fprintf(intermediate, "MOV R0,\"Read\"\n");
            fprintf(intermediate, "PUSH R0\n"); // function code "Write"
            fprintf(intermediate, "MOV R0,-1\n");
            fprintf(intermediate, "PUSH R0\n"); //Argument 1

            r1 = getMemoryAddress(t->left);
            fprintf(intermediate, "PUSH R%d\n", r1); //Argument 2
            freeReg();

            fprintf(intermediate, "ADD SP,2\n");
            fprintf(intermediate, "CALL 0\n");
            fprintf(intermediate, "SUB SP,5\n");

            for (i = status; i >= 0; i--)
                fprintf(intermediate, "POP R%d\n", i);
            counter = status;
            break;
        case NODE_IF:
            r1 = codegen(t->left); 
            l1 = getlabel();
            fprintf(intermediate, "JZ R%d,L%d\n", r1, l1);
            number = codegen(t->right);
            fprintf(intermediate, "L%d:\n", l1);
            freeReg();
            break;
        case NODE_IF_ELSE:
            r1 = codegen(t->left);
            l1 = getlabel();
            l2 = getlabel();
            fprintf(intermediate, "JZ R%d,L%d\n", r1, l1);
            freeReg();
            number = codegen(t->middle);
            fprintf(intermediate, "JMP L%d\n", l2);
            fprintf(intermediate, "L%d:\n", l1);
            number = codegen(t->right);
            fprintf(intermediate, "L%d:\n", l2);
            break;
        case NODE_WHILE:
            l1 = getlabel();
            l2 = getlabel();

            // Store old while start and end
            prevWhileStart = whileStart;
            prevWhileEnd = whileEnd;
            // Change to new start and end labels
            whileStart = l1;
            whileEnd = l2;

            fprintf(intermediate, "L%d:\n", l1);
            r1 = codegen(t->left);
            fprintf(intermediate, "JZ R%d,L%d\n", r1, l2);
            freeReg();
            number = codegen(t->right);
            fprintf(intermediate, "JMP L%d\n", l1);
            fprintf(intermediate, "L%d:\n", l2);

            // Restore while start and end labels
            whileStart = prevWhileStart;
            whileEnd = prevWhileEnd;
            break;
        case NODE_BREAK:
            if(whileEnd != -1)
                fprintf(intermediate, "JMP L%d\n", whileEnd);
            break;
        case NODE_CONT:
            if(whileStart != -1)
                fprintf(intermediate, "JMP L%d\n", whileStart);
            break;
    }
}
