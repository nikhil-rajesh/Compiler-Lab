#define NODE_CONNECTOR 0
#define NODE_PLUS 1
#define NODE_MINUS 2
#define NODE_MUL 3
#define NODE_DIV 4
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

#define TYPE_VOID 0
#define TYPE_INT 1
#define TYPE_BOOL 2

struct tnode{
    int val; //value of the expression tree
    int type; //type of variable
    char* varname; //Name of variable for ID names
    int nodetype; //Information of non-leaf nodes. Ex NODE_PLUS
    struct tnode *left, *middle, *right; //left and right branches, middle for NODE_IF_ELSE
};
	
/*Create a node tnode*/
struct tnode* createTree(int type, int val, int nodetype, char* name, struct tnode *l, struct tnode *r, struct tnode *mid);
	
/*To evaluate an expression tree*/
//int evaluate(struct tnode *t);
int codegen(struct tnode *t);
void initialize();
