#include <stdio.h> 
#include <dlfcn.h> 

int main(){
    char op[6], lib[32]; 

    // op holds the 5-char operation name + 1 byte for the null terminator
    // lib buffer to hold the constructed file path

    int a, b;
    
    while(scanf("%s %d %d", op, &a, &b) == 3){ // for eof handling , in previous code we will had to do ctrl c
        //  i am converting the  char op to "./lib<op>.so" string to feed to my handler h
        sprintf(lib, "./lib%s.so", op); 
         
        void *h = dlopen(lib, RTLD_LAZY); 
        // we find the specific math function inside the loaded library

        int (*f)(int, int) = dlsym(h, op);
         
        printf("%d\n", f(a, b)); 
        // after performing the opration it will remove the loaded library to free up the memory so that the total mem cannot exceed 2 gb 
        dlclose(h); 
    }
}