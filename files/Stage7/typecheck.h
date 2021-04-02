struct Gsymbol* Gtemp;
struct Lsymbol* Ltemp;
struct Paramstruct* Ptemp;

int checkAvailability(char *name, int global);
void assignType(struct ASTNode* node, int func);
void assignTypeField(struct ASTNode* node, struct Fieldlist *fields);
void typecheck(struct Typetable *t1,struct Typetable *t2, char c);
