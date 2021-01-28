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

typedef struct tnode{
    int val; //value of the expression tree
    int type; //type of variable
    char* varname; //Name of variable for ID names
    int nodetype; //Information of non-leaf nodes. Ex NODE_PLUS
    struct tnode *left,*right; //left and right branches
}tnode;
	
/*Create a node tnode*/
struct tnode* createTree(int type, int val, int nodetype, char* name, struct tnode *l, struct tnode *r);
	
/*To evaluate an expression tree*/
//int evaluate(struct tnode *t);
int codegen(struct tnode *t);
void initialize();
