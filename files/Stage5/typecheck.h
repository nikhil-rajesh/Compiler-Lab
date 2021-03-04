struct Gsymbol* Gtemp;
struct Lsymbol* Ltemp;
struct Paramstruct* Ptemp;

int checkAvailability(char *name, int global);
void assignType(struct ASTNode* node, int func);
void typecheck(int t1, int t2, char c);
