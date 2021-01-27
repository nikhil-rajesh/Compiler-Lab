int counter = -1;
extern FILE *intermediate;

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
int codegen(struct tnode* t) {
    if(t == NULL) {
        return -1;
    } else if(t->op == NULL) {
        int r1 = getReg();
        fprintf(intermediate, "MOV R%d, %d\n", r1, t->val);
        return r1;
    }
    int r1 = codegen(t->left);
    int r2 = codegen(t->right);
    switch(*(t->op)) {
        case '+' : fprintf(intermediate, "ADD R%d, R%d\n", r1, r2);
                   freeReg();
                   return r1;
        case '-' : fprintf(intermediate, "SUB R%d, R%d\n", r1, r2);
                   freeReg();
                   return r1;
        case '*' : fprintf(intermediate, "MUL R%d, R%d\n", r1, r2);
                   freeReg();
                   return r1;
        case '/' : fprintf(intermediate, "DIV R%d, R%d\n", r1, r2);
                   freeReg();
                   return r1;
    }
}
