int declaration_type;   // To pass variable type in yacc
int FDeclaration_type;  // To pass variable type to functions in yacc
int totalCount = 4096;  // Memory address of next variable
int fLabelCount = 0;

struct Paramstruct {
    char *name;
    int type;
    struct Paramstruct *next;
};

struct Gsymbol{
    char *name;     //name of the variable or function
    int type;       //type of the variable:(Integer / String)
    int size;       //size of an array
    int binding;    //static binding of global variables
    struct Paramstruct *paramlist; //pointer to the head of the formal parameter list in the case of functions
    int flabel;     //a label for identifying the starting address of a function's code
    struct Gsymbol *next;   //points to the next Global Symbol Table entry
};

struct Lsymbol{
    char *name;     //name of the variable
    int type;       //type of the variable:(Integer / String)
    int binding;    //local binding of the variable
    struct Lsymbol *next;   //points to the next Local Symbol Table entry
};

struct Gsymbol* GLookup(char * name); // Returns a pointer to the symbol table entry for the variable, returns NULL otherwise.
void GInstall(char *name, int type, int size, struct Paramstruct *paramlist); // Creates a symbol table entry.
struct Gsymbol *Ghead, *Gtail;

struct Lsymbol* LLookup(char *name);
void LInstall(char* name, int type);
struct Lsymbol *Lhead, *Ltail;

void PInstall(char* name, int type);
struct Paramstruct *Phead, *Ptail;

void printLSymbolTable(); // FOR TESTING
void printGSymbolTable(); // FOR TESTING
