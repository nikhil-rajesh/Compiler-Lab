struct LList {
    char* name;
    int lineNo;
    struct LList *next;
};

struct LList *labels = NULL;

void Lappend(char* Lname, int lineNo) {
    struct LList *label = (struct LList*)malloc(sizeof(struct LList));
    label->name = Lname;
    label->lineNo = lineNo;
    label->next = labels;
    labels = label;
}

int LLookup(char *Lname) {
    struct LList *head = labels;
    while(head != NULL) {
        if(strcmp(head->name, Lname) == 0)
            return head->lineNo;
        head = head->next;
    }
    return -1;
}
