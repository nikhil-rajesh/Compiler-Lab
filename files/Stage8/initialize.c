extern FILE *intermediate;
FILE *append;

void initialize() {
    fclose(intermediate);
    rename("machinecode.xsm", "copy_machinecode.xsm");
    intermediate = fopen("machinecode.xsm", "w");
    append = fopen("copy_machinecode.xsm", "r");

    fprintf(intermediate, "0\n2056\n0\n0\n0\n0\n0\n0\n");

    struct Classtable *CIter = Chead;
    struct Memberfunclist *MIter;
    int counter = 4095, counter2;
    while(CIter != NULL) {
        totalCount = totalCount + 8;
        counter = counter + 8;
        MIter = CIter->Vfuncptr;

        counter2 = 0;
        while(MIter != NULL) {
            fprintf(intermediate, "MOV R0,M%d\n", MIter->flabel);
            fprintf(intermediate, "PUSH R0\n");
            MIter = MIter->next; 
            counter2++;
        }

        if(counter2 != 8 && CIter->next != NULL)
            fprintf(intermediate, "MOV SP, %d\n", counter);
        CIter = CIter->next;
    }
}

void start() {
    fprintf(intermediate, "MOV SP, %d\n", totalCount-1);
    fprintf(intermediate, "PUSH R0\n");
    fprintf(intermediate, "CALL MAIN\n");
    fprintf(intermediate, "MOV R0, 10\nPUSH R0\nINT 10\n");

    char ch;
    while ((ch = fgetc(append)) != EOF)
        fputc(ch, intermediate);
    fclose(append);
    remove("copy_machinecode.xsm"); 
}
