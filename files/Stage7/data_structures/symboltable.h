struct Paramstruct {
    char *name;
    struct Typetable *type;         //type of the variable:(Integer / String)
    struct Paramstruct *next;
};

struct Gsymbol{
    char *name;     //name of the variable or function
    int size;       //size of an array
    int binding;    //static binding of global variables
    int flabel;     //a label for identifying the starting address of a function's code
    struct Typetable *type;         //type of the variable:(Integer / String)
    struct Classtable *Ctype;
    struct Paramstruct *paramlist;  //pointer to the head of the formal parameter list in the case of functions
    struct Gsymbol *next;           //points to the next Global Symbol Table entry
};

struct Lsymbol{
    char *name;             //name of the variable
    int binding;            //local binding of the variable
    struct Typetable *type; //type of the variable:(Integer / String)
    struct Lsymbol *next;   //points to the next Local Symbol Table entry
};

int totalCount = 4096;      // Memory address of next variable
int localBindingStart = 1;
int fLabelCount = 0;

struct Paramstruct *Phead, *Ptail;
struct Gsymbol *Ghead, *Gtail;
struct Lsymbol *Lhead, *Ltail;

void PInstall(char* name, struct Typetable *type);
void GInstall(char *name, struct Typetable *type, struct Classtable *Ctype, int size, struct Paramstruct *paramlist);
void LInstall(char* name, struct Typetable *type);
struct Gsymbol* GLookup(char * name);
struct Lsymbol* LLookup(char *name);

void printLSymbolTable(char* name); // FOR TESTING
void printGSymbolTable();           // FOR TESTING
