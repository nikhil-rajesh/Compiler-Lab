# Experimental Compiler
This is my implementation of an experimental compiler that I made using the documentations provided [here](https://silcnitc.github.io/index.html).
This was done as part of a Compiler Lab course I took up in my 6th Semester at NITC.

## Progress
- :heavy_check_mark: Stage 0
- :heavy_check_mark: Stage 1
- :heavy_check_mark: Stage 2
- :heavy_check_mark: Stage 3
- :o: Stage 4
- :o: Stage 5
- :o: Stage 6
- :o: Stage 7
- :o: Stage 8

## Running
The environment can be setup using the instructions provided [here](https://gist.github.com/anandubajith/c924be647fd2d164e478e9e9c7cf4961).<br/>

There is a slight modification to the run command given in the above gist.
```
docker run -v $PWD/files:/xsm_expl/files -d --name silc -i silc:ubuntu20.04
```

For each implement there is a makefile given in the directory. The code can be compiled using
```
make
```
And finally just run the corresponding executable file.
