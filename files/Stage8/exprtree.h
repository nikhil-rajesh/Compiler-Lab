#define NODE_CONNECTOR 0
#define NODE_PLUS 1
#define NODE_MINUS 2
#define NODE_MUL 3
#define NODE_DIV 4
#define NODE_MOD 23
#define NODE_ID 5
#define NODE_NUM 6
#define NODE_ASSGN 7
#define NODE_READ 8
#define NODE_WRITE 9
#define NODE_IF 10
#define NODE_IF_ELSE 11
#define NODE_WHILE 12
#define NODE_LT 13
#define NODE_GT 14
#define NODE_LE 15
#define NODE_GE 16
#define NODE_EQ 17
#define NODE_NEQ 18
#define NODE_BREAK 19
#define NODE_CONT 20
#define NODE_STRVAL 21
#define NODE_ARRAY 22
#define NODE_RET 24
#define NODE_FUNC 25
#define NODE_FIELD 26
#define NODE_NULL 27
#define NODE_ALLOC 28
#define NODE_FREE 29
#define NODE_INIT 30
#define NODE_NEW 31
#define NODE_DELETE 32
#define NODE_SELF 33
#define NODE_FIELDFUNC 34
#define NODE_BRKPT 35

union Constant{
    int intval;
    char* strval;
};

struct ASTNode{
    struct Typetable *type;                         //pointer to the type table entry
    struct Classtable *Ctype;
    int nodetype;                     //node type information,eg : NODETYPE_WHILE,NODETYPE_PLUS,NODETYPE_STMT etc
    char *name;                       //stores the variable/function name in case of variable/function nodes
    union Constant value;             //stores the value of the constant if the node corresponds to a constant
    struct ASTNode *arglist;          //pointer to the expression list given as arguments to a function call
    struct ASTNode *ptr1,*ptr2,*ptr3; //Subtrees of the node. (Maximum Subtrees for IF THEN ELSE)
    struct Gsymbol *Gentry;           //pointer to GST entry for global variables and functions
    struct Lsymbol *Lentry;           //pointer to the function's LST for local variables and arguements
};

struct ASTNode* TreeCreate(
    struct Typetable *type,
    int nodetype,
    char *name,
    union Constant *value,
    struct ASTNode *arglist,
    struct ASTNode *ptr1,
    struct ASTNode *ptr2,
    struct ASTNode *ptr3
);
	
/*To evaluate an expression tree*/
int codegen(struct ASTNode *t);
void initialize();
struct ASTNode* reverseList(struct ASTNode *t);
struct ASTNode* insertFieldId(struct ASTNode *field, struct ASTNode *id);
struct ASTNode* tempASTNode;
