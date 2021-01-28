extern FILE *intermediate;

void initialize() {
    intermediate = fopen("intermediate.xsm", "w");
    fprintf(intermediate, "0\n2056\n0\n0\n0\n0\n0\n0\n");
    fprintf(intermediate, "ADD SP, 26\n");
}
