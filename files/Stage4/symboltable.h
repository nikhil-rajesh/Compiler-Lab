int declaration_type; // To pass variable type in yacc
int totalCount = 4096; // Memory address of next variable

struct Gsymbol {
    char* name;     // name of the variable
    int type;       // type of the variable
    int size;       // size of the type of the variable
    int binding;    // stores the static memory address allocated to the variable
    struct Gsymbol *next;
};

struct Gsymbol* GLookup(char * name); // Returns a pointer to the symbol table entry for the variable, returns NULL otherwise.
void GInstall(char *name, int type, int size); // Creates a symbol table entry.
void printSymbolTable(); // FOR TESTING
struct Gsymbol *Ghead, *Gtail;
