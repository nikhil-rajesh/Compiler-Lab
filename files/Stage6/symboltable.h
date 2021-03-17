int totalCount = 4096;  // Memory address of next variable
int localBindingStart = 1;
int fLabelCount = 0;

struct Typetable{
    char *name;                 //type name
    int size;                   //size of the type
    struct Fieldlist *fields;   //pointer to the head of fields list
    struct Typetable *next;     // pointer to the next type table entry
};

struct Typetable *TLookup(char *name);
void TInstall(char *name, struct Fieldlist *fields);
struct Typetable *Thead, *Ttail;
struct Typetable *declarationType;   // To pass variable type in yacc
struct Typetable *FDeclarationType;  // To pass variable type to functions in yacc

struct Fieldlist{
    char *name;              //name of the field
    int fieldIndex;          //the position of the field in the field list
    struct Typetable *type;  //pointer to type table entry of the field's type
    struct Fieldlist *next;  //pointer to the next field
};

struct Fieldlist *FLookup(char *name, struct Fieldlist *list);
void FInstall(char *name, struct Typetable *type);
struct Fieldlist *Fhead, *Ftail;

struct Paramstruct {
    char *name;
    struct Typetable *type;       //type of the variable:(Integer / String)
    struct Paramstruct *next;
};

void PInstall(char* name, struct Typetable *type);
struct Paramstruct *Phead, *Ptail;

struct Gsymbol{
    char *name;     //name of the variable or function
    struct Typetable *type;       //type of the variable:(Integer / String)
    int size;       //size of an array
    int binding;    //static binding of global variables
    struct Paramstruct *paramlist; //pointer to the head of the formal parameter list in the case of functions
    int flabel;     //a label for identifying the starting address of a function's code
    struct Gsymbol *next;   //points to the next Global Symbol Table entry
};

struct Gsymbol* GLookup(char * name); // Returns a pointer to the symbol table entry for the variable, returns NULL otherwise.
void GInstall(char *name, struct Typetable *type, int size, struct Paramstruct *paramlist); // Creates a symbol table entry.
struct Gsymbol *Ghead, *Gtail;

struct Lsymbol{
    char *name;     //name of the variable
    struct Typetable *type;       //type of the variable:(Integer / String)
    int binding;    //local binding of the variable
    struct Lsymbol *next;   //points to the next Local Symbol Table entry
};

struct Lsymbol* LLookup(char *name);
void LInstall(char* name, struct Typetable *type);
struct Lsymbol *Lhead, *Ltail;


void printLSymbolTable(char* name);   // FOR TESTING
void printGSymbolTable();   // FOR TESTING
void printTypeTable();      // FOR TESTING
