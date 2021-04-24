struct Memberfunclist {
    char *name;                      //name of the member function in the class
    int funcPosition;                //position of the function in the class table
    int flabel;                      //A label for identifying the starting address of the function's code in the memory
    struct Typetable *type;          //pointer to typetable
    struct Paramstruct *paramlist;   //pointer to the head of the formal parameter list
    struct Memberfunclist *next;     //pointer to next Memberfunclist entry
};

struct Classtable {
    char *name;                         //name of the class
    int classIndex;                     //position of the class in the virtual function table
    int fieldCount;                     //count of fields
    int methodCount;                    //count of methods
    struct Fieldlist *memberfield;      //pointer to Fieldlist 
    struct Memberfunclist *Vfuncptr;    //pointer to Memberfunclist
    struct Classtable *parentptr;       //pointer to the parent's class table
    struct Classtable *next;            //pointer to next class table entry
};

struct Classtable *Chead, *Ctail, *CCurrent;
struct Classtable *declarationCType;
int classFuncLabelCount = 0;

struct Classtable* CInstall(char *name, char *parent_class_name);
struct Classtable* CLookup(char *name);
struct Memberfunclist* Class_Mlookup(struct Classtable* Ctype, char* name);
struct Fieldlist* Class_Flookup(struct Classtable* Ctype, char* name);
void Class_Finstall(struct Classtable *cptr, struct Typetable *type, struct Classtable *Ctype, char *name);
void Class_Minstall(struct Classtable *cptr, char *name, struct Typetable *type, struct Paramstruct *paramlist);
struct Memberfunclist* copyClassMethod(struct Classtable *Ctemp);
struct Fieldlist* copyClassFields(struct Classtable *Ctemp);
