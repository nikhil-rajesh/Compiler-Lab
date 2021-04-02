struct Fieldlist{
    char *name;              //name of the field
    int fieldIndex;          //the position of the field in the field list
    struct Typetable *type;  //pointer to type table entry of the field's type
    struct Classtable *Ctype;//pointer to the class containing the field
    struct Fieldlist *next;  //pointer to the next field
};

struct Typetable{
    char *name;                 //type name
    int size;                   //size of the type
    struct Fieldlist *fields;   //pointer to the head of fields list
    struct Typetable *next;     // pointer to the next type table entry
};

struct Typetable *Thead, *Ttail;
struct Typetable *declarationType;   // To pass variable type in yacc
struct Typetable *FDeclarationType;  // To pass variable type to functions in yacc
struct Fieldlist *Fhead, *Ftail;

struct Typetable *TLookup(char *name);
struct Fieldlist *FLookup(char *name, struct Fieldlist *list);
void TInstall(char *name, struct Fieldlist *fields);
void FInstall(char *name, struct Typetable *type, struct Classtable *Ctype);

void printTypeTable();      // FOR TESTING
