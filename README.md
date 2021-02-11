# Experimental Compiler
This is my implementation of an experimental compiler that I made using the documentations provided [here](https://silcnitc.github.io/index.html).
This was done as part of a Compiler Lab course I took up in my 6th Semester at NITC.

## Progress
- :heavy_check_mark: Installation
- :heavy_check_mark: CodeGeneration for Arithmetic Expressions
- :heavy_check_mark: Introduction to static storage allocation
- :heavy_check_mark: Adding Flow Control Statements
- :heavy_check_mark: User Defined Variables and arrays
- :o: Adding Functions
- :o: User defined types and Dynamic Memory Allocation
- :o: Adding Objects – Data encapsulation
- :o: Inheritance and Sub-type Polymorphism

## Running
The environment can be setup using the instructions provided [here](https://gist.github.com/anandubajith/c924be647fd2d164e478e9e9c7cf4961).<br/>

There is a slight modification to the run command given in the above gist.
```
docker run -v $PWD/files:/xsm_expl/files -d --name silc -i silc:ubuntu2- :heavy_check_mark:04
```

For each implement there is a makefile given in the directory. The code can be compiled using
```
make
```
And finally just run the corresponding executable file.
